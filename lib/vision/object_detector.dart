import 'dart:typed_data';

import '../models/detected_object.dart';
import 'object_detection_exception.dart';

/// Поиск объектов на фото
abstract interface class ObjectDetector {
  /// Объекты по убыванию вероятности, не больше пяти
  ///
  /// Бросает [ObjectDetectionException], если определение объекта невозможно
  Future<List<DetectedObject>> detect(Uint8List jpeg);
}
