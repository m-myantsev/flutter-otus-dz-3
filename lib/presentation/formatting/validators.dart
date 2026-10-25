import '../../core/l10n/app_localizations.dart';

/// Пустое ли значение после обрезки пробелов
bool _isBlank(String? value) => value == null || value.trim().isEmpty;

/// Сообщение об ошибке, если значение пустое после обрезки пробелов, иначе `null`
String? _requireNonBlank(String? value, String message) => _isBlank(value) ? message : null;

/// Проверяет, что название рецепта является непустым после обрезки пробелов
String? validateRecipeName(AppLocalizations l10n, String? value) {
  return _requireNonBlank(value, l10n.validationRecipeNameRequired);
}

/// Проверяет, что название ингредиента является непустым после обрезки пробелов
String? validateIngredientName(AppLocalizations l10n, String? value) {
  return _requireNonBlank(value, l10n.validationIngredientNameRequired);
}

/// Проверяет, что описание шага является непустым после обрезки пробелов
String? validateStepDescription(AppLocalizations l10n, String? value) {
  return _requireNonBlank(value, l10n.validationStepDescriptionRequired);
}

/// Количество ингредиента из текстового значения
///
/// Разделителем дробной части может быть как запятая, так и точка
/// Возвращает `null`, если значение не является числом
double? parseIngredientCount(String? value) => double.tryParse((value ?? '').trim().replaceAll(',', '.'));

/// Проверяет, что количество ингредиента является числом больше нуля, кратным четверти единицы
String? validateIngredientCount(AppLocalizations l10n, String? value) {
  final count = parseIngredientCount(value);
  final isValid = count != null && count > 0 && (count * 4) % 1 == 0;
  return isValid ? null : l10n.validationIngredientCount;
}

/// Проверяет, что время шага является целым числом больше нуля и меньше 60
String? validateStepTimePart(AppLocalizations l10n, String? value) {
  if (_isBlank(value)) {
    return null;
  }

  final parsed = int.tryParse(value!);
  return (parsed == null || parsed < 0 || parsed > 59) ? l10n.validationStepTimePart : null;
}

/// Длительность шага в секундах из текстовых значений
///
/// Пустые или некорректные значения заменяет нулём
int stepDurationSeconds({required String? minutes, required String? seconds}) {
  return (int.tryParse(minutes ?? '') ?? 0) * 60 + (int.tryParse(seconds ?? '') ?? 0);
}

/// Проверяет, что суммарная длительность шага больше нуля
String? validateStepDurationTotal(AppLocalizations l10n, {required String? minutes, required String? seconds}) {
  return stepDurationSeconds(minutes: minutes, seconds: seconds) > 0 ? null : l10n.validationStepDurationPositive;
}
