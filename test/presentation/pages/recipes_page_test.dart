import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/recipe_ingredient.dart';
import 'package:recipes/domain/entities/recipe_step.dart';
import 'package:recipes/presentation/pages/add_recipe_page.dart';
import 'package:recipes/presentation/pages/recipe_page.dart';
import 'package:recipes/presentation/pages/recipes_page.dart';
import 'package:recipes/presentation/state/locale_controller.dart';
import 'package:recipes/presentation/state/recipes_manager.dart';
import 'package:recipes/presentation/widgets/language_menu_button.dart';
import 'package:recipes/presentation/widgets/recipe_card.dart';

import '../../fakes.dart';
import '../../fixtures.dart';
import '../../helpers.dart';

void main() {
  group('RecipesPage', () {
    testWidgets('показывает рецепт, сохранённый менеджером, без ручного обновления', (tester) async {
      final manager = await createTestManager();
      await tester.pumpWidget(
        localizedApp(
          RecipesPage(
            manager: manager,
            picker: FakePhotoPicker(),
            localeController: LocaleController(InMemorySettingsStore()),
          ),
        ),
      );
      await tester.pump();

      await manager.saveRecipe(
        name: 'Рецепт из теста',
        ingredients: [RecipeIngredient(count: 1, ingredient: manager.ingredients.first)],
        steps: const [RecipeStep(name: 'Смешать', duration: 60)],
      );
      await tester.pump();

      // Новый рецепт попадает в конец списка, и до него нужно доскроллить
      await tester.scrollUntilVisible(find.text('Рецепт из теста'), 300);
      expect(find.text('Рецепт из теста'), findsOneWidget);
    });

    testWidgets('кнопка добавления открывает страницу нового рецепта', (tester) async {
      await tester.pumpWidget(
        localizedApp(
          RecipesPage(
            manager: await createTestManager(),
            picker: FakePhotoPicker(),
            localeController: LocaleController(InMemorySettingsStore()),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddRecipePage), findsOneWidget);
    });

    testWidgets('передаёт picker на страницу рецепта', (tester) async {
      final fakePicker = FakePhotoPicker();
      await tester.pumpWidget(
        localizedApp(
          RecipesPage(
            manager: await createTestManager(),
            picker: fakePicker,
            localeController: LocaleController(InMemorySettingsStore()),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pumpAndSettle();

      expect(tester.widget<RecipePage>(find.byType(RecipePage)).picker, same(fakePicker));
    });

    testWidgets('пока идёт первая загрузка виден индикатор', (tester) async {
      // `init` не вызывается, и менеджер остаётся в состоянии первой загрузки
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: InMemoryRecipesStore(),
      );

      await tester.pumpWidget(
        localizedApp(
          RecipesPage(
            manager: manager,
            picker: FakePhotoPicker(),
            localeController: LocaleController(InMemorySettingsStore()),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('без сети и без сохранённых данных показывается пояснение', (tester) async {
      final manager = await createTestManager(api: FakeFoodApi(offline: true), store: InMemoryRecipesStore());

      await tester.pumpWidget(
        localizedApp(
          RecipesPage(
            manager: manager,
            picker: FakePhotoPicker(),
            localeController: LocaleController(InMemorySettingsStore()),
          ),
        ),
      );

      expect(find.textContaining('Нет рецептов'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('показывает заголовок на английском', (tester) async {
      await tester.pumpWidget(
        localizedApp(
          RecipesPage(
            manager: await createTestManager(),
            picker: FakePhotoPicker(),
            localeController: LocaleController(InMemorySettingsStore()),
          ),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();

      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('Рецепты'), findsNothing);
      expect(find.byTooltip('Add recipe'), findsOneWidget);
    });

    testWidgets('пустой список на английском показывает пояснение', (tester) async {
      final manager = await createTestManager(api: FakeFoodApi(offline: true), store: InMemoryRecipesStore());

      await tester.pumpWidget(
        localizedApp(
          RecipesPage(
            manager: manager,
            picker: FakePhotoPicker(),
            localeController: LocaleController(InMemorySettingsStore()),
          ),
          locale: const Locale('en'),
        ),
      );

      expect(find.text('No recipes. Check your internet connection'), findsOneWidget);
      expect(find.textContaining('Нет рецептов'), findsNothing);
    });

    testWidgets('меню языка в AppBar получает контроллер страницы', (tester) async {
      final controller = LocaleController(InMemorySettingsStore());
      await tester.pumpWidget(
        localizedApp(
          RecipesPage(manager: await createTestManager(), picker: FakePhotoPicker(), localeController: controller),
        ),
      );
      await tester.pump();

      final button = find.descendant(of: find.byType(AppBar), matching: find.byType(LanguageMenuButton));
      expect(tester.widget<LanguageMenuButton>(button).controller, same(controller));
    });
  });
}
