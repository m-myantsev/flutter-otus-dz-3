import 'package:recipes/domain/repositories/object_detector.dart';
import 'package:recipes/presentation/state/recipes_manager.dart';

import 'fakes.dart';
import 'fixtures.dart';

/// Менеджер с уже загруженными данными
Future<RecipesManager> createTestManager({
  FakeFoodApi? api,
  InMemoryRecipesStore? store,
  ObjectDetector? detector,
}) async {
  final manager = RecipesManager(
    api: api ?? FakeFoodApi(data: fixtureData()),
    store: store ?? InMemoryRecipesStore(comments: fixtureComments()),
    detector: detector,
  );
  await manager.init();
  return manager;
}
