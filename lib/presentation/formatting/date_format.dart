/// Форматирует дату как `дд.мм.гггг`
///
/// ```dart
/// formatDate(DateTime(2022, 5, 25)); // '25.05.2022'
/// formatDate(DateTime(2022, 12, 7)); // '07.12.2022'
/// ```
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString().padLeft(4, '0');
  return '$day.$month.$year';
}
