import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/measure_unit.dart';
import 'package:recipes/presentation/formatting/count_format.dart';

void main() {
  const tablespoon = MeasureUnit(id: 0, one: 'ст. ложка', few: 'ст. ложки', many: 'ст. ложек');
  const gram = MeasureUnit(id: 2, one: 'грамм', few: 'грамма', many: 'граммов');

  /// Дроби, заданные кодами символов
  const quarter = '\u00BC';
  const half = '\u00BD';
  const threeQuarters = '\u00BE';

  group('formatCount', () {
    group('дроби набраны одним глифом, а не составной записью', () {
      final cases = {1.25: '1$quarter ст. ложки', 1.5: '1$half ст. ложки', 1.75: '1$threeQuarters ст. ложки'};
      for (final MapEntry(key: count, value: expected) in cases.entries) {
        test('$count - $expected', () => expect(formatCount(count, tablespoon), expected));
      }
    });

    group('целые количества выводятся без дробной части', () {
      final cases = {1.0: '1 ст. ложка', 2.0: '2 ст. ложки', 8.0: '8 ст. ложек', 680.0: '680 ст. ложек'};
      for (final MapEntry(key: count, value: expected) in cases.entries) {
        test('$count - $expected', () => expect(formatCount(count, tablespoon), expected));
      }
    });

    group('форма единицы для целых выбирается по правилам русского языка', () {
      final cases = {
        1.0: '1 грамм',
        3.0: '3 грамма',
        5.0: '5 граммов',
        11.0: '11 граммов',
        14.0: '14 граммов',
        21.0: '21 грамм',
        22.0: '22 грамма',
        680.0: '680 граммов',
      };
      for (final MapEntry(key: count, value: expected) in cases.entries) {
        test('$count - $expected', () => expect(formatCount(count, gram), expected));
      }
    });

    group('дробные количества выводятся дробью', () {
      final cases = {
        0.25: '$quarter ст. ложки',
        0.5: '$half ст. ложки',
        0.75: '$threeQuarters ст. ложки',
        1.25: '1$quarter ст. ложки',
        1.5: '1$half ст. ложки',
        2.5: '2$half ст. ложки',
        2.75: '2$threeQuarters ст. ложки',
        680.5: '680$half ст. ложки',
        680.25: '680$quarter ст. ложки',
      };
      for (final MapEntry(key: count, value: expected) in cases.entries) {
        test('$count - $expected', () => expect(formatCount(count, tablespoon), expected));
      }
    });

    group('при дробном числительном единица стоит в форме родительного единственного', () {
      final cases = {
        0.25: '$quarter грамма',
        0.5: '$half грамма',
        0.75: '$threeQuarters грамма',
        1.5: '1$half грамма',
        5.5: '5$half грамма',
        5.75: '5$threeQuarters грамма',
        11.5: '11$half грамма',
        21.5: '21$half грамма',
        21.25: '21$quarter грамма',
      };
      for (final MapEntry(key: count, value: expected) in cases.entries) {
        test('$count - $expected', () => expect(formatCount(count, gram), expected));
      }
    });
  });
}
