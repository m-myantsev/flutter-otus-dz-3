import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/presentation/state/locale_controller.dart';

import '../../fakes.dart';

void main() {
  group('LocaleController', () {
    test('берёт сохранённый поддерживаемый язык', () {
      final controller = LocaleController(InMemorySettingsStore(languageCode: 'en'));

      expect(controller.value, const Locale('en'));
    });

    test('без сохранённого языка следует системе', () {
      final controller = LocaleController(InMemorySettingsStore());

      expect(controller.value, isNull);
    });

    test('неподдерживаемый сохранённый язык сбрасывается на системный', () {
      final controller = LocaleController(InMemorySettingsStore(languageCode: 'fr'));

      expect(controller.value, isNull);
    });

    test('пустой сохранённый код сбрасывается на системный', () {
      final controller = LocaleController(InMemorySettingsStore(languageCode: ''));

      expect(controller.value, isNull);
    });

    test('выбор языка уведомляет слушателей и сохраняет код', () async {
      final store = InMemorySettingsStore();
      final controller = LocaleController(store);
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.select(const Locale('ru'));

      expect(controller.value, const Locale('ru'));
      expect(notifications, 1);
      expect(store.languageCode, 'ru');
    });

    test('выбор системного языка стирает сохранённый код', () async {
      final store = InMemorySettingsStore(languageCode: 'en');
      final controller = LocaleController(store);

      await controller.select(null);

      expect(controller.value, isNull);
      expect(store.languageCode, isNull);
    });

    test('сбой записи не мешает переключить язык', () async {
      final store = InMemorySettingsStore(languageCode: 'ru', failOnSave: true);
      final controller = LocaleController(store);

      await controller.select(const Locale('en'));

      expect(controller.value, const Locale('en'));
      expect(store.languageCode, 'ru');
    });
  });
}
