import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                  const Text('Шаг рецепта', style: TextStyle(fontSize: 16, color: AppColors.text)),
                  TextFormField(
                    controller: _nameController,
                    minLines: 5,
                    maxLines: 5,
                    validator: validateStepDescription,
                    decoration: const InputDecoration(labelText: 'Описание шага', alignLabelWithHint: true),
                  ),
                  const Text('Длительность шага', style: TextStyle(fontSize: 10, color: AppColors.text)),
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
                              validateStepTimePart(value) ??
                              validateStepDurationTotal(minutes: value, seconds: _secondsController.text),
                          decoration: const InputDecoration(labelText: 'Минуты', hintText: '59'),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _secondsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: validateStepTimePart,
                          decoration: const InputDecoration(labelText: 'Секунды', hintText: '59'),
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
                      child: Text(widget.initial == null ? 'Добавить' : 'Сохранить'),
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
