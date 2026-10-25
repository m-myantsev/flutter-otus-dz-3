import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/recipe_ingredient.dart';
import 'package:recipes/domain/entities/recipe_step.dart';
import 'package:recipes/presentation/pages/add_recipe_page.dart';
import 'package:recipes/presentation/pages/recipes_page.dart';
import 'package:recipes/presentation/state/recipes_manager.dart';

import '../../fakes.dart';
import '../../fixtures.dart';
import '../../helpers.dart';

void main() {
  group('RecipesPage', () {
    testWidgets('показывает рецепт, сохранённый менеджером, без ручного обновления', (tester) async {
      final manager = await createTestManager();
      await tester.pumpWidget(MaterialApp(home: RecipesPage(manager: manager)));
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
      await tester.pumpWidget(MaterialApp(home: RecipesPage(manager: await createTestManager())));
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddRecipePage), findsOneWidget);
    });

    testWidgets('пока идёт первая загрузка виден индикатор', (tester) async {
      // `init` не вызывается, и менеджер остаётся в состоянии первой загрузки
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: InMemoryRecipesStore(),
      );

      await tester.pumpWidget(MaterialApp(home: RecipesPage(manager: manager)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('без сети и без сохранённых данных показывается пояснение', (tester) async {
      final manager = await createTestManager(api: FakeFoodApi(offline: true), store: InMemoryRecipesStore());

      await tester.pumpWidget(MaterialApp(home: RecipesPage(manager: manager)));

      expect(find.textContaining('Нет рецептов'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
