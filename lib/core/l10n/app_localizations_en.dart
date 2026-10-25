// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Otus.Food';

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get recipesEmpty => 'No recipes. Check your internet connection';

  @override
  String get recipesAddRecipe => 'Add recipe';

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count hours', one: '$count hour');
    return '$_temp0';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count minutes', one: '$count minute');
    return '$_temp0';
  }

  @override
  String get validationRecipeNameRequired => 'Enter the recipe name';

  @override
  String get validationIngredientNameRequired => 'Enter the ingredient name';

  @override
  String get validationStepDescriptionRequired => 'Enter the step description';

  @override
  String get validationIngredientCount => 'Enter a number greater than zero in steps of 0.25, e.g. 1.5 or 0.75';

  @override
  String get validationStepTimePart => 'A number from 0 to 59';

  @override
  String get validationStepDurationPositive => 'Duration must be greater than zero';

  @override
  String get stepDialogTitle => 'Recipe step';

  @override
  String get stepDialogDescriptionLabel => 'Step description';

  @override
  String get stepDialogDurationLabel => 'Step duration';

  @override
  String get stepDialogMinutesLabel => 'Minutes';

  @override
  String get stepDialogSecondsLabel => 'Seconds';

  @override
  String get stepDialogAdd => 'Add';

  @override
  String get stepDialogSave => 'Save';

  @override
  String get ingredientDialogTitle => 'Ingredient';

  @override
  String get ingredientDialogNameLabel => 'Ingredient name';

  @override
  String get ingredientDialogUnitLabel => 'Unit of measure';

  @override
  String get ingredientDialogUnitRequired => 'Choose a unit of measure';

  @override
  String get ingredientDialogCountLabel => 'Quantity';

  @override
  String get ingredientDialogAdd => 'Add';

  @override
  String get ingredientDialogSave => 'Save';

  @override
  String get galleryAddPhoto => 'Add photo';

  @override
  String get galleryAnalyzing => 'Analyzing photo';

  @override
  String galleryPhotoLabel(int index, String summary) {
    return 'Photo $index: $summary';
  }

  @override
  String get photoSourceCamera => 'Take photo';

  @override
  String get photoSourceAlbum => 'Choose from album';

  @override
  String get photoSourceDelete => 'Delete';

  @override
  String get photoSourceCancel => 'Cancel';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteActive => 'In favorites';

  @override
  String stepTileTitle(int number) {
    return 'Step $number';
  }

  @override
  String get stepTileEdit => 'Edit step';

  @override
  String get stepTileDelete => 'Delete step';

  @override
  String get ingredientTileEdit => 'Edit ingredient';

  @override
  String get ingredientTileDelete => 'Delete ingredient';

  @override
  String get photoObjectsNone => 'no objects found';

  @override
  String get recipePageTitle => 'Recipe';

  @override
  String get recipePageShare => 'Share';

  @override
  String get recipePageIngredientsTitle => 'Ingredients';

  @override
  String get recipePageIngredientsEmpty => 'no ingredients';

  @override
  String get recipePageCheckAvailability => 'Check availability';

  @override
  String get recipePageStepsTitle => 'Cooking steps';

  @override
  String get recipePageStepsEmpty => 'no cooking steps';

  @override
  String get recipePageStartCooking => 'Start cooking';

  @override
  String get recipePageCommentHint => 'leave a comment';

  @override
  String get recipePageAttachPhoto => 'Attach photo';

  @override
  String get recipePageSendComment => 'Send';

  @override
  String get recipePageAddPhotoFailed => 'Couldn\'t add photo';

  @override
  String get addRecipeTitle => 'New recipe';

  @override
  String get addRecipeNameLabel => 'Recipe name';

  @override
  String get addRecipeIngredientsTitle => 'Ingredients';

  @override
  String get addRecipeIngredientsEmpty => 'no ingredients';

  @override
  String get addRecipeAddIngredient => 'Add ingredient';

  @override
  String get addRecipeStepsTitle => 'Cooking steps';

  @override
  String get addRecipeStepsEmpty => 'no cooking steps';

  @override
  String get addRecipeAddStep => 'Add step';

  @override
  String get addRecipeSave => 'Save recipe';

  @override
  String get addRecipeAddPhotoFailed => 'Couldn\'t add photo';

  @override
  String get addRecipeSavedWithoutPhotos => 'Recipe saved without photos';

  @override
  String imagesPageCounter(int index, int count) {
    return '$index of $count';
  }

  @override
  String get imagesPageDelete => 'Delete photo';

  @override
  String get imagesPageDeleteTitle => 'Delete photo?';

  @override
  String get imagesPageDeleteCancel => 'Cancel';

  @override
  String get imagesPageDeleteConfirm => 'Delete';

  @override
  String get imagesPageDeleteFailed => 'Couldn\'t delete photo';

  @override
  String get imagesPageNoObjects => 'No objects found';

  @override
  String get commentAuthorYou => 'You';

  @override
  String get languageMenuTooltip => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';
}
