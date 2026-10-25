import '../../core/l10n/app_localizations.dart';
import '../../domain/entities/recipe_image.dart';

/// Сводка найденных на фото [image] объектов для скринридера на языке [l10n]
///
/// Подписи объектов не переводятся, это метки модели, переводится только сообщение о пустом списке
///
/// ```dart
/// photoSummary(ru, image); // 'cup 87%, bowl 65%'
/// photoSummary(en, emptyImage); // 'no objects found'
/// ```
String photoSummary(AppLocalizations l10n, RecipeImage image) {
  final objects = image.objects;
  return objects.isEmpty ? l10n.photoObjectsNone : objects.map((o) => o.caption).join(', ');
}
