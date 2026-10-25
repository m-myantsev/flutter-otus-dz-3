import 'package:flutter/material.dart';

import '../../domain/entities/comment.dart';
import '../formatting/date_format.dart';
import '../theme/app_colors.dart';
import 'image_placeholder.dart';

/// Комментарий к рецепту, включающий аватар, имя автора, дату, текст и приложенное фото
class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment});

  /// Диаметр круглого аватара
  static const double avatarSize = 63;

  /// Высота фотографии, приложенной к комментарию
  static const double photoHeight = 160;

  /// Отображаемый комментарий
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 18,
      children: [
        ClipOval(
          child: SizedBox(
            width: avatarSize,
            height: avatarSize,
            child: comment.avatar.isEmpty
                ? const ImagePlaceholder(icon: Icons.person)
                : Image.asset(
                    comment.avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ImagePlaceholder(icon: Icons.person),
                  ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      comment.author,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, color: AppColors.accent),
                    ),
                  ),
                  Text(formatDate(comment.date), style: const TextStyle(fontSize: 14, color: AppColors.placeholder)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                comment.text,
                style: const TextStyle(fontSize: 16, height: 19 / 16, color: AppColors.text),
              ),
              if (comment.photo.isNotEmpty) ...[
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: photoHeight,
                  child: Image.asset(
                    comment.photo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ImagePlaceholder(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
