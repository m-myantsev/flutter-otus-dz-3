import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/core/l10n/app_localizations.dart';
import 'package:recipes/presentation/formatting/duration_format.dart';

void main() {
  final ru = lookupAppLocalizations(const Locale('ru'));
  final en = lookupAppLocalizations(const Locale('en'));

  group('formatDurationMinutes', () {
    group('возвращает форму минута', () {
      const cases = {1: '1 минута', 21: '21 минута', 31: '31 минута'};
      for (final MapEntry(key: minutes, value: expected) in cases.entries) {
        test('$minutes - $expected', () => expect(formatDurationMinutes(ru, minutes), expected));
      }
    });

    group('возвращает форму минуты', () {
      const cases = {2: '2 минуты', 3: '3 минуты', 4: '4 минуты', 22: '22 минуты', 32: '32 минуты'};
      for (final MapEntry(key: minutes, value: expected) in cases.entries) {
        test('$minutes - $expected', () => expect(formatDurationMinutes(ru, minutes), expected));
      }
    });

    group('возвращает форму минут', () {
      const cases = {
        0: '0 минут',
        5: '5 минут',
        10: '10 минут',
        11: '11 минут',
        12: '12 минут',
        13: '13 минут',
        14: '14 минут',
        19: '19 минут',
        25: '25 минут',
        45: '45 минут',
      };
      for (final MapEntry(key: minutes, value: expected) in cases.entries) {
        test('$minutes - $expected', () => expect(formatDurationMinutes(ru, minutes), expected));
      }
    });

    group('возвращает форму час', () {
      const cases = {60: '1 час', 1260: '21 час'};
      for (final MapEntry(key: minutes, value: expected) in cases.entries) {
        test('$minutes - $expected', () => expect(formatDurationMinutes(ru, minutes), expected));
      }
    });

    group('возвращает форму часа', () {
      const cases = {120: '2 часа', 180: '3 часа', 1320: '22 часа'};
      for (final MapEntry(key: minutes, value: expected) in cases.entries) {
        test('$minutes - $expected', () => expect(formatDurationMinutes(ru, minutes), expected));
      }
    });

    group('возвращает форму часов', () {
      const cases = {300: '5 часов', 600: '10 часов', 660: '11 часов', 720: '12 часов', 840: '14 часов'};
      for (final MapEntry(key: minutes, value: expected) in cases.entries) {
        test('$minutes - $expected', () => expect(formatDurationMinutes(ru, minutes), expected));
      }
    });

    group('возвращает часы с остатком минут', () {
      const cases = {
        61: '1 час 1 минута',
        65: '1 час 5 минут',
        75: '1 час 15 минут',
        90: '1 час 30 минут',
        101: '1 час 41 минута',
        102: '1 час 42 минуты',
        111: '1 час 51 минута',
        122: '2 часа 2 минуты',
      };
      for (final MapEntry(key: minutes, value: expected) in cases.entries) {
        test('$minutes - $expected', () => expect(formatDurationMinutes(ru, minutes), expected));
      }
    });

    group('на английском', () {
      const cases = {
        0: '0 minutes',
        1: '1 minute',
        2: '2 minutes',
        5: '5 minutes',
        11: '11 minutes',
        21: '21 minutes',
        60: '1 hour',
        61: '1 hour 1 minute',
        75: '1 hour 15 minutes',
        120: '2 hours',
      };
      for (final MapEntry(key: minutes, value: expected) in cases.entries) {
        test('$minutes - $expected', () => expect(formatDurationMinutes(en, minutes), expected));
      }
    });
  });

  group('formatDurationSeconds', () {
    const cases = {0: '00:00', 5: '00:05', 59: '00:59', 60: '01:00', 330: '05:30', 3599: '59:59', 3600: '60:00'};
    for (final MapEntry(key: seconds, value: expected) in cases.entries) {
      test('$seconds - $expected', () => expect(formatDurationSeconds(seconds), expected));
    }
  });
}
