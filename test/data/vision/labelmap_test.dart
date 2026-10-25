import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/data/vision/detection_model.dart';
import 'package:recipes/data/vision/label_map.dart';
import 'package:recipes/data/vision/model_output.dart';

/// Читает настоящий `labelmap.txt` с диска и разбирает тем же [parseLabelMap], что и `TfliteObjectDetector`
List<String> readLabels() => parseLabelMap(File(DetectionModel.labelsAsset).readAsStringSync());

void main() {
  // Сдвиг строк или CRLF в файле молча портят все подписи на фото, поэтому структура файла зафиксирована
  group('labelmap.txt', () {
    test('91 строка без \\r, первая ???, person на 1, toothbrush последняя, всего 11 заглушек', () {
      final labels = readLabels();

      expect(labels, hasLength(91));
      expect(labels.where((label) => label.contains('\r')), isEmpty);
      expect(labels.first, DetectionModel.unknownLabel);
      expect(labels[1], 'person');
      expect(labels.last, 'toothbrush');
      expect(labels.where((label) => label == DetectionModel.unknownLabel), hasLength(11));
    });

    test('классы модели с пропусками COCO попадают в свои подписи', () {
      final labels = readLabels();

      // Номера классов EfficientDet-Lite4 идут с пропусками COCO, где 46 это `cup`, 55 это `broccoli`, 56 это `carrot`
      final result = parseModelOutput(
        boxes: List.generate(3, (_) => [0.1, 0.2, 0.5, 0.6]),
        classes: [46, 55, 56],
        scores: [0.9, 0.8, 0.7],
        count: 3,
        labels: labels,
      );

      expect(result.map((o) => o.label), ['cup', 'broccoli', 'carrot']);
    });
  });
}
