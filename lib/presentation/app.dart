import 'package:flutter/material.dart';

import '../core/l10n/app_localizations.dart';
import '../core/l10n/l10n_context.dart';
import '../domain/repositories/photo_picker.dart';
import 'pages/recipes_page.dart';
import 'state/locale_controller.dart';
import 'state/recipes_manager.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key, required this.manager, required this.picker, required this.localeController});

  /// Источник рецептов
  final RecipesManager manager;

  /// Источник фото рецептов
  final PhotoPicker picker;

  /// Выбранный язык интерфейса
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) => MaterialApp(
        locale: localeController.value,
        onGenerateTitle: (context) => context.l10n.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: RecipesPage(manager: manager, picker: picker, localeController: localeController),
      ),
    );
  }
}
