import '../models/comment.dart';
import '../models/food_data.dart';
import '../models/ingredient.dart';
import '../models/measure_unit.dart';
import '../models/recipe.dart';
import '../models/recipe_image.dart';

/// Локальное хранилище данных о рецептах
///
/// Чтение синхронное, запись асинхронная.
/// Методы чтения возвращают копии, и изменение результата не влияет на хранилище
abstract interface class RecipesStore {
  /// Все сохранённые рецепты
  List<Recipe> loadRecipes();

  /// Каталог ингредиентов
  List<Ingredient> loadIngredients();

  /// Справочник единиц измерения
  List<MeasureUnit> loadMeasureUnits();

  /// Комментарии к рецепту в порядке добавления
  List<Comment> loadComments(int recipeId);

  /// Идентификаторы избранных рецептов
  Set<int> loadFavoriteIds();

  /// Фото рецепта в порядке добавления
  List<RecipeImage> loadImages(int recipeId);

  /// Замещает серверные данные свежими
  Future<void> saveAll(FoodData data);

  /// Сохраняет или обновляет рецепт
  Future<void> putRecipe(Recipe recipe);

  /// Сохраняет или обновляет ингредиент каталога
  Future<void> putIngredient(Ingredient ingredient);

  /// Сохраняет комментарии рецепта
  Future<void> saveComments(int recipeId, List<Comment> comments);

  /// Сохраняет или снимает отметку избранного
  Future<void> saveFavorite(int recipeId, bool isFavorite);

  /// Сохраняет фото рецепта
  Future<void> saveImages(int recipeId, List<RecipeImage> images);
}
