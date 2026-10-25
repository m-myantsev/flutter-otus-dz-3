import '../entities/food_data.dart';
import '../entities/ingredient.dart';
import '../entities/measure_unit.dart';
import '../entities/recipe.dart';
import '../entities/recipe_ingredient.dart';
import '../entities/recipe_step.dart';

/// API рецептов
///
/// Методы бросают исключение при недоступности сервера для возможности переключения на локальные данные
abstract interface class FoodApi {
  /// Загружает рецепты с составом и шагами вместе с каталогами
  Future<FoodData> fetchFoodData();

  /// Создаёт рецепт на сервере и возвращает его с присвоенным идентификатором
  Future<Recipe> createRecipe({
    required String name,
    required int duration,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> steps,
  });

  /// Создаёт ингредиент каталога на сервере и возвращает его с присвоенным идентификатором
  Future<Ingredient> createIngredient(String name, MeasureUnit measureUnit);
}
