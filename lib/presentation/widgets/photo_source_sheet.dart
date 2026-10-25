import 'package:flutter/material.dart';

import '../../core/l10n/l10n_context.dart';
import '../theme/app_colors.dart';

/// Выбор пользователя в нижней панели фото
enum PhotoSourceChoice { camera, album, delete }

/// Показывает нижнюю панель выбора фото и возвращает выбор или `null` при отмене
Future<PhotoSourceChoice?> showPhotoSourceSheet(
  BuildContext context, {
  bool canTakePhoto = true,
  bool canDelete = true,
}) {
  return showModalBottomSheet<PhotoSourceChoice>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(),
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _PhotoSourceSheet(canTakePhoto: canTakePhoto, canDelete: canDelete),
  );
}

/// Нижняя панель с источниками фото и его удалением
class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet({required this.canTakePhoto, required this.canDelete});

  /// Разделитель между пунктами
  static const _divider = Divider(height: 0.5, thickness: 0.5, color: AppColors.placeholder);

  /// Доступна ли камера для съёмки
  final bool canTakePhoto;

  /// Есть ли что удалять
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Без камеры пункт остаётся видимым, но неактивным, чтобы состав панели не прыгал
          _PhotoSourceItem(
            label: l10n.photoSourceCamera,
            onPressed: canTakePhoto ? () => Navigator.pop(context, PhotoSourceChoice.camera) : null,
          ),
          _divider,
          _PhotoSourceItem(
            label: l10n.photoSourceAlbum,
            onPressed: () => Navigator.pop(context, PhotoSourceChoice.album),
          ),
          if (canDelete) ...[
            _divider,
            _PhotoSourceItem(
              label: l10n.photoSourceDelete,
              color: AppColors.danger,
              onPressed: () => Navigator.pop(context, PhotoSourceChoice.delete),
            ),
          ],
          const SizedBox(height: 8),
          Center(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.field,
                foregroundColor: AppColors.text,
                minimumSize: const Size(401, 46),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.photoSourceCancel),
            ),
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }
}

/// Пункт панели выбора фото во всю ширину
class _PhotoSourceItem extends StatelessWidget {
  const _PhotoSourceItem({required this.label, required this.onPressed, this.color = AppColors.text});

  /// Подпись пункта
  final String label;

  /// Действие по нажатию
  ///
  /// `null` делает пункт неактивным
  final VoidCallback? onPressed;

  /// Цвет подписи активного пункта
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    // `InkWell` без `onTap` не сообщает скринридеру ни роль кнопки, ни выключенное состояние
    return Semantics(
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 66,
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 16, color: enabled ? color : AppColors.placeholder)),
          ),
        ),
      ),
    );
  }
}
