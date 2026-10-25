import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:recipes/data/local/hive/hive_registrar.g.dart';
import 'package:recipes/domain/entities/comment.dart';
import 'package:recipes/domain/entities/ingredient.dart';
import 'package:recipes/domain/entities/measure_unit.dart';
import 'package:recipes/domain/entities/recipe.dart';
import 'package:recipes/domain/entities/recipe_image.dart';
import 'package:recipes/domain/entities/recipe_ingredient.dart';
import 'package:recipes/domain/entities/recipe_step.dart';

import '../../../fixtures.dart';

void main() {
  late Directory tempDir;

  setUpAll(Hive.registerAdapters);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_adapters_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('рецепт с составом и шагами переживает запись и чтение с диска', () async {
    const unit = MeasureUnit(id: 2, one: 'грамм', few: 'грамма', many: 'граммов');
    const recipe = Recipe(
      id: 1,
      name: 'Тестовый хлеб',
      duration: 45,
      photo: 'https://example.com/photo.jpg',
      ingredients: [
        RecipeIngredient(
          count: 1.5,
          ingredient: Ingredient(id: 3, name: 'Мука', measureUnit: unit),
        ),
      ],
      steps: [RecipeStep(name: 'Смешать и выпечь', duration: 90)],
    );

    var box = await Hive.openBox<Recipe>('recipes_test');
    await box.put('1', recipe);
    await box.close();

    // Повторное открытие гарантирует чтение именно с диска, а не из кэша бокса
    box = await Hive.openBox<Recipe>('recipes_test');
    final restored = box.get('1')!;

    expect(restored.id, 1);
    expect(restored.name, 'Тестовый хлеб');
    expect(restored.duration, 45);
    expect(restored.photo, 'https://example.com/photo.jpg');
    expect(restored.ingredients.single.count, 1.5);

    // `Ingredient` и `MeasureUnit` равны по одному лишь `id`, поэтому сравнение подтверждает только взаимозаменяемость
    final restoredIngredient = restored.ingredients.single.ingredient;
    expect(restoredIngredient, const Ingredient(id: 3, name: 'Мука', measureUnit: unit));
    expect(restoredIngredient.id, 3);
    expect(restoredIngredient.name, 'Мука');
    expect(restoredIngredient.measureUnit.id, 2);
    expect(restoredIngredient.measureUnit.one, 'грамм');
    expect(restoredIngredient.measureUnit.few, 'грамма');
    expect(restoredIngredient.measureUnit.many, 'граммов');

    expect(restored.steps.single.name, 'Смешать и выпечь');
    expect(restored.steps.single.duration, 90);
  });

  test('список комментариев с датой переживает запись и чтение с диска', () async {
    final comment = Comment(author: 'Вы', text: 'Отлично!', date: DateTime(2026, 8, 12));

    var box = await Hive.openBox<List>('comments_test');
    await box.put('1', [comment]);
    await box.close();

    box = await Hive.openBox<List>('comments_test');
    final restored = box.get('1')!.cast<Comment>();

    expect(restored.single.author, 'Вы');
    expect(restored.single.text, 'Отлично!');
    expect(restored.single.date, DateTime(2026, 8, 12));
    expect(restored.single.avatar, '');
    expect(restored.single.photo, '');
  });

  test('фото с объектами переживает запись и чтение с диска', () async {
    final image = fixtureImage();
    var box = await Hive.openBox<List>('images_test');
    await box.put('1', [image]);
    await box.close();

    box = await Hive.openBox<List>('images_test');
    final restored = box.get('1')!.cast<RecipeImage>().single;

    expect(restored.bytes, image.bytes);
    expect(restored.objects.length, 2);
    expect(restored.objects.first.label, 'cup');
    expect(restored.objects.first.score, 0.87);
    expect(restored.objects.first.box.right, 0.5);
  });
}
