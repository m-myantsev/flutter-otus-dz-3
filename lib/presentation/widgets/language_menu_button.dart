import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/l10n/l10n_context.dart';
import '../state/locale_controller.dart';

/// Кнопка меню выбора языка интерфейса
///
/// Отмечает пункт, совпадающий с текущим выбором [controller]
class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key, required this.controller});

  /// Выбранный язык интерфейса
  final LocaleController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Значения пунктов не `Locale?`, потому что `PopupMenuButton` принимает выбор `null` за отмену меню
    return PopupMenuButton<_LanguageOption>(
      icon: const Icon(Icons.language),
      tooltip: l10n.languageMenuTooltip,
      onSelected: (option) => unawaited(controller.select(option.locale)),
      // Пункты строятся при каждом открытии, поэтому отметка всегда соответствует текущему значению контроллера
      itemBuilder: (context) => [
        for (final option in _LanguageOption.values)
          CheckedPopupMenuItem(
            value: option,
            checked: option.matches(controller.value),
            child: Text(option.label(l10n)),
          ),
      ],
    );
  }
}

/// Пункт меню языка
enum _LanguageOption {
  system(null),
  russian(Locale('ru')),
  english(Locale('en'));

  const _LanguageOption(this.locale);

  /// Язык интерфейса
  ///
  /// `null` у языка системы
  final Locale? locale;

  /// Совпадает ли пункт с выбранным языком [current]
  ///
  /// Сравнивается только код языка, чтобы `en_US` отметил английский
  bool matches(Locale? current) => current?.languageCode == locale?.languageCode;

  /// Подпись пункта
  String label(AppLocalizations l10n) => switch (this) {
    _LanguageOption.system => l10n.languageSystem,
    _LanguageOption.russian => l10n.languageRussian,
    _LanguageOption.english => l10n.languageEnglish,
  };
}
