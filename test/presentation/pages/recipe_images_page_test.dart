import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/recipe_image.dart';
import 'package:recipes/presentation/pages/recipe_images_page.dart';
import 'package:recipes/presentation/state/recipes_manager.dart';
import 'package:recipes/presentation/theme/app_colors.dart';

import '../../fakes.dart';
import '../../fixtures.dart';
import '../../helpers.dart';

void main() {
  group('RecipeImagesPage', () {
    /// Открывает просмотр поверх пустого экрана, чтобы закрытию было куда возвращаться
    ///
    /// При [failOnSave] хранилище отказывает в записи фото, без [locale] страница строится на русском
    Future<RecipesManager> pumpPage(
      WidgetTester tester, {
      List<RecipeImage>? images,
      int initialIndex = 0,
      bool failOnSave = false,
      Locale locale = const Locale('ru'),
    }) async {
      final manager = await createTestManager(
        store: InMemoryRecipesStore(images: {0: images ?? fixtureImages(2)}, failOnSaveImages: failOnSave),
      );
      await tester.pumpWidget(localizedApp(const Scaffold(), locale: locale));
      final context = tester.element(find.byType(Scaffold));
      unawaited(
        Navigator.push(context, RecipeImagesPage.route(manager: manager, recipeId: 0, initialIndex: initialIndex)),
      );
      await tester.pumpAndSettle();
      return manager;
    }

    /// Подписи первых объектов фото рецепта, по ним фото отличаются друг от друга
    List<String> labels(RecipesManager manager) => [for (final image in manager.images(0)) image.objects.first.label];

    /// Нажимает удаление и подтверждает его в диалоге
    Future<void> deleteShown(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Удалить фото'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Удалить'));
    }

    testWidgets('показывает счётчик, фото и объекты', (tester) async {
      await pumpPage(tester, images: fixtureImages(3), initialIndex: 1);
      expect(find.text('2 из 3'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsWidgets);
      expect(find.text('fork 87%'), findsOneWidget);
      expect(find.text('bowl 65%'), findsOneWidget);
    });

    testWidgets('пролистывание меняет счётчик', (tester) async {
      await pumpPage(tester, images: fixtureImages(3));
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('2 из 3'), findsOneWidget);
    });

    testWidgets('фото без объектов показывает подпись-заглушку', (tester) async {
      await pumpPage(tester, images: [RecipeImage(bytes: fixtureJpeg())]);
      expect(find.text('Объекты не найдены'), findsOneWidget);
    });

    testWidgets('подписи объектов не повторяют для скринридера метку фото', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpPage(tester, images: fixtureImages(1));
      expect(find.bySemanticsLabel('cup 87%, bowl 65%'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('cup 87%')), findsOneWidget, reason: 'объект назван только в метке фото');
      semantics.dispose();
    });

    testWidgets('на английском счётчик, подпись-заглушка и метка фото переведены', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpPage(
        tester,
        images: [
          RecipeImage(bytes: fixtureJpeg()),
          fixtureImage(),
        ],
        locale: const Locale('en'),
      );

      expect(find.text('1 of 2'), findsOneWidget);
      expect(find.text('No objects found'), findsOneWidget);
      expect(find.bySemanticsLabel('no objects found'), findsOneWidget);
      expect(find.byTooltip('Delete photo'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('на английском диалог удаления и сообщение об ошибке переведены', (tester) async {
      await pumpPage(tester, failOnSave: true, locale: const Locale('en'));

      await tester.tap(find.byTooltip('Delete photo'));
      await tester.pumpAndSettle();
      expect(find.text('Delete photo?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't delete photo"), findsOneWidget);
    });

    testWidgets('удаление спрашивает подтверждение, а `Отмена` ничего не удаляет', (tester) async {
      final manager = await pumpPage(tester, images: fixtureImages(3), initialIndex: 1);
      await tester.tap(find.byTooltip('Удалить фото'));
      await tester.pumpAndSettle();

      expect(find.text('Удалить фото?'), findsOneWidget);
      final confirm = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Удалить'));
      expect(confirm.style?.foregroundColor?.resolve({}), AppColors.danger);

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.text('Удалить фото?'), findsNothing);
      expect(labels(manager), ['cup', 'fork', 'knife']);
      expect(find.text('2 из 3'), findsOneWidget);
    });

    testWidgets('удаление убирает именно показанное фото', (tester) async {
      final manager = await pumpPage(tester, images: fixtureImages(3), initialIndex: 1);
      await deleteShown(tester);
      await tester.pumpAndSettle();

      expect(labels(manager), ['cup', 'knife']);
      expect(find.text('2 из 2'), findsOneWidget);
      expect(find.text('knife 87%'), findsOneWidget, reason: 'на место удалённого встало следующее');
    });

    testWidgets('удаление последнего в списке фото держит индекс в границах', (tester) async {
      final manager = await pumpPage(tester, images: fixtureImages(3), initialIndex: 2);
      await deleteShown(tester);
      await tester.pumpAndSettle();

      expect(labels(manager), ['cup', 'fork']);
      expect(find.text('2 из 2'), findsOneWidget);
      expect(find.text('fork 87%'), findsOneWidget);
    });

    testWidgets('отказ записи показывает SnackBar и оставляет фото', (tester) async {
      final manager = await pumpPage(tester, failOnSave: true);
      await deleteShown(tester);
      await tester.pumpAndSettle();

      expect(find.text('Не удалось удалить фото'), findsOneWidget);
      expect(labels(manager), ['cup', 'fork']);
      expect(find.byType(RecipeImagesPage), findsOneWidget);
      expect(find.text('1 из 2'), findsOneWidget);
    });

    testWidgets('удаление единственного фото закрывает страницу, не опустошая её во время ухода', (tester) async {
      final manager = await pumpPage(tester, images: fixtureImages(1));
      await deleteShown(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(manager.images(0), isEmpty);
      expect(find.text('1 из 1'), findsOneWidget, reason: 'уходящая страница показывает фото, а не пустоту');

      await tester.pumpAndSettle();

      expect(find.byType(RecipeImagesPage), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('отказ записи единственного фото показывает SnackBar после закрытия', (tester) async {
      final manager = await pumpPage(tester, images: fixtureImages(1), failOnSave: true);
      await deleteShown(tester);
      await tester.pumpAndSettle();

      expect(find.byType(RecipeImagesPage), findsNothing);
      expect(find.text('Не удалось удалить фото'), findsOneWidget);
      expect(labels(manager), ['cup']);
    });

    testWidgets('закрытая страница отписана от менеджера', (tester) async {
      final manager = await pumpPage(tester);
      // `pageBack` ищет кнопку по английской подсказке `Back`, а в русской локали она называется иначе
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(RecipeImagesPage), findsNothing);

      manager.toggleFavorite(0);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('удаление из черновика убирает фото из его списка', (tester) async {
      final images = ValueNotifier(fixtureImages(3));
      addTearDown(images.dispose);
      await tester.pumpWidget(localizedApp(const Scaffold()));
      final context = tester.element(find.byType(Scaffold));
      unawaited(Navigator.push(context, RecipeImagesPage.routeDraft(images: images, initialIndex: 1)));
      await tester.pumpAndSettle();
      expect(find.text('2 из 3'), findsOneWidget);

      await deleteShown(tester);
      await tester.pumpAndSettle();

      expect([for (final image in images.value) image.objects.first.label], ['cup', 'knife']);
      expect(find.text('2 из 2'), findsOneWidget, reason: 'просмотр перестроился по уведомлению черновика');
    });
  });
}

/// Различимые фото с объектами, первое называется `cup`
List<RecipeImage> fixtureImages(int count) {
  const labels = ['cup', 'fork', 'knife', 'spoon'];
  return [for (final label in labels.take(count)) fixtureImage(label: label)];
}
