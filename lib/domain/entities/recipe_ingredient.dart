import 'ingredient.dart';

/// Ингредиент в составе рецепта
class RecipeIngredient {
  const RecipeIngredient({required this.count, required this.ingredient});

  /// Количество в единицах измерения ингредиента
  ///
  /// Дробные количества кратны четверти единицы, например `1.5` или `0.75`
  final double count;

  /// Ингредиент из каталога
  final Ingredient ingredient;
}
