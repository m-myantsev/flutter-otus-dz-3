import '../models/measure_unit.dart';

/// Единицы измерения на случай, пока серверный справочник не загружен
///
/// Без единицы нельзя добавить ингредиент, а без ингредиента нельзя сохранить рецепт.
/// Идентификаторы отрицательные, потому что серверу такие единицы неизвестны, как и локальные ингредиенты и рецепты
abstract final class OfflineMeasureUnits {
  /// Встроенный набор в порядке показа в выпадающем списке
  static const List<MeasureUnit> all = [
    MeasureUnit(id: -1, one: 'грамм', few: 'грамма', many: 'граммов'),
    MeasureUnit(id: -2, one: 'килограмм', few: 'килограмма', many: 'килограммов'),
    MeasureUnit(id: -3, one: 'миллилитр', few: 'миллилитра', many: 'миллилитров'),
    MeasureUnit(id: -4, one: 'литр', few: 'литра', many: 'литров'),
    MeasureUnit(id: -5, one: 'штука', few: 'штуки', many: 'штук'),
    MeasureUnit(id: -6, one: 'ст. ложка', few: 'ст. ложки', many: 'ст. ложек'),
    MeasureUnit(id: -7, one: 'ч. ложка', few: 'ч. ложки', many: 'ч. ложек'),
    MeasureUnit(id: -8, one: 'стакан', few: 'стакана', many: 'стаканов'),
    MeasureUnit(id: -9, one: 'щепотка', few: 'щепотки', many: 'щепоток'),
  ];
}
