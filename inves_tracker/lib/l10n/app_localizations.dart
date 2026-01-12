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

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

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

  /// No description provided for @crypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get crypto;

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

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'debt'**
  String get debt;

  /// No description provided for @asset.
  ///
  /// In en, this message translates to:
  /// **'asset'**
  String get asset;

  /// No description provided for @loadingMarketData.
  ///
  /// In en, this message translates to:
  /// **'Loading market data...'**
  String get loadingMarketData;

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedToLoadData;

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

  /// No description provided for @designer.
  ///
  /// In en, this message translates to:
  /// **'Designer'**
  String get designer;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

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

  /// No description provided for @currencyTRY.
  ///
  /// In en, this message translates to:
  /// **'Turkish Lira'**
  String get currencyTRY;

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

  /// No description provided for @currencyNZD.
  ///
  /// In en, this message translates to:
  /// **'New Zealand Dollar'**
  String get currencyNZD;

  /// No description provided for @currencySGD.
  ///
  /// In en, this message translates to:
  /// **'Singapore Dollar'**
  String get currencySGD;

  /// No description provided for @currencyHKD.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Dollar'**
  String get currencyHKD;

  /// No description provided for @currencyTHB.
  ///
  /// In en, this message translates to:
  /// **'Thai Baht'**
  String get currencyTHB;

  /// No description provided for @currencyPLN.
  ///
  /// In en, this message translates to:
  /// **'Polish Zloty'**
  String get currencyPLN;

  /// No description provided for @currencyCZK.
  ///
  /// In en, this message translates to:
  /// **'Czech Koruna'**
  String get currencyCZK;

  /// No description provided for @currencyHUF.
  ///
  /// In en, this message translates to:
  /// **'Hungarian Forint'**
  String get currencyHUF;

  /// No description provided for @currencyRON.
  ///
  /// In en, this message translates to:
  /// **'Romanian Leu'**
  String get currencyRON;

  /// No description provided for @currencyQAR.
  ///
  /// In en, this message translates to:
  /// **'Qatari Riyal'**
  String get currencyQAR;

  /// No description provided for @currencyBHD.
  ///
  /// In en, this message translates to:
  /// **'Bahraini Dinar'**
  String get currencyBHD;

  /// No description provided for @currencyOMR.
  ///
  /// In en, this message translates to:
  /// **'Omani Rial'**
  String get currencyOMR;

  /// No description provided for @currencyINR.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee'**
  String get currencyINR;

  /// No description provided for @currencyPKR.
  ///
  /// In en, this message translates to:
  /// **'Pakistani Rupee'**
  String get currencyPKR;

  /// No description provided for @currencyIDR.
  ///
  /// In en, this message translates to:
  /// **'Indonesian Rupiah'**
  String get currencyIDR;

  /// No description provided for @currencyMYR.
  ///
  /// In en, this message translates to:
  /// **'Malaysian Ringgit'**
  String get currencyMYR;

  /// No description provided for @currencyPHP.
  ///
  /// In en, this message translates to:
  /// **'Philippine Peso'**
  String get currencyPHP;

  /// No description provided for @currencyMXN.
  ///
  /// In en, this message translates to:
  /// **'Mexican Peso'**
  String get currencyMXN;

  /// No description provided for @currencyBRL.
  ///
  /// In en, this message translates to:
  /// **'Brazilian Real'**
  String get currencyBRL;

  /// No description provided for @currencyARS.
  ///
  /// In en, this message translates to:
  /// **'Argentine Peso'**
  String get currencyARS;

  /// No description provided for @currencyCLP.
  ///
  /// In en, this message translates to:
  /// **'Chilean Peso'**
  String get currencyCLP;

  /// No description provided for @currencyCOP.
  ///
  /// In en, this message translates to:
  /// **'Colombian Peso'**
  String get currencyCOP;

  /// No description provided for @currencyPEN.
  ///
  /// In en, this message translates to:
  /// **'Peruvian Sol'**
  String get currencyPEN;

  /// No description provided for @currencyUYU.
  ///
  /// In en, this message translates to:
  /// **'Uruguayan Peso'**
  String get currencyUYU;

  /// No description provided for @currencyCRC.
  ///
  /// In en, this message translates to:
  /// **'Costa Rican Colon'**
  String get currencyCRC;

  /// No description provided for @currencyUAH.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian Hryvnia'**
  String get currencyUAH;

  /// No description provided for @currencyGEL.
  ///
  /// In en, this message translates to:
  /// **'Georgian Lari'**
  String get currencyGEL;

  /// No description provided for @currencyAZN.
  ///
  /// In en, this message translates to:
  /// **'Azerbaijani Manat'**
  String get currencyAZN;

  /// No description provided for @currencyMKD.
  ///
  /// In en, this message translates to:
  /// **'Macedonian Denar'**
  String get currencyMKD;

  /// No description provided for @currencyBGN.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian Lev'**
  String get currencyBGN;

  /// No description provided for @currencyBAM.
  ///
  /// In en, this message translates to:
  /// **'Bosnia and Herzegovina Mark'**
  String get currencyBAM;

  /// No description provided for @currencyMDL.
  ///
  /// In en, this message translates to:
  /// **'Moldovan Leu'**
  String get currencyMDL;

  /// No description provided for @currencyALL.
  ///
  /// In en, this message translates to:
  /// **'Albanian Lek'**
  String get currencyALL;

  /// No description provided for @currencyLBP.
  ///
  /// In en, this message translates to:
  /// **'Lebanese Pound'**
  String get currencyLBP;

  /// No description provided for @currencyEGP.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Pound'**
  String get currencyEGP;

  /// No description provided for @currencyDZD.
  ///
  /// In en, this message translates to:
  /// **'Algerian Dinar'**
  String get currencyDZD;

  /// No description provided for @currencyTND.
  ///
  /// In en, this message translates to:
  /// **'Tunisian Dinar'**
  String get currencyTND;

  /// No description provided for @currencySYP.
  ///
  /// In en, this message translates to:
  /// **'Syrian Pound'**
  String get currencySYP;

  /// No description provided for @currencyISK.
  ///
  /// In en, this message translates to:
  /// **'Icelandic Krona'**
  String get currencyISK;

  /// No description provided for @currencyKZT.
  ///
  /// In en, this message translates to:
  /// **'Kazakhstani Tenge'**
  String get currencyKZT;

  /// No description provided for @currencyCNY.
  ///
  /// In en, this message translates to:
  /// **'Chinese Yuan'**
  String get currencyCNY;

  /// No description provided for @currencyTWD.
  ///
  /// In en, this message translates to:
  /// **'New Taiwan Dollar'**
  String get currencyTWD;

  /// No description provided for @currencyKRW.
  ///
  /// In en, this message translates to:
  /// **'South Korean Won'**
  String get currencyKRW;

  /// No description provided for @currencyILS.
  ///
  /// In en, this message translates to:
  /// **'Israeli New Shekel'**
  String get currencyILS;

  /// No description provided for @currencyIQD.
  ///
  /// In en, this message translates to:
  /// **'Iraqi Dinar'**
  String get currencyIQD;

  /// No description provided for @currencyLYD.
  ///
  /// In en, this message translates to:
  /// **'Libyan Dinar'**
  String get currencyLYD;

  /// No description provided for @currencyIRR.
  ///
  /// In en, this message translates to:
  /// **'Iranian Rial'**
  String get currencyIRR;

  /// No description provided for @currencyMAD.
  ///
  /// In en, this message translates to:
  /// **'Moroccan Dirham'**
  String get currencyMAD;

  /// No description provided for @currencyZAR.
  ///
  /// In en, this message translates to:
  /// **'South African Rand'**
  String get currencyZAR;

  /// No description provided for @currencyLKR.
  ///
  /// In en, this message translates to:
  /// **'Sri Lankan Rupee'**
  String get currencyLKR;

  /// No description provided for @myAssets.
  ///
  /// In en, this message translates to:
  /// **'My Assets'**
  String get myAssets;

  /// No description provided for @myDebts.
  ///
  /// In en, this message translates to:
  /// **'My Debts'**
  String get myDebts;

  /// No description provided for @addAsset.
  ///
  /// In en, this message translates to:
  /// **'Add Asset'**
  String get addAsset;

  /// No description provided for @addDebt.
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDebt;

  /// No description provided for @editAsset.
  ///
  /// In en, this message translates to:
  /// **'Edit Asset'**
  String get editAsset;

  /// No description provided for @editDebt.
  ///
  /// In en, this message translates to:
  /// **'Edit Debt'**
  String get editDebt;

  /// No description provided for @debtDetails.
  ///
  /// In en, this message translates to:
  /// **'Debt Details'**
  String get debtDetails;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get purchasePrice;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @exchangeType.
  ///
  /// In en, this message translates to:
  /// **'Exchange Type'**
  String get exchangeType;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @selectGold.
  ///
  /// In en, this message translates to:
  /// **'Select Gold'**
  String get selectGold;

  /// No description provided for @selectCrypto.
  ///
  /// In en, this message translates to:
  /// **'Select Crypto'**
  String get selectCrypto;

  /// No description provided for @preciousMetals.
  ///
  /// In en, this message translates to:
  /// **'Precious Metals'**
  String get preciousMetals;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @noAssetsYet.
  ///
  /// In en, this message translates to:
  /// **'No assets yet'**
  String get noAssetsYet;

  /// No description provided for @noDebtsYet.
  ///
  /// In en, this message translates to:
  /// **'No debts yet'**
  String get noDebtsYet;

  /// No description provided for @deleteAsset.
  ///
  /// In en, this message translates to:
  /// **'Delete Asset'**
  String get deleteAsset;

  /// No description provided for @deleteDebt.
  ///
  /// In en, this message translates to:
  /// **'Delete Debt'**
  String get deleteDebt;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteAsset.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this asset?'**
  String get confirmDeleteAsset;

  /// No description provided for @confirmDeleteDebt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this debt?'**
  String get confirmDeleteDebt;

  /// No description provided for @assetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Asset deleted successfully'**
  String get assetDeleted;

  /// No description provided for @debtDeleted.
  ///
  /// In en, this message translates to:
  /// **'Debt deleted successfully'**
  String get debtDeleted;

  /// No description provided for @assetAdded.
  ///
  /// In en, this message translates to:
  /// **'Asset added successfully'**
  String get assetAdded;

  /// No description provided for @debtAdded.
  ///
  /// In en, this message translates to:
  /// **'Debt added successfully'**
  String get debtAdded;

  /// No description provided for @assetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Asset updated successfully'**
  String get assetUpdated;

  /// No description provided for @debtUpdated.
  ///
  /// In en, this message translates to:
  /// **'Debt updated successfully'**
  String get debtUpdated;

  /// No description provided for @failedToDeleteAsset.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete asset'**
  String get failedToDeleteAsset;

  /// No description provided for @failedToDeleteDebt.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete debt'**
  String get failedToDeleteDebt;

  /// No description provided for @failedToAddAsset.
  ///
  /// In en, this message translates to:
  /// **'Failed to add asset'**
  String get failedToAddAsset;

  /// No description provided for @failedToAddDebt.
  ///
  /// In en, this message translates to:
  /// **'Failed to add debt'**
  String get failedToAddDebt;

  /// No description provided for @failedToUpdateAsset.
  ///
  /// In en, this message translates to:
  /// **'Failed to update asset'**
  String get failedToUpdateAsset;

  /// No description provided for @failedToUpdateDebt.
  ///
  /// In en, this message translates to:
  /// **'Failed to update debt'**
  String get failedToUpdateDebt;

  /// No description provided for @subscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription required to add more debts'**
  String get subscriptionRequired;

  /// No description provided for @debtLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Free users can only have 1 debt'**
  String get debtLimitReached;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @totalDebt.
  ///
  /// In en, this message translates to:
  /// **'Total Debt'**
  String get totalDebt;

  /// No description provided for @pleaseSelectEntity.
  ///
  /// In en, this message translates to:
  /// **'Please select an entity'**
  String get pleaseSelectEntity;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get noteOptional;

  /// No description provided for @dueDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Due Date (Optional)'**
  String get dueDateOptional;

  /// No description provided for @clearDueDate.
  ///
  /// In en, this message translates to:
  /// **'Clear due date'**
  String get clearDueDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @freeUsersCanOnlyHaveOneDebt.
  ///
  /// In en, this message translates to:
  /// **'Free users can only have 1 debt record. Please upgrade to Premium to add unlimited debts.'**
  String get freeUsersCanOnlyHaveOneDebt;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat Password'**
  String get repeatPassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidEmailOrPassword;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseRepeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Please repeat your password'**
  String get pleaseRepeatPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMustBeAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMustBeAtLeast8Characters;

  /// No description provided for @pleaseEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get pleaseEnterFirstName;

  /// No description provided for @pleaseEnterLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get pleaseEnterLastName;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @iAccept.
  ///
  /// In en, this message translates to:
  /// **'I accept'**
  String get iAccept;

  /// No description provided for @dataProtectionNotice.
  ///
  /// In en, this message translates to:
  /// **'Data Protection Notice'**
  String get dataProtectionNotice;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @explicitConsent.
  ///
  /// In en, this message translates to:
  /// **'Explicit Consent'**
  String get explicitConsent;

  /// No description provided for @pleaseAcceptAllConsents.
  ///
  /// In en, this message translates to:
  /// **'Please accept all consents to continue'**
  String get pleaseAcceptAllConsents;

  /// No description provided for @dataProtectionNoticeText.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL DATA PROCESSING NOTICE\n\nThis notice has been prepared by InvesTracker as the data controller in accordance with Article 10 of the Law on the Protection of Personal Data No. 6698 (“KVKK”). InvesTracker processes personal data within the scope of using the mobile application for account creation, financial tracking services, application functionality, and service continuity. The processed data includes first name, last name, phone number, password, and the foreign currency, gold, cryptocurrency asset, and debt information declared by the user.\n\nData is collected electronically and automatically. Processing is based on KVKK Article 5/2(c), 5/2(ç), and 5/2(f). No special categories of personal data are processed.\n\nPersonal data is not shared with any third party, is not transferred domestically or internationally, and is stored only on secure servers located in Turkey. Data may be shared only when legally required.\n\nData is retained as long as the account is active. Upon deletion request, all data is permanently removed.\n\nUnder Article 11 of KVKK, you may request information, correction, deletion, or restriction of your data. Requests can be submitted to investrackerapp@gmail.com.'**
  String get dataProtectionNoticeText;

  /// No description provided for @privacyPolicyText.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY POLICY\n\nAt InvesTracker, we prioritize the privacy and security of users’ personal data. This Privacy Policy explains how data collected through the mobile application is stored, processed, used, and protected. The application processes personal information such as name, surname, phone number, password, and user-declared foreign currency, gold, cryptocurrency assets, and debt information solely for providing financial tracking services.\n\nData is securely stored and not used for purposes other than account creation, application functionality, and service continuity. Data is not shared with third parties nor transferred domestically or internationally. It may be shared only with authorized authorities when required by law.\n\nUsers may request account or data deletion at any time. All data will be permanently erased. Updates to this Privacy Policy will be announced through the application.'**
  String get privacyPolicyText;

  /// No description provided for @explicitConsentText.
  ///
  /// In en, this message translates to:
  /// **'CONSENT FORM\n\nBy using the services offered by InvesTracker, the financial data you declare (foreign currency, gold, cryptocurrency assets, debts) is processed solely to enable financial tracking features. No special categories of personal data are processed.\n\nAlthough personal data related to account creation is processed under KVKK legal grounds, explicit consent is required for storing financial data within the application. These data are stored on secure servers in Turkey and not shared with third parties. Upon account or data deletion request, all financial data will be permanently erased.\n\nYou may withdraw your consent at any time by contacting investrackerapp@gmail.com. Upon withdrawal, all related data will be deleted from our systems.'**
  String get explicitConsentText;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @totalAssets.
  ///
  /// In en, this message translates to:
  /// **'Total Assets'**
  String get totalAssets;

  /// No description provided for @portfolioBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Breakdown'**
  String get portfolioBreakdown;

  /// No description provided for @noAssetsOrDebtsYet.
  ///
  /// In en, this message translates to:
  /// **'No assets or debts yet'**
  String get noAssetsOrDebtsYet;

  /// No description provided for @thousand.
  ///
  /// In en, this message translates to:
  /// **'K'**
  String get thousand;

  /// No description provided for @million.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get million;

  /// No description provided for @billion.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get billion;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @profileDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile deleted successfully'**
  String get profileDeletedSuccessfully;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get errorUpdatingProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @failedToDeleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete profile'**
  String get failedToDeleteProfile;

  /// No description provided for @userInformation.
  ///
  /// In en, this message translates to:
  /// **'User Informaitons'**
  String get userInformation;

  /// No description provided for @enterPasswordToDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'To delete your account, please enter your password. This action is irreversible.'**
  String get enterPasswordToDeleteAccount;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @areYouSureToDeleteYourAccount.
  ///
  /// In en, this message translates to:
  /// **'You are about to delete your account. This action is irreversible and all your data will be permanently deleted. Are you sure?'**
  String get areYouSureToDeleteYourAccount;

  /// No description provided for @wordContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get wordContinue;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @pleaseConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmNewPassword;

  /// No description provided for @newPasswordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get newPasswordMustBeDifferent;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// No description provided for @errorChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error changing password'**
  String get errorChangingPassword;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequired;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of InvesTracker is required to continue. Please update from the Play Store.'**
  String get updateRequiredMessage;

  /// No description provided for @updateRecommendedMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of InvesTracker is available. We recommend updating for the best experience.'**
  String get updateRecommendedMessage;

  /// No description provided for @minimumVersion.
  ///
  /// In en, this message translates to:
  /// **'Minimum version'**
  String get minimumVersion;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendVerificationCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get enterVerificationCode;

  /// No description provided for @codeMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 digits'**
  String get codeMustBe6Digits;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @weSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to'**
  String get weSentCodeTo;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code? Request new one'**
  String get didntReceiveCode;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get resetPasswordSuccess;

  /// No description provided for @passwordResetSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset successfully. You can now log in with your new password.'**
  String get passwordResetSuccessMessage;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to your email'**
  String get verificationCodeSent;

  /// No description provided for @failedToSendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification code'**
  String get failedToSendVerificationCode;

  /// No description provided for @enterEmailForVerification.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a verification code to reset your password.'**
  String get enterEmailForVerification;

  /// No description provided for @failedToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password'**
  String get failedToResetPassword;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get incorrectPassword;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @piece.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get piece;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get pieces;

  /// No description provided for @gram.
  ///
  /// In en, this message translates to:
  /// **'Gram'**
  String get gram;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'Grams'**
  String get grams;
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
