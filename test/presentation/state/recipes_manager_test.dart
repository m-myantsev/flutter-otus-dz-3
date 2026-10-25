import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/food_data.dart';
import 'package:recipes/domain/entities/ingredient.dart';
import 'package:recipes/domain/entities/measure_unit.dart';
import 'package:recipes/domain/entities/offline_measure_units.dart';
import 'package:recipes/domain/entities/recipe.dart';
import 'package:recipes/domain/entities/recipe_image.dart';
import 'package:recipes/domain/entities/recipe_ingredient.dart';
import 'package:recipes/domain/entities/recipe_step.dart';
import 'package:recipes/domain/exceptions/recipe_images_save_exception.dart';
import 'package:recipes/domain/repositories/food_api.dart';
import 'package:recipes/presentation/state/recipes_manager.dart';

import '../../fakes.dart';
import '../../fixtures.dart';
import '../../helpers.dart';

void main() {
  final newIngredients = [const RecipeIngredient(count: 2, ingredient: soySauce)];
  final newSteps = [
    const RecipeStep(name: 'Смешать всё', duration: 90),
    const RecipeStep(name: 'Подать', duration: 30),
  ];

  group('загрузка', () {
    test('данные с сервера попадают в хранилище и доступны через менеджер', () async {
      final store = InMemoryRecipesStore();
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: store,
      );

      await manager.init();

      expect(manager.isLoading, isFalse);
      expect(manager.recipes.map((recipe) => recipe.name), contains('Лосось в соусе терияки'));
      expect(manager.ingredients, hasLength(21));
      expect(manager.measureUnits, hasLength(7));
      expect(store.loadRecipes(), hasLength(7), reason: 'полученное сохранено в локальную базу');
    });

    test('при недоступном сервере используются сохранённые данные', () async {
      final store = InMemoryRecipesStore(
        recipes: fixtureRecipes,
        ingredients: fixtureIngredients,
        measureUnits: fixtureMeasureUnits,
      );
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);

      await manager.init();

      expect(manager.isLoading, isFalse);
      expect(manager.recipes, hasLength(7));
      expect(manager.measureUnits, hasLength(7));
    });

    test('без сети и без сохранённых данных менеджер работает с пустым списком', () async {
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: InMemoryRecipesStore());

      await manager.init();

      expect(manager.isLoading, isFalse);
      expect(manager.recipes, isEmpty);
    });

    test('уведомляет и при показе кэша, и после ответа сервера', () async {
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: InMemoryRecipesStore(),
      );
      var notifications = 0;
      manager.addListener(() => notifications++);

      await manager.init();

      expect(notifications, greaterThanOrEqualTo(2));
    });

    test('пустой ответ сервера не стирает сохранённые рецепты', () async {
      final store = InMemoryRecipesStore(
        recipes: fixtureRecipes,
        ingredients: fixtureIngredients,
        measureUnits: fixtureMeasureUnits,
      );
      final manager = RecipesManager(
        api: FakeFoodApi(
          data: const FoodData(recipes: [], ingredients: [], measureUnits: []),
        ),
        store: store,
      );

      await manager.init();

      expect(manager.recipes, hasLength(7), reason: 'сменившийся формат ответа выглядит как пустой успех');
      expect(store.loadRecipes(), hasLength(7));
    });

    test('пустой каталог с сервера не стирает сохранённые ингредиенты и единицы', () async {
      final store = InMemoryRecipesStore(
        recipes: fixtureRecipes,
        ingredients: fixtureIngredients,
        measureUnits: fixtureMeasureUnits,
      );

      final manager = RecipesManager(
        api: FakeFoodApi(
          data: const FoodData(recipes: fixtureRecipes, ingredients: [], measureUnits: []),
        ),
        store: store,
      );
      await manager.init();

      expect(manager.ingredients, hasLength(21), reason: 'без каталога нельзя создать ни один рецепт');
      expect(manager.measureUnits, hasLength(7));
      expect(store.loadIngredients(), hasLength(21));
    });

    test('ошибка в собственном коде не маскируется под недоступный сервер', () async {
      final manager = RecipesManager(api: _BrokenFoodApi(), store: InMemoryRecipesStore());

      await expectLater(manager.init(), throwsA(isA<TypeError>()));
    });

    test('отказ записи в хранилище не оставляет вечный индикатор загрузки', () async {
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: InMemoryRecipesStore(failOnSaveAll: true),
      );

      await expectLater(manager.init(), throwsStateError);

      expect(manager.isLoading, isFalse, reason: 'ожидание завершено даже при отказе диска');
    });

    test('возвращаемые списки нельзя изменить', () async {
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: InMemoryRecipesStore(),
      );
      await manager.init();

      expect(() => manager.recipes.clear(), throwsUnsupportedError);
      expect(() => manager.ingredients.clear(), throwsUnsupportedError);
      expect(() => manager.measureUnits.clear(), throwsUnsupportedError);
    });
  });

  group('создание рецепта', () {
    test('при доступном сервере рецепт получает серверный идентификатор и сохраняется локально', () async {
      final store = InMemoryRecipesStore();
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: store,
      );
      await manager.init();
      var notified = false;
      manager.addListener(() => notified = true);

      final recipe = await manager.saveRecipe(name: 'Новый', ingredients: newIngredients, steps: newSteps);

      expect(recipe.id, 100, reason: 'идентификатор присвоен `сервером`');
      expect(recipe.duration, 2, reason: '120 секунд шагов округляются до 2 минут');
      expect(manager.recipes.map((r) => r.id), contains(100));
      expect(store.loadRecipes().map((r) => r.id), contains(100), reason: 'сохранено и локально');
      expect(notified, isTrue);
    });

    test('без сети рецепт получает отрицательный идентификатор и сохраняется локально', () async {
      final store = InMemoryRecipesStore(
        recipes: fixtureRecipes,
        ingredients: fixtureIngredients,
        measureUnits: fixtureMeasureUnits,
      );
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await manager.init();

      final first = await manager.saveRecipe(name: 'Первый черновик', ingredients: newIngredients, steps: newSteps);
      final second = await manager.saveRecipe(name: 'Второй черновик', ingredients: newIngredients, steps: newSteps);

      expect(first.id, -1);
      expect(second.id, -2);
      expect(store.loadRecipes().map((r) => r.id), containsAll([-1, -2]));
    });

    test('оффлайн-рецепты идут после серверных в порядке создания', () async {
      final manager = RecipesManager(
        api: FakeFoodApi(offline: true),
        store: InMemoryRecipesStore(recipes: fixtureRecipes),
      );
      await manager.init();

      await manager.saveRecipe(name: 'Первый черновик', ingredients: newIngredients, steps: newSteps);
      await manager.saveRecipe(name: 'Второй черновик', ingredients: newIngredients, steps: newSteps);

      final names = manager.recipes.map((r) => r.name).toList();
      expect(names.sublist(names.length - 2), ['Первый черновик', 'Второй черновик']);
      expect(manager.recipes.first.id, 0, reason: 'серверные рецепты остаются в начале по возрастанию id');
    });

    test('рецепт с ингредиентом, созданным без сети, на сервер не отправляется', () async {
      final api = FakeFoodApi(data: fixtureData());
      final manager = RecipesManager(
        api: api,
        store: InMemoryRecipesStore(measureUnits: fixtureMeasureUnits),
      );
      await manager.init();

      api.offline = true;
      final local = await manager.addIngredient('Соль морская', gram);
      api.offline = false;

      final recipe = await manager.saveRecipe(
        name: 'Рецепт с локальным ингредиентом',
        ingredients: [
          const RecipeIngredient(count: 2, ingredient: soySauce),
          RecipeIngredient(count: 1, ingredient: local),
        ],
        steps: newSteps,
      );

      expect(local.id, isNegative);
      expect(api.createRecipeCalls, 0, reason: 'связь ушла бы на неизвестный серверу идентификатор');
      expect(recipe.id, isNegative);
      expect(manager.recipes.map((r) => r.id), contains(recipe.id));
    });

    test('длительностью является сумма шагов, округлённая вверх до минут', () async {
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: InMemoryRecipesStore());
      await manager.init();

      final recipe = await manager.saveRecipe(
        name: 'Быстрый',
        ingredients: newIngredients,
        steps: [const RecipeStep(name: 'Один шаг', duration: 61)],
      );

      expect(recipe.duration, 2);
    });

    test('фото сохраняются под серверным идентификатором нового рецепта', () async {
      final store = InMemoryRecipesStore();
      final manager = await createTestManager(store: store);
      final images = [fixtureImage(label: 'cup'), fixtureImage(label: 'fork')];

      final recipe = await manager.saveRecipe(
        name: 'С фото',
        ingredients: newIngredients,
        steps: newSteps,
        images: images,
      );

      expect(recipe.id, 100);
      expect(labels(manager.images(100)), ['cup', 'fork']);
      expect(labels(store.loadImages(100)), ['cup', 'fork']);
    });

    test('без сети фото сохраняются под локальным идентификатором нового рецепта', () async {
      final store = InMemoryRecipesStore();
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await manager.init();

      final recipe = await manager.saveRecipe(
        name: 'С фото без сети',
        ingredients: newIngredients,
        steps: newSteps,
        images: [fixtureImage(label: 'knife')],
      );

      expect(recipe.id, -1);
      expect(labels(manager.images(-1)), ['knife']);
      expect(labels(store.loadImages(-1)), ['knife']);
    });

    test('сохранение без фото не трогает хранилище фото', () async {
      final store = InMemoryRecipesStore();
      final manager = await createTestManager(store: store);

      final recipe = await manager.saveRecipe(name: 'Без фото', ingredients: newIngredients, steps: newSteps);

      expect(store.saveImagesCalls, 0);
      expect(manager.images(recipe.id), isEmpty);
    });

    test('отказ записи фото бросает RecipeImagesSaveException, а рецепт остаётся сохранённым', () async {
      final store = InMemoryRecipesStore(failOnSaveImages: true);
      final manager = await createTestManager(store: store);

      await expectLater(
        manager.saveRecipe(
          name: 'Фото не записались',
          ingredients: newIngredients,
          steps: newSteps,
          images: [fixtureImage()],
        ),
        throwsA(isA<RecipeImagesSaveException>()),
      );

      final recipe = manager.recipes.singleWhere((r) => r.name == 'Фото не записались');
      expect(store.loadRecipes().map((r) => r.id), contains(recipe.id), reason: 'рецепт записан до фото');
      expect(manager.images(recipe.id), isEmpty);
    });
  });

  group('каталог ингредиентов', () {
    test('при доступном сервере ингредиент получает серверный идентификатор', () async {
      final store = InMemoryRecipesStore();
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: store,
      );
      await manager.init();

      final ingredient = await manager.addIngredient('Соль морская', gram);

      expect(ingredient.id, 100);
      expect(manager.ingredients, contains(ingredient));
      expect(store.loadIngredients().map((i) => i.id), contains(100));
    });

    test('без сети ингредиент получает отрицательный идентификатор и сохраняется', () async {
      final store = InMemoryRecipesStore(ingredients: fixtureIngredients, measureUnits: fixtureMeasureUnits);
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await manager.init();

      final ingredient = await manager.addIngredient('Соль морская', gram);

      expect(ingredient.id, -1);
      expect(store.loadIngredients().map((i) => i.id), contains(-1));
    });
  });

  group('встроенные единицы измерения', () {
    test('при пустом хранилище единиц справочником является встроенный набор', () async {
      final store = InMemoryRecipesStore();
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);

      await manager.init();

      expect(manager.measureUnits, OfflineMeasureUnits.all);
      expect(store.loadMeasureUnits(), isEmpty, reason: 'встроенный набор в базу не пишется');
      expect(() => manager.measureUnits.clear(), throwsUnsupportedError);
    });

    test('после загрузки серверных единиц встроенных в справочнике нет', () async {
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: InMemoryRecipesStore(),
      );

      await manager.init();

      expect(manager.measureUnits, unorderedEquals(fixtureMeasureUnits));
      expect(manager.measureUnits.where((unit) => unit.id < 0), isEmpty);
    });

    test('ингредиент со встроенной единицей не отправляется на сервер и получает локальный идентификатор', () async {
      final api = FakeFoodApi(data: fixtureData());
      final store = InMemoryRecipesStore();
      final manager = RecipesManager(api: api, store: store);
      await manager.init();
      final unit = OfflineMeasureUnits.all.first;

      final ingredient = await manager.addIngredient('Соль морская', unit);

      expect(api.createIngredientCalls, 0, reason: 'серверу встроенная единица неизвестна');
      expect(ingredient.id, isNegative);
      expect(ingredient.measureUnit, same(unit));
      expect(store.loadIngredients(), contains(ingredient));
    });

    test('ингредиент с серверной единицей по-прежнему создаётся на сервере', () async {
      final api = FakeFoodApi(data: fixtureData());
      final manager = RecipesManager(api: api, store: InMemoryRecipesStore());
      await manager.init();

      final ingredient = await manager.addIngredient('Соль морская', gram);

      expect(api.createIngredientCalls, 1);
      expect(ingredient.id, 100);
      expect(ingredient.measureUnit, same(gram));
    });
  });

  group('избранное', () {
    test('переключается, уведомляет и переживает пересоздание менеджера', () async {
      final store = InMemoryRecipesStore(recipes: fixtureRecipes);
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await manager.init();
      var notifications = 0;
      manager.addListener(() => notifications++);

      manager.toggleFavorite(0);
      expect(manager.isFavorite(0), isTrue);
      expect(manager.isFavorite(1), isFalse);
      expect(notifications, 1);

      manager.toggleFavorite(0);
      expect(manager.isFavorite(0), isFalse);
      expect(notifications, 2);

      manager.toggleFavorite(6);
      final reopened = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await reopened.init();
      expect(reopened.isFavorite(6), isTrue, reason: 'избранное хранится в локальной базе');
    });
  });

  group('комментарии', () {
    test('комментарии читаются из хранилища', () async {
      final manager = RecipesManager(
        api: FakeFoodApi(offline: true),
        store: InMemoryRecipesStore(comments: fixtureComments()),
      );
      await manager.init();

      expect(manager.comments(0).single.author, 'anna_obraztsova');
      expect(manager.comments(1), isEmpty);
      expect(() => manager.comments(0).clear(), throwsUnsupportedError);
    });

    test('добавленный комментарий подписан, уведомляет и переживает пересоздание', () async {
      final store = InMemoryRecipesStore(comments: fixtureComments());
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await manager.init();
      var notified = false;
      manager.addListener(() => notified = true);
      final before = DateTime.now();

      final comment = manager.addComment(0, 'Очень вкусно!');

      expect(comment.isOwn, isTrue);
      expect(comment.author, isEmpty, reason: 'подпись собственного комментария берётся из локализации');
      expect(comment.text, 'Очень вкусно!');
      expect(comment.date.isBefore(before), isFalse, reason: 'датой комментария является момент добавления');
      expect(notified, isTrue);
      expect(manager.comments(0).map((c) => c.text), contains('Очень вкусно!'));

      final reopened = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await reopened.init();
      expect(
        reopened.comments(0).map((c) => c.text),
        contains('Очень вкусно!'),
        reason: 'комментарий сохранён в локальной базе',
      );
      expect(reopened.comments(0).last.isOwn, isTrue, reason: 'признак собственного комментария сохранён');
    });
  });

  group('фото рецепта', () {
    test('addImage размечает фото объектами детектора и сохраняет в хранилище', () async {
      final store = InMemoryRecipesStore();
      final manager = await createTestManager(
        store: store,
        detector: FakeObjectDetector(objects: fixtureImage().objects),
      );
      final photo = fixtureJpeg();

      final image = await manager.addImage(0, photo);

      expect(image.objects.map((o) => o.label), ['cup', 'bowl']);
      expect(image.bytes, isNot(equals(photo)), reason: 'рамки нарисованы, JPEG перекодирован');
      expect(manager.images(0).single, same(image));
      expect(store.loadImages(0), hasLength(1));
    });

    test('сбой детектора сохраняет фото без объектов', () async {
      final manager = await createTestManager(detector: FakeObjectDetector(fails: true));
      final photo = fixtureJpeg();

      final image = await manager.addImage(0, photo);

      expect(image.objects, isEmpty);
      expect(image.bytes, same(photo));
    });

    test('без детектора фото сохраняется как есть', () async {
      final manager = await createTestManager();
      final image = await manager.addImage(0, fixtureJpeg());
      expect(image.objects, isEmpty);
    });

    test('analyzeImage размечает фото, ничего не записывая и не уведомляя', () async {
      final store = InMemoryRecipesStore();
      final manager = await createTestManager(
        store: store,
        detector: FakeObjectDetector(objects: fixtureImage().objects),
      );
      var notifications = 0;
      manager.addListener(() => notifications++);
      final photo = fixtureJpeg();

      final image = await manager.analyzeImage(photo);

      expect(image.objects.map((o) => o.label), ['cup', 'bowl']);
      expect(image.bytes, isNot(equals(photo)), reason: 'рамки нарисованы');
      expect(store.saveImagesCalls, 0);
      expect(notifications, 0);
    });

    test('removeImage удаляет выбранное фото и записывает список в хранилище', () async {
      final store = InMemoryRecipesStore(
        images: {
          0: [fixtureImage(label: 'cup'), fixtureImage(label: 'fork'), fixtureImage(label: 'knife')],
        },
      );
      final manager = await createTestManager(store: store);

      await manager.removeImage(0, 1);

      expect(labels(manager.images(0)), ['cup', 'knife']);
      expect(labels(store.loadImages(0)), ['cup', 'knife']);
    });

    test('отказ записи при добавлении не меняет кэш и не уведомляет', () async {
      final manager = await createTestManager(store: InMemoryRecipesStore(failOnSaveImages: true));
      var notifications = 0;
      manager.addListener(() => notifications++);

      await expectLater(manager.addImage(0, fixtureJpeg()), throwsException);

      expect(manager.images(0), isEmpty, reason: 'фото не записано, показывать его нельзя');
      expect(notifications, 0);
    });

    test('отказ записи при удалении оставляет фото и не уведомляет', () async {
      final manager = await createTestManager(
        store: InMemoryRecipesStore(
          images: {
            0: [fixtureImage(label: 'cup'), fixtureImage(label: 'fork')],
          },
          failOnSaveImages: true,
        ),
      );
      var notifications = 0;
      manager.addListener(() => notifications++);

      await expectLater(manager.removeImage(0, 0), throwsException);

      expect(labels(manager.images(0)), ['cup', 'fork'], reason: 'на диске фото осталось, значит и в интерфейсе тоже');
      expect(notifications, 0);
    });

    test('добавление и удаление уведомляют слушателей, список наружу неизменяемый', () async {
      final manager = await createTestManager();
      var notifications = 0;
      manager.addListener(() => notifications++);

      await manager.addImage(0, fixtureJpeg());
      await manager.removeImage(0, 0);

      expect(notifications, 2);
      expect(() => manager.images(0).add(fixtureImage()), throwsUnsupportedError);
    });

    test('удаление во время записи добавленного фото ждёт её и не теряет ни одной правки', () async {
      final store = InMemoryRecipesStore(
        images: {
          0: [fixtureImage(label: 'cup'), fixtureImage(label: 'fork')],
        },
      );
      final manager = await createTestManager(store: store);
      final gate = store.saveImagesGate = Completer<void>();
      final photo = fixtureJpeg();

      final adding = manager.addImage(0, photo);
      await pumpEventQueue();
      expect(store.saveImagesCalls, 1, reason: 'запись добавленного фото висит');

      final removing = manager.removeImage(0, 0);
      await pumpEventQueue();
      gate.complete();
      await adding;
      await removing;

      for (final (source, images) in [('кэш', manager.images(0)), ('хранилище', store.loadImages(0))]) {
        expect(images, hasLength(2), reason: '$source: cup удалено, новое фото осталось');
        expect(images.first.objects.first.label, 'fork', reason: source);
        expect(images.last.bytes, same(photo), reason: source);
      }
    });
  });
}

/// Подписи первых объектов фото, по ним фото отличаются друг от друга
List<String> labels(List<RecipeImage> images) => [for (final image in images) image.objects.first.label];

/// Падения приведения типа не должны подменяться локальными данными
class _BrokenFoodApi implements FoodApi {
  @override
  Future<FoodData> fetchFoodData() async {
    final Object wrongType = 'не FoodData';
    return wrongType as FoodData;
  }

  @override
  Future<Recipe> createRecipe({
    required String name,
    required int duration,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> steps,
  }) => throw UnimplementedError();

  @override
  Future<Ingredient> createIngredient(String name, MeasureUnit measureUnit) => throw UnimplementedError();
}
