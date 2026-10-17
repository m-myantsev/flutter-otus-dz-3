import 'detection_box.dart';

/// Найденный на фото объект
class DetectedObject {
  const DetectedObject({required this.label, required this.score, required this.box});

  /// Название класса, например `cup`
  final String label;

  /// Вероятность от 0 до 1
  final double score;

  /// Рамка в долях размера изображения
  final DetectionBox box;

  /// Подпись с вероятностью в процентах, например `cup 87%`
  String get caption => '$label ${(score * 100).round()}%';
}
