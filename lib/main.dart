import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'api/food_api_client.dart';
import 'data/hive_recipes_store.dart';
import 'data/recipes_manager.dart';
import 'screens/recipes_page.dart';
import 'theme/app_theme.dart';
import 'vision/object_detector_loader_web.dart' if (dart.library.io) 'vision/object_detector_loader_io.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  unawaited(rive.RiveNative.init());

  final manager = RecipesManager(
    api: FoodApiClient(),
    store: await HiveRecipesStore.open(),
    detector: await loadObjectDetector(),
  );
  unawaited(manager.init());

  runApp(App(manager: manager));
}

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
