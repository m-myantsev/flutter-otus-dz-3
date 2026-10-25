/// Рамка найденного объекта в долях размера изображения
class DetectionBox {
  const DetectionBox({required this.left, required this.top, required this.right, required this.bottom});

  /// Левая граница от 0 до 1
  final double left;

  /// Верхняя граница от 0 до 1
  final double top;

  /// Правая граница от 0 до 1
  final double right;

  /// Нижняя граница от 0 до 1
  final double bottom;

  /// Рамки равны при совпадении всех четырёх границ
  @override
  bool operator ==(Object other) {
    if (other is! DetectionBox) {
      return false;
    }

    return other.left == left && other.top == top && other.right == right && other.bottom == bottom;
  }

  /// Хеш равен при совпадении всех четырёх границ
  @override
  int get hashCode => Object.hash(left, top, right, bottom);
}
