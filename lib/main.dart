import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'data/api/food_api_client.dart';
import 'data/local/hive_recipes_store.dart';
import 'data/vision/object_detector_loader_web.dart' if (dart.library.io) 'data/vision/object_detector_loader_io.dart';
import 'presentation/app.dart';
import 'presentation/state/recipes_manager.dart';

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
