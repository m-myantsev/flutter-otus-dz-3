import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/data/offline_measure_units.dart';
import 'package:recipes/data/recipes_manager.dart';
import 'package:recipes/models/measure_unit.dart';
import 'package:recipes/screens/add_recipe_page.dart';
import 'package:recipes/screens/recipe_images_page.dart';
import 'package:recipes/theme/app_colors.dart';
import 'package:recipes/widgets/recipe_gallery.dart';
import 'package:recipes/widgets/recipe_photo.dart';

import 'fakes.dart';
import 'fixtures.dart';
import 'helpers.dart';

void main() {
  /// Прокручивает до кнопки и нажимает её
  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.text(label);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  /// Заполняет форму минимальным набором, включающим название, один ингредиент из каталога и один шаг
  Future<void> fillForm(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextFormField, 'Название рецепта'), 'Пробный рецепт');

    await tapButton(tester, 'Добавить ингредиент');
    await tester.enterText(find.widgetWithText(TextFormField, 'Название ингредиента'), 'Мёд');
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextFormField, 'Количество'), '2');
    await tapButton(tester, 'Добавить');

    await tapButton(tester, 'Добавить шаг');
    await tester.enterText(find.widgetWithText(TextFormField, 'Описание шага'), 'Смешать всё');
    await tester.enterText(find.widgetWithText(TextFormField, 'Минуты'), '2');
    await tapButton(tester, 'Добавить');
  }

  testWidgets('повторное нажатие во время сохранения не создаёт второй рецепт', (tester) async {
    final api = FakeFoodApi(data: fixtureData())..delay = const Duration(milliseconds: 200);
    final manager = await createTestManager(api: api);
    final recipesBefore = manager.recipes.length;

    await tester.pumpWidget(MaterialApp(home: AddRecipePage(manager: manager)));
    await fillForm(tester);

    // Первое нажатие уводит сохранение в ожидание ответа сервера
    final saveButton = find.widgetWithText(FilledButton, 'Сохранить рецепт');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pump();

    // Пока ответ не пришёл, кнопка выключена и показывает индикатор
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed, isNull);

    // Повторный тап по выключенной кнопке ничего не запускает
    await tester.tap(find.byType(FilledButton).last, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(api.createRecipeCalls, 1, reason: 'запрос к серверу ушёл ровно один раз');
    expect(manager.recipes.length, recipesBefore + 1);
  });

  testWidgets('без сети и с пустой базой рецепт создаётся со встроенной единицей измерения', (tester) async {
    final api = FakeFoodApi(offline: true);
    final manager = await createTestManager(api: api, store: InMemoryRecipesStore());
    final unit = OfflineMeasureUnits.all.first;

    // Форма открывается поверх пустого экрана, чтобы после сохранения ей было куда закрыться
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    unawaited(
      Navigator.push(
        tester.element(find.byType(Scaffold)),
        MaterialPageRoute<void>(builder: (_) => AddRecipePage(manager: manager)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Название рецепта'), 'Пробный рецепт');

    // Каталог пуст, поэтому имя новое и единицу выбирают из встроенного набора
    await tapButton(tester, 'Добавить ингредиент');
    await tester.enterText(find.widgetWithText(TextFormField, 'Название ингредиента'), 'Соль морская');
    await tester.pump();
    await tester.tap(find.byType(DropdownButtonFormField<MeasureUnit>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(unit.one).last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Количество'), '5');
    await tapButton(tester, 'Добавить');

    await tapButton(tester, 'Добавить шаг');
    await tester.enterText(find.widgetWithText(TextFormField, 'Описание шага'), 'Посолить');
    await tester.enterText(find.widgetWithText(TextFormField, 'Минуты'), '1');
    await tapButton(tester, 'Добавить');

    await tapButton(tester, 'Сохранить рецепт');

    expect(find.byType(AddRecipePage), findsNothing);
    final recipe = manager.recipes.single;
    expect(recipe.name, 'Пробный рецепт');
    expect(recipe.id, isNegative);
    final ingredient = recipe.ingredients.single.ingredient;
    expect(ingredient.name, 'Соль морская');
    expect(ingredient.id, isNegative);
    expect(ingredient.measureUnit, same(unit));
    expect(api.createIngredientCalls, 0, reason: 'серверу встроенная единица неизвестна');
    expect(api.createRecipeCalls, 0, reason: 'рецепт с локальным ингредиентом на сервер не отправляется');
  });

  group('лента фото', () {
    /// Миниатюры фото черновика, других `Image` внутри ленты нет
    final thumbnails = find.descendant(of: find.byType(RecipeGallery), matching: find.byType(Image));

    /// Плитка анализа добавляемого фото
    final busyTile = find.descendant(of: find.byType(RecipeGallery), matching: find.byType(CircularProgressIndicator));

    /// Открывает форму поверх пустого экрана, чтобы закрытию формы было куда возвращаться
    Future<void> pumpForm(WidgetTester tester, RecipesManager manager, FakePhotoPicker picker) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final context = tester.element(find.byType(Scaffold));
      unawaited(
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => AddRecipePage(manager: manager, picker: picker),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// Нажимает плитку добавления и выбирает альбом, ответ пикера не дожидается
    Future<void> pickFromAlbum(WidgetTester tester) async {
      final addTile = find.byTooltip('Добавить фото');
      await tester.ensureVisible(addTile);
      await tester.pumpAndSettle();
      await tester.tap(addTile);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выбрать из альбома'));
    }

    /// Нажимает на сохранение рецепта при записи рецепта, висящей на возвращённом gate хранилища
    Future<Completer<void>> startSavingOnGate(WidgetTester tester, InMemoryRecipesStore store) async {
      final gate = store.putRecipeGate = Completer<void>();
      final saveButton = find.widgetWithText(FilledButton, 'Сохранить рецепт');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      // Индикатор на кнопке крутится, пока висит запись рецепта, поэтому `pumpAndSettle` здесь не дождался бы покоя
      await tester.pump();
      return gate;
    }

    /// Кнопка сохранения рецепта
    FilledButton saveButton(WidgetTester tester) {
      return tester.widget(find.widgetWithText(FilledButton, 'Сохранить рецепт'));
    }

    testWidgets('плитка добавления стоит под главным фото вровень с ним', (tester) async {
      await pumpForm(tester, await createTestManager(), FakePhotoPicker());

      expect(find.byTooltip('Добавить фото'), findsOneWidget);
      final photo = tester.getRect(find.byType(RecipePhoto));
      final addTile = tester.getRect(find.bySemanticsLabel('Добавить фото'));
      expect(tester.getRect(find.byType(RecipeGallery)).top - photo.bottom, 12);
      expect(addTile.left, photo.left, reason: 'отступ ленты не складывается с отступом формы');
    });

    testWidgets('фото из альбома проходит анализ и появляется в ленте', (tester) async {
      final picker = FakePhotoPicker(bytes: fixtureJpeg());
      final detector = FakeObjectDetector();
      await pumpForm(tester, await createTestManager(detector: detector), picker);

      await pickFromAlbum(tester);
      await tester.pumpAndSettle();

      expect(detector.calls, 1);
      expect(thumbnails, findsOneWidget);
    });

    testWidgets('во время анализа сохранение недоступно, а в ленте плитка анализа', (tester) async {
      final detector = FakeObjectDetector()..gate = Completer();
      await pumpForm(tester, await createTestManager(detector: detector), FakePhotoPicker(bytes: fixtureJpeg()));
      await fillForm(tester);
      expect(saveButton(tester).onPressed, isNotNull);

      await pickFromAlbum(tester);
      // Индикатор крутится бесконечно, поэтому `pumpAndSettle` до ответа детектора не дождался бы покоя
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(busyTile, findsOneWidget);
      expect(saveButton(tester).onPressed, isNull);

      // Пустой ответ не уводит разметку в `compute`, чей изолят под тестовым временем не завершился бы
      detector.gate!.complete(const []);
      await tester.pumpAndSettle();

      expect(busyTile, findsNothing);
      expect(thumbnails, findsOneWidget);
      expect(saveButton(tester).onPressed, isNotNull);
    });

    testWidgets('сохранённый рецепт получает фото черновика', (tester) async {
      final photo = fixtureJpeg();
      final manager = await createTestManager(detector: FakeObjectDetector());
      await pumpForm(tester, manager, FakePhotoPicker(bytes: photo));

      await pickFromAlbum(tester);
      await tester.pumpAndSettle();
      await fillForm(tester);
      await tapButton(tester, 'Сохранить рецепт');

      final recipe = manager.recipes.singleWhere((r) => r.name == 'Пробный рецепт');
      expect(manager.images(recipe.id).single.bytes, same(photo));
      expect(find.byType(AddRecipePage), findsNothing);
    });

    testWidgets('удаление в просмотре убирает миниатюру из ленты', (tester) async {
      await pumpForm(
        tester,
        await createTestManager(detector: FakeObjectDetector()),
        FakePhotoPicker(bytes: fixtureJpeg()),
      );
      await pickFromAlbum(tester);
      await tester.pumpAndSettle();

      await tester.tap(thumbnails);
      await tester.pumpAndSettle();
      expect(find.byType(RecipeImagesPage), findsOneWidget);
      expect(find.text('1 из 1'), findsOneWidget);

      await tester.tap(find.byTooltip('Удалить фото'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();

      expect(find.byType(RecipeImagesPage), findsNothing);
      expect(thumbnails, findsNothing);
    });

    testWidgets('во время сохранения плитка добавления не открывает панель источников', (tester) async {
      final store = InMemoryRecipesStore(comments: fixtureComments());
      final picker = FakePhotoPicker(bytes: fixtureJpeg());
      await pumpForm(tester, await createTestManager(store: store), picker);
      await fillForm(tester);

      final gate = await startSavingOnGate(tester, store);

      final addTile = find.byTooltip('Добавить фото');
      await tester.ensureVisible(addTile);
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(addTile);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Выбрать из альбома'), findsNothing, reason: 'панель выбора не открылась');
      expect(picker.calls, 0);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(AddRecipePage), findsNothing);
    });

    testWidgets('во время сохранения тап по миниатюре не открывает просмотр', (tester) async {
      final store = InMemoryRecipesStore(comments: fixtureComments());
      final manager = await createTestManager(store: store, detector: FakeObjectDetector());
      await pumpForm(tester, manager, FakePhotoPicker(bytes: fixtureJpeg()));
      await pickFromAlbum(tester);
      await tester.pumpAndSettle();
      await fillForm(tester);

      final gate = await startSavingOnGate(tester, store);
      await tester.ensureVisible(thumbnails);
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(thumbnails);
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(RecipeImagesPage), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(AddRecipePage), findsNothing, reason: 'закрылась форма, а не просмотр');
      final recipe = manager.recipes.singleWhere((r) => r.name == 'Пробный рецепт');
      expect(manager.images(recipe.id), hasLength(1));
    });

    testWidgets('во время сохранения кнопки добавления и правки состава и шагов неактивны', (tester) async {
      final store = InMemoryRecipesStore(comments: fixtureComments());
      await pumpForm(tester, await createTestManager(store: store), FakePhotoPicker());
      await fillForm(tester);

      // Иконки карточек ингредиента и шага, у остальных кнопок формы есть подсказки
      Iterable<IconButton> tileButtons() =>
          tester.widgetList<IconButton>(find.byType(IconButton)).where((b) => b.tooltip == null);
      expect(tileButtons().map((b) => (b.icon as Icon).color), everyElement(AppColors.primary));

      final gate = await startSavingOnGate(tester, store);

      for (final label in ['Добавить ингредиент', 'Добавить шаг']) {
        expect(
          tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, label)).onPressed,
          isNull,
          reason: label,
        );
      }
      expect(tileButtons(), hasLength(4), reason: 'правка и удаление у ингредиента и у шага');
      expect(tileButtons().map((b) => b.onPressed), everyElement(isNull));
      expect(
        tileButtons().map((b) => (b.icon as Icon).color),
        everyElement(AppColors.placeholder),
        reason: 'выключенные иконки выглядят выключенными',
      );

      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('отмена выбора ничего не добавляет', (tester) async {
      final detector = FakeObjectDetector();
      await pumpForm(tester, await createTestManager(detector: detector), FakePhotoPicker());

      await pickFromAlbum(tester);
      await tester.pumpAndSettle();

      expect(detector.calls, 0);
      expect(thumbnails, findsNothing);
      expect(busyTile, findsNothing);
    });

    testWidgets('отказ записи фото закрывает форму с сообщением, рецепт остаётся в списке', (tester) async {
      final manager = await createTestManager(
        store: InMemoryRecipesStore(failOnSaveImages: true),
        detector: FakeObjectDetector(),
      );
      await pumpForm(tester, manager, FakePhotoPicker(bytes: fixtureJpeg()));

      await pickFromAlbum(tester);
      await tester.pumpAndSettle();
      await fillForm(tester);
      await tapButton(tester, 'Сохранить рецепт');

      expect(find.text('Рецепт сохранён без фото'), findsOneWidget);
      expect(find.byType(AddRecipePage), findsNothing);
      final recipe = manager.recipes.singleWhere((r) => r.name == 'Пробный рецепт');
      expect(manager.images(recipe.id), isEmpty);
    });
  });
}
