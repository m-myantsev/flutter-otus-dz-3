import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/core/utils/plural.dart';

void main() {
  group('plural', () {
    group('возвращает форму one', () {
      const cases = {1: 'минута', 21: 'минута', 101: 'минута'};
      for (final MapEntry(key: n, value: expected) in cases.entries) {
        test('$n - $expected', () => expect(plural(n, one: 'минута', few: 'минуты', many: 'минут'), expected));
      }
    });

    group('возвращает форму few', () {
      const cases = {2: 'минуты', 4: 'минуты', 22: 'минуты', 104: 'минуты'};
      for (final MapEntry(key: n, value: expected) in cases.entries) {
        test('$n - $expected', () => expect(plural(n, one: 'минута', few: 'минуты', many: 'минут'), expected));
      }
    });

    group('возвращает форму many', () {
      const cases = {
        0: 'минут',
        5: 'минут',
        10: 'минут',
        11: 'минут',
        12: 'минут',
        14: 'минут',
        19: 'минут',
        100: 'минут',
        111: 'минут',
      };
      for (final MapEntry(key: n, value: expected) in cases.entries) {
        test('$n - $expected', () => expect(plural(n, one: 'минута', few: 'минуты', many: 'минут'), expected));
      }
    });
  });
}
