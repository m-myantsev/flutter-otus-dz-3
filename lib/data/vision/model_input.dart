import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'detection_model.dart';

/// RGB-байты фото, уменьшенного до квадрата со стороной `size` без сохранения пропорций
///
/// Возвращает `null`, если фото не декодируется
Uint8List? prepareModelInput(Uint8List jpeg, {int size = DetectionModel.inputSize}) {
  final img.Image? image;

  try {
    image = img.decodeImage(jpeg);
  } on img.ImageException {
    // На испорченных маркерах JPEG декодер бросает вместо `null`, а вызывающему нужен один исход для любого мусора
    return null;
  }

  if (image == null) return null;

  // Растягиваем без полей, тогда рамки в долях кадра ложатся на фото без пересчёта
  final resized = img.copyResize(image, width: size, height: size, interpolation: img.Interpolation.linear);

  // Модель ждёт три байта на пиксель, а у фото с альфа-каналом getBytes без явного порядка отдал бы четыре
  return resized.getBytes(order: img.ChannelOrder.rgb);
}
