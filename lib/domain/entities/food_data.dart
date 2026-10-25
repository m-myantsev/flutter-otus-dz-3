import 'ingredient.dart';
import 'measure_unit.dart';
import 'recipe.dart';

/// Полный набор данных о рецептах
class FoodData {
  const FoodData({required this.recipes, required this.ingredients, required this.measureUnits});

  /// Рецепты с составом и шагами
  final List<Recipe> recipes;

  /// Каталог ингредиентов
  final List<Ingredient> ingredients;

  /// Справочник единиц измерения
  final List<MeasureUnit> measureUnits;
}
