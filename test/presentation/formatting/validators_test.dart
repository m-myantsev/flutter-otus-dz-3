import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/core/l10n/app_localizations.dart';
import 'package:recipes/presentation/formatting/validators.dart';

void main() {
  final ru = lookupAppLocalizations(const Locale('ru'));
  final en = lookupAppLocalizations(const Locale('en'));

  group('validateRecipeName', () {
    const invalid = [null, '', '   '];
    for (final value in invalid) {
      test('$value - ошибка', () => expect(validateRecipeName(ru, value), 'Введите название рецепта'));
    }
    test('обычный текст - корректно', () => expect(validateRecipeName(ru, 'Плов'), isNull));
    test('на английском', () => expect(validateRecipeName(en, ''), 'Enter the recipe name'));
  });

  group('validateIngredientName', () {
    const invalid = [null, '', '   '];
    for (final value in invalid) {
      test('$value - ошибка', () => expect(validateIngredientName(ru, value), 'Введите название ингредиента'));
    }
    test('обычный текст - корректно', () => expect(validateIngredientName(ru, 'Соевый соус'), isNull));
    test('на английском', () => expect(validateIngredientName(en, ''), 'Enter the ingredient name'));
  });

  group('validateStepDescription', () {
    const invalid = [null, '', '   '];
    for (final value in invalid) {
      test('$value - ошибка', () => expect(validateStepDescription(ru, value), 'Введите описание шага'));
    }
    test('обычный текст - корректно', () => expect(validateStepDescription(ru, 'Нарежьте лук'), isNull));
    test('на английском', () => expect(validateStepDescription(en, ''), 'Enter the step description'));
  });

  group('validateIngredientCount', () {
    const message = 'Введите число больше нуля, кратное 0,25, например 1,5 или 0,75';
    const invalid = [null, '', '   ', 'абв', '0', '0,0', '-3', '-1,5', '2.3', '0,2', '1,3', '1,,5'];
    for (final value in invalid) {
      test('$value - ошибка', () => expect(validateIngredientCount(ru, value), message));
    }
    const valid = ['1', '8', '999', '0.5', '0,5', '1.5', '1,5', '  2,5  ', '0,25', '0.75', '2,25', '680'];
    for (final value in valid) {
      test('$value - корректно', () => expect(validateIngredientCount(ru, value), isNull));
    }
    test('на английском', () {
      expect(validateIngredientCount(en, '0'), 'Enter a number greater than zero in steps of 0.25, e.g. 1.5 or 0.75');
    });
  });

  group('parseIngredientCount', () {
    test('целое число', () => expect(parseIngredientCount('8'), 8.0));
    test('точка как разделитель', () => expect(parseIngredientCount('1.5'), 1.5));
    test('запятая как разделитель', () => expect(parseIngredientCount('1,5'), 1.5));
    test('пробелы по краям обрезаются', () => expect(parseIngredientCount('  2,5  '), 2.5));
    test('не число будет null', () => expect(parseIngredientCount('абв'), isNull));
    test('пустая строка будет null', () => expect(parseIngredientCount(''), isNull));
    test('null будет null', () => expect(parseIngredientCount(null), isNull));
  });

  group('validateStepTimePart', () {
    test('null корректно, пустое поле означает ноль', () => expect(validateStepTimePart(ru, null), isNull));
    test('пустая строка - корректно', () => expect(validateStepTimePart(ru, ''), isNull));
    test('пробелы - корректно', () => expect(validateStepTimePart(ru, '   '), isNull));
    const invalid = ['абв', '-1', '60', '2.5'];
    for (final value in invalid) {
      test('$value - ошибка', () => expect(validateStepTimePart(ru, value), 'Число от 0 до 59'));
    }
    const valid = ['0', '5', '59'];
    for (final value in valid) {
      test('$value - корректно', () => expect(validateStepTimePart(ru, value), isNull));
    }
    test('на английском', () => expect(validateStepTimePart(en, '60'), 'A number from 0 to 59'));
  });

  group('validateStepDurationTotal', () {
    const invalid = {'нули в обоих полях': ('0', '0'), 'пустые поля': (null, null), 'пустая строка и ноль': ('', '0')};
    for (final MapEntry(key: name, value: (minutes, seconds)) in invalid.entries) {
      test('$name - ошибка', () {
        expect(
          validateStepDurationTotal(ru, minutes: minutes, seconds: seconds),
          'Длительность должна быть больше нуля',
        );
      });
    }
    const valid = {'только секунды': ('0', '30'), 'только минуты': ('5', ''), 'минуты и секунды': ('59', '59')};
    for (final MapEntry(key: name, value: (minutes, seconds)) in valid.entries) {
      test(
        '$name - корректно',
        () => expect(validateStepDurationTotal(ru, minutes: minutes, seconds: seconds), isNull),
      );
    }
    test('на английском', () {
      expect(validateStepDurationTotal(en, minutes: '0', seconds: '0'), 'Duration must be greater than zero');
    });
  });

  group('stepDurationSeconds', () {
    test('минуты и секунды', () => expect(stepDurationSeconds(minutes: '1', seconds: '30'), 90));
    test('пустые минуты', () => expect(stepDurationSeconds(minutes: '', seconds: '45'), 45));
    test('пустые секунды', () => expect(stepDurationSeconds(minutes: '2', seconds: ''), 120));
    test('если оба null, то будет ноль', () => expect(stepDurationSeconds(minutes: null, seconds: null), 0));
    test('некорректные минуты игнорируются', () => expect(stepDurationSeconds(minutes: 'abc', seconds: '5'), 5));
  });
}
