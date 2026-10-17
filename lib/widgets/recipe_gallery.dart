import 'package:flutter/material.dart';

import '../models/recipe_image.dart';
import '../theme/app_colors.dart';

/// Горизонтальная лента фото рецепта
class RecipeGallery extends StatelessWidget {
  const RecipeGallery({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onOpen,
    this.isBusy = false,
  });

  /// Сторона квадратной плитки ленты
  static const double tileSize = _GalleryMetrics.tileSize;

  /// Фото рецепта в порядке добавления
  final List<RecipeImage> images;

  /// Запускает добавление нового фото
  ///
  /// `null` выключает плитку добавления
  final VoidCallback? onAdd;

  /// Открывает фото по индексу в [images]
  final ValueChanged<int> onOpen;

  /// Идёт анализ добавленного фото
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final busyTiles = isBusy ? 1 : 0;

    return SizedBox(
      height: _GalleryMetrics.tileSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _GalleryMetrics.sidePadding),
        itemCount: 1 + busyTiles + images.length,
        separatorBuilder: (_, _) => const SizedBox(width: _GalleryMetrics.spacing),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _AddTile(isBusy: isBusy, onAdd: onAdd);
          }

          if (index < 1 + busyTiles) {
            return const _BusyTile();
          }

          final imageIndex = index - 1 - busyTiles;
          return _ImageTile(index: imageIndex, image: images[imageIndex], onOpen: onOpen);
        },
      ),
    );
  }
}

/// Неизменные размеры ленты
abstract final class _GalleryMetrics {
  /// Сторона квадратной плитки
  static const double tileSize = 100;

  /// Промежуток между плитками
  static const double spacing = 8;

  /// Радиус скругления плиток
  static const double radius = 5;

  /// Толщина рамки кнопки добавления
  static const double borderWidth = 3;

  /// Отступ ленты от краёв экрана
  static const double sidePadding = 16;

  /// Ширина декодированной миниатюры
  ///
  /// С запасом на плотность экрана до 3x, чтобы не держать в памяти полноразмерные снимки камеры
  static const int cacheWidth = 300;

  /// Скругление плиток
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(radius));
}

/// Плитка добавления фото
class _AddTile extends StatelessWidget {
  const _AddTile({required this.isBusy, required this.onAdd});

  /// Идёт анализ, новое добавление недоступно
  final bool isBusy;

  /// Запускает добавление фото
  ///
  /// `null` выключает плитку
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    // Подсказка не дублирует метку в дереве семантики, иначе скринридер прочтёт название дважды
    return Tooltip(
      message: 'Добавить фото',
      excludeFromSemantics: true,
      child: Semantics(
        container: true,
        button: true,
        enabled: !isBusy && onAdd != null,
        label: 'Добавить фото',
        child: InkWell(
          // Пока предыдущее фото анализируется, второе добавление запустило бы гонку двух детекций
          onTap: isBusy ? null : onAdd,
          borderRadius: _GalleryMetrics.borderRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.muted, width: _GalleryMetrics.borderWidth),
              borderRadius: _GalleryMetrics.borderRadius,
            ),
            child: SizedBox.square(
              dimension: _GalleryMetrics.tileSize,
              // Цвет иконки задан явно, поэтому выключенная плитка сама не тускнеет, а при анализе рядом и так индикатор
              child: Center(
                child: Icon(Icons.add_a_photo, color: onAdd == null ? AppColors.placeholder : AppColors.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Плитка с индикатором анализа добавляемого фото
class _BusyTile extends StatelessWidget {
  const _BusyTile();

  @override
  Widget build(BuildContext context) {
    // Живой регион объявляет начало анализа сразу, без перевода фокуса скринридера на плитку
    return Semantics(
      container: true,
      liveRegion: true,
      child: const SizedBox.square(
        dimension: _GalleryMetrics.tileSize,
        child: Center(child: CircularProgressIndicator(semanticsLabel: 'Анализ фото')),
      ),
    );
  }
}

/// Миниатюра фото рецепта
class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.index, required this.image, required this.onOpen});

  /// Индекс фото в ленте, начиная с нуля
  final int index;

  /// Показываемое фото
  final RecipeImage image;

  /// Открывает фото по индексу
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: 'Фото ${index + 1}: ${image.summary}',
      child: InkWell(
        onTap: () => onOpen(index),
        borderRadius: _GalleryMetrics.borderRadius,
        child: ClipRRect(
          borderRadius: _GalleryMetrics.borderRadius,
          // Семантика картинки выключена, потому что подпись с объектами уже задана плитке
          child: Image.memory(
            image.bytes,
            width: _GalleryMetrics.tileSize,
            height: _GalleryMetrics.tileSize,
            fit: BoxFit.cover,
            cacheWidth: _GalleryMetrics.cacheWidth,
            excludeFromSemantics: true,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}
