import 'dart:ui' show Color;

import 'package:image/image.dart' as img;

/// `Color` в цвет пакета `image`
img.Color toImageColor(Color color) {
  return img.ColorRgb8((color.r * 255).round(), (color.g * 255).round(), (color.b * 255).round());
}
