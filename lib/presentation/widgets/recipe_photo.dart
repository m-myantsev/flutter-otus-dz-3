import 'package:flutter/material.dart';

import 'image_placeholder.dart';

/// Фото рецепта по сети или из ассетов
///
/// Серверные адреса начинаются с `http`, пустые и ошибки загрузки дают заглушку, остальное ассеты
class RecipePhoto extends StatelessWidget {
  const RecipePhoto({super.key, required this.photo, this.fit = BoxFit.cover});

  /// Адрес изображения, являющийся URL или путём к ассету
  final String photo;

  /// Вписывание изображения в отведённое место
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (photo.isEmpty) {
      return const ImagePlaceholder();
    }

    if (photo.startsWith('http')) {
      return Image.network(photo, fit: fit, errorBuilder: (_, _, _) => const ImagePlaceholder());
    }

    return Image.asset(photo, fit: fit, errorBuilder: (_, _, _) => const ImagePlaceholder());
  }
}
