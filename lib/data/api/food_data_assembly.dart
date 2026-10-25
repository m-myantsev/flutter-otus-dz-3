import '../../domain/entities/food_data.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/measure_unit.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_ingredient.dart';
import '../../domain/entities/recipe_step.dart';

/// Собирает полные данные из коллекций сервера
///
/// Записи, которые не удалось разобрать, пропускаются
FoodData assembleFoodData({
  required List<Map<String, dynamic>> recipes,
  required List<Map<String, dynamic>> measureUnits,
  required List<Map<String, dynamic>> ingredients,
  required List<Map<String, dynamic>> recipeIngredients,
  required List<Map<String, dynamic>> steps,
  required List<Map<String, dynamic>> stepLinks,
}) {
  final unitById = <int, MeasureUnit>{};

  for (final json in measureUnits) {
    final id = _intOf(json['id']);
    final one = _stringOf(json['one']);
    final few = _stringOf(json['few']);
    final many = _stringOf(json['many']);
    if (id == null || one == null || few == null || many == null) {
      continue;
    }

    unitById[id] = MeasureUnit(id: id, one: one, few: few, many: many);
  }

  final ingredientById = <int, Ingredient>{};

  for (final json in ingredients) {
    final id = _intOf(json['id']);
    final name = _stringOf(json['name']);
    final unit = unitById[_idOf(json['measureUnit'])];
    if (id == null || name == null || unit == null) {
      continue;
    }

    ingredientById[id] = Ingredient(id: id, name: name, measureUnit: unit);
  }

  final stepById = <int, RecipeStep>{};

  for (final json in steps) {
    final id = _intOf(json['id']);
    final name = _stringOf(json['name']);
    final duration = _intOf(json['duration']);
    if (id == null || name == null || duration == null) {
      continue;
    }

    stepById[id] = RecipeStep(name: name, duration: duration);
  }

  final ingredientsByRecipe = <int, List<RecipeIngredient>>{};

  for (final json in recipeIngredients) {
    final recipeId = _idOf(json['recipe']);
    final ingredient = ingredientById[_idOf(json['ingredient'])];
    final count = _doubleOf(json['count']);
    if (recipeId == null || ingredient == null || count == null) {
      continue;
    }

    ingredientsByRecipe.putIfAbsent(recipeId, () => []).add(RecipeIngredient(count: count, ingredient: ingredient));
  }

  final linksByRecipe = <int, List<_StepLink>>{};

  for (final json in stepLinks) {
    final recipeId = _idOf(json['recipe']);
    final number = _intOf(json['number']);
    final step = stepById[_idOf(json['step'])];
    if (recipeId == null || number == null || step == null) {
      continue;
    }

    linksByRecipe.putIfAbsent(recipeId, () => []).add(_StepLink(number: number, step: step));
  }

  final assembled = <Recipe>[];

  for (final json in recipes) {
    final id = _intOf(json['id']);
    final name = _stringOf(json['name']);
    final duration = _intOf(json['duration']);
    if (id == null || name == null || duration == null) {
      continue;
    }

    assembled.add(
      Recipe(
        id: id,
        name: name,
        duration: duration,
        photo: _stringOf(json['photo']) ?? '',
        ingredients: List.unmodifiable(ingredientsByRecipe[id] ?? const <RecipeIngredient>[]),
        steps: List.unmodifiable(_sortedSteps(linksByRecipe[id] ?? const [])),
      ),
    );
  }

  return FoodData(
    recipes: assembled,
    ingredients: List.unmodifiable(ingredientById.values),
    measureUnits: List.unmodifiable(unitById.values),
  );
}

/// Разобранная связь рецепта с шагом приготовления
class _StepLink {
  const _StepLink({required this.number, required this.step});

  /// Порядковый номер шага в рецепте
  final int number;

  /// Шаг приготовления
  final RecipeStep step;
}

/// Шаги рецепта в порядке номеров связей
List<RecipeStep> _sortedSteps(List<_StepLink> links) {
  final sorted = [...links]..sort((a, b) => a.number.compareTo(b.number));
  return [for (final link in sorted) link.step];
}

/// Идентификатор из вложенной ссылки или `null`
int? _idOf(Object? ref) => ref is Map ? _intOf(ref['id']) : null;

/// Целое из числа любой формы
int? _intOf(Object? value) => value is num ? value.toInt() : null;

/// Дробное из числа любой формы
double? _doubleOf(Object? value) => value is num ? value.toDouble() : null;

/// Строка или `null`, если поля нет либо оно иного типа
String? _stringOf(Object? value) => value is String ? value : null;
