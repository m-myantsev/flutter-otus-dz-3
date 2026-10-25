import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import '../../core/l10n/l10n_context.dart';
import '../theme/app_colors.dart';

/// Кнопка избранного
///
/// Сердце анимирует Rive-файл, и до его загрузки рисует [HeartPainter]
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key, required this.isFavorite, required this.onPressed});

  /// Видимый размер сердца
  static const double heartSize = 30;

  /// Размер области нажатия
  static const double tapSize = 48;

  /// Отмечена как избранная
  final bool isFavorite;

  /// Обработчик нажатия
  final VoidCallback onPressed;

  @override
  State<FavoriteButton> createState() => FavoriteButtonState();
}

/// Неизменные параметры Rive-файла с сердцем
abstract final class _HeartRive {
  /// Ассет с анимацией
  static const asset = 'assets/rive/heart.riv';

  /// Артборд с сердцем
  static const artboard = 'like';

  /// State machine, переключающая сердце
  static const stateMachine = 'stateMachine';

  /// Булево свойство view model с состоянием избранного
  static const checkedProperty = 'checked';

  /// Время, на которое машина проматывается сразу после загрузки
  static const settleSeconds = 10.0;

  /// Сколько вызовов `advanceAndApply` нужно до покоя
  ///
  /// Каждый делает не больше одного перехода
  static const settleCalls = 3;
}

/// Состояние [FavoriteButton], загружающее Rive-файл и передающее ему состояние избранного
class FavoriteButtonState extends State<FavoriteButton> {
  rive.File? _file;
  rive.RiveWidgetController? _controller;
  rive.ViewModelInstance? _viewModel;
  rive.ViewModelInstanceBoolean? _checked;
  bool _loadStarted = false;

  /// Переключатель сердца в Rive-файле
  ///
  /// `null` пока файл не загружен
  @visibleForTesting
  rive.ViewModelInstanceBoolean? get checked => _checked;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loadStarted) {
      _loadStarted = true;
      unawaited(_load(DefaultAssetBundle.of(context)));
    }
  }

  Future<void> _load(AssetBundle bundle) async {
    // `false` приходит только на веб, когда не загрузился WASM, и тогда остаётся `HeartPainter`
    if (!await rive.RiveNative.init()) return;

    final file = await rive.File.asset(_HeartRive.asset, riveFactory: rive.Factory.flutter, bundle: bundle);
    if (file == null) {
      throw StateError('Failed to load ${_HeartRive.asset}');
    }

    if (!mounted) {
      file.dispose();
      return;
    }

    final controller = rive.RiveWidgetController(
      file,
      artboardSelector: rive.ArtboardSelector.byName(_HeartRive.artboard),
      stateMachineSelector: rive.StateMachineSelector.byName(_HeartRive.stateMachine),
    );
    final rive.ViewModelInstance viewModel;
    try {
      viewModel = controller.dataBind(rive.DataBind.auto());
    } on rive.RiveDataBindException {
      controller.dispose();
      file.dispose();
      rethrow;
    }

    final checked = viewModel.boolean(_HeartRive.checkedProperty);
    if (checked == null) {
      viewModel.dispose();
      controller.dispose();
      file.dispose();
      throw StateError('View model of ${_HeartRive.asset} has no boolean property ${_HeartRive.checkedProperty}');
    }

    checked.value = widget.isFavorite;

    // Проматываем машину до состояния покоя, иначе при открытии страницы проиграется `check` или `back`
    for (var i = 0; i < _HeartRive.settleCalls; i++) {
      controller.stateMachine.advanceAndApply(_HeartRive.settleSeconds);
    }

    setState(() {
      _file = file;
      _controller = controller;
      _viewModel = viewModel;
      _checked = checked;
    });
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _checked?.value = widget.isFavorite;
    }
  }

  @override
  void dispose() {
    _checked?.dispose();
    _viewModel?.dispose();
    _controller?.dispose();
    _file?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Semantics(
      container: true,
      button: true,
      enabled: true,
      selected: widget.isFavorite,
      label: widget.isFavorite ? context.l10n.favoriteActive : context.l10n.favoriteAdd,
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: FavoriteButton.tapSize,
          height: FavoriteButton.tapSize,
          child: Center(
            child: SizedBox.square(
              dimension: FavoriteButton.heartSize,
              child: controller == null
                  ? CustomPaint(
                      painter: HeartPainter(color: widget.isFavorite ? AppColors.likeActive : AppColors.likeInactive),
                    )
                  // Хит-тест выключен, потому что тап обрабатывает внешний `GestureDetector`
                  : rive.RiveWidget(
                      controller: controller,
                      fit: rive.Fit.contain,
                      hitTestBehavior: rive.RiveHitTestBehavior.none,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Рисует заполненное сердце одним замкнутым путём из кубических кривых Безье
class HeartPainter extends CustomPainter {
  const HeartPainter({required this.color});

  /// Цвет заливки сердца
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      // верхняя выемка между долями
      ..moveTo(w * 0.500, h * 0.232)
      // от выемки к макушке влево
      ..cubicTo(w * 0.461, h * 0.140, w * 0.370, h * 0.080, w * 0.270, h * 0.080)
      // от макушки к левому краю
      ..cubicTo(w * 0.132, h * 0.080, w * 0.020, h * 0.192, w * 0.020, h * 0.330)
      // от левого края к нижнему кончику
      ..cubicTo(w * 0.020, h * 0.460, w * 0.051, h * 0.464, w * 0.500, h * 0.920)
      // от кончика к правому краю
      ..cubicTo(w * 0.949, h * 0.464, w * 0.980, h * 0.460, w * 0.980, h * 0.330)
      // от правого края к макушке
      ..cubicTo(w * 0.980, h * 0.192, w * 0.868, h * 0.080, w * 0.730, h * 0.080)
      // от макушки обратно к выемке
      ..cubicTo(w * 0.630, h * 0.080, w * 0.539, h * 0.140, w * 0.500, h * 0.232)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) => oldDelegate.color != color;
}
