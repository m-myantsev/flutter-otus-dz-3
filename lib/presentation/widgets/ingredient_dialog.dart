import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n_context.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/measure_unit.dart';
import '../../domain/entities/recipe_ingredient.dart';
import '../formatting/validators.dart';
import '../state/recipes_manager.dart';
import '../theme/app_colors.dart';
import 'landscape_half_width.dart';

/// Показывает диалог ввода ингредиента
///
/// Вернёт позицию состава или `null`, если диалог закрыли
Future<RecipeIngredient?> showIngredientDialog(
  BuildContext context, {
  required RecipesManager manager,
  RecipeIngredient? initial,
}) {
  return showDialog<RecipeIngredient>(
    context: context,
    builder: (context) => _IngredientDialog(
      manager: manager,
      initial: initial,
      decimalSeparator: NumberFormat.decimalPattern(
        Localizations.localeOf(context).toLanguageTag(),
      ).symbols.DECIMAL_SEP,
    ),
  );
}

/// Количество для поля ввода
///
/// Целые будут без дробной части, а дробные будут с разделителем [decimalSeparator]
///
/// ```dart
/// _countText(8, ','); // '8'
/// _countText(1.5, ','); // '1,5'
/// _countText(0.75, '.'); // '0.75'
/// _countText(null, ','); // ''
/// ```
String _countText(double? count, String decimalSeparator) {
  if (count == null) {
    return '';
  }

  return count % 1 == 0 ? '${count.toInt()}' : count.toString().replaceAll('.', decimalSeparator);
}

/// Диалог ввода ингредиента
///
/// Название можно выбрать из каталога, и единица измерения возьмётся из него
/// Название можно ввести новое, и тогда появляется выбор единицы, а ингредиент добавится в каталог
class _IngredientDialog extends StatefulWidget {
  const _IngredientDialog({required this.manager, this.initial, required this.decimalSeparator});

  /// Источник каталога ингредиентов и единиц измерения
  final RecipesManager manager;

  /// Исходная позиция состава при редактировании
  final RecipeIngredient? initial;

  /// Разделитель дробной части в языке интерфейса
  ///
  /// Исходное количество показывается так же, как в подсказке валидации, а разбор принимает оба разделителя
  final String decimalSeparator;

  @override
  State<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<_IngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name = widget.initial?.ingredient.name ?? '';
  late final _countController = TextEditingController(text: _countText(widget.initial?.count, widget.decimalSeparator));

  /// Справочник единиц на момент открытия диалога
  ///
  /// Справочник может смениться со встроенного на серверный, пока диалог открыт
  late final List<MeasureUnit> _units = widget.manager.measureUnits;

  /// Единица измерения для нового ингредиента
  MeasureUnit? _newIngredientUnit;

  /// Идёт добавление ингредиента в каталог
  bool _isSaving = false;

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  /// Ингредиент каталога с введённым именем
  Ingredient? get _existing {
    final query = _name.trim().toLowerCase();
    return widget.manager.ingredients.where((i) => i.name.toLowerCase() == query).firstOrNull;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Количество уже проверено, поэтому разбор не вернёт `null`
    final count = parseIngredientCount(_countController.text)!;

    setState(() => _isSaving = true);

    Ingredient ingredient;
    try {
      // Новое имя попадает в каталог только при подтверждении диалога
      ingredient = _existing ?? await widget.manager.addIngredient(_name.trim(), _newIngredientUnit!);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context, RecipeIngredient(count: count, ingredient: ingredient));
  }

  @override
  Widget build(BuildContext context) {
    final existing = _existing;
    final l10n = context.l10n;
    return Dialog(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: LandscapeHalfWidth(
        // Прокрутка спасает от переполнения, когда клавиатура съедает высоту на небольших экранах
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Text(l10n.ingredientDialogTitle, style: const TextStyle(fontSize: 16, color: AppColors.text)),
                  Autocomplete<Ingredient>(
                    initialValue: TextEditingValue(text: _name),
                    displayStringForOption: (ingredient) => ingredient.name,
                    optionsBuilder: (value) {
                      final query = value.text.trim().toLowerCase();
                      if (query.isEmpty) {
                        return const Iterable<Ingredient>.empty();
                      }

                      return widget.manager.ingredients.where((i) => i.name.toLowerCase().contains(query));
                    },
                    onSelected: (ingredient) => setState(() => _name = ingredient.name),
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        validator: (value) => validateIngredientName(context.l10n, value),
                        onChanged: (value) => setState(() => _name = value),
                        decoration: InputDecoration(labelText: l10n.ingredientDialogNameLabel),
                      );
                    },
                  ),
                  // Для нового ингредиента единицу выбирают, у известного она уже есть
                  if (existing == null)
                    DropdownButtonFormField<MeasureUnit>(
                      initialValue: _newIngredientUnit,
                      items: [for (final unit in _units) DropdownMenuItem(value: unit, child: Text(unit.one))],
                      onChanged: (unit) => setState(() => _newIngredientUnit = unit),
                      validator: (unit) => unit == null ? l10n.ingredientDialogUnitRequired : null,
                      decoration: InputDecoration(labelText: l10n.ingredientDialogUnitLabel, errorMaxLines: 2),
                    ),
                  TextFormField(
                    controller: _countController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
                    validator: (value) => validateIngredientCount(context.l10n, value),
                    // Ошибка количества с примерами длиннее строки диалога, в одну строку она обрезалась бы
                    decoration: InputDecoration(
                      labelText: l10n.ingredientDialogCountLabel,
                      suffixText: existing?.measureUnit.many,
                      errorMaxLines: 2,
                    ),
                  ),
                  Center(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(232, 48),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      onPressed: _isSaving ? null : _submit,
                      child: _isSaving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                            )
                          : Text(widget.initial == null ? l10n.ingredientDialogAdd : l10n.ingredientDialogSave),
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
