// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Otus.Food';

  @override
  String get recipesTitle => 'Рецепты';

  @override
  String get recipesEmpty => 'Нет рецептов. Проверьте соединение с интернетом';

  @override
  String get recipesAddRecipe => 'Добавить рецепт';

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа',
      many: '$count часов',
      few: '$count часа',
      one: '$count час',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты',
      many: '$count минут',
      few: '$count минуты',
      one: '$count минута',
    );
    return '$_temp0';
  }

  @override
  String get validationRecipeNameRequired => 'Введите название рецепта';

  @override
  String get validationIngredientNameRequired => 'Введите название ингредиента';

  @override
  String get validationStepDescriptionRequired => 'Введите описание шага';

  @override
  String get validationIngredientCount => 'Введите число больше нуля, кратное 0,25, например 1,5 или 0,75';

  @override
  String get validationStepTimePart => 'Число от 0 до 59';

  @override
  String get validationStepDurationPositive => 'Длительность должна быть больше нуля';

  @override
  String get stepDialogTitle => 'Шаг рецепта';

  @override
  String get stepDialogDescriptionLabel => 'Описание шага';

  @override
  String get stepDialogDurationLabel => 'Длительность шага';

  @override
  String get stepDialogMinutesLabel => 'Минуты';

  @override
  String get stepDialogSecondsLabel => 'Секунды';

  @override
  String get stepDialogAdd => 'Добавить';

  @override
  String get stepDialogSave => 'Сохранить';

  @override
  String get ingredientDialogTitle => 'Ингредиент';

  @override
  String get ingredientDialogNameLabel => 'Название ингредиента';

  @override
  String get ingredientDialogUnitLabel => 'Единица измерения';

  @override
  String get ingredientDialogUnitRequired => 'Выберите единицу измерения';

  @override
  String get ingredientDialogCountLabel => 'Количество';

  @override
  String get ingredientDialogAdd => 'Добавить';

  @override
  String get ingredientDialogSave => 'Сохранить';

  @override
  String get galleryAddPhoto => 'Добавить фото';

  @override
  String get galleryAnalyzing => 'Анализ фото';

  @override
  String galleryPhotoLabel(int index, String summary) {
    return 'Фото $index: $summary';
  }

  @override
  String get photoSourceCamera => 'Сфотографировать';

  @override
  String get photoSourceAlbum => 'Выбрать из альбома';

  @override
  String get photoSourceDelete => 'Удалить';

  @override
  String get photoSourceCancel => 'Отмена';

  @override
  String get favoriteAdd => 'Добавить в избранное';

  @override
  String get favoriteActive => 'В избранном';

  @override
  String stepTileTitle(int number) {
    return 'Шаг $number';
  }

  @override
  String get stepTileEdit => 'Изменить шаг';

  @override
  String get stepTileDelete => 'Удалить шаг';

  @override
  String get ingredientTileEdit => 'Изменить ингредиент';

  @override
  String get ingredientTileDelete => 'Удалить ингредиент';

  @override
  String get photoObjectsNone => 'объекты не найдены';

  @override
  String get recipePageTitle => 'Рецепт';

  @override
  String get recipePageShare => 'Поделиться';

  @override
  String get recipePageIngredientsTitle => 'Ингредиенты';

  @override
  String get recipePageIngredientsEmpty => 'нет ингредиентов';

  @override
  String get recipePageCheckAvailability => 'Проверить наличие';

  @override
  String get recipePageStepsTitle => 'Шаги приготовления';

  @override
  String get recipePageStepsEmpty => 'нет шагов приготовления';

  @override
  String get recipePageStartCooking => 'Начать готовить';

  @override
  String get recipePageCommentHint => 'оставить комментарий';

  @override
  String get recipePageAttachPhoto => 'Прикрепить фото';

  @override
  String get recipePageSendComment => 'Отправить';

  @override
  String get recipePageAddPhotoFailed => 'Не удалось добавить фото';

  @override
  String get addRecipeTitle => 'Новый рецепт';

  @override
  String get addRecipeNameLabel => 'Название рецепта';

  @override
  String get addRecipeIngredientsTitle => 'Ингредиенты';

  @override
  String get addRecipeIngredientsEmpty => 'нет ингредиентов';

  @override
  String get addRecipeAddIngredient => 'Добавить ингредиент';

  @override
  String get addRecipeStepsTitle => 'Шаги приготовления';

  @override
  String get addRecipeStepsEmpty => 'нет шагов приготовления';

  @override
  String get addRecipeAddStep => 'Добавить шаг';

  @override
  String get addRecipeSave => 'Сохранить рецепт';

  @override
  String get addRecipeAddPhotoFailed => 'Не удалось добавить фото';

  @override
  String get addRecipeSavedWithoutPhotos => 'Рецепт сохранён без фото';

  @override
  String imagesPageCounter(int index, int count) {
    return '$index из $count';
  }

  @override
  String get imagesPageDelete => 'Удалить фото';

  @override
  String get imagesPageDeleteTitle => 'Удалить фото?';

  @override
  String get imagesPageDeleteCancel => 'Отмена';

  @override
  String get imagesPageDeleteConfirm => 'Удалить';

  @override
  String get imagesPageDeleteFailed => 'Не удалось удалить фото';

  @override
  String get imagesPageNoObjects => 'Объекты не найдены';

  @override
  String get commentAuthorYou => 'Вы';

  @override
  String get languageMenuTooltip => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';
}
