import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/data/offline_measure_units.dart';
import 'package:recipes/models/measure_unit.dart';
import 'package:recipes/models/recipe_ingredient.dart';
import 'package:recipes/widgets/ingredient_dialog.dart';

import 'fakes.dart';
import 'fixtures.dart';
import 'helpers.dart';

void main() {
  testWidgets('повторное нажатие во время добавления не создаёт второй ингредиент', (tester) async {
    final api = FakeFoodApi(data: fixtureData())..delay = const Duration(milliseconds: 200);
    final manager = await createTestManager(api: api);
    final catalogBefore = manager.ingredients.length;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showIngredientDialog(context, manager: manager),
              child: const Text('открыть'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    // Имени нет в каталоге, поэтому ингредиент будет создаваться на сервере
    await tester.enterText(find.widgetWithText(TextFormField, 'Название ингредиента'), 'Соль морская');
    await tester.pump();
    await tester.tap(find.byType(DropdownButtonFormField<MeasureUnit>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(gram.one).last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Количество'), '2');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Добавить'));
    await tester.pump();

    // Пока идёт запрос, кнопка выключена и показывает индикатор
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(manager.ingredients.length, catalogBefore + 1, reason: 'ингредиент создан ровно один раз');
    expect(manager.ingredients.where((item) => item.name == 'Соль морская'), hasLength(1));
  });

  testWidgets('выбранная встроенная единица переживает загрузку серверного справочника при открытом диалоге', (
    tester,
  ) async {
    final api = FakeFoodApi(data: fixtureData(), offline: true);
    final manager = await createTestManager(api: api, store: InMemoryRecipesStore());
    final unit = OfflineMeasureUnits.all.first;
    RecipeIngredient? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showIngredientDialog(context, manager: manager),
              child: const Text('открыть'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    final nameField = find.widgetWithText(TextFormField, 'Название ингредиента');
    await tester.enterText(nameField, 'Соль морска');
    await tester.pump();
    await tester.tap(find.byType(DropdownButtonFormField<MeasureUnit>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(unit.one).last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Количество'), '2');

    // Появилась сеть, и синхронизация сменила встроенный справочник серверным
    api.offline = false;
    await manager.init();
    expect(manager.measureUnits, isNot(contains(unit)));

    // Ввод перестраивает диалог, и пункты списка собираются заново
    await tester.enterText(nameField, 'Соль морская');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Добавить'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(result?.ingredient.name, 'Соль морская');
    expect(result?.ingredient.measureUnit, same(unit));
  });
}
