/// Единица измерения ингредиента
class MeasureUnit {
  const MeasureUnit({required this.id, required this.one, required this.few, required this.many});

  /// Уникальный идентификатор единицы
  final int id;

  /// Форма названия для 1 единицы
  final String one;

  /// Форма названия для 2–4 единиц
  final String few;

  /// Форма названия для остального количеств единиц
  final String many;

  /// Единицы равны при совпадении идентификатора
  @override
  bool operator ==(Object other) => other is MeasureUnit && other.id == id;

  /// Согласован с [operator ==] и совпадает при равном идентификаторе
  @override
  int get hashCode => id.hashCode;
}
