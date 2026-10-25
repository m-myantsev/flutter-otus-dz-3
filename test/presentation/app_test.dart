import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/presentation/app.dart';
import 'package:recipes/presentation/state/locale_controller.dart';
import 'package:recipes/presentation/state/recipes_manager.dart';
import 'package:recipes/presentation/widgets/favorite_button.dart';
import 'package:recipes/presentation/widgets/recipe_card.dart';
import 'package:rive/rive.dart' as rive;

import '../fakes.dart';
import '../helpers.dart';

void main() {
  // Страница рецепта рисует сердце избранного через Rive
  setUpAll(() async => expect(await rive.RiveNative.init(), isTrue));

  group('App', () {
    /// Выводит приложение на платформе с языками [locales] и возвращает его контроллер языка
    ///
    /// Тестовая платформа по умолчанию сообщает `en_US`, поэтому русский задаётся явно.
    /// Без [localeController] язык не выбран и следует платформе, без [manager] берётся менеджер с тестовыми данными
    Future<LocaleController> pumpApp(
      WidgetTester tester, {
      List<Locale> locales = const [Locale('ru')],
      LocaleController? localeController,
      RecipesManager? manager,
    }) async {
      tester.platformDispatcher.localesTestValue = locales;
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final controller = localeController ?? LocaleController(InMemorySettingsStore());
      await tester.pumpWidget(
        App(manager: manager ?? await createTestManager(), picker: FakePhotoPicker(), localeController: controller),
      );
      await tester.pump();
      return controller;
    }

    /// Выбирает в меню языка списка рецептов пункт [label]
    Future<void> selectLanguage(WidgetTester tester, String label) async {
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    testWidgets('отображает список рецептов', (tester) async {
      await pumpApp(tester);

      // Заголовок AppBar является признаком, что стартовый экран собрался целиком
      expect(find.text('Рецепты'), findsOneWidget);

      // Первый рецепт набора виден без прокрутки
      expect(find.text('Лосось в соусе терияки'), findsOneWidget);

      // Точное число видимых карточек зависит от высоты тестового экрана, поэтому проверяется только их наличие
      expect(find.byType(RecipeCard), findsWidgets);
    });

    testWidgets('прокручивает список до последнего рецепта', (tester) async {
      await pumpApp(tester);

      // Проверка, что список скроллится и строит карточки за пределами первого экрана
      final lastRecipe = find.text('Пицца Маргарита домашняя');
      await tester.scrollUntilVisible(lastRecipe, 300);

      expect(lastRecipe, findsOneWidget);
    });

    testWidgets('название приложения берётся из локализации', (tester) async {
      await pumpApp(tester);

      expect(tester.widget<Title>(find.byType(Title)).title, 'Otus.Food');
    });

    testWidgets('на английской платформе интерфейс английский', (tester) async {
      await pumpApp(tester, locales: const [Locale('en', 'US')]);

      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('Рецепты'), findsNothing);
    });

    testWidgets('падает на русский при неподдерживаемом системном языке', (tester) async {
      // Язык в приложении не выбран, поэтому решает платформа, а её немецкий не поддерживается
      final controller = await pumpApp(tester, locales: const [Locale('de', 'DE')]);

      expect(controller.value, isNull);
      expect(find.text('Рецепты'), findsOneWidget);
    });

    testWidgets('переключает язык на английский', (tester) async {
      final store = InMemorySettingsStore();
      await pumpApp(tester, localeController: LocaleController(store));

      await selectLanguage(tester, 'English');

      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('Рецепты'), findsNothing);
      expect(store.languageCode, 'en');
    });

    testWidgets('восстанавливает сохранённый язык', (tester) async {
      await pumpApp(tester, localeController: LocaleController(InMemorySettingsStore(languageCode: 'en')));

      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('Рецепты'), findsNothing);
    });

    testWidgets('выбранный язык важнее языка платформы', (tester) async {
      await pumpApp(
        tester,
        locales: const [Locale('en', 'US')],
        localeController: LocaleController(InMemorySettingsStore(languageCode: 'ru')),
      );

      expect(find.text('Рецепты'), findsOneWidget);
    });

    testWidgets('`Как в системе` возвращает язык платформы', (tester) async {
      final store = InMemorySettingsStore(languageCode: 'en');
      await pumpApp(tester, localeController: LocaleController(store));

      await selectLanguage(tester, 'System default');

      expect(find.text('Рецепты'), findsOneWidget);
      expect(store.languageCode, isNull);
    });

    testWidgets('сохраняет данные менеджера при смене языка', (tester) async {
      final handle = tester.ensureSemantics();
      final manager = await createTestManager();
      final recipeId = manager.recipes.first.id;
      await pumpApp(tester, manager: manager);

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FavoriteButton));
      await tester.pump();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await selectLanguage(tester, 'English');

      expect(manager.isFavorite(recipeId), isTrue);

      // Страница рецепта строится заново уже на английском и берёт состояние избранного из того же менеджера
      await tester.tap(find.byType(RecipeCard).first);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('In favorites'), findsOneWidget);

      handle.dispose();
    });
  });
}
