import 'package:flutter/material.dart';
import 'package:recipes/core/l10n/app_localizations.dart';
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

/// Приложение с делегатами локализации вокруг [home] на языке [locale]
///
/// Локаль задаётся явно, потому что тестовая платформа сообщает `en_US` и без неё строки ушли бы на английский
Widget localizedApp(Widget home, {Locale locale = const Locale('ru'), ThemeData? theme}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    theme: theme,
    home: home,
  );
}
