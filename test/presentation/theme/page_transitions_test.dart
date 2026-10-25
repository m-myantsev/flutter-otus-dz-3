import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/presentation/theme/app_theme.dart';

void main() {
  group('Переход между страницами', () {
    /// Суммарная непрозрачность [target] с учётом всех затуханий над ним
    double opacityOf(WidgetTester tester, Finder target) {
      final fades = tester.widgetList<FadeTransition>(find.ancestor(of: target, matching: find.byType(FadeTransition)));
      return fades.fold<double>(1, (value, fade) => value * fade.opacity.value);
    }

    /// Выводит приложение с кнопкой, открывающей вторую страницу
    Future<void> pumpApp(WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: Center(child: Text('вторая страница'))),
                    ),
                  ),
                  child: const Text('открыть'),
                ),
              ),
            ),
          ),
        ),
      );
    }

    test('переход по умолчанию одинаков на всех платформах', () {
      final builders = AppTheme.light.pageTransitionsTheme.builders;

      expect(builders.keys, containsAll(TargetPlatform.values));
      expect(builders.values.map((builder) => builder.runtimeType).toSet(), hasLength(1));
    });

    testWidgets('новая страница проявляется на месте за 300 мс', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('открыть'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      final second = find.text('вторая страница');
      final middlePosition = tester.getTopLeft(second);
      expect(opacityOf(tester, second), inExclusiveRange(0.0, 1.0));

      await tester.pump(const Duration(milliseconds: 150));
      expect(opacityOf(tester, second), 1.0);

      // Страница не съезжает, на середине перехода она уже стоит на своём месте
      expect(tester.getTopLeft(second), middlePosition);
    });

    testWidgets('возврат назад затухает', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('открыть'));
      await tester.pumpAndSettle();

      final context = tester.element(find.text('вторая страница'));
      Navigator.pop(context);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(opacityOf(tester, find.text('вторая страница')), inExclusiveRange(0.0, 1.0));
    });
  });
}
