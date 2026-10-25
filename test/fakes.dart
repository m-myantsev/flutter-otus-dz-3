import 'dart:async';
import 'dart:typed_data';

import 'package:recipes/domain/entities/comment.dart';
import 'package:recipes/domain/entities/detected_object.dart';
import 'package:recipes/domain/entities/food_data.dart';
import 'package:recipes/domain/entities/ingredient.dart';
import 'package:recipes/domain/entities/measure_unit.dart';
import 'package:recipes/domain/entities/recipe.dart';
import 'package:recipes/domain/entities/recipe_image.dart';
import 'package:recipes/domain/entities/recipe_ingredient.dart';
import 'package:recipes/domain/entities/recipe_step.dart';
import 'package:recipes/domain/exceptions/object_detection_exception.dart';
import 'package:recipes/domain/repositories/food_api.dart';
import 'package:recipes/domain/repositories/object_detector.dart';
import 'package:recipes/domain/repositories/photo_picker.dart';
import 'package:recipes/domain/repositories/photo_source.dart';
import 'package:recipes/domain/repositories/recipes_store.dart';
import 'package:recipes/domain/repositories/settings_store.dart';

/// Сетевой API для тестов
///
/// При [offline] каждый метод бросает исключение, как настоящий клиент без сети
class FakeFoodApi implements FoodApi {
  FakeFoodApi({FoodData? data, this.offline = false})
    : data = data ?? const FoodData(recipes: [], ingredients: [], measureUnits: []);

  /// Данные, отдаваемые [fetchFoodData]
  FoodData data;

  /// Имитация отсутствия сети
  bool offline;

  /// Идентификатор, присваиваемый следующему созданному объекту
  int nextId = 100;

  /// Сколько раз запрашивали создание рецепта
  int createRecipeCalls = 0;

  /// Сколько раз запрашивали создание ингредиента
  int createIngredientCalls = 0;

  /// Искусственная задержка ответа для тестов, проверяющих поведение во время ожидания
  Duration delay = Duration.zero;

  @override
  Future<FoodData> fetchFoodData() async {
    _throwIfOffline();
    return data;
  }

  @override
  Future<Recipe> createRecipe({
    required String name,
    required int duration,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> steps,
  }) async {
    createRecipeCalls++;
    // Таймер заводим только когда тест сам его прокачает
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    _throwIfOffline();
    return Recipe(
      id: nextId++,
      name: name,
      duration: duration,
      photo: '',
      ingredients: List.unmodifiable(ingredients),
      steps: List.unmodifiable(steps),
    );
  }

  @override
  Future<Ingredient> createIngredient(String name, MeasureUnit measureUnit) async {
    createIngredientCalls++;

    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    _throwIfOffline();
    return Ingredient(id: nextId++, name: name, measureUnit: measureUnit);
  }

  void _throwIfOffline() {
    if (offline) {
      throw Exception('сеть недоступна');
    }
  }
}

/// Хранилище в памяти для тестов
class InMemoryRecipesStore implements RecipesStore {
  InMemoryRecipesStore({
    List<Recipe> recipes = const [],
    List<Ingredient> ingredients = const [],
    List<MeasureUnit> measureUnits = const [],
    Map<int, List<Comment>> comments = const {},
    Set<int> favoriteIds = const {},
    Map<int, List<RecipeImage>> images = const {},
    this.failOnSaveAll = false,
    this.failOnSaveImages = false,
  }) : _recipes = {for (final recipe in recipes) recipe.id: recipe},
       _ingredients = {for (final item in ingredients) item.id: item},
       _measureUnits = {for (final unit in measureUnits) unit.id: unit},
       _comments = {
         for (final entry in comments.entries) entry.key: [...entry.value],
       },
       _favoriteIds = {...favoriteIds},
       _images = {
         for (final entry in images.entries) entry.key: [...entry.value],
       };

  final Map<int, Recipe> _recipes;
  final Map<int, Ingredient> _ingredients;
  final Map<int, MeasureUnit> _measureUnits;
  final Map<int, List<Comment>> _comments;
  final Set<int> _favoriteIds;
  final Map<int, List<RecipeImage>> _images;

  @override
  List<Recipe> loadRecipes() => _recipes.values.toList();

  @override
  List<Ingredient> loadIngredients() => _ingredients.values.toList();

  @override
  List<MeasureUnit> loadMeasureUnits() => _measureUnits.values.toList();

  @override
  List<Comment> loadComments(int recipeId) => [...?_comments[recipeId]];

  @override
  Set<int> loadFavoriteIds() => {..._favoriteIds};

  @override
  List<RecipeImage> loadImages(int recipeId) => [...?_images[recipeId]];

  /// Имитация отказа записи на диск
  final bool failOnSaveAll;

  @override
  Future<void> saveAll(FoodData data) async {
    if (failOnSaveAll) {
      throw StateError('запись в хранилище не удалась');
    }

    _recipes.removeWhere((id, _) => id >= 0);
    _recipes.addAll({for (final recipe in data.recipes) recipe.id: recipe});
    _ingredients.removeWhere((id, _) => id >= 0);
    _ingredients.addAll({for (final item in data.ingredients) item.id: item});
    _measureUnits.removeWhere((id, _) => id >= 0);
    _measureUnits.addAll({for (final unit in data.measureUnits) unit.id: unit});
  }

  /// Пока задан, [putRecipe] ждёт его завершения, чтобы тест проверил интерфейс во время сохранения
  Completer<void>? putRecipeGate;

  @override
  Future<void> putRecipe(Recipe recipe) async {
    final gate = putRecipeGate;
    if (gate != null) {
      await gate.future;
    }

    _recipes[recipe.id] = recipe;
  }

  @override
  Future<void> putIngredient(Ingredient ingredient) async => _ingredients[ingredient.id] = ingredient;

  @override
  Future<void> saveComments(int recipeId, List<Comment> comments) async => _comments[recipeId] = [...comments];

  @override
  Future<void> saveFavorite(int recipeId, bool isFavorite) async {
    if (isFavorite) {
      _favoriteIds.add(recipeId);
    } else {
      _favoriteIds.remove(recipeId);
    }
  }

  /// Имитация отказа записи фото на диск
  ///
  /// Бросает `Exception`, а не `StateError` как [failOnSaveAll], потому что интерфейс ловит только `Exception`
  final bool failOnSaveImages;

  /// Пока задан, [saveImages] ждёт его завершения, как медленная запись на диск
  Completer<void>? saveImagesGate;

  /// Сколько раз начиналась запись фото
  int saveImagesCalls = 0;

  @override
  Future<void> saveImages(int recipeId, List<RecipeImage> images) async {
    saveImagesCalls++;
    final gate = saveImagesGate;
    if (gate != null) {
      await gate.future;
    }

    if (failOnSaveImages) {
      throw Exception('запись фото не удалась');
    }

    _images[recipeId] = [...images];
  }
}

/// Детектор объектов для тестов
///
/// При [fails] бросает [ObjectDetectionException], как детектор без загруженной модели
class FakeObjectDetector implements ObjectDetector {
  FakeObjectDetector({this.objects = const [], this.fails = false});

  /// Объекты, отдаваемые [detect]
  final List<DetectedObject> objects;

  /// Имитация сбоя детекции
  final bool fails;

  /// Сколько раз запрашивали детекцию
  int calls = 0;

  /// Пока задан, [detect] ждёт его завершения, чтобы тест проверил интерфейс во время анализа
  Completer<List<DetectedObject>>? gate;

  @override
  Future<List<DetectedObject>> detect(Uint8List jpeg) async {
    calls++;

    final gate = this.gate;
    if (gate != null) {
      return gate.future;
    }

    if (fails) {
      throw const ObjectDetectionException('тестовый сбой');
    }

    return objects;
  }
}

/// Пикер фото для тестов
///
/// Отдаёт заранее заданные [bytes], `null` в них имитирует отмену выбора
class FakePhotoPicker implements PhotoPicker {
  FakePhotoPicker({this.bytes, this.supportsCamera = true, this.fails = false});

  /// Байты, отдаваемые [pick]
  final Uint8List? bytes;

  /// Есть ли у устройства камера
  final bool supportsCamera;

  /// Имитация сбоя пикера
  final bool fails;

  /// Источник последнего запроса фото
  PhotoSource? lastSource;

  /// Сколько раз запрашивали фото
  int calls = 0;

  @override
  bool supports(PhotoSource source) => switch (source) {
    PhotoSource.camera => supportsCamera,
    PhotoSource.album => true,
  };

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    calls++;

    lastSource = source;
    if (fails) {
      throw Exception('пикер недоступен');
    }

    return bytes;
  }
}

/// Хранилище настроек в памяти для тестов
class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore({this.languageCode, this.failOnSave = false});

  /// Сохранённый код языка, открыт тестам для проверки записи
  String? languageCode;

  /// Имитация отказа записи на диск
  final bool failOnSave;

  @override
  String? loadLanguageCode() => languageCode;

  @override
  Future<void> saveLanguageCode(String? code) async {
    if (failOnSave) {
      throw Exception('запись настроек не удалась');
    }

    languageCode = code;
  }
}
