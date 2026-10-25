import 'dart:typed_data';

import 'detected_object.dart';

/// Фото, добавленное к рецепту
class RecipeImage {
  const RecipeImage({required this.bytes, this.objects = const []});

  /// JPEG с уже нарисованными рамками и подписями
  final Uint8List bytes;

  /// Найденные объекты, не больше пяти, по убыванию вероятности
  final List<DetectedObject> objects;

  /// Подписи объектов через запятую или сообщение, что ничего не найдено
  String get summary => objects.isEmpty ? 'объекты не найдены' : objects.map((o) => o.caption).join(', ');
}
