import 'object_detector.dart';
import 'tflite_object_detector.dart';

/// Детектор на TensorFlow Lite для мобильных и десктопных платформ
///
/// Ничего не читает, модель загрузится при первом поиске объектов, а `Future` нужен ради общей сигнатуры с web
Future<ObjectDetector?> loadObjectDetector() => Future.value(TfliteObjectDetector());
