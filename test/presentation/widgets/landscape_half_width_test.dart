import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/presentation/widgets/landscape_half_width.dart';

void main() {
  group('LandscapeHalfWidth', () {
    /// Ширина, которую получает содержимое на `surface` заданного размера
    Future<double> childWidth(WidgetTester tester, Size surface) async {
      double? width;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox.fromSize(
              size: surface,
              child: LandscapeHalfWidth(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    width = constraints.maxWidth;
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // `builder` уже отработал при построении дерева, поэтому ширина известна
      return width!;
    }

    testWidgets('в альбомной ориентации отдаёт содержимому половину ширины', (tester) async {
      expect(await childWidth(tester, const Size(800, 600)), 400);
    });

    testWidgets('в портретной ориентации отдаёт содержимому всю ширину', (tester) async {
      expect(await childWidth(tester, const Size(300, 500)), 300);
    });

    testWidgets('пересчитывает ширину при смене ориентации', (tester) async {
      expect(await childWidth(tester, const Size(800, 600)), 400);
      expect(await childWidth(tester, const Size(300, 500)), 300);
    });
  });
}
