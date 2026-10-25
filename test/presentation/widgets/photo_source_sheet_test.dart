import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/presentation/theme/app_colors.dart';
import 'package:recipes/presentation/widgets/photo_source_sheet.dart';

import '../../helpers.dart';

void main() {
  group('showPhotoSourceSheet', () {
    /// Выбор, которым закрылся последний открытый шит
    PhotoSourceChoice? choice;

    /// Открывает нижнюю панель с кнопками в минимальном окружении и запоминает его результат
    Future<void> pumpSheet(
      WidgetTester tester, {
      bool canTakePhoto = true,
      bool canDelete = true,
      Locale locale = const Locale('ru'),
    }) async {
      choice = null;
      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  choice = await showPhotoSourceSheet(context, canTakePhoto: canTakePhoto, canDelete: canDelete);
                },
                child: const Text('фото'),
              ),
            ),
          ),
          locale: locale,
        ),
      );

      await tester.tap(find.text('фото'));
      await tester.pumpAndSettle();
    }

    testWidgets('показывает съёмку, выбор из альбома, удаление и отмену', (tester) async {
      await pumpSheet(tester);

      expect(find.text('Сфотографировать'), findsOneWidget);
      expect(find.text('Выбрать из альбома'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
    });

    testWidgets('на английском пункты и отмена переведены', (tester) async {
      await pumpSheet(tester, locale: const Locale('en'));

      expect(find.text('Take photo'), findsOneWidget);
      expect(find.text('Choose from album'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('тап по отмене закрывает шит', (tester) async {
      await pumpSheet(tester);

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.text('Отмена'), findsNothing);
    });

    testWidgets('пункты закрывают шит и возвращают выбор', (tester) async {
      for (final (label, expected) in [
        ('Сфотографировать', PhotoSourceChoice.camera),
        ('Выбрать из альбома', PhotoSourceChoice.album),
        ('Удалить', PhotoSourceChoice.delete),
      ]) {
        await pumpSheet(tester);
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.text(label), findsNothing);
        expect(choice, expected);
      }
    });

    testWidgets('отмена возвращает null', (tester) async {
      await pumpSheet(tester);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(choice, isNull);
    });

    testWidgets('без возможности удаления пункт и его разделитель не показываются', (tester) async {
      await pumpSheet(tester, canDelete: false);
      expect(find.text('Удалить'), findsNothing);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('без камеры пункт съёмки неактивен и не закрывает шит', (tester) async {
      await pumpSheet(tester, canTakePhoto: false);
      final text = tester.widget<Text>(find.text('Сфотографировать'));
      expect(text.style?.color, AppColors.placeholder);
      await tester.tap(find.text('Сфотографировать'));
      await tester.pumpAndSettle();
      expect(find.text('Сфотографировать'), findsOneWidget);
    });

    testWidgets('неактивный пункт скринридер видит как выключенную кнопку', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpSheet(tester, canTakePhoto: false);

      expect(
        tester.getSemantics(find.text('Сфотографировать')),
        isSemantics(
          label: 'Сфотографировать',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      expect(
        tester.getSemantics(find.text('Выбрать из альбома')),
        isSemantics(
          label: 'Выбрать из альбома',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('на низком экране помещается целиком и отмена остаётся доступной', (tester) async {
      const screen = Size(800, 360);
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpSheet(tester);

      expect(tester.takeException(), isNull, reason: 'содержимое шита не должно переполняться');

      final cancel = tester.getRect(find.byType(FilledButton));
      expect(cancel.top, greaterThanOrEqualTo(0.0));
      expect(cancel.bottom, lessThanOrEqualTo(screen.height), reason: 'кнопка отмены должна быть в границах экрана');
      expect(cancel.left, greaterThanOrEqualTo(0.0));
      expect(cancel.right, lessThanOrEqualTo(screen.width));

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.text('Отмена'), findsNothing, reason: 'тап по отмене должен закрывать шит');
    });

    testWidgets('на экране ниже содержимого шит прокручивается до отмены', (tester) async {
      const screen = Size(600, 200);
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpSheet(tester);

      expect(tester.takeException(), isNull, reason: 'содержимое шита не должно переполняться');

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      final cancel = tester.getRect(find.byType(FilledButton));
      expect(cancel.bottom, lessThanOrEqualTo(screen.height), reason: 'после прокрутки отмена должна быть на экране');

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.text('Отмена'), findsNothing, reason: 'тап по отмене должен закрывать шит');
    });
  });
}
