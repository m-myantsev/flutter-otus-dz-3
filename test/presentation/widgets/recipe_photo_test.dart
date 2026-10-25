import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/presentation/widgets/image_placeholder.dart';
import 'package:recipes/presentation/widgets/recipe_photo.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('пустой адрес сразу даёт заглушку', (tester) async {
    await tester.pumpWidget(wrap(const RecipePhoto(photo: '')));

    expect(find.byType(ImagePlaceholder), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('путь к ассету использует корректный класс', (tester) async {
    await tester.pumpWidget(wrap(const RecipePhoto(photo: 'assets/images/recipe_0.jpg')));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
  });

  testWidgets('http-адрес использует корректный класс, и ошибка сети даёт заглушку', (tester) async {
    await tester.pumpWidget(wrap(const RecipePhoto(photo: 'https://example.com/x.jpg')));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());

    // В тестах сетевые запросы запрещены, и ошибка загрузки ожидаема
    await tester.pump();
    tester.takeException();
    expect(find.byType(ImagePlaceholder), findsOneWidget);
  });
}
