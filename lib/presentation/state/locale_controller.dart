import 'package:flutter/widgets.dart';

import '../../core/l10n/app_localizations.dart';
import '../../domain/repositories/settings_store.dart';

/// Выбранный язык интерфейса
///
/// `null` означает язык системы
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController(SettingsStore store) : _store = store, super(_restore(store.loadLanguageCode()));

  final SettingsStore _store;

  /// Переключает язык интерфейса и запоминает выбор
  ///
  /// `null` возвращает язык системы
  Future<void> select(Locale? locale) async {
    value = locale;
    try {
      await _store.saveLanguageCode(locale?.languageCode);
    } on Exception catch (error) {
      // Язык уже переключён, и сбой записи не должен ронять вызов из меню, он только не переживёт перезапуск
      debugPrint('Saving language failed. $error');
    }
  }

  /// Поддерживаемая локаль по сохранённому [code]
  static Locale? _restore(String? code) {
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == code) {
        return locale;
      }
    }

    return null;
  }
}
