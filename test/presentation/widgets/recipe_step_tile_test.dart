import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/recipe_step.dart';
import 'package:recipes/presentation/widgets/recipe_step_tile.dart';

import '../../helpers.dart';

void main() {
  testWidgets('на английском номер шага подписан по-английски', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: RecipeStepTile(
            number: 2,
            step: const RecipeStep(name: 'Boil water', duration: 330),
            onEdit: () {},
            onDelete: () {},
          ),
        ),
        locale: const Locale('en'),
      ),
    );

    expect(find.text('Step 2'), findsOneWidget);
    expect(find.byTooltip('Edit step'), findsOneWidget);
    expect(find.byTooltip('Delete step'), findsOneWidget);
  });
}
