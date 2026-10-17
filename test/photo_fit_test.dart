import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:recipes/data/photo_fit.dart';
import 'package:recipes/data/photo_limits.dart';

void main() {
  final side = PhotoLimits.maxSide.toInt();

  test('большое фото уменьшается до maxSide по большей стороне с сохранением пропорций и становится JPEG', () {
    // PNG на входе, чтобы проверить и смену формата
    final png = img.encodePng(img.Image(width: 3000, height: 1500));

    final result = fitPhotoLimitsSync(png);

    expect(img.findDecoderForData(result), isA<img.JpegDecoder>());
    final decoded = img.decodeImage(result)!;
    expect((decoded.width, decoded.height), (side, side ~/ 2));
  });

  test('вертикальное фото ограничивается по высоте', () {
    final jpeg = img.encodeJpg(img.Image(width: 1000, height: 2000));

    final decoded = img.decodeImage(fitPhotoLimitsSync(jpeg))!;

    expect((decoded.width, decoded.height), (side ~/ 2, side));
  });

  test('фото в пределах ограничений возвращается теми же байтами', () {
    final jpeg = img.encodeJpg(img.Image(width: side, height: 600));
    expect(identical(fitPhotoLimitsSync(jpeg), jpeg), isTrue);
  });

  test('мусор возвращается теми же байтами', () {
    final garbage = Uint8List.fromList([1, 2, 3]);
    expect(identical(fitPhotoLimitsSync(garbage), garbage), isTrue);
  });

  test('асинхронный вариант даёт тот же результат', () async {
    final jpeg = img.encodeJpg(img.Image(width: 2048, height: 1024));
    final decoded = img.decodeImage(await fitPhotoLimits(jpeg))!;
    expect((decoded.width, decoded.height), (side, side ~/ 2));
  });
}
