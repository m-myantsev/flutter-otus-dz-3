import 'package:flutter/material.dart';

import 'pages/recipes_page.dart';
import 'state/recipes_manager.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key, required this.manager});

  /// Источник рецептов
  final RecipesManager manager;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otus.Food',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: RecipesPage(manager: manager),
    );
  }
}
