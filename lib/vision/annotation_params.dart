/// Параметры разметки фото
abstract final class AnnotationParams {
  /// Качество JPEG после разметки
  static const quality = 85;

  /// Минимальная толщина рамки в пикселях
  static const minThickness = 2;

  /// Ширина кадра на один пиксель толщины рамки
  static const thicknessDivisor = 300;

  /// Ширина кадра, начиная с которой подпись крупнее
  static const largeFontWidth = 800;

  /// Отступ текста от края плашки
  static const platePadding = 4;

  /// Причина ошибки для нечитаемого фото
  static const undecodableMessage = 'Фото не декодируется';
}
