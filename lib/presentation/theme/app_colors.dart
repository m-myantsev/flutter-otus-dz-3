import 'package:flutter/material.dart';

/// Цветовая схема приложения
abstract final class AppColors {
  static const Color primary = Color(0xFF165932);
  static const Color accent = Color(0xFF2ECC71);
  static const Color background = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF000000);
  static const Color shadow = Color(0x1A000000);

  /// Фон полей ввода
  static const Color field = Color(0xFFECECEC);

  /// Неактивная кнопка сохранения, рамки и подписи карточек формы
  static const Color muted = Color(0xFF797676);

  /// Плейсхолдеры в полях ввода
  static const Color placeholder = Color(0xFFC2C2C2);

  /// Активная кнопка избранного
  static const Color likeActive = Color(0xFFE74C3C);

  /// Неактивная кнопка избранного
  static const Color likeInactive = Color(0xB3000000);

  /// Фон отмеченного шага приготовления
  static const Color stepActiveBackground = Color(0x262ECC71);

  /// Текст отмеченного шага приготовления
  static const Color stepActiveText = Color(0xFF2D490C);

  /// Разрушающее действие, например удаление фото
  static const Color danger = Color(0xFFF54848);
}
