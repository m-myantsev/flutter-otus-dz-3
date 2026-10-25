import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/presentation/formatting/date_format.dart';

void main() {
  group('formatDate', () {
    group('форматирует дату как дд.мм.гггг', () {
      final cases = {
        DateTime(2022, 5, 25): '25.05.2022',
        DateTime(2022, 5, 21): '21.05.2022',
        DateTime(2022, 12, 7): '07.12.2022',
        DateTime(2023, 1, 1): '01.01.2023',
        DateTime(2024, 2, 29): '29.02.2024',
        DateTime(2022, 10, 10): '10.10.2022',
      };
      for (final MapEntry(key: date, value: expected) in cases.entries) {
        test('$date - $expected', () => expect(formatDate(date), expected));
      }
    });

    test('игнорирует время суток', () => expect(formatDate(DateTime(2022, 5, 25, 23, 59, 59)), '25.05.2022'));
  });
}
