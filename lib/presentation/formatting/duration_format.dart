import '../../core/l10n/app_localizations.dart';

/// Форматирует длительность в минутах на языке [l10n]
///
/// Нулевая часть опускается, кроме нулевой длительности целиком
///
/// ```dart
/// formatDurationMinutes(ru, 45); // '45 минут'
/// formatDurationMinutes(ru, 75); // '1 час 15 минут'
/// formatDurationMinutes(en, 120); // '2 hours'
/// ```
String formatDurationMinutes(AppLocalizations l10n, int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;

  final minutesPart = l10n.durationMinutes(rest);
  if (hours == 0) return minutesPart;

  final hoursPart = l10n.durationHours(hours);
  return rest == 0 ? hoursPart : '$hoursPart $minutesPart';
}

/// Форматирует длительность в секундах как `мм:сс`
///
/// ```dart
/// formatDurationSeconds(330); // '05:30'
/// formatDurationSeconds(59); // '00:59'
/// ```
String formatDurationSeconds(int seconds) {
  final minutesPart = (seconds ~/ 60).toString().padLeft(2, '0');
  final secondsPart = (seconds % 60).toString().padLeft(2, '0');
  return '$minutesPart:$secondsPart';
}
