import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:recipes/domain/entities/detected_object.dart';
import 'package:recipes/domain/entities/detection_box.dart';
import 'package:recipes/domain/exceptions/object_detection_exception.dart';
import 'package:recipes/presentation/vision/annotate_detections.dart';

import '../../fixtures.dart';

const accent = (46, 204, 113);

bool isNear(img.Pixel p, (int, int, int) rgb) =>
    (p.r - rgb.$1).abs() < 16 && (p.g - rgb.$2).abs() < 16 && (p.b - rgb.$3).abs() < 16;

const cup = DetectedObject(label: 'cup', score: 0.87, box: DetectionBox(left: 0.1, top: 0.2, right: 0.5, bottom: 0.8));

void main() {
  test('без объектов возвращает те же байты, не перекодируя', () async {
    final jpeg = fixtureJpeg();
    expect(identical(await annotateDetections(jpeg, const []), jpeg), isTrue);
  });

  test('рамка рисуется цветом accent по границе объекта, середина остаётся белой', () async {
    final result = img.decodeImage(await annotateDetections(fixtureJpeg(width: 300, height: 200), [cup]))!;
    expect(isNear(result.getPixel(30, 100), accent), isTrue, reason: 'левая граница x = 0.1 * 300');
    // Не угол x = 150, так как при субдискретизации цвета JPEG угловой пиксель смешивается с белыми соседями
    expect(isNear(result.getPixel(90, 160), accent), isTrue, reason: 'нижняя граница y = 0.8 * 200');
    expect(isNear(result.getPixel(90, 100), (255, 255, 255)), isTrue, reason: 'внутри рамки фото не закрашено');
  });

  test('подпись стоит на плашке над рамкой', () async {
    final result = img.decodeImage(await annotateDetections(fixtureJpeg(width: 300, height: 200), [cup]))!;
    expect(isNear(result.getPixel(32, 36), accent), isTrue, reason: 'плашка начинается над верхней границей y = 40');
  });

  test('подпись более вероятного объекта лежит поверх плашки соседа', () async {
    // Рамки рядом на одной высоте, плашка `bowl` с x = 60 накрыла бы хвост плашки `cup` (30..129), рисуйся она позже
    const first = DetectedObject(
      label: 'cup',
      score: 0.9,
      box: DetectionBox(left: 0.1, top: 0.5, right: 0.3, bottom: 0.9),
    );
    const second = DetectedObject(
      label: 'bowl',
      score: 0.6,
      box: DetectionBox(left: 0.2, top: 0.5, right: 0.5, bottom: 0.9),
    );
    final result = img.decodeImage(await annotateDetections(fixtureJpeg(width: 300, height: 200), [first, second]))!;
    expect(isNear(result.getPixel(32, 66), accent), isTrue, reason: 'плашка cup начинается с x = 30, y = 64');
    // Точка (61, 89), и хвост буквы `p` из `cup` в левом отступе плашки `bowl` (x 60..63), при обратном порядке тут был бы её фон
    expect(isNear(result.getPixel(61, 89), (255, 255, 255)), isTrue, reason: 'буква p из cup 90% не закрыта');
  });

  test('рамка за пределами кадра не роняет отрисовку', () async {
    const wide = DetectedObject(label: 'tv', score: 0.5, box: DetectionBox(left: 0, top: 0, right: 1, bottom: 1));
    final result = await annotateDetections(fixtureJpeg(width: 300, height: 200), [wide]);
    expect(img.decodeImage(result)!.width, 300);
  });

  test('кадр с EXIF-поворотом размечается повёрнутым, и рамка ложится на него', () async {
    final source = img.Image(width: 300, height: 200)..exif.imageIfd.orientation = 6;
    img.fill(source, color: img.ColorRgb8(255, 255, 255));
    final jpeg = img.encodeJpg(source);
    // Проверка самого фикстурного JPEG, и без тега тест проверял бы пустоту, а `decodeImage` тег обнуляет, применяя поворот
    expect(img.decodeJpgExif(jpeg)!.imageIfd.orientation, 6, reason: 'encodeJpg должен записать EXIF');

    final result = img.decodeImage(await annotateDetections(jpeg, [cup]))!;
    expect((result.width, result.height), (200, 300));
    expect(result.exif.imageIfd.orientation, anyOf(isNull, 1));
    // Рамка, нарисованная до поворота, ушла бы на x 39..159, y 30..150, и столбец x = 20 остался бы белым
    expect(isNear(result.getPixel(20, 150), accent), isTrue, reason: 'левая граница x = 0.1 * 200 на кадре 200×300');
  });

  test('большое фото размечается и сохраняет размер', () async {
    final result = img.decodeImage(await annotateDetections(fixtureJpeg(width: 1200, height: 800), [cup]))!;
    expect((result.width, result.height), (1200, 800));
  });

  test('испорченный JPEG даёт ObjectDetectionException', () async {
    // Портим таблицы Хаффмана, а не скан, на них стабильно бросает, а мусор в скане может пройти как картинка
    final broken = Uint8List.fromList(fixtureJpeg(width: 300, height: 200))..fillRange(200, 400, 0);
    await expectLater(annotateDetections(broken, [cup]), throwsA(isA<ObjectDetectionException>()));
  });

  test('мусор вместо JPEG даёт ObjectDetectionException', () async {
    await expectLater(
      annotateDetections(Uint8List.fromList([1, 2, 3]), [cup]),
      throwsA(isA<ObjectDetectionException>()),
    );
  });
}
