import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tesserotto'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search cards...'**
  String get searchHint;

  /// No description provided for @noCards.
  ///
  /// In en, this message translates to:
  /// **'No cards yet. Tap + to add your first card!'**
  String get noCards;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editCard;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @cardName.
  ///
  /// In en, this message translates to:
  /// **'Card Name'**
  String get cardName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @cardColor.
  ///
  /// In en, this message translates to:
  /// **'Card Color'**
  String get cardColor;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescan;

  /// No description provided for @cancelScanning.
  ///
  /// In en, this message translates to:
  /// **'Cancel Scanning'**
  String get cancelScanning;

  /// No description provided for @cardInfo.
  ///
  /// In en, this message translates to:
  /// **'Card Info'**
  String get cardInfo;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCard;

  /// No description provided for @deleteCardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteCardConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @sortAZ.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortAZ;

  /// No description provided for @sortMostOpened.
  ///
  /// In en, this message translates to:
  /// **'Most Opened'**
  String get sortMostOpened;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @deleteCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Cardx2'**
  String get deleteCardTitle;

  /// No description provided for @deleteCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{cardName}\"?'**
  String deleteCardMessage(Object cardName);

  /// No description provided for @deleteCardCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteCardCancel;

  /// No description provided for @importExport.
  ///
  /// In en, this message translates to:
  /// **'Import/Export'**
  String get importExport;

  /// No description provided for @exportCards.
  ///
  /// In en, this message translates to:
  /// **'Export Cards'**
  String get exportCards;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your cards to a backup file'**
  String get exportDescription;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cards exported successfully'**
  String get exportSuccess;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting cards'**
  String get exportError;

  /// No description provided for @importCards.
  ///
  /// In en, this message translates to:
  /// **'Import Cards'**
  String get importCards;

  /// No description provided for @importDescription.
  ///
  /// In en, this message translates to:
  /// **'Import cards from a backup file'**
  String get importDescription;

  /// No description provided for @importCard.
  ///
  /// In en, this message translates to:
  /// **'Import Card'**
  String get importCard;

  /// No description provided for @importCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to import this card?'**
  String get importCardMessage;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cards imported successfully'**
  String get importSuccess;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Error importing cards'**
  String get importError;

  /// No description provided for @importFromCatima.
  ///
  /// In en, this message translates to:
  /// **'Import from Catima'**
  String get importFromCatima;

  /// No description provided for @importFromCatimaDescription.
  ///
  /// In en, this message translates to:
  /// **'Import cards from a Catima backup file'**
  String get importFromCatimaDescription;

  /// No description provided for @deleteAllCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Cards'**
  String get deleteAllCardsTitle;

  /// No description provided for @deleteAllCardsContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all cards? This action cannot be undone.'**
  String get deleteAllCardsContent;

  /// No description provided for @deleteAllCardsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get deleteAllCardsConfirm;

  /// No description provided for @shareCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out this loyalty card'**
  String get shareCardMessage;

  /// No description provided for @shareViaQr.
  ///
  /// In en, this message translates to:
  /// **'Share via QR code'**
  String get shareViaQr;

  /// No description provided for @shareViaLink.
  ///
  /// In en, this message translates to:
  /// **'Share via link'**
  String get shareViaLink;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
