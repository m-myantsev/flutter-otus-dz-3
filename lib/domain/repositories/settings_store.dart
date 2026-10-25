/// Хранилище пользовательских настроек приложения
abstract interface class SettingsStore {
  /// Код выбранного языка интерфейса
  ///
  /// `null`, если язык не выбирали и интерфейс следует системе
  String? loadLanguageCode();

  /// Сохраняет код языка интерфейса
  ///
  /// `null` возвращает выбор системе
  Future<void> saveLanguageCode(String? code);
}
