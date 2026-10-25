import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../domain/entities/detected_object.dart';
import '../../domain/exceptions/object_detection_exception.dart';
import '../theme/app_colors.dart';
import 'annotation_params.dart';
import 'image_color.dart';

/// Рисует рамки и подписи объектов
///
/// Без объектов возвращает исходные байты, чтобы не терять качество на перекодировании
Future<Uint8List> annotateDetections(Uint8List jpeg, List<DetectedObject> objects) {
  if (objects.isEmpty) return Future.value(jpeg);

  return compute(annotateDetectionsSync, (jpeg: jpeg, objects: objects));
}

/// Та же работа синхронно, для compute и тестов
///
/// Бросает [ObjectDetectionException], если фото не декодируется
Uint8List annotateDetectionsSync(({Uint8List jpeg, List<DetectedObject> objects}) input) {
  final img.Image? decoded;

  try {
    decoded = img.decodeImage(input.jpeg);
  } on img.ImageException {
    // `guardDecode` пакета `image` заворачивает ошибки разбора в `ImageException`, а менеджер ждёт `ObjectDetectionException`
    throw const ObjectDetectionException(AnnotationParams.undecodableMessage);
  }

  // `null` приходит, когда формат не распознан по сигнатуре или файл обрезан в самом начале
  if (decoded == null) throw const ObjectDetectionException(AnnotationParams.undecodableMessage);

  // Доли рамок посчитаны по кадру в том виде, как его видит пользователь, поэтому рисовать надо на повёрнутом кадре
  final image = img.bakeOrientation(decoded);

  final width = image.width;
  final height = image.height;
  final thickness = max(AnnotationParams.minThickness, width ~/ AnnotationParams.thicknessDivisor);

  // На большом фото мелкий шрифт после уменьшения превью не читается
  final font = width > AnnotationParams.largeFontWidth ? img.arial48 : img.arial24;

  final color = toImageColor(AppColors.accent);
  final white = img.ColorRgb8(255, 255, 255);

  // Модель может вернуть доли чуть за пределами `0..1`, и рисование за краем кадра недопустимо
  int px(double fraction, int size) => (fraction * size).round().clamp(0, size - 1);

  // Сначала все рамки, потом все плашки, иначе рамка позднего объекта перечёркивала бы подпись раннего
  for (final object in input.objects) {
    final box = object.box;
    img.drawRect(
      image,
      x1: px(box.left, width),
      y1: px(box.top, height),
      x2: px(box.right, width),
      y2: px(box.bottom, height),
      color: color,
      thickness: thickness,
    );
  }

  // Объекты идут по убыванию вероятности, и обратный порядок кладёт подпись самого вероятного поверх остальных
  for (final object in input.objects.reversed) {
    final left = px(object.box.left, width);
    final top = px(object.box.top, height);
    final caption = object.caption;
    final textWidth = caption.split('').fold(0, (sum, ch) => sum + font.characterXAdvance(ch));
    final plateWidth = textWidth + 2 * AnnotationParams.platePadding;
    final plateHeight = font.lineHeight + 2 * AnnotationParams.platePadding;

    // Над рамкой подпись не закрывает объект, у верхнего края кадра места нет и плашка уходит внутрь рамки
    final plateTop = top - plateHeight >= 0 ? top - plateHeight : top;

    // У правого края плашка сдвигается влево, чтобы подпись не обрезалась
    final plateLeft = max(0, min(left, width - plateWidth));

    img.fillRect(
      image,
      x1: plateLeft,
      y1: plateTop,
      x2: plateLeft + plateWidth - 1,
      y2: plateTop + plateHeight - 1,
      color: color,
    );
    img.drawString(
      image,
      caption,
      font: font,
      x: plateLeft + AnnotationParams.platePadding,
      y: plateTop + AnnotationParams.platePadding,
      color: white,
    );
  }

  return img.encodeJpg(image, quality: AnnotationParams.quality);
}
