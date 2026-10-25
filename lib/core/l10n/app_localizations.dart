import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ru'), Locale('en')];

  /// Название приложения в заголовке окна и в списке задач
  ///
  /// In ru, this message translates to:
  /// **'Otus.Food'**
  String get appTitle;

  /// Заголовок экрана со списком рецептов
  ///
  /// In ru, this message translates to:
  /// **'Рецепты'**
  String get recipesTitle;

  /// Пояснение на экране списка, когда рецептов нет ни на сервере, ни в локальной базе
  ///
  /// In ru, this message translates to:
  /// **'Нет рецептов. Проверьте соединение с интернетом'**
  String get recipesEmpty;

  /// Подсказка и метка для скринридера у круглой кнопки на экране списка, открывающей форму нового рецепта
  ///
  /// In ru, this message translates to:
  /// **'Добавить рецепт'**
  String get recipesAddRecipe;

  /// Часовая часть длительности рецепта, например `2 часа` в `2 часа 15 минут`
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} час} few{{count} часа} many{{count} часов} other{{count} часа}}'**
  String durationHours(int count);

  /// Минутная часть длительности рецепта или вся длительность, если она меньше часа
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} минута} few{{count} минуты} many{{count} минут} other{{count} минуты}}'**
  String durationMinutes(int count);

  /// Ошибка под пустым полем названия на форме рецепта
  ///
  /// In ru, this message translates to:
  /// **'Введите название рецепта'**
  String get validationRecipeNameRequired;

  /// Ошибка под пустым полем названия в диалоге ингредиента
  ///
  /// In ru, this message translates to:
  /// **'Введите название ингредиента'**
  String get validationIngredientNameRequired;

  /// Ошибка под пустым полем описания в диалоге шага
  ///
  /// In ru, this message translates to:
  /// **'Введите описание шага'**
  String get validationStepDescriptionRequired;

  /// Ошибка под полем количества в диалоге ингредиента, когда это не положительное число, кратное четверти
  ///
  /// In ru, this message translates to:
  /// **'Введите число больше нуля, кратное 0,25, например 1,5 или 0,75'**
  String get validationIngredientCount;

  /// Ошибка под полем минут или секунд в диалоге шага, когда значение вне диапазона
  ///
  /// In ru, this message translates to:
  /// **'Число от 0 до 59'**
  String get validationStepTimePart;

  /// Ошибка под полем минут в диалоге шага, когда минуты и секунды оба нулевые
  ///
  /// In ru, this message translates to:
  /// **'Длительность должна быть больше нуля'**
  String get validationStepDurationPositive;

  /// Заголовок диалога добавления и редактирования шага
  ///
  /// In ru, this message translates to:
  /// **'Шаг рецепта'**
  String get stepDialogTitle;

  /// Подпись многострочного поля с текстом шага в диалоге шага
  ///
  /// In ru, this message translates to:
  /// **'Описание шага'**
  String get stepDialogDescriptionLabel;

  /// Подзаголовок над полями минут и секунд в диалоге шага
  ///
  /// In ru, this message translates to:
  /// **'Длительность шага'**
  String get stepDialogDurationLabel;

  /// Подпись поля минут в диалоге шага
  ///
  /// In ru, this message translates to:
  /// **'Минуты'**
  String get stepDialogMinutesLabel;

  /// Подпись поля секунд в диалоге шага
  ///
  /// In ru, this message translates to:
  /// **'Секунды'**
  String get stepDialogSecondsLabel;

  /// Кнопка подтверждения диалога нового шага
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get stepDialogAdd;

  /// Кнопка подтверждения диалога при редактировании существующего шага
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get stepDialogSave;

  /// Заголовок диалога добавления и редактирования ингредиента
  ///
  /// In ru, this message translates to:
  /// **'Ингредиент'**
  String get ingredientDialogTitle;

  /// Подпись поля названия с подсказками из каталога в диалоге ингредиента
  ///
  /// In ru, this message translates to:
  /// **'Название ингредиента'**
  String get ingredientDialogNameLabel;

  /// Подпись выпадающего списка единиц для нового ингредиента
  ///
  /// In ru, this message translates to:
  /// **'Единица измерения'**
  String get ingredientDialogUnitLabel;

  /// Ошибка под списком единиц, когда для нового ингредиента единица не выбрана
  ///
  /// In ru, this message translates to:
  /// **'Выберите единицу измерения'**
  String get ingredientDialogUnitRequired;

  /// Подпись поля количества в диалоге ингредиента
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get ingredientDialogCountLabel;

  /// Кнопка подтверждения диалога нового ингредиента
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get ingredientDialogAdd;

  /// Кнопка подтверждения диалога при редактировании существующего ингредиента
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get ingredientDialogSave;

  /// Подсказка и метка для скринридера у плитки добавления фото в ленте рецепта
  ///
  /// In ru, this message translates to:
  /// **'Добавить фото'**
  String get galleryAddPhoto;

  /// Метка для скринридера у индикатора, пока на новом фото ищутся объекты
  ///
  /// In ru, this message translates to:
  /// **'Анализ фото'**
  String get galleryAnalyzing;

  /// Метка для скринридера у миниатюры фото с её номером в ленте и найденными объектами
  ///
  /// In ru, this message translates to:
  /// **'Фото {index}: {summary}'**
  String galleryPhotoLabel(int index, String summary);

  /// Пункт нижней панели фото, открывающий камеру
  ///
  /// In ru, this message translates to:
  /// **'Сфотографировать'**
  String get photoSourceCamera;

  /// Пункт нижней панели фото, открывающий галерею устройства
  ///
  /// In ru, this message translates to:
  /// **'Выбрать из альбома'**
  String get photoSourceAlbum;

  /// Пункт нижней панели фото, удаляющий открытое фото
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get photoSourceDelete;

  /// Кнопка закрытия нижней панели фото без выбора
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get photoSourceCancel;

  /// Метка для скринридера у кнопки-сердца, когда рецепт не в избранном
  ///
  /// In ru, this message translates to:
  /// **'Добавить в избранное'**
  String get favoriteAdd;

  /// Метка для скринридера у кнопки-сердца, когда рецепт уже в избранном
  ///
  /// In ru, this message translates to:
  /// **'В избранном'**
  String get favoriteActive;

  /// Заголовок карточки шага в форме нового рецепта с его порядковым номером
  ///
  /// In ru, this message translates to:
  /// **'Шаг {number}'**
  String stepTileTitle(int number);

  /// Подсказка и метка для скринридера у кнопки-карандаша на карточке шага в форме нового рецепта
  ///
  /// In ru, this message translates to:
  /// **'Изменить шаг'**
  String get stepTileEdit;

  /// Подсказка и метка для скринридера у кнопки-корзины на карточке шага в форме нового рецепта
  ///
  /// In ru, this message translates to:
  /// **'Удалить шаг'**
  String get stepTileDelete;

  /// Подсказка и метка для скринридера у кнопки-карандаша на карточке ингредиента в форме нового рецепта
  ///
  /// In ru, this message translates to:
  /// **'Изменить ингредиент'**
  String get ingredientTileEdit;

  /// Подсказка и метка для скринридера у кнопки-корзины на карточке ингредиента в форме нового рецепта
  ///
  /// In ru, this message translates to:
  /// **'Удалить ингредиент'**
  String get ingredientTileDelete;

  /// Сводка найденных объектов для скринридера, когда на фото ничего не найдено; идёт в метку фото в ленте и в полноэкранном просмотре
  ///
  /// In ru, this message translates to:
  /// **'объекты не найдены'**
  String get photoObjectsNone;

  /// Заголовок страницы просмотра рецепта
  ///
  /// In ru, this message translates to:
  /// **'Рецепт'**
  String get recipePageTitle;

  /// Подсказка и метка для скринридера у кнопки `поделиться` в AppBar страницы рецепта
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get recipePageShare;

  /// Заголовок секции состава на странице рецепта
  ///
  /// In ru, this message translates to:
  /// **'Ингредиенты'**
  String get recipePageIngredientsTitle;

  /// Заглушка на странице рецепта, когда у рецепта нет состава
  ///
  /// In ru, this message translates to:
  /// **'нет ингредиентов'**
  String get recipePageIngredientsEmpty;

  /// Кнопка под составом на странице рецепта, проверяющая наличие продуктов
  ///
  /// In ru, this message translates to:
  /// **'Проверить наличие'**
  String get recipePageCheckAvailability;

  /// Заголовок секции шагов на странице рецепта
  ///
  /// In ru, this message translates to:
  /// **'Шаги приготовления'**
  String get recipePageStepsTitle;

  /// Заглушка на странице рецепта, когда у рецепта нет шагов
  ///
  /// In ru, this message translates to:
  /// **'нет шагов приготовления'**
  String get recipePageStepsEmpty;

  /// Кнопка под шагами на странице рецепта, запускающая приготовление
  ///
  /// In ru, this message translates to:
  /// **'Начать готовить'**
  String get recipePageStartCooking;

  /// Подсказка в пустом поле нового комментария на странице рецепта
  ///
  /// In ru, this message translates to:
  /// **'оставить комментарий'**
  String get recipePageCommentHint;

  /// Подсказка и метка для скринридера у кнопки прикрепления фото в поле комментария
  ///
  /// In ru, this message translates to:
  /// **'Прикрепить фото'**
  String get recipePageAttachPhoto;

  /// Подсказка и метка для скринридера у кнопки отправки комментария
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get recipePageSendComment;

  /// Сообщение внизу экрана рецепта, когда фото не получено от камеры или альбома или не сохранено
  ///
  /// In ru, this message translates to:
  /// **'Не удалось добавить фото'**
  String get recipePageAddPhotoFailed;

  /// Заголовок формы создания рецепта
  ///
  /// In ru, this message translates to:
  /// **'Новый рецепт'**
  String get addRecipeTitle;

  /// Подпись поля названия на форме создания рецепта
  ///
  /// In ru, this message translates to:
  /// **'Название рецепта'**
  String get addRecipeNameLabel;

  /// Заголовок секции состава на форме создания рецепта
  ///
  /// In ru, this message translates to:
  /// **'Ингредиенты'**
  String get addRecipeIngredientsTitle;

  /// Заглушка на форме создания рецепта, пока не добавлен ни один ингредиент
  ///
  /// In ru, this message translates to:
  /// **'нет ингредиентов'**
  String get addRecipeIngredientsEmpty;

  /// Кнопка на форме создания рецепта, открывающая диалог нового ингредиента
  ///
  /// In ru, this message translates to:
  /// **'Добавить ингредиент'**
  String get addRecipeAddIngredient;

  /// Заголовок секции шагов на форме создания рецепта
  ///
  /// In ru, this message translates to:
  /// **'Шаги приготовления'**
  String get addRecipeStepsTitle;

  /// Заглушка на форме создания рецепта, пока не добавлен ни один шаг
  ///
  /// In ru, this message translates to:
  /// **'нет шагов приготовления'**
  String get addRecipeStepsEmpty;

  /// Кнопка на форме создания рецепта, открывающая диалог нового шага
  ///
  /// In ru, this message translates to:
  /// **'Добавить шаг'**
  String get addRecipeAddStep;

  /// Кнопка сохранения формы создания рецепта
  ///
  /// In ru, this message translates to:
  /// **'Сохранить рецепт'**
  String get addRecipeSave;

  /// Сообщение внизу формы создания рецепта, когда фото не получено от камеры или альбома или не проанализировано
  ///
  /// In ru, this message translates to:
  /// **'Не удалось добавить фото'**
  String get addRecipeAddPhotoFailed;

  /// Сообщение после закрытия формы, когда рецепт сохранён, а его фото записать не удалось
  ///
  /// In ru, this message translates to:
  /// **'Рецепт сохранён без фото'**
  String get addRecipeSavedWithoutPhotos;

  /// Заголовок полноэкранного просмотра фото с номером показанного фото и их общим числом
  ///
  /// In ru, this message translates to:
  /// **'{index} из {count}'**
  String imagesPageCounter(int index, int count);

  /// Подсказка и метка для скринридера у кнопки удаления в полноэкранном просмотре фото
  ///
  /// In ru, this message translates to:
  /// **'Удалить фото'**
  String get imagesPageDelete;

  /// Заголовок диалога подтверждения удаления фото
  ///
  /// In ru, this message translates to:
  /// **'Удалить фото?'**
  String get imagesPageDeleteTitle;

  /// Кнопка диалога подтверждения, отменяющая удаление фото
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get imagesPageDeleteCancel;

  /// Кнопка диалога подтверждения, удаляющая фото
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get imagesPageDeleteConfirm;

  /// Сообщение внизу экрана, когда удаление фото не записалось в хранилище
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить фото'**
  String get imagesPageDeleteFailed;

  /// Подпись поверх фото в полноэкранном просмотре, когда на нём не найдено ни одного объекта
  ///
  /// In ru, this message translates to:
  /// **'Объекты не найдены'**
  String get imagesPageNoObjects;

  /// Подпись автора у комментария, оставленного текущим пользователем
  ///
  /// In ru, this message translates to:
  /// **'Вы'**
  String get commentAuthorYou;

  /// Подсказка и метка для скринридера у кнопки меню языка в AppBar списка рецептов
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get languageMenuTooltip;

  /// Пункт меню языка, при котором интерфейс следует языку устройства
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get languageSystem;

  /// Пункт меню языка с русским; название языка на нём самом, чтобы его узнал и тот, кто не читает текущий язык
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// Пункт меню языка с английским; название языка на нём самом, чтобы его узнал и тот, кто не читает текущий язык
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEnglish;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
