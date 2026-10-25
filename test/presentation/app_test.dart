import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/presentation/app.dart';
import 'package:recipes/presentation/widgets/recipe_card.dart';

import '../helpers.dart';

void main() {
  group('App', () {
    testWidgets('отображает список рецептов', (tester) async {
      await tester.pumpWidget(App(manager: await createTestManager()));
      await tester.pump();

      // Заголовок AppBar является признаком, что стартовый экран собрался целиком
      expect(find.text('Рецепты'), findsOneWidget);

      // Первый рецепт набора виден без прокрутки
      expect(find.text('Лосось в соусе терияки'), findsOneWidget);

      // Точное число видимых карточек зависит от высоты тестового экрана, поэтому проверяется только их наличие
      expect(find.byType(RecipeCard), findsWidgets);
    });

    testWidgets('прокручивает список до последнего рецепта', (tester) async {
      await tester.pumpWidget(App(manager: await createTestManager()));
      await tester.pump();

      // Проверка, что список скроллится и строит карточки за пределами первого экрана
      final lastRecipe = find.text('Пицца Маргарита домашняя');
      await tester.scrollUntilVisible(lastRecipe, 300);

      expect(lastRecipe, findsOneWidget);
    });
  });
}
