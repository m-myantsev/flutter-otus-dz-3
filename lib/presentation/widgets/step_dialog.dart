import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/l10n_context.dart';
import '../../domain/entities/recipe_step.dart';
import '../formatting/validators.dart';
import '../theme/app_colors.dart';
import 'landscape_half_width.dart';

/// Показывает диалог ввода шага
///
/// Вернёт шаг или `null`, если диалог закрыли
Future<RecipeStep?> showStepDialog(BuildContext context, {RecipeStep? initial}) {
  return showDialog<RecipeStep>(
    context: context,
    builder: (context) => _StepDialog(initial: initial),
  );
}

/// Диалог ввода шага рецепта
class _StepDialog extends StatefulWidget {
  const _StepDialog({this.initial});

  /// Исходный шаг при редактировании
  final RecipeStep? initial;

  @override
  State<_StepDialog> createState() => _StepDialogState();
}

class _StepDialogState extends State<_StepDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.initial?.name);
  late final _minutesController = TextEditingController(
    text: widget.initial == null ? '' : (widget.initial!.duration ~/ 60).toString(),
  );
  late final _secondsController = TextEditingController(
    text: widget.initial == null ? '' : (widget.initial!.duration % 60).toString(),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final duration = stepDurationSeconds(minutes: _minutesController.text, seconds: _secondsController.text);
    Navigator.pop(context, RecipeStep(name: _nameController.text.trim(), duration: duration));
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(l10n.stepDialogTitle, style: const TextStyle(fontSize: 16, color: AppColors.text)),
                  TextFormField(
                    controller: _nameController,
                    minLines: 5,
                    maxLines: 5,
                    validator: (value) => validateStepDescription(context.l10n, value),
                    decoration: InputDecoration(labelText: l10n.stepDialogDescriptionLabel, alignLabelWithHint: true),
                  ),
                  Text(l10n.stepDialogDurationLabel, style: const TextStyle(fontSize: 10, color: AppColors.text)),
                  Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minutesController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          // Нулевая суммарная длительность у минут в любом случае
                          validator: (value) =>
                              validateStepTimePart(context.l10n, value) ??
                              validateStepDurationTotal(context.l10n, minutes: value, seconds: _secondsController.text),
                          // Поле в половину строки, и длинная ошибка в одну строку обрезалась бы многоточием
                          decoration: InputDecoration(
                            labelText: l10n.stepDialogMinutesLabel,
                            hintText: '59',
                            errorMaxLines: 2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _secondsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) => validateStepTimePart(context.l10n, value),
                          decoration: InputDecoration(
                            labelText: l10n.stepDialogSecondsLabel,
                            hintText: '59',
                            errorMaxLines: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(232, 48),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      onPressed: _submit,
                      child: Text(widget.initial == null ? l10n.stepDialogAdd : l10n.stepDialogSave),
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
