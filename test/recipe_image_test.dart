import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/models/detected_object.dart';
import 'package:recipes/models/detection_box.dart';
import 'package:recipes/models/recipe_image.dart';

import 'fixtures.dart';

void main() {
  test('подпись объекта округляет вероятность до процентов', () {
    const object = DetectedObject(label: 'cup', score: 0.874, box: DetectionBox(left: 0, top: 0, right: 1, bottom: 1));
    expect(object.caption, 'cup 87%');
  });

  test('сводка перечисляет объекты через запятую, без объектов сообщает об этом', () {
    expect(fixtureImage().summary, 'cup 87%, bowl 65%');
    expect(RecipeImage(bytes: fixtureJpeg()).summary, 'объекты не найдены');
  });
}
