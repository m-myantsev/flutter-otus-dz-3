import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/comment.dart';
import 'package:recipes/domain/entities/ingredient.dart';
import 'package:recipes/domain/entities/measure_unit.dart';

void main() {
  const gram = MeasureUnit(id: 2, one: 'грамм', few: 'грамма', many: 'граммов');

  test('единицы измерения равны при совпадении идентификатора', () {
    const copy = MeasureUnit(id: 2, one: 'г', few: 'г', many: 'г');
    const other = MeasureUnit(id: 3, one: 'грамм', few: 'грамма', many: 'граммов');

    expect(gram, equals(copy));
    expect(gram.hashCode, copy.hashCode);
    expect(gram, isNot(equals(other)));
  });

  test('ингредиенты равны при совпадении идентификатора', () {
    const flour = Ingredient(id: 7, name: 'Мука', measureUnit: gram);
    const copy = Ingredient(id: 7, name: 'Мука пшеничная', measureUnit: gram);
    const other = Ingredient(id: 8, name: 'Мука', measureUnit: gram);

    expect(flour, equals(copy));
    expect(flour.hashCode, copy.hashCode);
    expect(flour, isNot(equals(other)));
  });

  test('комментарии равны при совпадении всех полей и различаются признаком собственного', () {
    final comment = Comment(author: '', text: 'Вкусно', date: DateTime(2026, 8, 12), avatar: 'a.png', photo: 'p.jpg');
    final copy = Comment(author: '', text: 'Вкусно', date: DateTime(2026, 8, 12), avatar: 'a.png', photo: 'p.jpg');
    final own = Comment(
      author: '',
      text: 'Вкусно',
      date: DateTime(2026, 8, 12),
      avatar: 'a.png',
      photo: 'p.jpg',
      isOwn: true,
    );

    expect(comment, equals(copy));
    expect(comment.hashCode, copy.hashCode);
    expect(comment, isNot(equals(own)));
  });
}
