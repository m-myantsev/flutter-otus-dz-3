import 'package:flutter/material.dart';

/// Переход между страницами затуханием
///
/// Длительность берётся из [PageTransitionsBuilder]
class FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadePageTransitionsBuilder();

  /// Кривая проявления страницы
  static final Animatable<double> _fade = CurveTween(curve: Curves.easeOut);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation.drive(_fade), child: child);
  }
}
