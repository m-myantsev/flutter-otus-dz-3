import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/comment.dart';
import '../models/food_data.dart';
import '../models/ingredient.dart';
import '../models/measure_unit.dart';
import '../models/recipe.dart';
import '../models/recipe_image.dart';
import 'hive/hive_registrar.g.dart';
import 'recipes_store.dart';

/// Локальное хранилище на Hive
class HiveRecipesStore implements RecipesStore {
  HiveRecipesStore({
    required this._recipes,
    required this._ingredients,
    required this._measureUnits,
    required this._comments,
    required this._favorites,
    required this._images,
  });

  final Box<Recipe> _recipes;
  final Box<Ingredient> _ingredients;
  final Box<MeasureUnit> _measureUnits;
  final Box<List> _comments;
  final Box<bool> _favorites;

  /// Фото по рецептам
  ///
  /// Фото живут только на устройстве
  final Box<List> _images;

  /// Инициализирует Hive, регистрирует адаптеры и открывает боксы приложения
  static Future<HiveRecipesStore> open() async {
    await Hive.initFlutter();

    Hive.registerAdapters();

    return HiveRecipesStore(
      recipes: await Hive.openBox<Recipe>('recipes'),
      ingredients: await Hive.openBox<Ingredient>('ingredients'),
      measureUnits: await Hive.openBox<MeasureUnit>('measure_units'),
      comments: await Hive.openBox<List>('comments'),
      favorites: await Hive.openBox<bool>('favorites'),
      images: await Hive.openBox<List>('recipe_images'),
    );
  }

  @override
  List<Recipe> loadRecipes() => _recipes.values.toList();

  @override
  List<Ingredient> loadIngredients() => _ingredients.values.toList();

  @override
  List<MeasureUnit> loadMeasureUnits() => _measureUnits.values.toList();

  @override
  List<Comment> loadComments(int recipeId) => (_comments.get(recipeId.toString()) ?? const []).cast<Comment>().toList();

  @override
  Set<int> loadFavoriteIds() => _favorites.keys.map((key) => int.parse(key as String)).toSet();

  @override
  List<RecipeImage> loadImages(int recipeId) {
    return (_images.get(recipeId.toString()) ?? const []).cast<RecipeImage>().toList();
  }

  @override
  Future<void> saveAll(FoodData data) async {
    await _replaceServerEntries(_recipes, {for (final recipe in data.recipes) recipe.id.toString(): recipe});
    await _replaceServerEntries(_ingredients, {for (final item in data.ingredients) item.id.toString(): item});
    await _replaceServerEntries(_measureUnits, {for (final unit in data.measureUnits) unit.id.toString(): unit});
  }

  @override
  Future<void> putRecipe(Recipe recipe) => _recipes.put(recipe.id.toString(), recipe);

  @override
  Future<void> putIngredient(Ingredient ingredient) => _ingredients.put(ingredient.id.toString(), ingredient);

  @override
  Future<void> saveComments(int recipeId, List<Comment> comments) {
    return _comments.put(recipeId.toString(), List<Comment>.from(comments));
  }

  @override
  Future<void> saveFavorite(int recipeId, bool isFavorite) {
    return isFavorite ? _favorites.put(recipeId.toString(), true) : _favorites.delete(recipeId.toString());
  }

  @override
  Future<void> saveImages(int recipeId, List<RecipeImage> images) {
    return _images.put(recipeId.toString(), List<RecipeImage>.from(images));
  }

  /// Замещает серверные записи бокса свежими, не трогая созданные оффлайн с ключами, начинающимися с `-`
  static Future<void> _replaceServerEntries<T>(Box<T> box, Map<String, T> fresh) async {
    final serverKeys = box.keys.where((key) => !(key as String).startsWith('-')).toList();
    await box.deleteAll(serverKeys);
    await box.putAll(fresh);
  }
}
