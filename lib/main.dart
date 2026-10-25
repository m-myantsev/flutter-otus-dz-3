import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'data/api/food_api_client.dart';
import 'data/local/hive_recipes_store.dart';
import 'data/local/hive_settings_store.dart';
import 'data/local/hive_storage.dart';
import 'data/photos/image_picker_photo_picker.dart';
import 'data/vision/object_detector_loader_web.dart' if (dart.library.io) 'data/vision/object_detector_loader_io.dart';
import 'presentation/app.dart';
import 'presentation/state/locale_controller.dart';
import 'presentation/state/recipes_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  unawaited(rive.RiveNative.init());

  // Hive инициализируется до открытия хранилищ, потому что они делят один экземпляр и один набор адаптеров
  await initHiveStorage();
  final recipesStore = await HiveRecipesStore.open();
  final settingsStore = await HiveSettingsStore.open();

  final manager = RecipesManager(api: FoodApiClient(), store: recipesStore, detector: await loadObjectDetector());
  unawaited(manager.init());

  // Сохранённый язык читается синхронно до первого кадра, и интерфейс не мигает языком системы
  final localeController = LocaleController(settingsStore);

  runApp(App(manager: manager, picker: ImagePickerPhotoPicker(), localeController: localeController));
}
