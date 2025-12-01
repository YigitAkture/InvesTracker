import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @exchangeRates.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rates'**
  String get exchangeRates;

  /// No description provided for @addInvestment.
  ///
  /// In en, this message translates to:
  /// **'Add Investment'**
  String get addInvestment;

  /// No description provided for @currencyConverter.
  ///
  /// In en, this message translates to:
  /// **'Currency Converter'**
  String get currencyConverter;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @buying.
  ///
  /// In en, this message translates to:
  /// **'Buying'**
  String get buying;

  /// No description provided for @selling.
  ///
  /// In en, this message translates to:
  /// **'Selling'**
  String get selling;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @loadingMarketData.
  ///
  /// In en, this message translates to:
  /// **'Loading market data...'**
  String get loadingMarketData;

  /// No description provided for @failedToLoadMarketData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load market data'**
  String get failedToLoadMarketData;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noCurrencyDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No currency data available'**
  String get noCurrencyDataAvailable;

  /// No description provided for @noGoldDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No gold data available'**
  String get noGoldDataAvailable;

  /// No description provided for @noCryptoDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No crypto data available'**
  String get noCryptoDataAvailable;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less...'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More...'**
  String get showMore;

  /// No description provided for @currenciesAndMetals.
  ///
  /// In en, this message translates to:
  /// **'Currencies & Metals'**
  String get currenciesAndMetals;

  /// No description provided for @cryptoCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Crypto Currencies'**
  String get cryptoCurrencies;

  /// No description provided for @cryptoToCurrency.
  ///
  /// In en, this message translates to:
  /// **'Crypto to Currency'**
  String get cryptoToCurrency;

  /// No description provided for @currencyConverterTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency Converter'**
  String get currencyConverterTitle;

  /// No description provided for @goldToCurrency.
  ///
  /// In en, this message translates to:
  /// **'Gold to Currency'**
  String get goldToCurrency;

  /// No description provided for @loadingConverter.
  ///
  /// In en, this message translates to:
  /// **'Loading converter...'**
  String get loadingConverter;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @debts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debts;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

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

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @goldHAS.
  ///
  /// In en, this message translates to:
  /// **'Fine Gold'**
  String get goldHAS;

  /// No description provided for @goldGRA.
  ///
  /// In en, this message translates to:
  /// **'Gram of Gold'**
  String get goldGRA;

  /// No description provided for @goldCEYREKALTIN.
  ///
  /// In en, this message translates to:
  /// **'Quarter of Gold'**
  String get goldCEYREKALTIN;

  /// No description provided for @goldYARIMALTIN.
  ///
  /// In en, this message translates to:
  /// **'Half of Gold'**
  String get goldYARIMALTIN;

  /// No description provided for @goldTAMALTIN.
  ///
  /// In en, this message translates to:
  /// **'Full of Gold'**
  String get goldTAMALTIN;

  /// No description provided for @goldATAALTIN.
  ///
  /// In en, this message translates to:
  /// **'Ata Gold'**
  String get goldATAALTIN;

  /// No description provided for @goldRESATALTIN.
  ///
  /// In en, this message translates to:
  /// **'Resat Gold'**
  String get goldRESATALTIN;

  /// No description provided for @goldCUMHURIYETALTINI.
  ///
  /// In en, this message translates to:
  /// **'Republic Gold'**
  String get goldCUMHURIYETALTINI;

  /// No description provided for @goldGREMSEALTIN.
  ///
  /// In en, this message translates to:
  /// **'Gremse Gold'**
  String get goldGREMSEALTIN;

  /// No description provided for @gold14AYARALTIN.
  ///
  /// In en, this message translates to:
  /// **'14 Carat Gold'**
  String get gold14AYARALTIN;

  /// No description provided for @gold18AYARALTIN.
  ///
  /// In en, this message translates to:
  /// **'18 Carat Gold'**
  String get gold18AYARALTIN;

  /// No description provided for @goldYIA.
  ///
  /// In en, this message translates to:
  /// **'22 Carat Bracelet'**
  String get goldYIA;

  /// No description provided for @goldIKIBUCUKALTIN.
  ///
  /// In en, this message translates to:
  /// **'Two and a Half Gold'**
  String get goldIKIBUCUKALTIN;

  /// No description provided for @goldBESLIALTIN.
  ///
  /// In en, this message translates to:
  /// **'Five Piece Gold'**
  String get goldBESLIALTIN;

  /// No description provided for @currencyUSD.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currencyUSD;

  /// No description provided for @currencyEUR.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyEUR;

  /// No description provided for @currencyGBP.
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get currencyGBP;

  /// No description provided for @currencyCHF.
  ///
  /// In en, this message translates to:
  /// **'Swiss Franc'**
  String get currencyCHF;

  /// No description provided for @currencyCAD.
  ///
  /// In en, this message translates to:
  /// **'Canadian Dollar'**
  String get currencyCAD;

  /// No description provided for @currencyJPY.
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get currencyJPY;

  /// No description provided for @currencySAR.
  ///
  /// In en, this message translates to:
  /// **'Saudi Riyal'**
  String get currencySAR;

  /// No description provided for @currencyRUB.
  ///
  /// In en, this message translates to:
  /// **'Russian Ruble'**
  String get currencyRUB;

  /// No description provided for @currencyAED.
  ///
  /// In en, this message translates to:
  /// **'UAE Dirham'**
  String get currencyAED;

  /// No description provided for @currencyKWD.
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti Dinar'**
  String get currencyKWD;

  /// No description provided for @currencyAUD.
  ///
  /// In en, this message translates to:
  /// **'Australian Dollar'**
  String get currencyAUD;

  /// No description provided for @currencyDKK.
  ///
  /// In en, this message translates to:
  /// **'Danish Krone'**
  String get currencyDKK;

  /// No description provided for @currencySEK.
  ///
  /// In en, this message translates to:
  /// **'Swedish Krona'**
  String get currencySEK;

  /// No description provided for @currencyNOK.
  ///
  /// In en, this message translates to:
  /// **'Norwegian Krone'**
  String get currencyNOK;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
