/// Определение объекта не удалось, например нативная библиотека не загрузилась
class ObjectDetectionException implements Exception {
  const ObjectDetectionException(this.message);

  /// Причина ошибки
  final String message;

  @override
  String toString() => 'ObjectDetectionException: $message';
}
