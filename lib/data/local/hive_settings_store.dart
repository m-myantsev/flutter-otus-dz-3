import 'package:hive_ce/hive.dart';

import '../../domain/repositories/settings_store.dart';

/// Настройки приложения на Hive
class HiveSettingsStore implements SettingsStore {
  HiveSettingsStore(this._box);

  /// Хранилище с настройками приложения
  static const _boxName = 'settings';

  /// Ключ кода языка интерфейса
  static const _languageCodeKey = 'languageCode';

  final Box<String> _box;

  /// Открывает хранилище настроек
  ///
  /// Hive к этому моменту уже инициализирован `initHiveStorage`
  static Future<HiveSettingsStore> open() async => HiveSettingsStore(await Hive.openBox<String>(_boxName));

  @override
  String? loadLanguageCode() => _box.get(_languageCodeKey);

  @override
  Future<void> saveLanguageCode(String? code) {
    // Ключ удаляется, а не хранит пустую строку, чтобы `как в системе` ничем не отличалось от первого запуска
    return code == null ? _box.delete(_languageCodeKey) : _box.put(_languageCodeKey, code);
  }
}
