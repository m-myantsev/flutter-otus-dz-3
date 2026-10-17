/// Параметры детектора EfficientDet-Lite4
abstract final class DetectionModel {
  /// EfficientDet-Lite4 из TensorFlow Hub, квантована в int8, обучена на COCO
  static const String modelAsset = 'assets/models/efficientdet_lite4.tflite';

  /// Метки классов COCO, первая строка `???`
  static const String labelsAsset = 'assets/models/labelmap.txt';

  /// Сторона квадратного входа модели в пикселях
  static const int inputSize = 640;

  /// Сколько строк проверок выдаёт модель
  static const int maxDetections = 25;

  /// Порог вероятности, ниже которого объект не показывается
  static const double minScore = 0.3;

  /// Сколько объектов сохраняется на одно фото
  static const int maxObjects = 5;

  /// Метка-заглушка для классов, которых нет в COCO
  static const String unknownLabel = '???';
}
