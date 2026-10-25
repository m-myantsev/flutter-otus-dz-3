import 'dart:typed_data';

import 'package:flutter_litert/flutter_litert.dart';

import '../../domain/entities/detected_object.dart';
import '../../domain/exceptions/object_detection_exception.dart';
import 'detection_model.dart';
import 'model_input.dart';
import 'model_output.dart';

/// Прогоняет модель на одном фото
///
/// Работает в изоляте, поэтому получает адрес интерпретатора и метки вместо самого детектора
///
/// Бросает [ObjectDetectionException], если фото не декодируется
List<DetectedObject> runModel(int interpreterAddress, List<String> labels, Uint8List jpeg) {
  final input = prepareModelInput(jpeg);
  if (input == null) throw const ObjectDetectionException('Photo cannot be decoded');

  final interpreter = Interpreter.fromAddress(interpreterAddress, allocated: true);

  const n = DetectionModel.maxDetections;
  final boxes = List.filled(n * 4, 0.0).reshape([1, n, 4]);
  final classes = List.filled(n, 0.0).reshape([1, n]);
  final scores = List.filled(n, 0.0).reshape([1, n]);
  final count = List.filled(1, 0.0);

  // Пакет принимает плоский `Uint8List` как есть, а `reshape` строит на каждый кадр сотни тысяч вложенных списков
  interpreter.runForMultipleInputs([input], {0: boxes, 1: classes, 2: scores, 3: count});

  return parseModelOutput(
    boxes: (boxes[0] as List).map((row) => (row as List).cast<double>().toList()).toList(),
    classes: (classes[0] as List).cast<double>(),
    scores: (scores[0] as List).cast<double>(),
    count: count[0].round(),
    labels: labels,
  );
}
