import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:recipes/data/local/hive/hive_registrar.g.dart';
import 'package:recipes/data/local/hive_recipes_store.dart';
import 'package:recipes/domain/entities/comment.dart';
import 'package:recipes/domain/entities/food_data.dart';
import 'package:recipes/domain/entities/ingredient.dart';
import 'package:recipes/domain/entities/measure_unit.dart';
import 'package:recipes/domain/entities/recipe.dart';

import '../../fixtures.dart';

void main() {
  const gram = MeasureUnit(id: 1, one: 'грамм', few: 'грамма', many: 'граммов');
  const flour = Ingredient(id: 10, name: 'Мука', measureUnit: gram);
  const serverRecipe = Recipe(id: 2, name: 'Хлеб', duration: 90, photo: 'https://example.com/bread.jpg');
  const localRecipe = Recipe(id: -1, name: 'Черновик', duration: 5, photo: '');
  const serverData = FoodData(recipes: [serverRecipe], ingredients: [flour], measureUnits: [gram]);

  late Directory tempDir;

  setUpAll(Hive.registerAdapters);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_store_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  /// Открывает хранилище над боксами в текущей временной папке
  Future<HiveRecipesStore> openStore() async => HiveRecipesStore(
    recipes: await Hive.openBox<Recipe>('recipes'),
    ingredients: await Hive.openBox<Ingredient>('ingredients'),
    measureUnits: await Hive.openBox<MeasureUnit>('measure_units'),
    comments: await Hive.openBox<List>('comments'),
    favorites: await Hive.openBox<bool>('favorites'),
    images: await Hive.openBox<List>('recipe_images'),
  );

  test('данные сохраняются и читаются после переоткрытия боксов', () async {
    var store = await openStore();
    await store.saveAll(serverData);
    await Hive.close();

    store = await openStore();
    expect(store.loadRecipes().single.name, 'Хлеб');
    expect(store.loadIngredients().single, flour);
    expect(store.loadMeasureUnits().single, gram);
  });

  test('серверные записи замещаются и созданные оффлайн не трогаются', () async {
    final store = await openStore();
    await store.putRecipe(const Recipe(id: 2, name: 'Старый хлеб', duration: 10, photo: ''));
    await store.putRecipe(localRecipe);

    await store.saveAll(serverData);

    final byId = {for (final recipe in store.loadRecipes()) recipe.id: recipe};
    expect(byId.keys, containsAll([2, -1]));
    expect(byId[2]!.name, 'Хлеб', reason: 'серверная запись замещена свежей');
    expect(byId[-1]!.name, 'Черновик', reason: 'оффлайн-запись пережила синхронизацию');
  });

  test('удалённые на сервере рецепты исчезают', () async {
    final store = await openStore();
    await store.putRecipe(const Recipe(id: 99, name: 'Удалённый', duration: 1, photo: ''));

    await store.saveAll(serverData);

    expect(store.loadRecipes().map((recipe) => recipe.id), isNot(contains(99)));
  });

  test('избранное сохраняется и снимается', () async {
    final store = await openStore();
    await store.saveFavorite(5, true);
    await store.saveFavorite(7, true);
    await store.saveFavorite(5, false);

    expect(store.loadFavoriteIds(), {7});
  });

  test('комментарии сохраняются по рецепту', () async {
    final store = await openStore();
    final comment = Comment(author: 'Вы', text: 'Супер', date: DateTime(2026, 8, 12));

    await store.saveComments(3, [comment]);

    expect(store.loadComments(3).single.text, 'Супер');
    expect(store.loadComments(4), isEmpty);
  });

  test('фото рецепта сохраняются и читаются, у рецепта без фото пустой список', () async {
    final store = await openStore();
    await store.saveImages(1, [fixtureImage()]);
    expect(store.loadImages(1).single.objects.length, 2);
    expect(store.loadImages(2), isEmpty);
  });

  test('обновление с сервера не трогает фото, в том числе у локальных рецептов', () async {
    final store = await openStore();
    await store.saveImages(1, [fixtureImage()]);
    await store.saveImages(-1, [fixtureImage()]);
    await store.saveAll(fixtureData());
    expect(store.loadImages(1), hasLength(1));
    expect(store.loadImages(-1), hasLength(1));
  });
}
