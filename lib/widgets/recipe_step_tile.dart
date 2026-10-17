import 'package:flutter/material.dart';

import '../models/recipe_step.dart';
import '../theme/app_colors.dart';
import '../utils/duration_format.dart';

/// Карточка шага в форме нового рецепта
class RecipeStepTile extends StatelessWidget {
  const RecipeStepTile({
    super.key,
    required this.number,
    required this.step,
    required this.onEdit,
    required this.onDelete,
  });

  /// Порядковый номер шага
  final int number;

  /// Отображаемый шаг
  final RecipeStep step;

  /// Открывает диалог редактирования шага
  ///
  /// `null` выключает кнопку
  final VoidCallback? onEdit;

  /// Удаляет шаг из рецепта
  ///
  /// `null` выключает кнопку
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.muted, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              'Шаг $number',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.text),
            ),
            Text(step.name, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            Row(
              children: [
                Text(
                  formatDurationSeconds(step.duration),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.text),
                ),
                const Spacer(),
                // Цвет иконки задан явно, поэтому выключенная кнопка сама не тускнеет
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, color: onEdit == null ? AppColors.placeholder : AppColors.primary),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: onDelete == null ? AppColors.placeholder : AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
