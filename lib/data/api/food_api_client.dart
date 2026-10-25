import 'package:dio/dio.dart';

import '../../domain/entities/food_data.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/measure_unit.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_ingredient.dart';
import '../../domain/entities/recipe_step.dart';
import '../../domain/repositories/food_api.dart';
import 'allow_expired_certificate_web.dart' if (dart.library.io) 'allow_expired_certificate_io.dart';
import 'food_data_assembly.dart';

/// Общий API рецептов
///
/// Сервер отдаёт коллекции со ссылками на `id`, и полные рецепты собираются из нескольких коллекций
class FoodApiClient implements FoodApi {
  FoodApiClient({Dio? dio}) : _dio = dio ?? _createDio();

  /// Хост API
  static const _host = 'foodapi.dzolotov.pro';

  final Dio _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://$_host',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    allowExpiredCertificateForHost(dio, _host);

    return dio;
  }

  @override
  Future<FoodData> fetchFoodData() async {
    final [recipes, measureUnits, ingredients, recipeIngredients, steps, stepLinks] = await Future.wait([
      _fetchList('/recipe'),
      _fetchList('/measure_unit'),
      _fetchList('/ingredient'),
      _fetchList('/recipe_ingredient'),
      _fetchList('/recipe_step'),
      _fetchList('/recipe_step_link'),
    ]);
    return assembleFoodData(
      recipes: recipes,
      measureUnits: measureUnits,
      ingredients: ingredients,
      recipeIngredients: recipeIngredients,
      steps: steps,
      stepLinks: stepLinks,
    );
  }

  @override
  Future<Recipe> createRecipe({
    required String name,
    required int duration,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> steps,
  }) async {
    // TODO: Загрузка фото ещё не реализована
    final recipeId = await _post('/recipe', {'name': name, 'duration': duration, 'photo': ''});

    for (final (index, step) in steps.indexed) {
      final stepId = await _post('/recipe_step', {'name': step.name, 'duration': step.duration});
      await _post('/recipe_step_link', {
        'number': index + 1,
        'recipe': {'id': recipeId},
        'step': {'id': stepId},
      });
    }

    for (final item in ingredients) {
      await _post('/recipe_ingredient', {
        // Сервер хранит количество целым и отвергает дробное
        'count': item.count.ceil(),
        'ingredient': {'id': item.ingredient.id},
        'recipe': {'id': recipeId},
      });
    }

    return Recipe(
      id: recipeId,
      name: name,
      duration: duration,
      photo: '',
      ingredients: List.unmodifiable(ingredients),
      steps: List.unmodifiable(steps),
    );
  }

  @override
  Future<Ingredient> createIngredient(String name, MeasureUnit measureUnit) async {
    final id = await _post('/ingredient', {
      'name': name,
      'caloriesForUnit': 0,
      'measureUnit': {'id': measureUnit.id},
    });
    return Ingredient(id: id, name: name, measureUnit: measureUnit);
  }

  /// Загружает коллекцию объектов
  ///
  /// Элементы неожиданного вида отбрасываются здесь
  Future<List<Map<String, dynamic>>> _fetchList(String path) async {
    try {
      final response = await _dio.get<List<dynamic>>(path);
      return (response.data ?? const []).whereType<Map<String, dynamic>>().toList();
    } on DioException catch (error) {
      throw _explain(error, 'GET', path);
    }
  }

  /// Отправляет объект и возвращает присвоенный сервером идентификатор
  Future<int> _post(String path, Map<String, dynamic> body) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(path, data: body);
    } on DioException catch (error) {
      throw _explain(error, 'POST', path);
    }

    final id = response.data?['id'];
    if (id is! num) {
      throw FormatException('$path не вернул идентификатор созданного объекта');
    }

    return id.toInt();
  }

  /// Дополняет сетевую ошибку запросом и ответом сервера
  DioException _explain(DioException error, String method, String path) {
    final status = error.response?.statusCode;
    final body = error.response?.data;
    return error.copyWith(
      message: '$method $path${status == null ? '' : ' → $status'}${body == null ? '' : ': $body'}',
    );
  }
}
