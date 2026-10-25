import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:recipes/data/local/hive_settings_store.dart';

void main() {
  late Directory tempDir;
  late Box<String> box;
  late HiveSettingsStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_settings_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<String>('settings');
    store = HiveSettingsStore(box);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('в пустом боксе язык не выбран', () {
    expect(store.loadLanguageCode(), isNull);
  });

  test('сохранённый код языка читается обратно', () async {
    await store.saveLanguageCode('en');

    expect(store.loadLanguageCode(), 'en');
  });

  test('сохранённый код языка переживает переоткрытие бокса', () async {
    await store.saveLanguageCode('en');
    await Hive.close();

    final reopened = HiveSettingsStore(await Hive.openBox<String>('settings'));
    expect(reopened.loadLanguageCode(), 'en');
  });

  test('сохранение null удаляет ключ из бокса', () async {
    await store.saveLanguageCode('en');

    await store.saveLanguageCode(null);

    expect(store.loadLanguageCode(), isNull);
    // Ключ удаляется, а не перезаписывается пустым значением, чтобы `как в системе` не отличалось от первого запуска
    expect(box.containsKey('languageCode'), isFalse);
  });
}
