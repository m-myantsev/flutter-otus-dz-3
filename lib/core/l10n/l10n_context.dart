import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Короткий доступ к строкам интерфейса из контекста виджета
extension L10nContext on BuildContext {
  /// Строки текущей локали
  AppLocalizations get l10n => AppLocalizations.of(this);
}
