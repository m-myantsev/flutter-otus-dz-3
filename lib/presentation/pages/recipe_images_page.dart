import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/l10n/l10n_context.dart';
import '../../domain/entities/recipe_image.dart';
import '../formatting/photo_summary.dart';
import '../state/recipes_manager.dart';
import '../theme/app_colors.dart';

/// Полноэкранный просмотр фото рецепта с перелистыванием, зумом и удалением
///
/// Источник фото задаётся снаружи, поэтому страница показывает и сохранённые фото рецепта, и черновик формы создания
class RecipeImagesPage extends StatefulWidget {
  const RecipeImagesPage({
    super.key,
    required this.listenable,
    required this.images,
    required this.remove,
    this.initialIndex = 0,
  });

  /// Просмотр фото сохранённого рецепта из [manager]
  RecipeImagesPage.ofRecipe({super.key, required RecipesManager manager, required int recipeId, this.initialIndex = 0})
    : listenable = manager,
      images = (() => manager.images(recipeId)),
      remove = ((index) => manager.removeImage(recipeId, index));

  /// Уведомляет об изменении списка [images]
  final Listenable listenable;

  /// Текущие фото в порядке показа
  final List<RecipeImage> Function() images;

  /// Удаляет фото по позиции в [images], ошибка удаления показывается пользователю
  final Future<void> Function(int index) remove;

  /// Позиция фото, открытого первым
  final int initialIndex;

  /// Маршрут на просмотр фото сохранённого рецепта
  static Route<void> route({required RecipesManager manager, required int recipeId, required int initialIndex}) {
    return MaterialPageRoute(
      builder: (_) => RecipeImagesPage.ofRecipe(manager: manager, recipeId: recipeId, initialIndex: initialIndex),
    );
  }

  /// Маршрут на просмотр фото черновика, удаление меняет только [images]
  static Route<void> routeDraft({required ValueNotifier<List<RecipeImage>> images, required int initialIndex}) {
    return MaterialPageRoute(
      builder: (_) => RecipeImagesPage(
        listenable: images,
        images: () => images.value,
        remove: (index) async {
          images.value = [...images.value]..removeAt(index);
        },
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  State<RecipeImagesPage> createState() => _RecipeImagesPageState();
}

class _RecipeImagesPageState extends State<RecipeImagesPage> {
  /// Перелистывание фото
  late final PageController _controller = PageController(initialPage: widget.initialIndex);

  /// Позиция показанного фото
  late int _index = widget.initialIndex;

  /// Идёт удаление, повторное нажатие до перестройки списка удалило бы не то фото
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_handleImagesChange);
  }

  @override
  void dispose() {
    // Повторная отписка после удаления последнего фото безвредна
    widget.listenable.removeListener(_handleImagesChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleImagesChange() => setState(() {});

  /// Удаляет показанное фото после подтверждения и закрывает страницу, если фото не осталось
  Future<void> _delete() async {
    if (!await _confirmDelete() || !mounted) {
      return;
    }

    // Захвачены до ожидания записи, потому что после ухода страницы её контекст уже не годится
    final messenger = ScaffoldMessenger.of(context);
    final failureMessage = context.l10n.imagesPageDeleteFailed;
    final images = widget.images();
    if (images.isEmpty) {
      return;
    }

    final index = _index.clamp(0, images.length - 1);

    // Смотреть больше нечего, возвращаемся к рецепту ещё до записи
    if (images.length == 1) {
      // Без отписки уведомление об удалении перестроило бы страницу в пустую, и анимация ухода показала бы пустое место
      widget.listenable.removeListener(_handleImagesChange);
      Navigator.pop(context);
      await _tryRemove(index, messenger, failureMessage);
      return;
    }

    setState(() => _isDeleting = true);

    try {
      final isRemoved = await _tryRemove(index, messenger, failureMessage);
      if (isRemoved && mounted) {
        // После удаления последнего в списке фото индекс указывал бы за конец
        setState(() => _index = min(_index, widget.images().length - 1));
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  /// Спрашивает подтверждение удаления
  ///
  /// Фото хранятся только на устройстве, поэтому случайно удалённое восстановить неоткуда
  Future<bool> _confirmDelete() async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.imagesPageDeleteTitle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.imagesPageDeleteCancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.imagesPageDeleteConfirm),
          ),
        ],
      ),
    );

    return isConfirmed ?? false;
  }

  /// Удаляет фото по позиции [index] и возвращает, удалось ли
  ///
  /// Об отказе записи сообщает через [messenger] текстом [failureMessage]
  Future<bool> _tryRemove(int index, ScaffoldMessengerState messenger, String failureMessage) async {
    try {
      await widget.remove(index);
      return true;
    } on Exception catch (error) {
      debugPrint('Deleting photo failed. $error');
      messenger.showSnackBar(SnackBar(content: Text(failureMessage)));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images();

    // Страница отписана от источника фото до ухода, пустой список здесь только при внешнем удалении
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    // Индекс поправляется после своего удаления, а зажим страхует от удаления фото в обход этой страницы
    final index = _index.clamp(0, images.length - 1);
    final objects = images[index].objects;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        // Цвет задан на тексте, потому что `titleTextStyle` темы явно красит заголовок и перекрывает `foregroundColor`
        title: Text(
          context.l10n.imagesPageCounter(index + 1, images.length),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.imagesPageDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: _isDeleting ? null : _delete,
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (page) => setState(() => _index = page),
            itemBuilder: (context, page) {
              final image = images[page];
              return Semantics(
                // Ключ по фото сбрасывает зум, когда после удаления на эту позицию встаёт соседнее фото
                key: ObjectKey(image),
                image: true,
                label: photoSummary(context.l10n, image),
                child: InteractiveViewer(
                  // Без нижнего предела фото можно было бы сжать меньше экрана, и вокруг осталась бы пустая рамка
                  minScale: _ViewerStyle.minScale,
                  maxScale: _ViewerStyle.maxScale,
                  child: Image.memory(image.bytes, fit: BoxFit.contain, excludeFromSemantics: true),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                // Метка фото уже перечисляет объекты, без исключения скринридер прочёл бы их дважды
                child: ExcludeSemantics(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: objects.isEmpty
                        ? [_CaptionChip(context.l10n.imagesPageNoObjects)]
                        : [for (final object in objects) _CaptionChip(object.caption)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Подпись поверх фото на полупрозрачной подложке
class _CaptionChip extends StatelessWidget {
  const _CaptionChip(this.text);

  /// Текст подписи
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _ViewerStyle.chipBackground,
        borderRadius: BorderRadius.all(Radius.circular(_ViewerStyle.chipRadius)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: _ViewerStyle.captionSize),
        ),
      ),
    );
  }
}

/// Неизменное оформление просмотра
abstract final class _ViewerStyle {
  /// Наименьший масштаб фото, исходный размер
  static const double minScale = 1.0;

  /// Предельное увеличение фото
  static const double maxScale = 4.0;

  /// Радиус скругления подписей
  static const double chipRadius = 5.0;

  /// Подложка подписей, полупрозрачная, чтобы не закрывать фото целиком
  static const Color chipBackground = Color(0x8A000000);

  /// Размер шрифта подписей
  static const double captionSize = 14.0;
}
