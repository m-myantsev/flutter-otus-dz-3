import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/domain/entities/recipe.dart';

import 'fakes.dart';
import 'fixtures.dart';

void main() {
  test('оффлайн бросает исключение из каждого метода', () async {
    final api = FakeFoodApi(offline: true);

    await expectLater(api.fetchFoodData(), throwsException);
    await expectLater(api.createIngredient('Соль', gram), throwsException);
    await expectLater(
      api.createRecipe(name: 'x', duration: 1, ingredients: const [], steps: const []),
      throwsException,
    );
  });

  test('хранилище в памяти повторяет семантику настоящего', () async {
    final store = InMemoryRecipesStore(
      recipes: const [Recipe(id: -1, name: 'Черновик', duration: 5, photo: '')],
    );
    await store.putRecipe(const Recipe(id: 0, name: 'Старый', duration: 1, photo: ''));

    await store.saveAll(fixtureData());

    final ids = store.loadRecipes().map((recipe) => recipe.id);
    expect(ids, contains(-1), reason: 'оффлайн-запись выживает');
    expect(
      store.loadRecipes().singleWhere((recipe) => recipe.id == 0).name,
      'Лосось в соусе терияки',
      reason: 'серверная запись замещена',
    );
  });

  test('фикстуры согласованы', () {
    expect(fixtureRecipes.map((recipe) => recipe.id), [0, 1, 2, 3, 4, 5, 6]);
    expect(fixtureIngredients, hasLength(21));
    expect(fixtureMeasureUnits, hasLength(7));
    expect(fixtureComments().keys, containsAll([0, 6]));
  });
}
