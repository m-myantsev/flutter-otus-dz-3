import 'package:flutter/material.dart';

/// Ограничивает ширину содержимого половиной в альбомной ориентации
///
/// В портретной ориентации отдаёт содержимое без изменений
class LandscapeHalfWidth extends StatelessWidget {
  const LandscapeHalfWidth({super.key, required this.child});

  /// Содержимое с ограниченной шириной
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return child;
        }

        return FractionallySizedBox(widthFactor: 0.5, child: child);
      },
    );
  }
}
