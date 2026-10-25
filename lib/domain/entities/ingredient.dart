import 'measure_unit.dart';

/// Ингредиент из каталога
class Ingredient {
  const Ingredient({required this.id, required this.name, required this.measureUnit});

  /// Уникальный идентификатор ингредиента
  final int id;

  /// Название ингредиента
  final String name;

  /// Единица, в которой измеряется количество ингредиента
  final MeasureUnit measureUnit;

  /// Ингредиенты равны при совпадении идентификатора
  @override
  bool operator ==(Object other) => other is Ingredient && other.id == id;

  /// Согласован с [operator ==] и совпадает при равном идентификаторе
  @override
  int get hashCode => id.hashCode;
}
