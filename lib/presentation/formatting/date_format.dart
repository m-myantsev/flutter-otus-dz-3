import 'package:intl/intl.dart';

/// Форматирует дату в коротком числовом виде, принятом в локали [locale]
///
/// ```dart
/// formatDate(DateTime(2022, 5, 25), 'ru'); // '25.05.2022'
/// formatDate(DateTime(2022, 5, 25), 'en'); // '5/25/2022'
/// ```
String formatDate(DateTime date, String locale) => DateFormat.yMd(locale).format(date);
