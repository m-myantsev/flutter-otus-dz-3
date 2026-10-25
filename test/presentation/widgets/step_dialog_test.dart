import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/presentation/widgets/step_dialog.dart';

import '../../helpers.dart';

void main() {
  testWidgets('на английском заголовок, поля и кнопка диалога шага переведены', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(onPressed: () => showStepDialog(context), child: const Text('open')),
          ),
        ),
        locale: const Locale('en'),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Recipe step'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Step description'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Add'), findsOneWidget);
  });

  testWidgets('ошибки под узкими полями минут и секунд переносятся на вторую строку', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(onPressed: () => showStepDialog(context), child: const Text('открыть')),
          ),
        ),
      ),
    );
    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    for (final label in ['Минуты', 'Секунды']) {
      final field = find.descendant(of: find.widgetWithText(TextFormField, label), matching: find.byType(TextField));
      expect(tester.widget<TextField>(field).decoration?.errorMaxLines, 2, reason: label);
    }
  });
}
