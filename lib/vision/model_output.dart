import 'dart:math';

import '../models/detected_object.dart';
import '../models/detection_box.dart';
import 'detection_model.dart';

/// Превращает сырой выход `TFLite_Detection_PostProcess` в SSD-подобном формате в найденные объекты
List<DetectedObject> parseModelOutput({
  /// Строки `[ymin, xmin, ymax, xmax]` в долях кадра
  required List<List<double>> boxes,

  /// Индексы классов
  required List<double> classes,

  /// Вероятности
  required List<double> scores,

  /// Сколько первых строк валидны
  required int count,

  /// Строки `labelmap`
  required List<String> labels,
}) {
  // `count` приходит из самой модели, поэтому не доверяем ему больше, чем длинам массивов
  final valid = min(count, min(boxes.length, min(classes.length, scores.length)));

  final objects = <DetectedObject>[];
  for (var i = 0; i < valid; i++) {
    final score = scores[i];
    if (score < DetectionModel.minScore) continue;

    // Модель нумерует классы с нуля, а `labelmap` начинается с заглушки `???`
    final labelIndex = classes[i].round() + 1;
    if (labelIndex < 0 || labelIndex >= labels.length) continue;

    final label = labels[labelIndex];
    if (label == DetectionModel.unknownLabel) continue;

    final [ymin, xmin, ymax, xmax] = boxes[i];

    // Рамки у края кадра модель вытягивает за его пределы, а рисовать их надо внутри фото
    objects.add(
      DetectedObject(
        label: label,
        score: score,
        box: DetectionBox(
          left: xmin.clamp(0, 1),
          top: ymin.clamp(0, 1),
          right: xmax.clamp(0, 1),
          bottom: ymax.clamp(0, 1),
        ),
      ),
    );
  }

  objects.sort((a, b) => b.score.compareTo(a.score));
  return objects.take(DetectionModel.maxObjects).toList();
}
