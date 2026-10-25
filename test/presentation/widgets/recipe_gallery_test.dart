import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/recipe_image.dart';
import 'package:recipes/presentation/theme/app_colors.dart';
import 'package:recipes/presentation/widgets/recipe_gallery.dart';

import '../../fixtures.dart';
import '../../helpers.dart';

void main() {
  group('RecipeGallery', () {
    /// Выводит галерею на экран в минимальном окружении
    Future<void> pumpGallery(
      WidgetTester tester, {
      List<RecipeImage> images = const [],
      bool isBusy = false,
      VoidCallback? onAdd,
      ValueChanged<int>? onOpen,
    }) => tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: RecipeGallery(images: images, isBusy: isBusy, onAdd: onAdd ?? () {}, onOpen: onOpen ?? (_) {}),
        ),
      ),
    );

    testWidgets('без фото показывает только кнопку добавления с подписью для скринридера', (tester) async {
      await pumpGallery(tester);
      expect(find.byTooltip('Добавить фото'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(tester.getSize(find.byTooltip('Добавить фото')), const Size(100, 100));
    });

    testWidgets('тап по кнопке добавления вызывает onAdd', (tester) async {
      var adds = 0;
      await pumpGallery(tester, onAdd: () => adds++);
      expect(tester.widget<Icon>(find.byIcon(Icons.add_a_photo)).color, AppColors.primary);
      await tester.tap(find.byTooltip('Добавить фото'));
      expect(adds, 1);
    });

    testWidgets('во время анализа показывает индикатор и не принимает новое добавление', (tester) async {
      var adds = 0;
      await pumpGallery(tester, isBusy: true, onAdd: () => adds++);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byTooltip('Добавить фото'));
      expect(adds, 0);
    });

    testWidgets('без onAdd плитка добавления неактивна и без индикатора анализа', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            body: RecipeGallery(images: const [], onAdd: null, onOpen: (_) {}),
          ),
        ),
      );

      final addTile = find.byTooltip('Добавить фото');
      expect(
        tester.getSemantics(find.bySemanticsLabel('Добавить фото')),
        isSemantics(
          label: 'Добавить фото',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      expect(tester.widget<InkWell>(find.descendant(of: addTile, matching: find.byType(InkWell))).onTap, isNull);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.widget<Icon>(find.byIcon(Icons.add_a_photo)).color, AppColors.placeholder);
      await tester.tap(addTile);
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('плитка анализа подписана и объявляется скринридером как живой регион', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpGallery(tester, isBusy: true);

      final node = tester.getSemantics(find.bySemanticsLabel('Анализ фото'));
      expect(node.label, 'Анализ фото');
      expect(node.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('миниатюры подписаны номером и объектами, тап отдаёт индекс', (tester) async {
      final handle = tester.ensureSemantics();
      int? opened;
      await pumpGallery(
        tester,
        images: [
          fixtureImage(),
          RecipeImage(bytes: fixtureJpeg()),
        ],
        onOpen: (i) => opened = i,
      );

      expect(find.byType(Image), findsNWidgets(2));
      expect(find.bySemanticsLabel('Фото 1: cup 87%, bowl 65%'), findsOneWidget);
      expect(find.bySemanticsLabel('Фото 2: объекты не найдены'), findsOneWidget);

      await tester.tap(find.byType(Image).last);
      expect(opened, 1);
      handle.dispose();
    });

    testWidgets('на английском подписи для скринридера переведены', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            body: RecipeGallery(
              images: [
                fixtureImage(),
                RecipeImage(bytes: fixtureJpeg()),
              ],
              isBusy: true,
              onAdd: () {},
              onOpen: (_) {},
            ),
          ),
          locale: const Locale('en'),
        ),
      );

      expect(find.byTooltip('Add photo'), findsOneWidget);
      expect(find.bySemanticsLabel('Add photo'), findsOneWidget);
      expect(find.bySemanticsLabel('Analyzing photo'), findsOneWidget);
      expect(find.bySemanticsLabel('Photo 1: cup 87%, bowl 65%'), findsOneWidget);
      expect(find.bySemanticsLabel('Photo 2: no objects found'), findsOneWidget);
      handle.dispose();
    });
  });
}
