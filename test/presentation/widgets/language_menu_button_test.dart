import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/presentation/state/locale_controller.dart';
import 'package:recipes/presentation/widgets/language_menu_button.dart';

import '../../fakes.dart';
import '../../helpers.dart';

void main() {
  group('LanguageMenuButton', () {
    /// Выводит кнопку в AppBar и открывает меню
    Future<void> openMenu(
      WidgetTester tester,
      LocaleController controller, {
      Locale locale = const Locale('ru'),
    }) async {
      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            appBar: AppBar(actions: [LanguageMenuButton(controller: controller)]),
          ),
          locale: locale,
        ),
      );
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
    }

    /// Отмечен ли пункт меню с текстом [label]
    bool isChecked(WidgetTester tester, String label) {
      final item = find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((w) => w is CheckedPopupMenuItem),
      );
      return tester.widget<CheckedPopupMenuItem<Object?>>(item).checked;
    }

    testWidgets('показывает три языка и отмечает системный по умолчанию', (tester) async {
      await openMenu(tester, LocaleController(InMemorySettingsStore()));

      expect(find.byWidgetPredicate((w) => w is CheckedPopupMenuItem), findsNWidgets(3));
      expect(isChecked(tester, 'Как в системе'), isTrue);
      expect(isChecked(tester, 'Русский'), isFalse);
      expect(isChecked(tester, 'English'), isFalse);
    });

    testWidgets('отмечает выбранный язык', (tester) async {
      await openMenu(tester, LocaleController(InMemorySettingsStore(languageCode: 'en')));

      expect(isChecked(tester, 'Как в системе'), isFalse);
      expect(isChecked(tester, 'Русский'), isFalse);
      expect(isChecked(tester, 'English'), isTrue);
    });

    testWidgets('выбор English переключает контроллер', (tester) async {
      final controller = LocaleController(InMemorySettingsStore());
      await openMenu(tester, controller);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(controller.value, const Locale('en'));
    });

    testWidgets('выбор `Как в системе` после English сбрасывает язык', (tester) async {
      final controller = LocaleController(InMemorySettingsStore(languageCode: 'en'));
      await openMenu(tester, controller);

      await tester.tap(find.text('Как в системе'));
      await tester.pumpAndSettle();

      expect(controller.value, isNull);
    });

    testWidgets('закрытие меню без выбора не меняет язык', (tester) async {
      final controller = LocaleController(InMemorySettingsStore(languageCode: 'en'));
      await openMenu(tester, controller);

      // Тап мимо меню закрывает его так же, как системная кнопка `Назад`
      await tester.tapAt(const Offset(10, 300));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsNothing);
      expect(controller.value, const Locale('en'));
    });

    testWidgets('подсказка и системный пункт на английском', (tester) async {
      await openMenu(tester, LocaleController(InMemorySettingsStore()), locale: const Locale('en'));

      expect(find.byTooltip('Language'), findsOneWidget);
      expect(find.text('System default'), findsOneWidget);
      expect(find.text('Русский'), findsOneWidget);
    });

    testWidgets('подсказка на русском', (tester) async {
      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            appBar: AppBar(actions: [LanguageMenuButton(controller: LocaleController(InMemorySettingsStore()))]),
          ),
        ),
      );

      expect(find.byTooltip('Язык'), findsOneWidget);
    });
  });
}
