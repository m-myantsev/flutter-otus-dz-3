import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'photo_limits.dart';

/// Приводит фото к [PhotoLimits], уменьшая и пережимая его в фоновом изоляте
///
/// Фото в пределах ограничений и нечитаемое пакетом `image`, например HEIC, возвращается теми же байтами
Future<Uint8List> fitPhotoLimits(Uint8List bytes) => compute(fitPhotoLimitsSync, bytes);

/// Та же работа синхронно, для compute и тестов
Uint8List fitPhotoLimitsSync(Uint8List bytes) {
  try {
    final decoder = img.findDecoderForData(bytes);

    // Заголовок отдаёт размеры без декодирования пикселей, и фото в пределах ограничений не разжимается вовсе
    final info = decoder?.startDecode(bytes);
    if (decoder == null || info == null || max(info.width, info.height) <= PhotoLimits.maxSide) return bytes;

    final image = decoder.decode(bytes);
    if (image == null) return bytes;

    // Одна заданная сторона сохраняет пропорции, а EXIF-поворот декодер уже применил
    final side = PhotoLimits.maxSide.toInt();
    final resized = image.width >= image.height
        ? img.copyResize(image, width: side, interpolation: img.Interpolation.linear)
        : img.copyResize(image, height: side, interpolation: img.Interpolation.linear);

    return img.encodeJpg(resized, quality: PhotoLimits.quality);
  } on img.ImageException {
    // Испорченный файл лучше сохранить как есть, чем потерять выбранное пользователем фото
    return bytes;
  }
}
