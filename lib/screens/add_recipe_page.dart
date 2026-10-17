import 'package:flutter/material.dart';

import '../data/image_picker_photo_picker.dart';
import '../data/photo_picker.dart';
import '../data/photo_source.dart';
import '../data/recipe_images_save_exception.dart';
import '../data/recipes_manager.dart';
import '../models/recipe_image.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/ingredient_dialog.dart';
import '../widgets/landscape_half_width.dart';
import '../widgets/photo_source_sheet.dart';
import '../widgets/recipe_gallery.dart';
import '../widgets/recipe_ingredient_tile.dart';
import '../widgets/recipe_photo.dart';
import '../widgets/recipe_step_tile.dart';
import '../widgets/step_dialog.dart';
import 'recipe_images_page.dart';

/// Страница создания нового рецепта
class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key, required this.manager, this.picker});

  /// Хранилище рецептов
  final RecipesManager manager;

  /// Источник фото рецепта
  ///
  /// По умолчанию системный пикер
  final PhotoPicker? picker;

  /// Маршрут на эту страницу
  static Route<void> route({required RecipesManager manager}) {
    return MaterialPageRoute(builder: (_) => AddRecipePage(manager: manager));
  }

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ingredients = <RecipeIngredient>[];
  final _steps = <RecipeStep>[];

  /// Фото черновика
  ///
  /// У рецепта ещё нет идентификатора, поэтому они живут в форме до сохранения
  final _images = ValueNotifier<List<RecipeImage>>(const []);

  /// Источник новых фото
  ///
  /// Системный пикер создаётся лениво только при отсутствии `widget.picker`
  late final PhotoPicker _picker = widget.picker ?? ImagePickerPhotoPicker();

  /// Идёт сохранение рецепта
  bool _isSaving = false;

  /// Добавляемое фото уже получено от пикера и анализируется менеджером
  bool _isAnalyzing = false;

  /// Для определения активности кнопки сохранения
  ///
  /// Во время анализа сохранение ждёт, иначе анализируемое фото не попало бы в рецепт
  bool get _canSave {
    return !_isSaving &&
        !_isAnalyzing &&
        _nameController.text.trim().isNotEmpty &&
        _ingredients.isNotEmpty &&
        _steps.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _images.dispose();
    super.dispose();
  }

  /// Запрашивает источник, получает фото от пикера и добавляет его к черновику после анализа
  Future<void> _addImage() async {
    // Фото, добавленное после сохранения рецепта, не попало бы в сохранённый список
    if (_isSaving) {
      return;
    }

    // Удалять с плитки добавления нечего, поэтому пункт удаления не показывается
    final choice = await showPhotoSourceSheet(
      context,
      canTakePhoto: _picker.supports(PhotoSource.camera),
      canDelete: false,
    );

    final source = switch (choice) {
      PhotoSourceChoice.camera => PhotoSource.camera,
      PhotoSourceChoice.album => PhotoSource.album,
      PhotoSourceChoice.delete || null => null,
    };

    if (source == null || !mounted) {
      return;
    }

    try {
      final bytes = await _picker.pick(source);
      // Индикатор включается только с готовыми байтами, иначе отмена выбора мигнула бы плиткой анализа
      if (bytes == null || !mounted) {
        return;
      }

      setState(() => _isAnalyzing = true);
      final image = await widget.manager.analyzeImage(bytes);
      // Закрытая за время анализа форма уже освободила черновик, и запись в него упала бы
      if (!mounted) {
        return;
      }

      _images.value = [..._images.value, image];
    } on Exception catch (error) {
      debugPrint('Не удалось добавить фото. $error');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось добавить фото')));
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  /// Открывает фото черновика с позиции [index] на весь экран
  void _openImage(int index) {
    // Форма закрывается через `Navigator.pop`, и открытый поверх неё просмотр закрылся бы вместо формы
    if (_isSaving) {
      return;
    }

    Navigator.push(context, RecipeImagesPage.routeDraft(images: _images, initialIndex: index));
  }

  Future<void> _addIngredient() async {
    final added = await showIngredientDialog(context, manager: widget.manager);
    if (added == null) {
      return;
    }

    setState(() => _ingredients.add(added));
  }

  Future<void> _editIngredient(int index) async {
    final edited = await showIngredientDialog(context, manager: widget.manager, initial: _ingredients[index]);
    if (edited == null) {
      return;
    }

    setState(() => _ingredients[index] = edited);
  }

  Future<void> _addStep() async {
    final added = await showStepDialog(context);
    if (added == null) {
      return;
    }

    setState(() => _steps.add(added));
  }

  Future<void> _editStep(int index) async {
    final edited = await showStepDialog(context, initial: _steps[index]);
    if (edited == null) {
      return;
    }

    setState(() => _steps[index] = edited);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Захвачен до ожидания записи, он принадлежит `MaterialApp` и покажет сообщение уже после закрытия формы
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    try {
      await widget.manager.saveRecipe(
        name: _nameController.text.trim(),
        ingredients: _ingredients,
        steps: _steps,
        images: _images.value,
      );
    } on RecipeImagesSaveException catch (error) {
      // Рецепт уже в списке, повторное сохранение создало бы дубль, поэтому форма закрывается как после успеха
      debugPrint('Рецепт сохранён без фото. $error');
      messenger.showSnackBar(const SnackBar(content: Text('Рецепт сохранён без фото')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Боковой отступ навешивается на элементы точечно, а не на прокрутку, чтобы лента фото шла от края до края
    Widget padded(Widget child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: _FormMetrics.sidePadding),
        child: child,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Новый рецепт',
          style: TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.primary),
        ),
      ),
      body: Center(
        child: LandscapeHalfWidth(
          child: Form(
            key: _formKey,
            // Для обновления цвета кнопки сохранения
            onChanged: () => setState(() {}),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 24,
                children: [
                  padded(
                    TextFormField(
                      controller: _nameController,
                      validator: validateRecipeName,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(labelText: 'Название рецепта'),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // Тот же промежуток между главным фото и лентой, что на странице рецепта
                    spacing: 12,
                    children: [
                      // TODO: Показывать выбранное фото после реализации его загрузки
                      padded(const SizedBox(height: 215, child: RecipePhoto(photo: ''))),
                      // Лента сама держит боковые отступы, чтобы прокручиваемые миниатюры уходили под край экрана
                      ValueListenableBuilder<List<RecipeImage>>(
                        valueListenable: _images,
                        builder: (context, images, _) => RecipeGallery(
                          images: images,
                          isBusy: _isAnalyzing,
                          // Во время сохранения плитка выключена честно, проверка в `_addImage` остаётся страховкой
                          onAdd: _isSaving ? null : _addImage,
                          onOpen: _openImage,
                        ),
                      ),
                    ],
                  ),
                  padded(
                    const Text(
                      'Ингредиенты',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primary),
                    ),
                  ),
                  if (_ingredients.isEmpty)
                    padded(
                      const Center(
                        child: Text('нет ингредиентов', style: TextStyle(fontSize: 12, color: AppColors.text)),
                      ),
                    )
                  else
                    padded(
                      Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (index, item) in _ingredients.indexed)
                            RecipeIngredientTile(
                              item: item,
                              // Во время сохранения состав уже отдан менеджеру, и правка разошлась бы с сохранённым
                              onEdit: _isSaving ? null : () => _editIngredient(index),
                              onDelete: _isSaving ? null : () => setState(() => _ingredients.removeAt(index)),
                            ),
                        ],
                      ),
                    ),
                  padded(
                    Center(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 3),
                          minimumSize: const Size(232, 48),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onPressed: _isSaving ? null : _addIngredient,
                        child: const Text('Добавить ингредиент'),
                      ),
                    ),
                  ),
                  padded(
                    const Text(
                      'Шаги приготовления',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primary),
                    ),
                  ),
                  if (_steps.isEmpty)
                    padded(
                      const Center(
                        child: Text('нет шагов приготовления', style: TextStyle(fontSize: 12, color: AppColors.text)),
                      ),
                    )
                  else
                    padded(
                      Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (index, step) in _steps.indexed)
                            RecipeStepTile(
                              number: index + 1,
                              step: step,
                              onEdit: _isSaving ? null : () => _editStep(index),
                              onDelete: _isSaving ? null : () => setState(() => _steps.removeAt(index)),
                            ),
                        ],
                      ),
                    ),
                  padded(
                    Center(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 3),
                          minimumSize: const Size(232, 48),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onPressed: _isSaving ? null : _addStep,
                        child: const Text('Добавить шаг'),
                      ),
                    ),
                  ),
                  padded(
                    Center(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          disabledBackgroundColor: AppColors.muted,
                          disabledForegroundColor: AppColors.background,
                          minimumSize: const Size(232, 48),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onPressed: _canSave ? _save : null,
                        child: _isSaving
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                              )
                            : const Text('Сохранить рецепт'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Неизменные размеры формы
abstract final class _FormMetrics {
  /// Отступ содержимого формы от краёв экрана
  static const double sidePadding = 16;
}
