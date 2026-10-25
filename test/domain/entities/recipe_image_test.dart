import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/detected_object.dart';
import 'package:recipes/domain/entities/detection_box.dart';

void main() {
  test('подпись объекта округляет вероятность до процентов', () {
    const object = DetectedObject(label: 'cup', score: 0.874, box: DetectionBox(left: 0, top: 0, right: 1, bottom: 1));
    expect(object.caption, 'cup 87%');
  });
}
