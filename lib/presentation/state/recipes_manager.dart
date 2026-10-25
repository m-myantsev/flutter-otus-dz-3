import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../domain/entities/comment.dart';
import '../../domain/entities/detected_object.dart';
import '../../domain/entities/food_data.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/measure_unit.dart';
import '../../domain/entities/offline_measure_units.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_image.dart';
import '../../domain/entities/recipe_ingredient.dart';
import '../../domain/entities/recipe_step.dart';
import '../../domain/exceptions/recipe_images_save_exception.dart';
import '../../domain/repositories/food_api.dart';
import '../../domain/repositories/object_detector.dart';
import '../../domain/repositories/recipes_store.dart';
import '../vision/annotate_detections.dart';

/// Точка доступа к рецептам, каталогу ингредиентов и единицам измерения, уведомляющая слушателей об изменении данных
///
/// Сервер является источником данных, а локальное хранилище является источником истины для интерфейса.
/// Загрузка обновляет хранилище, интерфейс показывает сохранённое, и без сети приложение работает на локальных данных
class RecipesManager extends ChangeNotifier {
  RecipesManager({required this._api, required this._store, this._detector});

  final FoodApi _api;
  final RecipesStore _store;

  /// Детектор объектов на фото, без него фото сохраняются без разметки
  final ObjectDetector? _detector;

  List<Recipe> _recipes = [];
  List<Ingredient> _ingredients = [];
  List<MeasureUnit> _measureUnits = [];

  /// Кэш комментариев по идентификатору рецепта
  final Map<int, List<Comment>> _comments = {};

  /// Кэш фото по идентификатору рецепта
  final Map<int, List<RecipeImage>> _images = {};

  /// Завершается, когда закончилась последняя поставленная в очередь мутация списка фото
  Future<void> _lastImagesMutation = Future<void>.value();

  /// Идентификаторы избранных рецептов
  Set<int> _favoriteIds = {};

  bool _isLoading = true;

  /// Идёт первая загрузка данных
  bool get isLoading => _isLoading;

  /// **Все** доступные рецепты
  List<Recipe> get recipes => List.unmodifiable(_recipes);

  /// Каталог ингредиентов
  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  /// Справочник единиц измерения
  ///
  /// Пока серверный справочник не загружен, возвращает встроенный набор [OfflineMeasureUnits.all]
  List<MeasureUnit> get measureUnits {
    // Встроенный набор в базу не пишется, поэтому после синхронизации в списке только серверные единицы без дублей
    if (_measureUnits.isEmpty) {
      return OfflineMeasureUnits.all;
    }

    return List.unmodifiable(_measureUnits);
  }

  /// Показывает сохранённые данные и обновляет их с сервера
  ///
  /// Ответ сервера сохраняется в локальную базу, если не выглядит потерей данных
  Future<void> init() async {
    // Локальное хранилище читается синхронно, поэтому первый кадр рисуется без ожидания сети
    _favoriteIds = _store.loadFavoriteIds();
    _reload();
    notifyListeners();

    try {
      // Ответ сервера сначала попадает в хранилище и только оттуда в интерфейс
      final data = await _tryRemote(_api.fetchFoodData);
      if (data != null && _isSafeToReplace(data)) {
        await _store.saveAll(data);
        _reload();
      }
    } finally {
      // Ожидание закончено при любом исходе, включая отказ записи на диск, иначе остался бы вечный индикатор
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Добавляет в каталог новый ингредиент и возвращает его
  ///
  /// Без сети ингредиент получает локальный отрицательный идентификатор.
  /// Так же и со встроенной единицей из [OfflineMeasureUnits], потому что сервер её не знает
  Future<Ingredient> addIngredient(String name, MeasureUnit measureUnit) async {
    // Серверу неизвестна встроенная единица, как и локальный ингредиент для рецепта в `saveRecipe`
    final isKnownToServer = measureUnit.id >= 0;
    final remote = isKnownToServer ? await _tryRemote(() => _api.createIngredient(name, measureUnit)) : null;
    final ingredient =
        remote ?? Ingredient(id: _nextLocalId(_ingredients.map((i) => i.id)), name: name, measureUnit: measureUnit);

    _ingredients.add(ingredient);
    await _store.putIngredient(ingredient);
    notifyListeners();

    return ingredient;
  }

  /// Сохраняет новый рецепт вместе с его [images] и возвращает рецепт
  ///
  /// Время приготовления является суммой длительностей шагов, округлённой вверх до минут.
  /// Рецепт в любом случае сохраняется локально.
  /// Без сети рецепт получает локальный отрицательный идентификатор, чтобы синхронизация его не перезаписала.
  /// Фото записываются уже после рецепта, и при отказе этой записи бросается [RecipeImagesSaveException]
  Future<Recipe> saveRecipe({
    required String name,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> steps,
    List<RecipeImage> images = const [],
  }) async {
    final totalSeconds = steps.fold(0, (sum, step) => sum + step.duration);
    final duration = (totalSeconds / 60).ceil();

    // Ингредиент, созданный без сети, серверу неизвестен
    final isKnownToServer = ingredients.every((item) => item.ingredient.id >= 0);
    final remote = isKnownToServer
        ? await _tryRemote(
            () => _api.createRecipe(name: name, duration: duration, ingredients: ingredients, steps: steps),
          )
        : null;
    final recipe =
        remote ??
        Recipe(
          id: _nextLocalId(_recipes.map((r) => r.id)),
          name: name,
          duration: duration,
          // TODO: Загрузка фото ещё не реализована
          photo: '',
          ingredients: List.unmodifiable(ingredients),
          steps: List.unmodifiable(steps),
        );

    _recipes
      ..add(recipe)
      ..sort(_compareRecipes);
    await _store.putRecipe(recipe);
    notifyListeners();

    if (images.isNotEmpty) {
      await _saveNewRecipeImages(recipe, images);
    }

    return recipe;
  }

  /// Записывает [images] к только что сохранённому [recipe]
  ///
  /// Отказ записи оборачивается в [RecipeImagesSaveException], чтобы вызывающий отличил его от несохранённого рецепта
  Future<void> _saveNewRecipeImages(Recipe recipe, List<RecipeImage> images) async {
    try {
      await _mutateImages(recipe.id, (_) => List.of(images));
    } on Exception catch (error, stackTrace) {
      Error.throwWithStackTrace(RecipeImagesSaveException(recipe, error), stackTrace);
    }
  }

  /// Входит ли рецепт в избранное
  bool isFavorite(int recipeId) => _favoriteIds.contains(recipeId);

  /// Переключает отметку избранного рецепта
  void toggleFavorite(int recipeId) {
    final isNowFavorite = !isFavorite(recipeId);
    if (isNowFavorite) {
      _favoriteIds.add(recipeId);
    } else {
      _favoriteIds.remove(recipeId);
    }

    unawaited(_store.saveFavorite(recipeId, isNowFavorite));
    notifyListeners();
  }

  /// Комментарии к рецепту в порядке добавления
  List<Comment> comments(int recipeId) => List.unmodifiable(_cachedComments(recipeId));

  /// Добавляет комментарий текущего пользователя к рецепту и возвращает его
  Comment addComment(int recipeId, String text) {
    // Имя не хранится, потому что подпись `Вы` зависит от языка интерфейса
    final comment = Comment(author: '', text: text, date: DateTime.now(), isOwn: true);
    final comments = _cachedComments(recipeId)..add(comment);

    unawaited(_store.saveComments(recipeId, comments));
    notifyListeners();

    return comment;
  }

  /// Изменяемый список комментариев из кэша
  List<Comment> _cachedComments(int recipeId) => _comments.putIfAbsent(recipeId, () => _store.loadComments(recipeId));

  /// Фото рецепта в порядке добавления
  List<RecipeImage> images(int recipeId) => List.unmodifiable(_cachedImages(recipeId));

  /// Размечает фото найденными объектами, ничего не сохраняя
  ///
  /// Нужен форме создания рецепта, которая копит фото, пока у рецепта нет идентификатора.
  /// При сбое поиска объектов фото возвращается без них
  Future<RecipeImage> analyzeImage(Uint8List photo) async {
    final detector = _detector;
    final objects = detector == null ? const <DetectedObject>[] : await _tryDetect(detector, photo);
    return RecipeImage(bytes: await annotateDetections(photo, objects), objects: objects);
  }

  /// Размечает фото найденными объектами, сохраняет его к рецепту и возвращает
  ///
  /// При сбое поиска объектов фото сохраняется без них
  Future<RecipeImage> addImage(int recipeId, Uint8List photo) async {
    // Определение объектов и разметка идут до очереди, потому что они долгие и кэш не трогают
    final image = await analyzeImage(photo);
    await _mutateImages(recipeId, (images) => images..add(image));
    return image;
  }

  /// Удаляет фото рецепта по позиции в [images]
  Future<void> removeImage(int recipeId, int index) => _mutateImages(recipeId, (images) => images..removeAt(index));

  /// Применяет [change] к копии списка фото, записывает результат, кладёт его в кэш и уведомляет слушателей
  ///
  /// Ошибка записи уходит вызывающему, а кэш остаётся прежним
  Future<void> _mutateImages(int recipeId, List<RecipeImage> Function(List<RecipeImage> images) change) async {
    // Две перекрывающиеся мутации берут один снимок кэша, и последняя запись затирает первую в Hive и в кэше
    final previous = _lastImagesMutation;
    final done = Completer<void>();
    _lastImagesMutation = done.future;

    try {
      await previous;
      final images = change([..._cachedImages(recipeId)]);

      // Кэш меняется только после записи, иначе при отказе диска интерфейс разошёлся бы с тем, что переживёт перезапуск
      await _store.saveImages(recipeId, images);
      _images[recipeId] = images;
      notifyListeners();
    } finally {
      // Очередь продолжается и после ошибки, потому что `done` завершается всегда без ошибки
      done.complete();
    }
  }

  /// Список фото из кэша, при первом обращении читается из хранилища
  List<RecipeImage> _cachedImages(int recipeId) => _images.putIfAbsent(recipeId, () => _store.loadImages(recipeId));

  /// Перечитывает данные из хранилища
  void _reload() {
    _recipes = _store.loadRecipes()..sort(_compareRecipes);
    _ingredients = _store.loadIngredients();
    _measureUnits = _store.loadMeasureUnits();
  }

  /// Выполняет запрос к серверу и возвращает `null`, если он недоступен или ответил неожиданными данными
  ///
  /// Ловится только `Exception`, чтобы намеренно падать на всех остальных
  static Future<T?> _tryRemote<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on Exception catch (error) {
      debugPrint('Server request failed. $error');
      return null;
    }
  }

  /// Ищет объекты на фото и возвращает пустой список, если поиск не удался
  static Future<List<DetectedObject>> _tryDetect(ObjectDetector detector, Uint8List photo) async {
    try {
      return await detector.detect(photo);
    } on Exception catch (error) {
      debugPrint('Object detection on photo failed. $error');
      return const [];
    }
  }

  /// Стоит ли замещать сохранённое ответом сервера
  ///
  /// Разбор терпим к битым записям, и пустой набор поверх непустого кэша не применяется
  bool _isSafeToReplace(FoodData data) =>
      (data.recipes.isNotEmpty || _recipes.isEmpty) &&
      (data.ingredients.isNotEmpty || _ingredients.isEmpty) &&
      (data.measureUnits.isNotEmpty || _measureUnits.isEmpty);

  /// Локальный идентификатор для созданного без сети, например `−1`
  ///
  /// Отрицательные значения не пересекаются с серверными, поэтому синхронизация не перезапишет созданное оффлайн
  int _nextLocalId(Iterable<int> ids) => ids.fold(0, min) - 1;

  /// Серверные рецепты по возрастанию идентификатора, затем локальные в порядке создания
  static int _compareRecipes(Recipe a, Recipe b) {
    final aLocal = a.id < 0;
    if (aLocal != (b.id < 0)) {
      return aLocal ? 1 : -1;
    }

    return aLocal ? b.id.compareTo(a.id) : a.id.compareTo(b.id);
  }
}
