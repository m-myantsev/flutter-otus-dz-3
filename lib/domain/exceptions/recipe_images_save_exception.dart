import '../entities/recipe.dart';

/// Рецепт сохранён, а его фото нет
///
/// Бросается из `RecipesManager.saveRecipe`, повторное сохранение создало бы второй такой же рецепт
class RecipeImagesSaveException implements Exception {
  const RecipeImagesSaveException(this.recipe, this.cause);

  /// Сохранённый рецепт, к которому не записались фото
  final Recipe recipe;

  /// Исходная ошибка записи фото
  final Exception cause;

  @override
  String toString() => 'RecipeImagesSaveException: photos of recipe ${recipe.id} were not saved. $cause';
}
