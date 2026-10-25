import 'package:flutter/material.dart';

import '../../domain/entities/recipe_step.dart';
import '../formatting/duration_format.dart';
import '../theme/app_colors.dart';
import '../theme/recipe_step_colors.dart';

/// Карточка шага приготовления на странице рецепта
class RecipeStepCard extends StatefulWidget {
  const RecipeStepCard({
    super.key,
    required this.number,
    required this.step,
    required this.checked,
    required this.onToggle,
  });

  /// Минимальная высота карточки
  static const double minHeight = 120;

  /// Ширина колонки с номером шага
  static const double numberWidth = 72;

  /// Видимый размер чекбокса
  static const double checkboxSize = 30;

  /// Размер области нажатия на чекбокс
  static const double tapSize = 48;

  /// Длительность перехода между состояниями шага
  static const Duration toggleDuration = Duration(milliseconds: 300);

  /// Насколько область нажатия выступает за края чекбокса с каждой стороны
  static const double _tapInset = (tapSize - checkboxSize) / 2;

  /// Порядковый номер шага, начиная с единицы
  final int number;

  /// Отображаемый шаг
  final RecipeStep step;

  /// Отмечен ли шаг как пройденный
  final bool checked;

  /// Переключает отметку шага
  final VoidCallback onToggle;

  @override
  State<RecipeStepCard> createState() => _RecipeStepCardState();
}

class _RecipeStepCardState extends State<RecipeStepCard> with SingleTickerProviderStateMixin {
  /// Ход перехода шага в отмеченное состояние
  ///
  /// Уже отмеченный шаг рисуется конечным кадром, поэтому при первой сборке анимация не проигрывается
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: RecipeStepCard.toggleDuration,
    value: widget.checked ? 1 : 0,
  );

  /// Заполнение чекбокса и перекраска карточки
  late final CurvedAnimation _fill = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  /// Появление галочки с лёгким перелётом, чтобы отметка ощущалась щелчком
  late final CurvedAnimation _checkScale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeIn,
  );

  @override
  void didUpdateWidget(RecipeStepCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.checked != oldWidget.checked) {
      if (widget.checked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkScale.dispose();
    _fill.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        checked: widget.checked,
        child: GestureDetector(
          onTap: widget.onToggle,
          behavior: HitTestBehavior.opaque,
          // Цвета карточки ведёт тот же контроллер, что и чекбокс, поэтому состояние меняется целиком
          child: AnimatedBuilder(animation: _fill, builder: (context, _) => _buildCard()),
        ),
      ),
    );
  }

  /// Карточка в текущем кадре перехода
  Widget _buildCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RecipeStepColors.background.evaluate(_fill),
        borderRadius: BorderRadius.circular(5),
      ),
      // Высота карточки определяется текстом шага, но не меньше `minHeight`
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: RecipeStepCard.minHeight),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: RecipeStepCard.numberWidth,
                child: Center(
                  child: Text(
                    '${widget.number}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: RecipeStepColors.number.evaluate(_fill),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 17, 20, 17),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.step.name,
                      style: TextStyle(fontSize: 12, height: 1.5, color: RecipeStepColors.description.evaluate(_fill)),
                    ),
                  ),
                ),
              ),
              Padding(
                // Отступы уменьшены на вылет области нажатия, чтобы чекбокс остался на месте
                padding: const EdgeInsets.only(
                  top: 33 - RecipeStepCard._tapInset,
                  right: 22 - RecipeStepCard._tapInset,
                ),
                child: Column(
                  spacing: 14 - RecipeStepCard._tapInset,
                  children: [
                    GestureDetector(
                      onTap: widget.onToggle,
                      behavior: HitTestBehavior.opaque,
                      // Нажатие уже озвучено узлом карточки, второй узел ему не нужен
                      excludeFromSemantics: true,
                      child: SizedBox(
                        width: RecipeStepCard.tapSize,
                        height: RecipeStepCard.tapSize,
                        child: Center(
                          child: _Checkbox(fill: _fill, checkScale: _checkScale),
                        ),
                      ),
                    ),
                    Text(
                      formatDurationSeconds(widget.step.duration),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: RecipeStepColors.duration.evaluate(_fill),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Квадратный чекбокс шага, состоящий из пустой рамки и заливки с галочкой
class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.fill, required this.checkScale});

  /// Скруглённый квадрат чекбокса
  static final BorderRadius _shape = BorderRadius.circular(5);

  /// Ход замены рамки заливкой
  final Animation<double> fill;

  /// Ход появления галочки
  final Animation<double> checkScale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FadeTransition(
          opacity: ReverseAnimation(fill),
          child: Container(
            width: RecipeStepCard.checkboxSize,
            height: RecipeStepCard.checkboxSize,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.muted, width: 4),
              borderRadius: _shape,
            ),
          ),
        ),
        FadeTransition(
          opacity: fill,
          child: Container(
            width: RecipeStepCard.checkboxSize,
            height: RecipeStepCard.checkboxSize,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: _shape),
            child: ScaleTransition(
              scale: checkScale,
              child: const Icon(Icons.check, size: 22, color: AppColors.background),
            ),
          ),
        ),
      ],
    );
  }
}
