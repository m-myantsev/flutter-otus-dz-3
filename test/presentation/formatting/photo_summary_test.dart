import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/core/l10n/app_localizations.dart';
import 'package:recipes/domain/entities/recipe_image.dart';
import 'package:recipes/presentation/formatting/photo_summary.dart';

import '../../fixtures.dart';

void main() {
  final ru = lookupAppLocalizations(const Locale('ru'));
  final en = lookupAppLocalizations(const Locale('en'));

  group('photoSummary', () {
    test('перечисляет объекты через запятую', () {
      expect(photoSummary(ru, fixtureImage()), 'cup 87%, bowl 65%');
    });

    test('без объектов сообщает, что ничего не найдено', () {
      expect(photoSummary(ru, RecipeImage(bytes: fixtureJpeg())), 'объекты не найдены');
    });

    test('на английском сообщение о пустом списке переведено', () {
      expect(photoSummary(en, RecipeImage(bytes: fixtureJpeg())), 'no objects found');
    });
  });
}
