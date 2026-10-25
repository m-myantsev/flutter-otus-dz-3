import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Цвета карточки шага на переходе от снятой отметки к проставленной
abstract final class RecipeStepColors {
  /// Фон карточки
  static final ColorTween background = ColorTween(begin: AppColors.field, end: AppColors.stepActiveBackground);

  /// Номер шага
  static final ColorTween number = ColorTween(begin: AppColors.placeholder, end: AppColors.accent);

  /// Описание шага
  static final ColorTween description = ColorTween(begin: AppColors.muted, end: AppColors.stepActiveText);

  /// Время выполнения шага
  static final ColorTween duration = ColorTween(begin: AppColors.muted, end: AppColors.primary);
}
