import 'recipe_ingredient.dart';
import 'recipe_step.dart';

/// Рецепт
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.duration,
    required this.photo,
    this.ingredients = const [],
    this.steps = const [],
  });

  /// Уникальный идентификатор рецепта
  final int id;

  /// Название рецепта
  final String name;

  /// Время приготовления в минутах
  final int duration;

  /// Изображение рецепта
  final String photo;

  /// Ингридиенты
  final List<RecipeIngredient> ingredients;

  /// Шаги приготовления
  final List<RecipeStep> steps;
}
