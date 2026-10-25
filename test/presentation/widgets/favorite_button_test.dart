import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/presentation/theme/app_colors.dart';
import 'package:recipes/presentation/widgets/favorite_button.dart';
import 'package:rive/rive.dart' as rive;

void main() {
  setUpAll(() async => expect(await rive.RiveNative.init(), isTrue));

  group('FavoriteButton', () {
    /// Граница перерисовки вокруг кнопки, с которой снимаются кадры
    final boundaryKey = GlobalKey();

    /// Выводит кнопку на экран в минимальном окружении
    ///
    /// [bundle] позволяет подставить [_PendingAssetBundle], потому что с настоящим `bundle` загрузка завершается до первого кадра
    Future<void> pumpButton(
      WidgetTester tester, {
      required bool isFavorite,
      VoidCallback? onPressed,
      AssetBundle? bundle,
    }) {
      return tester.pumpWidget(
        // Обёртка есть всегда, чтобы форма дерева не зависела от `bundle` и `State` кнопки не пересоздавался между вызовами
        DefaultAssetBundle(
          bundle: bundle ?? rootBundle,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RepaintBoundary(
                key: boundaryKey,
                child: FavoriteButton(isFavorite: isFavorite, onPressed: onPressed ?? () {}),
              ),
            ),
          ),
        ),
      );
    }

    /// Возвращает [HeartPainter] из поддерева кнопки
    HeartPainter painterOf(WidgetTester tester) {
      final customPaint = tester.widget<CustomPaint>(
        find.descendant(of: find.byType(FavoriteButton), matching: find.byType(CustomPaint)),
      );

      return customPaint.painter! as HeartPainter;
    }

    /// Выводит кнопку и ждёт появления [rive.RiveWidget], отдавая время реальному циклу событий через `runAsync`
    ///
    /// Декодирование идёт в нативной библиотеке вне фейкового времени, поэтому опрос ограничен числом попыток, а не часами теста
    Future<void> pumpLoadedButton(WidgetTester tester, {required bool isFavorite}) async {
      const attempts = 250;
      const step = Duration(milliseconds: 20);

      await pumpButton(tester, isFavorite: isFavorite);
      for (var i = 0; i < attempts; i++) {
        if (find.byType(rive.RiveWidget).evaluate().isNotEmpty) return;
        await tester.runAsync(() => Future<void>.delayed(step));
        await tester.pump();
      }

      fail('RiveWidget не появился за $attempts попыток по ${step.inMilliseconds} мс: heart.riv не загрузился');
    }

    /// Во сколько раз снимок крупнее логических пикселей кнопки
    const capturePixelRatio = 2.0;

    /// Снимает кнопку в сырые пиксели RGBA через `runAsync`, потому что растеризация идёт вне фейкового времени
    Future<Uint8List> captureButton(WidgetTester tester) async {
      final pixels = await tester.runAsync(() async {
        final boundary = boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: capturePixelRatio);
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        image.dispose();
        return data!.buffer.asUint8List();
      });

      return pixels!;
    }

    testWidgets('тап по кнопке вызывает переданную функцию', (tester) async {
      var taps = 0;
      await pumpButton(tester, isFavorite: false, onPressed: () => taps++);

      await tester.tap(find.byType(FavoriteButton));

      expect(taps, 1);
    });

    testWidgets('до загрузки файла рисует сердце на canvas', (tester) async {
      final bundle = _PendingAssetBundle();
      await pumpButton(tester, isFavorite: false, bundle: bundle);

      expect(find.descendant(of: find.byType(FavoriteButton), matching: find.byType(CustomPaint)), findsOneWidget);
      expect(painterOf(tester), isA<HeartPainter>());
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('после загрузки файла показывает RiveWidget вместо canvas', (tester) async {
      await pumpLoadedButton(tester, isFavorite: false);

      expect(find.byType(rive.RiveWidget), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is HeartPainter), findsNothing);
      expect(tester.getSize(find.byType(rive.RiveWidget)), const Size(30, 30));
    });

    testWidgets('свойство checked повторяет isFavorite, при частых переключениях побеждает последнее', (tester) async {
      await pumpLoadedButton(tester, isFavorite: false);
      final state = tester.state<FavoriteButtonState>(find.byType(FavoriteButton));
      expect(state.checked!.value, isFalse);

      await pumpButton(tester, isFavorite: true);
      expect(state.checked!.value, isTrue);

      await pumpButton(tester, isFavorite: false);
      await pumpButton(tester, isFavorite: true);
      await pumpButton(tester, isFavorite: false);
      expect(state.checked!.value, isFalse);
    });

    testWidgets('после загрузки с isFavorite сердце уже залито', (tester) async {
      /// Даёт тикеру две секунды, за которые недоигранный `check` или `back` изменил бы кадр
      Future<void> playTwoSeconds() async {
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await pumpLoadedButton(tester, isFavorite: true);
      final loaded = await captureButton(tester);
      expect(loaded.any((byte) => byte != 0), isTrue, reason: 'кадр не должен быть пустым');

      await playTwoSeconds();
      final filled = await captureButton(tester);
      expect(filled, orderedEquals(loaded), reason: 'промотка должна остановить машину в покое');

      // Середина сердца лежит внутри заливки, а вокруг кнопки прозрачный фон
      final side = (FavoriteButton.tapSize * capturePixelRatio).round();
      expect(filled, hasLength(side * side * 4));

      final center = ((side ~/ 2) * side + side ~/ 2) * 4;
      final [r, g, b, a] = filled.sublist(center, center + 4);
      expect(a, 255, reason: 'середина залитого сердца должна быть непрозрачной');
      expect(r == 255 && g == 255 && b == 255, isFalse, reason: 'середина залитого сердца не должна быть белой');

      // Новое дерево, чтобы `State` создался заново и загрузил файл с `!isFavorite`
      await tester.pumpWidget(const SizedBox());
      await pumpLoadedButton(tester, isFavorite: false);
      await playTwoSeconds();
      final empty = await captureButton(tester);

      expect(empty, isNot(orderedEquals(filled)), reason: 'без избранного сердце не должно совпадать с залитым');
    });

    testWidgets('рисует сердце размером 30 в области нажатия размером 48', (tester) async {
      final bundle = _PendingAssetBundle();
      await pumpButton(tester, isFavorite: false, bundle: bundle);

      expect(tester.getSize(find.byType(FavoriteButton)), const Size(48, 48));
      expect(
        tester.getSize(find.descendant(of: find.byType(FavoriteButton), matching: find.byType(CustomPaint))),
        const Size(30, 30),
      );
    });

    testWidgets('для скринридера остаётся кнопкой с меткой и состоянием', (tester) async {
      final handle = tester.ensureSemantics();

      await pumpButton(tester, isFavorite: false);
      expect(
        tester.getSemantics(find.byType(FavoriteButton)),
        matchesSemantics(
          label: 'Добавить в избранное',
          isButton: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      await pumpButton(tester, isFavorite: true);
      expect(
        tester.getSemantics(find.byType(FavoriteButton)),
        matchesSemantics(
          label: 'В избранном',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('цвет зависит от состояния избранного', (tester) async {
      final bundle = _PendingAssetBundle();
      await pumpButton(tester, isFavorite: false, bundle: bundle);
      expect(painterOf(tester).color, AppColors.likeInactive);

      await pumpButton(tester, isFavorite: true, bundle: bundle);
      expect(painterOf(tester).color, AppColors.likeActive);
    });

    testWidgets('перерисовывается при смене состояния', (tester) async {
      final bundle = _PendingAssetBundle();
      await pumpButton(tester, isFavorite: false, bundle: bundle);
      final inactive = painterOf(tester);

      await pumpButton(tester, isFavorite: true, bundle: bundle);
      final active = painterOf(tester);

      expect(active.shouldRepaint(inactive), isTrue);
      expect(active.shouldRepaint(active), isFalse);
    });
  });
}

/// Бандл, чья загрузка никогда не завершается: держит кнопку в состоянии до загрузки Rive-файла
class _PendingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => Completer<ByteData>().future;
}
