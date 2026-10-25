@Tags(['native'])
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/data/vision/detection_model.dart';
import 'package:recipes/data/vision/tflite_object_detector.dart';
import 'package:recipes/domain/entities/detected_object.dart';
import 'package:recipes/domain/exceptions/object_detection_exception.dart';

import '../../fixtures.dart';

/// Бандл, отдающий настоящие файлы с диска по пути ассета, с подменой отдельных ассетов
class _DiskBundle extends CachingAssetBundle {
  _DiskBundle({this.overrides = const {}});

  /// Содержимое, отдаваемое вместо файла с диска
  final Map<String, Uint8List> overrides;

  /// Сколько раз читалась модель
  int modelLoads = 0;

  @override
  Future<ByteData> load(String key) async {
    if (key == DetectionModel.modelAsset) modelLoads++;
    final bytes = overrides[key] ?? File(key).readAsBytesSync();
    return ByteData.sublistView(bytes);
  }
}

void main() {
  final photo = File('assets/images/comment_0.jpg').readAsBytesSync();
  final labels = File(DetectionModel.labelsAsset).readAsLinesSync().where((line) => line.isNotEmpty).toSet();

  void expectSane(List<DetectedObject> objects) {
    expect(objects.length, lessThanOrEqualTo(DetectionModel.maxObjects));
    for (var i = 1; i < objects.length; i++) {
      expect(objects[i].score, lessThanOrEqualTo(objects[i - 1].score), reason: 'объекты идут по убыванию score');
    }
    for (final object in objects) {
      expect(labels, contains(object.label));
      expect(object.label, isNot(DetectionModel.unknownLabel));
      expect(object.score, inInclusiveRange(DetectionModel.minScore, 1));
      final box = object.box;
      for (final side in [box.left, box.top, box.right, box.bottom]) {
        expect(side, inInclusiveRange(0, 1));
      }
      expect(box.left, lessThanOrEqualTo(box.right));
      expect(box.top, lessThanOrEqualTo(box.bottom));
    }
  }

  test('находит объекты на фото с метками из labelmap и рамками в долях кадра', () async {
    final detector = TfliteObjectDetector(bundle: _DiskBundle());

    final objects = await detector.detect(photo);

    expect(objects, isNotEmpty);
    expectSane(objects);
  });

  test('два вызова подряд проходят через очередь и дают одинаковый результат', () async {
    final bundle = _DiskBundle();
    final detector = TfliteObjectDetector(bundle: bundle);

    final [first, second] = await Future.wait([detector.detect(photo), detector.detect(photo)]);

    expectSane(first);
    expect(second.map((o) => o.label), first.map((o) => o.label));
    expect(bundle.modelLoads, 1, reason: 'модель читается один раз');
  });

  test('мусор вместо модели даёт ObjectDetectionException и на повторный вызов без нового чтения', () async {
    final bundle = _DiskBundle(overrides: {DetectionModel.modelAsset: Uint8List.fromList(List.filled(64, 7))});
    final detector = TfliteObjectDetector(bundle: bundle);

    await expectLater(detector.detect(photo), throwsA(isA<ObjectDetectionException>()));
    await expectLater(detector.detect(photo), throwsA(isA<ObjectDetectionException>()));
    expect(bundle.modelLoads, 1, reason: 'ошибка создания запоминается');
  });

  test('нечитаемый JPEG даёт ObjectDetectionException', () async {
    final detector = TfliteObjectDetector(bundle: _DiskBundle());
    final broken = Uint8List.fromList(fixtureJpeg(width: 300, height: 200))..fillRange(200, 400, 0);

    await expectLater(detector.detect(broken), throwsA(isA<ObjectDetectionException>()));
    await expectLater(detector.detect(Uint8List.fromList([1, 2, 3])), throwsA(isA<ObjectDetectionException>()));

    // Сбой на одном фото не ломает детектор для следующих
    expectSane(await detector.detect(photo));
  });
}
