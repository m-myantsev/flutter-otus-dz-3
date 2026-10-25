import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Нейтральная серая заглушка на месте изображения, которое не загрузилось
class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key, this.icon = Icons.image_not_supported_outlined});

  /// Иконка в центре заглушки
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.field,
      child: Center(child: Icon(icon, color: AppColors.placeholder)),
    );
  }
}
