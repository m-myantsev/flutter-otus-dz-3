import '../../core/utils/plural.dart';
import '../../domain/entities/measure_unit.dart';

/// Дроби по числу четвертей
///
/// Набраны готовыми глифами на случай, если в шрифте нет подстрочных цифр
const _quarterFractions = {1: '¼', 2: '½', 3: '¾'};

/// Дробь для дробной части количества [count] или пустая строка, если количество целое
///
/// Количества кратны четверти единицы
String _fractionOf(double count) => _quarterFractions[((count - count.truncate()) * 4).floor()] ?? '';

/// Собирает число из целой части [whole] и дроби [fraction]
///
/// У дроби без целой части ноль опускается
String _formatNumber(int whole, String fraction) {
  if (fraction.isEmpty) {
    return '$whole';
  }

  return whole == 0 ? fraction : '$whole$fraction';
}

/// Подбирает форму названия единицы [unit] для числа из целой части [whole] и дроби [fraction]
///
/// При дробном числительном существительное стоит в форме [MeasureUnit.few], например, `1½ ст. ложки`, `2¾ ст. ложки`
String _unitForm(int whole, String fraction, MeasureUnit unit) {
  return fraction.isNotEmpty ? unit.few : plural(whole, one: unit.one, few: unit.few, many: unit.many);
}

/// Форматирует количество [count] вместе с единицей измерения [unit] в нужной форме
///
/// Целые количества выводятся без дробной части, а четверти единицы выводятся дробью
///
/// ```dart
/// formatCount(8, tablespoon); // '8 ст. ложек'
/// formatCount(1, tablespoon); // '1 ст. ложка'
/// formatCount(1.5, tablespoon); // '1½ ст. ложки'
/// formatCount(0.5, tablespoon); // '½ ст. ложки'
/// formatCount(0.25, tablespoon); // '¼ ст. ложки'
/// formatCount(2.75, tablespoon); // '2¾ ст. ложки'
/// ```
String formatCount(double count, MeasureUnit unit) {
  final whole = count.truncate();
  final fraction = _fractionOf(count);
  return '${_formatNumber(whole, fraction)} ${_unitForm(whole, fraction, unit)}';
}
