import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/recipe_ingredient.dart';
import 'package:recipes/presentation/widgets/recipe_ingredient_tile.dart';

import '../../fixtures.dart';
import '../../helpers.dart';

void main() {
  testWidgets('на английском кнопки правки и удаления подписаны для скринридера', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: RecipeIngredientTile(
            item: const RecipeIngredient(count: 2, ingredient: honey),
            onEdit: () {},
            onDelete: () {},
          ),
        ),
        locale: const Locale('en'),
      ),
    );

    expect(find.byTooltip('Edit ingredient'), findsOneWidget);
    expect(find.byTooltip('Delete ingredient'), findsOneWidget);
  });
}
