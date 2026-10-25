import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/data/api/food_api_client.dart';
import 'package:recipes/domain/entities/ingredient.dart';
import 'package:recipes/domain/entities/measure_unit.dart';
import 'package:recipes/domain/entities/recipe_ingredient.dart';
import 'package:recipes/domain/entities/recipe_step.dart';

/// Транспорт, подменяющий сеть, запоминающий запросы и отдающий заготовленные ответы
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.byPath = const {}, this.statusByPath = const {}});

  /// Ответы по путям, остальные пути получают пустой массив
  final Map<String, Object> byPath;

  /// Коды состояния по путям, по умолчанию 200
  final Map<String, int> statusByPath;

  /// Дошедшие запросы в порядке отправки, как метод, путь без базового адреса и тело
  final requests = <({String method, String path, Object? body})>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add((method: options.method, path: options.path, body: options.data));
    return ResponseBody.fromString(
      jsonEncode(byPath[options.path] ?? const <Object>[]),
      statusByPath[options.path] ?? 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  /// Клиент поверх подменённого транспорта
  FoodApiClient clientOver(_FakeAdapter adapter) => FoodApiClient(dio: Dio()..httpClientAdapter = adapter);

  const gram = MeasureUnit(id: 1, one: 'грамм', few: 'грамма', many: 'граммов');
  const flour = Ingredient(id: 10, name: 'Мука', measureUnit: gram);

  group('fetchFoodData', () {
    test('запрашивает шесть коллекций и собирает рецепт с составом и шагами', () async {
      final adapter = _FakeAdapter(
        byPath: {
          '/recipe': [
            {'id': 2, 'name': 'Хлеб', 'duration': 90, 'photo': ''},
          ],
          '/measure_unit': [
            {'id': 1, 'one': 'грамм', 'few': 'грамма', 'many': 'граммов'},
          ],
          '/ingredient': [
            {
              'id': 10,
              'name': 'Мука',
              'measureUnit': {'id': 1},
            },
          ],
          '/recipe_ingredient': [
            {
              'id': 100,
              'count': 500,
              'ingredient': {'id': 10},
              'recipe': {'id': 2},
            },
          ],
          '/recipe_step': [
            {'id': 20, 'name': 'Замесить', 'duration': 300},
          ],
          '/recipe_step_link': [
            {
              'id': 200,
              'number': 1,
              'recipe': {'id': 2},
              'step': {'id': 20},
            },
          ],
        },
      );

      final data = await clientOver(adapter).fetchFoodData();

      expect(adapter.requests.map((request) => request.path), [
        '/recipe',
        '/measure_unit',
        '/ingredient',
        '/recipe_ingredient',
        '/recipe_step',
        '/recipe_step_link',
      ]);
      expect(adapter.requests.every((request) => request.method == 'GET'), isTrue);
      expect(data.recipes.single.name, 'Хлеб');
      expect(data.recipes.single.ingredients.single.count, 500.0);
      expect(data.recipes.single.steps.single.name, 'Замесить');
    });
  });

  group('createRecipe', () {
    test('связывает шаги по порядку и отправляет состав целым количеством', () async {
      final adapter = _FakeAdapter(
        byPath: {
          '/recipe': {'id': 7},
          '/recipe_step': {'id': 30},
          '/recipe_step_link': {'id': 40},
          '/recipe_ingredient': {'id': 50},
        },
      );

      final recipe = await clientOver(adapter).createRecipe(
        name: 'Хлеб',
        duration: 90,
        ingredients: const [RecipeIngredient(count: 1.5, ingredient: flour)],
        steps: const [
          RecipeStep(name: 'Замесить', duration: 300),
          RecipeStep(name: 'Выпечь', duration: 1800),
        ],
      );

      expect(recipe.id, 7, reason: 'идентификатор берётся из ответа сервера');
      expect(adapter.requests.map((request) => '${request.method} ${request.path}'), [
        'POST /recipe',
        'POST /recipe_step',
        'POST /recipe_step_link',
        'POST /recipe_step',
        'POST /recipe_step_link',
        'POST /recipe_ingredient',
      ]);

      final links = adapter.requests
          .where((request) => request.path == '/recipe_step_link')
          .map((request) => request.body as Map<String, dynamic>)
          .toList();
      expect(links.map((body) => body['number']), [1, 2], reason: 'нумерация шагов начинается с единицы');
      expect(links.map((body) => (body['recipe'] as Map<String, dynamic>)['id']), [7, 7]);

      final position = adapter.requests.last.body as Map<String, dynamic>;
      expect(position['count'], 2, reason: 'сервер хранит количество целым');
      expect(position['count'], isA<int>());
    });

    test('четверть ингредиента не превращается в ноль', () async {
      final adapter = _FakeAdapter(
        byPath: {
          '/recipe': {'id': 7},
          '/recipe_ingredient': {'id': 50},
        },
      );

      await clientOver(adapter).createRecipe(
        name: 'Тесто',
        duration: 5,
        ingredients: const [RecipeIngredient(count: 0.25, ingredient: flour)],
        steps: const [],
      );

      final position = adapter.requests.last.body as Map<String, dynamic>;
      expect(position['count'], 1, reason: 'округление вниз потеряло бы ингредиент');
    });

    test('ответ без идентификатора приводит к ошибке разбора', () async {
      final adapter = _FakeAdapter(byPath: {'/recipe': const <String, Object>{}});

      await expectLater(
        clientOver(adapter).createRecipe(name: 'Хлеб', duration: 90, ingredients: const [], steps: const []),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ошибки сервера', () {
    test('сообщение называет метод, путь, код и ответ сервера', () async {
      final adapter = _FakeAdapter(
        byPath: {
          '/recipe': {'id': 7},
          '/recipe_step': {'error': 'entity_already_exists'},
        },
        statusByPath: {'/recipe_step': 409},
      );

      try {
        await clientOver(adapter).createRecipe(
          name: 'Хлеб',
          duration: 90,
          ingredients: const [],
          steps: const [RecipeStep(name: 'Замесить', duration: 300)],
        );
        fail('ожидалась ошибка сервера');
      } on DioException catch (error) {
        expect(error.message, contains('POST /recipe_step'));
        expect(error.message, contains('409'));
        expect(error.message, contains('entity_already_exists'));
      }
    });
  });
}
