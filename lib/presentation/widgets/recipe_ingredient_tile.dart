import 'package:flutter/material.dart';

import '../../core/l10n/l10n_context.dart';
import '../../domain/entities/recipe_ingredient.dart';
import '../formatting/count_format.dart';
import '../theme/app_colors.dart';

/// Карточка позиции состава в форме нового рецепта
class RecipeIngredientTile extends StatelessWidget {
  const RecipeIngredientTile({super.key, required this.item, required this.onEdit, required this.onDelete});

  /// Отображаемая позиция состава
  final RecipeIngredient item;

  /// Открывает диалог редактирования позиции
  ///
  /// `null` выключает кнопку
  final VoidCallback? onEdit;

  /// Удаляет позицию из состава
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.ingredient.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text),
                  ),
                  Text(
                    formatCount(item.count, item.ingredient.measureUnit),
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            // Цвет иконки задан явно, поэтому выключенная кнопка сама не тускнеет
            IconButton(
              tooltip: context.l10n.ingredientTileEdit,
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, color: onEdit == null ? AppColors.placeholder : AppColors.primary),
            ),
            IconButton(
              tooltip: context.l10n.ingredientTileDelete,
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: onDelete == null ? AppColors.placeholder : AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
