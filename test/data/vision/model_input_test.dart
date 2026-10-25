import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:recipes/data/vision/detection_model.dart';
import 'package:recipes/data/vision/model_input.dart';

import '../../fixtures.dart';

void main() {
  test('фото уменьшается до ${DetectionModel.inputSize}×${DetectionModel.inputSize} без сохранения пропорций', () {
    final input = prepareModelInput(fixtureJpeg(width: 600, height: 200))!;
    expect(input.length, DetectionModel.inputSize * DetectionModel.inputSize * 3);
  });

  test('фото с альфа-каналом отдаётся как RGB без альфы', () {
    // У JPEG альфы не бывает, а PNG с четырьмя каналами без явного порядка дал бы по четыре байта на пиксель
    final png = img.encodePng(img.Image(width: 600, height: 200, numChannels: 4));
    final input = prepareModelInput(png)!;
    expect(input.length, DetectionModel.inputSize * DetectionModel.inputSize * 3);
  });

  test('цвет пикселя сохраняет порядок каналов RGB', () {
    final red = img.Image(width: 4, height: 4);
    img.fill(red, color: img.ColorRgb8(250, 10, 20));
    final input = prepareModelInput(img.encodeJpg(red), size: 2)!;
    expect(input[0], greaterThan(200));
    expect(input[1], lessThan(60));
    expect(input[2], lessThan(60));
  });

  test('мусор вместо JPEG даёт null', () {
    expect(prepareModelInput(Uint8List.fromList([1, 2, 3])), isNull);
  });
}
