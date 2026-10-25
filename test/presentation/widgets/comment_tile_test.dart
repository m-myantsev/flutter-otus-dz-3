import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/comment.dart';
import 'package:recipes/presentation/widgets/comment_tile.dart';

import '../../helpers.dart';

void main() {
  final own = Comment(author: '', text: 'Очень вкусно!', date: DateTime(2022, 5, 25), isOwn: true);

  Future<void> pumpTile(WidgetTester tester, Comment comment, {Locale locale = const Locale('ru')}) {
    return tester.pumpWidget(
      localizedApp(
        Scaffold(body: CommentTile(comment: comment)),
        locale: locale,
      ),
    );
  }

  testWidgets('собственный комментарий на русском подписан `Вы` и датирован по-русски', (tester) async {
    await pumpTile(tester, own);

    expect(find.text('Вы'), findsOneWidget);
    expect(find.text('25.05.2022'), findsOneWidget);
  });

  testWidgets('собственный комментарий на английском подписан `You` и датирован по-английски', (tester) async {
    await pumpTile(tester, own, locale: const Locale('en'));

    expect(find.text('You'), findsOneWidget);
    expect(find.text('5/25/2022'), findsOneWidget);
  });

  testWidgets('чужой комментарий подписан именем автора', (tester) async {
    await pumpTile(tester, Comment(author: 'anna_obraztsova', text: 'Вкусно', date: DateTime(2022, 5, 25)));

    expect(find.text('anna_obraztsova'), findsOneWidget);
    expect(find.text('Вы'), findsNothing);
  });
}
