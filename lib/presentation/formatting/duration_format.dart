import '../../core/utils/plural.dart';

/// Форматирует длительность в минутах по-русски
///
/// ```dart
/// formatDurationMinutes(45); // '45 минут'
/// formatDurationMinutes(32); // '32 минуты'
/// formatDurationMinutes(60); // '1 час'
/// formatDurationMinutes(75); // '1 час 15 минут'
/// formatDurationMinutes(120); // '2 часа'
/// ```
String formatDurationMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;

  final minutesPart = '$rest ${plural(rest, one: 'минута', few: 'минуты', many: 'минут')}';
  if (hours == 0) return minutesPart;

  final hoursPart = '$hours ${plural(hours, one: 'час', few: 'часа', many: 'часов')}';
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
