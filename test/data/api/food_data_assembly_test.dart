import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/data/api/food_data_assembly.dart';
import 'package:recipes/domain/entities/food_data.dart';

void main() {
  group('assembleFoodData', () {
    final measureUnits = <Map<String, dynamic>>[
      {'id': 1, 'one': 'грамм', 'few': 'грамма', 'many': 'граммов'},
    ];
    final ingredients = <Map<String, dynamic>>[
      {
        'id': 10,
        'name': 'Мука',
        'caloriesForUnit': 0.0,
        'measureUnit': {'id': 1},
      },
      // Битая ссылка на единицу, когда ингредиент должен быть отброшен
      {
        'id': 11,
        'name': 'Призрак',
        'caloriesForUnit': 0.0,
        'measureUnit': {'id': 999},
      },
    ];
    final recipes = <Map<String, dynamic>>[
      {'id': 2, 'name': 'Хлеб', 'duration': 90, 'photo': 'https://example.com/bread.jpg'},
      {'id': 3, 'name': 'Без всего', 'duration': 5, 'photo': null},
    ];
    final recipeIngredients = <Map<String, dynamic>>[
      // Сервер отдаёт `count` целым числом
      {
        'id': 100,
        'count': 500,
        'ingredient': {'id': 10},
        'recipe': {'id': 2},
      },
      // Битая ссылка на ингредиент
      {
        'id': 101,
        'count': 2,
        'ingredient': {'id': 999},
        'recipe': {'id': 2},
      },
      // Осиротевшая связь без рецепта
      {
        'id': 102,
        'count': 1,
        'ingredient': {'id': 10},
        'recipe': null,
      },
    ];
    final steps = <Map<String, dynamic>>[
      {'id': 20, 'name': 'Замесить тесто', 'duration': 300},
      {'id': 21, 'name': 'Выпечь', 'duration': 1800},
    ];
    final stepLinks = <Map<String, dynamic>>[
      // Номера идут не по порядку, и сборка обязана сортировать
      {
        'id': 200,
        'number': 2,
        'recipe': {'id': 2},
        'step': {'id': 21},
      },
      {
        'id': 201,
        'number': 1,
        'recipe': {'id': 2},
        'step': {'id': 20},
      },
      {
        'id': 202,
        'number': 1,
        'recipe': null,
        'step': {'id': 20},
      },
      {
        'id': 203,
        'number': 3,
        'recipe': {'id': 2},
        'step': {'id': 999},
      },
    ];

    FoodData assemble() => assembleFoodData(
      recipes: recipes,
      measureUnits: measureUnits,
      ingredients: ingredients,
      recipeIngredients: recipeIngredients,
      steps: steps,
      stepLinks: stepLinks,
    );

    test('рецепт собирается с составом и шагами, отсортированными по номеру', () {
      final bread = assemble().recipes.singleWhere((recipe) => recipe.id == 2);

      expect(bread.name, 'Хлеб');
      expect(bread.ingredients.single.count, 500.0);
      expect(bread.ingredients.single.ingredient.name, 'Мука');
      expect(bread.steps.map((step) => step.name).toList(), ['Замесить тесто', 'Выпечь']);
      expect(bread.steps.first.duration, 300);
    });

    test('битые связи отбрасываются, null-фото становится пустой строкой', () {
      final bare = assemble().recipes.singleWhere((recipe) => recipe.id == 3);

      expect(bare.ingredients, isEmpty);
      expect(bare.steps, isEmpty);
      expect(bare.photo, '');
    });

    test('каталоги содержат только валидные записи', () {
      final data = assemble();

      expect(data.ingredients.map((item) => item.id), [10]);
      expect(data.measureUnits.map((unit) => unit.id), [1]);
    });
  });

  group('на грязных данных', () {
    const validUnit = <String, dynamic>{'id': 1, 'one': 'грамм', 'few': 'грамма', 'many': 'граммов'};

    FoodData assemble({
      List<Map<String, dynamic>> recipes = const [],
      List<Map<String, dynamic>> measureUnits = const [validUnit],
      List<Map<String, dynamic>> ingredients = const [],
      List<Map<String, dynamic>> recipeIngredients = const [],
      List<Map<String, dynamic>> steps = const [],
      List<Map<String, dynamic>> stepLinks = const [],
    }) => assembleFoodData(
      recipes: recipes,
      measureUnits: measureUnits,
      ingredients: ingredients,
      recipeIngredients: recipeIngredients,
      steps: steps,
      stepLinks: stepLinks,
    );

    test('рецепт без названия пропускается, остальные собираются', () {
      final data = assemble(
        recipes: [
          {'id': 1, 'name': null, 'duration': 10},
          {'id': 2, 'name': 'Хлеб', 'duration': 90},
        ],
      );

      expect(data.recipes.map((recipe) => recipe.id), [2]);
    });

    test('дробная длительность приводится к минутам', () {
      final data = assemble(
        recipes: [
          {'id': 2, 'name': 'Хлеб', 'duration': 45.0},
        ],
      );

      expect(data.recipes.single.duration, 45);
    });

    test('единица измерения с полем неверного типа отбрасывается вместе со своими ингредиентами', () {
      final data = assemble(
        measureUnits: [
          {'id': 1, 'one': 'грамм', 'few': 42, 'many': 'граммов'},
        ],
        ingredients: [
          {
            'id': 10,
            'name': 'Мука',
            'measureUnit': {'id': 1},
          },
        ],
      );

      expect(data.measureUnits, isEmpty);
      expect(data.ingredients, isEmpty);
    });

    test('шаг без описания не попадает в рецепт, остальные сохраняют порядок', () {
      final data = assemble(
        recipes: [
          {'id': 2, 'name': 'Хлеб', 'duration': 90},
        ],
        steps: [
          {'id': 20, 'name': 'Замесить', 'duration': 300},
          {'id': 21, 'name': null, 'duration': 60},
          {'id': 22, 'name': 'Выпечь', 'duration': 1800},
        ],
        stepLinks: [
          {
            'id': 200,
            'number': 3,
            'recipe': {'id': 2},
            'step': {'id': 22},
          },
          {
            'id': 201,
            'number': 2,
            'recipe': {'id': 2},
            'step': {'id': 21},
          },
          {
            'id': 202,
            'number': 1,
            'recipe': {'id': 2},
            'step': {'id': 20},
          },
        ],
      );

      expect(data.recipes.single.steps.map((step) => step.name).toList(), ['Замесить', 'Выпечь']);
    });

    test('позиция состава с нечисловым количеством пропускается', () {
      final data = assemble(
        recipes: [
          {'id': 2, 'name': 'Хлеб', 'duration': 90},
        ],
        ingredients: [
          {
            'id': 10,
            'name': 'Мука',
            'measureUnit': {'id': 1},
          },
        ],
        recipeIngredients: [
          {
            'id': 100,
            'count': 'много',
            'ingredient': {'id': 10},
            'recipe': {'id': 2},
          },
        ],
      );

      expect(data.recipes.single.ingredients, isEmpty);
    });
  });
}
