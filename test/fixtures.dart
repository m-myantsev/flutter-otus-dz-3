import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:recipes/domain/entities/comment.dart';
import 'package:recipes/domain/entities/detected_object.dart';
import 'package:recipes/domain/entities/detection_box.dart';
import 'package:recipes/domain/entities/food_data.dart';
import 'package:recipes/domain/entities/ingredient.dart';
import 'package:recipes/domain/entities/measure_unit.dart';
import 'package:recipes/domain/entities/recipe.dart';
import 'package:recipes/domain/entities/recipe_image.dart';
import 'package:recipes/domain/entities/recipe_ingredient.dart';
import 'package:recipes/domain/entities/recipe_step.dart';

const MeasureUnit tablespoon = MeasureUnit(id: 0, one: 'ст. ложка', few: 'ст. ложки', many: 'ст. ложек');
const MeasureUnit teaspoon = MeasureUnit(id: 1, one: 'ч. ложка', few: 'ч. ложки', many: 'ч. ложек');
const MeasureUnit gram = MeasureUnit(id: 2, one: 'грамм', few: 'грамма', many: 'граммов');
const MeasureUnit piece = MeasureUnit(id: 3, one: 'штука', few: 'штуки', many: 'штук');
const MeasureUnit glass = MeasureUnit(id: 4, one: 'стакан', few: 'стакана', many: 'стаканов');
const MeasureUnit clove = MeasureUnit(id: 5, one: 'зубчик', few: 'зубчика', many: 'зубчиков');
const MeasureUnit pinch = MeasureUnit(id: 6, one: 'щепотка', few: 'щепотки', many: 'щепоток');

const Ingredient soySauce = Ingredient(id: 0, name: 'Соевый соус', measureUnit: tablespoon);
const Ingredient chickenFillet = Ingredient(id: 1, name: 'Куриное филе', measureUnit: gram);
const Ingredient honey = Ingredient(id: 2, name: 'Мёд', measureUnit: tablespoon);
const Ingredient garlic = Ingredient(id: 3, name: 'Чеснок', measureUnit: clove);
const Ingredient rice = Ingredient(id: 4, name: 'Рис', measureUnit: glass);
const Ingredient tomato = Ingredient(id: 5, name: 'Помидор', measureUnit: piece);
const Ingredient tofu = Ingredient(id: 6, name: 'Сыр тофу', measureUnit: gram);
const Ingredient oliveOil = Ingredient(id: 7, name: 'Оливковое масло', measureUnit: tablespoon);
const Ingredient lemonJuice = Ingredient(id: 8, name: 'Лимонный сок', measureUnit: tablespoon);
const Ingredient ginger = Ingredient(id: 9, name: 'Имбирь', measureUnit: gram);
const Ingredient water = Ingredient(id: 10, name: 'Вода', measureUnit: tablespoon);
const Ingredient brownSugar = Ingredient(id: 11, name: 'Коричневый сахар', measureUnit: tablespoon);
const Ingredient gratedGinger = Ingredient(id: 12, name: 'Тёртый свежий имбирь', measureUnit: tablespoon);
const Ingredient cornStarch = Ingredient(id: 13, name: 'Кукурузный крахмал', measureUnit: tablespoon);
const Ingredient vegetableOil = Ingredient(id: 14, name: 'Растительное масло', measureUnit: teaspoon);
const Ingredient salmonFillet = Ingredient(id: 15, name: 'Филе лосося', measureUnit: gram);
const Ingredient sesame = Ingredient(id: 16, name: 'Кунжут', measureUnit: pinch);
const Ingredient pizzaDough = Ingredient(id: 17, name: 'Тесто для пиццы', measureUnit: gram);
const Ingredient tomatoSauce = Ingredient(id: 18, name: 'Соус томатный', measureUnit: gram);
const Ingredient mozzarella = Ingredient(id: 19, name: 'Сыр Моцарелла', measureUnit: gram);
const Ingredient basil = Ingredient(id: 20, name: 'Базилик зелёный', measureUnit: piece);

const Recipe salmonTeriyaki = Recipe(
  id: 0,
  name: 'Лосось в соусе терияки',
  duration: 45,
  photo: 'assets/images/recipe_0.jpg',
  ingredients: [
    RecipeIngredient(count: 8, ingredient: soySauce),
    RecipeIngredient(count: 8, ingredient: water),
    RecipeIngredient(count: 3, ingredient: honey),
    RecipeIngredient(count: 2, ingredient: brownSugar),
    RecipeIngredient(count: 3, ingredient: garlic),
    RecipeIngredient(count: 1, ingredient: gratedGinger),
    RecipeIngredient(count: 1.5, ingredient: lemonJuice),
    RecipeIngredient(count: 1, ingredient: cornStarch),
    RecipeIngredient(count: 1, ingredient: vegetableOil),
    RecipeIngredient(count: 680, ingredient: salmonFillet),
    RecipeIngredient(count: 1, ingredient: sesame),
  ],
  steps: [
    RecipeStep(
      name:
          'В маленькой кастрюле соедините соевый соус, 6 столовых ложек воды, мёд, сахар, '
          'измельчённый чеснок, имбирь и лимонный сок.',
      duration: 330,
    ),
    RecipeStep(name: 'Поставьте на средний огонь и, помешивая, доведите до лёгкого кипения.', duration: 420),
    RecipeStep(name: 'Смешайте оставшуюся воду с крахмалом. Добавьте в кастрюлю и перемешайте.', duration: 360),
    RecipeStep(
      name: 'Готовьте, непрерывно помешивая венчиком, 1 минуту. Снимите с огня и немного остудите.',
      duration: 90,
    ),
    RecipeStep(name: 'Смажьте форму маслом и выложите туда рыбу. Полейте её соусом.', duration: 360),
    RecipeStep(name: 'Поставьте в разогретую до 200 °C духовку примерно на 15 минут.', duration: 900),
    RecipeStep(name: 'Перед подачей полейте соусом из формы и посыпьте кунжутом.', duration: 240),
  ],
);

const Recipe pokeBowl = Recipe(
  id: 1,
  name: 'Поке боул с сыром тофу',
  duration: 30,
  photo: 'assets/images/recipe_1.jpg',
);

const Recipe georgianSteak = Recipe(
  id: 2,
  name: 'Стейк из говядины по-грузински с кукурузой',
  duration: 75,
  photo: 'assets/images/recipe_2.jpg',
);

const Recipe blueberryToasts = Recipe(
  id: 3,
  name: 'Тосты с голубикой и бананом',
  duration: 45,
  photo: 'assets/images/recipe_3.jpg',
);

const Recipe seafoodPasta = Recipe(
  id: 4,
  name: 'Паста с морепродуктами',
  duration: 25,
  photo: 'assets/images/recipe_4.jpg',
);

const Recipe doubleBurger = Recipe(
  id: 5,
  name: 'Бургер с двумя котлетами',
  duration: 60,
  photo: 'assets/images/recipe_5.jpg',
);

const Recipe margherita = Recipe(
  id: 6,
  name: 'Пицца Маргарита домашняя',
  duration: 25,
  photo: 'assets/images/recipe_6.jpg',
  ingredients: [
    RecipeIngredient(count: 300, ingredient: pizzaDough),
    RecipeIngredient(count: 130, ingredient: tomatoSauce),
    RecipeIngredient(count: 180, ingredient: mozzarella),
    RecipeIngredient(count: 1, ingredient: tomato),
    RecipeIngredient(count: 1, ingredient: basil),
    RecipeIngredient(count: 1, ingredient: oliveOil),
  ],
  steps: [
    RecipeStep(
      name:
          'Тесто для пиццы раскатываем толщиной 2-3 мм, диаметром 32-35 см. Для того, чтобы получить '
          'красивые бортики на пицце, загибаем края по 2-3 см внутрь и хорошо залепляем, '
          'чтобы при выпекании они не отклеились.',
      duration: 60,
    ),
    RecipeStep(
      name:
          'Кладём на раскатанную основу томатный соус, пусть его будет побольше, особенно если вы '
          'используете не кетчуп или томатную пасту, а соус из помидоров.',
      duration: 60,
    ),
    RecipeStep(name: 'Равномерно распределяем соус по тесту, поливаем сверху оливковым маслом.', duration: 60),
    RecipeStep(
      name:
          'Духовку разогреваем до максимальной температуры (250-270 °C), ставим перевёрнутый противень '
          'с тестом на нижний уровень и выпекаем в течение 5-10 минут.',
      duration: 600,
    ),
    RecipeStep(name: 'Пока запекается корж, нарезаем моцареллу пластинами 5-10 мм толщиной.', duration: 60),
    RecipeStep(name: 'Нарезаем помидор ломтиками 3-5 мм.', duration: 60),
    RecipeStep(
      name:
          'Кладём сыр, помидоры и базилик на основу, ставим в духовку еще на 10 минут. '
          'Пицца готова, когда сыр расплавится.',
      duration: 600,
    ),
  ],
);

/// Справочник единиц измерения
const fixtureMeasureUnits = [tablespoon, teaspoon, gram, piece, glass, clove, pinch];

/// Каталог ингредиентов
const fixtureIngredients = [
  soySauce,
  chickenFillet,
  honey,
  garlic,
  rice,
  tomato,
  tofu,
  oliveOil,
  lemonJuice,
  ginger,
  water,
  brownSugar,
  gratedGinger,
  cornStarch,
  vegetableOil,
  salmonFillet,
  sesame,
  pizzaDough,
  tomatoSauce,
  mozzarella,
  basil,
];

/// Рецепты по возрастанию идентификатора
const fixtureRecipes = [
  salmonTeriyaki,
  pokeBowl,
  georgianSteak,
  blueberryToasts,
  seafoodPasta,
  doubleBurger,
  margherita,
];

/// Полный набор данных
FoodData fixtureData() =>
    const FoodData(recipes: fixtureRecipes, ingredients: fixtureIngredients, measureUnits: fixtureMeasureUnits);

/// Комментарии
Map<int, List<Comment>> fixtureComments() => {
  0: [
    Comment(
      author: 'anna_obraztsova',
      text: 'Я не большой любитель рыбы, но решила приготовить по этому рецепту и просто влюбилась!',
      date: DateTime(2022, 5, 25),
      avatar: 'assets/images/avatar_0.png',
      photo: 'assets/images/comment_0.jpg',
    ),
  ],
  6: [
    Comment(
      author: 'maxprimerov',
      text: 'Идеальный холостяцкий ужин',
      date: DateTime(2022, 5, 21),
      avatar: 'assets/images/avatar_1.png',
      photo: 'assets/images/comment_1.jpg',
    ),
  ],
};

/// Белый JPEG заданного размера
///
/// Настоящий JPEG, а не произвольные байты, потому что тесты интерфейса и детекции его декодируют
Uint8List fixtureJpeg({int width = 60, int height = 40}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));
  return img.encodeJpg(image, quality: 85);
}

/// Фото с двумя найденными объектами
///
/// Разные [label] первого объекта отличают фото друг от друга в тестах удаления
RecipeImage fixtureImage({String label = 'cup'}) => RecipeImage(
  bytes: fixtureJpeg(),
  objects: [
    DetectedObject(label: label, score: 0.87, box: const DetectionBox(left: 0.1, top: 0.1, right: 0.5, bottom: 0.5)),
    const DetectedObject(label: 'bowl', score: 0.65, box: DetectionBox(left: 0.6, top: 0.6, right: 0.9, bottom: 0.9)),
  ],
);
