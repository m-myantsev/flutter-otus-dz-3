import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/recipe.dart';
import 'package:recipes/domain/repositories/photo_source.dart';
import 'package:recipes/presentation/pages/recipe_images_page.dart';
import 'package:recipes/presentation/pages/recipe_page.dart';
import 'package:recipes/presentation/state/recipes_manager.dart';
import 'package:recipes/presentation/theme/app_colors.dart';
import 'package:recipes/presentation/widgets/favorite_button.dart';
import 'package:recipes/presentation/widgets/recipe_gallery.dart';
import 'package:recipes/presentation/widgets/recipe_photo.dart';
import 'package:recipes/presentation/widgets/recipe_step_card.dart';
import 'package:rive/rive.dart' as rive;

import '../../fakes.dart';
import '../../fixtures.dart';
import '../../helpers.dart';

void main() {
  setUpAll(() async => expect(await rive.RiveNative.init(), isTrue));

  group('RecipePage', () {
    /// Открывает страницу рецепта и возвращает менеджер, на котором она построена
    ///
    /// Без [recipe] берётся первый рецепт, без [store] хранилище с тестовыми комментариями, без [detector] нет разметки
    Future<RecipesManager> pumpPage(
      WidgetTester tester, {
      Recipe? recipe,
      FakePhotoPicker? picker,
      InMemoryRecipesStore? store,
      FakeObjectDetector? detector,
    }) async {
      final manager = await createTestManager(store: store, detector: detector);
      await tester.pumpWidget(
        MaterialApp(
          home: RecipePage(manager: manager, recipe: recipe ?? manager.recipes.first, picker: picker),
        ),
      );
      await tester.pump();
      return manager;
    }

    /// Прокручивает страницу до [finder]
    Future<void> scrollTo(WidgetTester tester, Finder finder) {
      return tester.scrollUntilVisible(finder, 300, scrollable: find.byType(Scrollable).first);
    }

    /// Находит единственный узел семантики страницы, чья итоговая метка содержит [part]
    ///
    /// Метка берётся уже склеенной, поэтому узел-обёртка над несколькими элементами будет найден вместе с ними
    SemanticsNode semanticsNodeWith(WidgetTester tester, String part) {
      final found = <SemanticsNode>[];

      void visit(SemanticsNode node) {
        if (node.getSemanticsData().label.contains(part)) {
          found.add(node);
        }

        node.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      visit(tester.getSemantics(find.byType(RecipePage)).owner!.rootSemanticsNode!);
      return found.single;
    }

    testWidgets('показывает название, время приготовления, состав и шаги', (tester) async {
      await pumpPage(tester);

      expect(find.text('Лосось в соусе терияки'), findsOneWidget);
      expect(find.text('45 минут'), findsOneWidget);
      expect(find.text('•  Соевый соус'), findsOneWidget);
      expect(find.text('680 граммов'), findsOneWidget);
      expect(find.text('8 ст. ложек'), findsWidgets);
      expect(find.text('1½ ст. ложки'), findsOneWidget);

      // До шагов нужно доскроллить
      final secondStep = find.textContaining('Поставьте на средний огонь');
      await scrollTo(tester, secondStep);
      expect(secondStep, findsOneWidget);
    });

    testWidgets('тап по чекбоксу отмечает шаг пройденным и снимает отметку', (tester) async {
      await pumpPage(tester);

      // До первого шага нужно доскроллить
      await scrollTo(tester, find.textContaining('В маленькой кастрюле'));

      // Тап обрабатывают вся карточка и чекбокс, он в дереве карточки последний
      final firstCard = find.byType(RecipeStepCard).first;
      final checkbox = find.descendant(of: firstCard, matching: find.byType(GestureDetector)).last;

      /// Насколько заполнен чекбокс карточки
      double fill() {
        final layer = find.descendant(of: firstCard, matching: find.byType(FadeTransition)).last;
        return tester.widget<FadeTransition>(layer).opacity.value;
      }

      expect(fill(), 0);

      // Отметка доигрывается до конца, поэтому состояние читается по завершённой анимации
      await tester.tap(checkbox);
      await tester.pumpAndSettle();
      expect(fill(), 1);

      await tester.tap(checkbox);
      await tester.pumpAndSettle();
      expect(fill(), 0);
    });

    testWidgets('отправленный комментарий появляется в списке', (tester) async {
      await pumpPage(tester);

      final field = find.byType(TextField);
      await scrollTo(tester, field);

      await tester.enterText(field, '  Готовил дважды  ');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Поле ввода очищается при отправке, поэтому текст в дереве является комментарием
      expect(find.text('Готовил дважды'), findsOneWidget);
    });

    testWidgets('кнопка отправки видна только при непустом тексте', (tester) async {
      await pumpPage(tester);

      final field = find.byType(TextField);
      await scrollTo(tester, field);

      // Прокрутка доводится до конца, иначе нажатие придётся по старым координатам поля
      await tester.pumpAndSettle();

      // В покое поле выглядит как в макете с отображением только иконки фото
      expect(find.byIcon(Icons.photo_size_select_actual), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);

      // Одни пробелы отправлять нечего
      await tester.enterText(field, '   ');
      await tester.pump();
      expect(find.byIcon(Icons.send), findsNothing);

      await tester.enterText(field, 'Готовил дважды');
      await tester.pump();
      expect(find.byIcon(Icons.send), findsOneWidget);

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // После отправки поле очищается, поэтому кнопка скрывается сама
      expect(find.byIcon(Icons.send), findsNothing);
      expect(find.byIcon(Icons.photo_size_select_actual), findsOneWidget);
    });

    testWidgets('иконка фото не сдвигается при появлении кнопки отправки', (tester) async {
      await pumpPage(tester);

      final field = find.byType(TextField);
      await scrollTo(tester, field);

      // Прокрутка доводится до конца, иначе замеры придутся по разным координатам поля
      await tester.pumpAndSettle();

      final photoIcon = find.byIcon(Icons.photo_size_select_actual);
      final beforeInput = tester.getRect(photoIcon);

      await tester.enterText(field, 'Готовил дважды');
      await tester.pumpAndSettle();

      // Место кнопки отправки занято и при пустом поле, поэтому иконка фото остаётся на прежнем месте
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(tester.getRect(photoIcon), beforeInput);
    });

    testWidgets('кнопка отправки стоит под иконкой фото, у обеих хит-зона 48', (tester) async {
      await pumpPage(tester);

      final field = find.byType(TextField);
      await scrollTo(tester, field);

      // Прокрутка доводится до конца, иначе замеры придутся по разным координатам поля
      await tester.pumpAndSettle();

      await tester.enterText(field, 'Готовил дважды');
      await tester.pumpAndSettle();

      // Обе кнопки держат минимальную область нажатия
      final buttons = find.descendant(of: field, matching: find.byType(IconButton));
      expect(buttons, findsNWidgets(2));
      expect(tester.getSize(buttons.first), const Size(48, 48));
      expect(tester.getSize(buttons.last), const Size(48, 48));

      final fieldRect = tester.getRect(field);
      final photo = tester.getRect(find.byIcon(Icons.photo_size_select_actual));
      final send = tester.getRect(find.byIcon(Icons.send));

      // Иконки стоят в столбик у правого края поля
      expect(send.center.dx, photo.center.dx);
      expect(fieldRect.right - photo.right, 12);
      expect(fieldRect.right - send.right, 12);

      expect(photo.top - fieldRect.top, 12);
      expect(fieldRect.bottom - send.bottom, 12);

      // Между зонами нажатия остаётся зазор 8, чтобы промах по краю не попадал в соседнюю кнопку
      expect(send.top - photo.bottom, 32);
      expect(fieldRect.height, 104);
    });

    testWidgets('размер кнопок поля не зависит от платформы', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await pumpPage(tester);

      final field = find.byType(TextField);
      await scrollTo(tester, field);

      // Прокрутка доводится до конца, иначе замеры придутся по разным координатам поля
      await tester.pumpAndSettle();

      final emptyHeight = tester.getSize(field).height;
      expect(tester.getSize(find.descendant(of: field, matching: find.byType(IconButton))), const Size(48, 48));

      await tester.enterText(field, 'Готовил дважды');
      await tester.pumpAndSettle();

      final buttons = find.descendant(of: field, matching: find.byType(IconButton));
      expect(buttons, findsNWidgets(2));
      expect(tester.getSize(buttons.first), const Size(48, 48));
      expect(tester.getSize(buttons.last), const Size(48, 48));

      // Заглушка на месте скрытой кнопки того же размера, поэтому ввод не меняет высоту поля
      expect(tester.getSize(field).height, emptyHeight);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('кнопки поля комментария подписаны для скринридера', (tester) async {
      await pumpPage(tester);

      final field = find.byType(TextField);
      await scrollTo(tester, field);
      await tester.pumpAndSettle();

      expect(find.byTooltip('Прикрепить фото'), findsOneWidget);

      await tester.enterText(field, 'Готовил дважды');
      await tester.pumpAndSettle();

      expect(find.byTooltip('Отправить'), findsOneWidget);
    });

    testWidgets('тап по иконке фото в поле комментария открывает шит выбора фото', (tester) async {
      await pumpPage(tester);

      await scrollTo(tester, find.byType(TextField));

      // Прокрутка доводится до конца, иначе нажатие придётся по старым координатам поля
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.photo_size_select_actual));
      await tester.pumpAndSettle();

      expect(find.text('Сфотографировать'), findsOneWidget);
    });

    testWidgets('тап по кнопке избранного отмечает рецепт в менеджере', (tester) async {
      final manager = await pumpPage(tester);
      expect(manager.isFavorite(0), isFalse);

      await tester.tap(find.byType(FavoriteButton));
      await tester.pump();

      expect(manager.isFavorite(0), isTrue);
    });

    testWidgets('кнопка избранного не склеивается с названием рецепта', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPage(tester);

      // У кнопки собственный узел размером с область нажатия, название рецепта в него не попадает
      final inactive = semanticsNodeWith(tester, 'избранно');
      expect(inactive.rect.size, const Size(48, 48));
      expect(inactive.getSemanticsData().label, 'Добавить в избранное');

      await tester.tap(find.byType(FavoriteButton));
      await tester.pump();

      // Состояние озвучивается меткой, а не только флагом `selected`
      expect(semanticsNodeWith(tester, 'избранно').getSemanticsData().label, 'В избранном');

      handle.dispose();
    });

    testWidgets('шаги не склеиваются в один узел семантики', (tester) async {
      final handle = tester.ensureSemantics();
      final manager = await pumpPage(tester);
      final steps = manager.recipes.first.steps;

      await scrollTo(tester, find.textContaining('В маленькой кастрюле'));
      await tester.pumpAndSettle();

      // У карточки собственный узел-переключатель, где склеены номер, текст и время только своего шага
      final firstStep = semanticsNodeWith(tester, steps.first.name);
      expect(
        firstStep,
        matchesSemantics(label: '1\n${steps.first.name}\n05:30', hasCheckedState: true, hasTapAction: true),
      );

      // Соседний шаг живёт в отдельном узле, а не в общей с первым метке
      expect(firstStep.getSemanticsData().label, isNot(contains(steps[1].name)));
      expect(semanticsNodeWith(tester, steps[1].name).id, isNot(firstStep.id));

      handle.dispose();
    });

    testWidgets('рецепт без состава и шагов показывает подписи-заглушки', (tester) async {
      final manager = await createTestManager();
      final recipe = manager.recipes.firstWhere((r) => r.ingredients.isEmpty && r.steps.isEmpty);
      await pumpPage(tester, recipe: recipe);

      expect(find.text('нет ингредиентов'), findsOneWidget);
      await scrollTo(tester, find.text('нет шагов приготовления'));
      expect(find.text('нет шагов приготовления'), findsOneWidget);
    });

    group('галерея', () {
      /// Миниатюры фото рецепта, других `Image` внутри ленты нет
      final thumbnails = find.descendant(of: find.byType(RecipeGallery), matching: find.byType(Image));

      testWidgets('галерея стоит между фото рецепта и ингредиентами', (tester) async {
        await pumpPage(tester);
        final photo = tester.getRect(find.byType(RecipePhoto));
        final gallery = tester.getRect(find.byType(RecipeGallery));
        final title = tester.getRect(find.text('Ингредиенты'));
        expect(gallery.top - photo.bottom, 12);
        expect(title.top - gallery.bottom, 17);
      });

      testWidgets('выбор из альбома добавляет фото в менеджер и в ленту', (tester) async {
        final picker = FakePhotoPicker(bytes: fixtureJpeg());
        final manager = await pumpPage(tester, picker: picker);

        await tester.tap(find.byTooltip('Добавить фото'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Выбрать из альбома'));
        await tester.pumpAndSettle();

        expect(picker.lastSource, PhotoSource.album);
        expect(manager.images(0), hasLength(1));
        expect(thumbnails, findsOneWidget);
      });

      testWidgets('пока фото анализируется, в ленте плитка анализа, а второе добавление недоступно', (tester) async {
        final picker = FakePhotoPicker(bytes: fixtureJpeg());
        final detector = FakeObjectDetector()..gate = Completer();
        final busyTile = find.descendant(
          of: find.byType(RecipeGallery),
          matching: find.byType(CircularProgressIndicator),
        );
        await pumpPage(tester, picker: picker, detector: detector);

        await tester.tap(find.byTooltip('Добавить фото'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Выбрать из альбома'));

        // Индикатор крутится бесконечно, поэтому `pumpAndSettle` до ответа детектора не дождался бы покоя
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(detector.calls, 1);
        expect(busyTile, findsOneWidget);
        expect(thumbnails, findsNothing);

        await tester.tap(find.byTooltip('Добавить фото'));
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Выбрать из альбома'), findsNothing, reason: 'панель выбора не открылась');
        expect(picker.calls, 1);

        // Пустой ответ не уводит разметку в `compute`, чей изолят под тестовым временем не завершился бы
        detector.gate!.complete(const []);
        await tester.pumpAndSettle();

        expect(busyTile, findsNothing);
        expect(thumbnails, findsOneWidget);
      });

      testWidgets('без камеры пункт съёмки неактивен', (tester) async {
        await pumpPage(tester, picker: FakePhotoPicker(supportsCamera: false));
        await tester.tap(find.byTooltip('Добавить фото'));
        await tester.pumpAndSettle();
        expect(tester.widget<Text>(find.text('Сфотографировать')).style?.color, AppColors.placeholder);
      });

      testWidgets('отмена выбора ничего не добавляет', (tester) async {
        final manager = await pumpPage(tester, picker: FakePhotoPicker());
        await tester.tap(find.byTooltip('Добавить фото'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Выбрать из альбома'));
        await tester.pumpAndSettle();
        expect(manager.images(0), isEmpty);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('сбой пикера показывает SnackBar', (tester) async {
        await pumpPage(tester, picker: FakePhotoPicker(fails: true));
        await tester.tap(find.byTooltip('Добавить фото'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Выбрать из альбома'));
        await tester.pumpAndSettle();
        expect(find.text('Не удалось добавить фото'), findsOneWidget);
      });

      testWidgets('тап по миниатюре открывает полноэкранный просмотр', (tester) async {
        await pumpPage(
          tester,
          store: InMemoryRecipesStore(
            comments: fixtureComments(),
            images: {
              0: [fixtureImage()],
            },
          ),
        );
        await tester.tap(thumbnails);
        await tester.pumpAndSettle();
        expect(find.byType(RecipeImagesPage), findsOneWidget);
        expect(find.text('1 из 1'), findsOneWidget);
      });
    });
  });
}
