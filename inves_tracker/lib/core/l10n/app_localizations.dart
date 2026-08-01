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
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz!'**
  String get welcome;

  /// No description provided for @myWallet.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdanım'**
  String get myWallet;

  /// No description provided for @exchangeRates.
  ///
  /// In tr, this message translates to:
  /// **'Döviz Kurları'**
  String get exchangeRates;

  /// No description provided for @addInvestment.
  ///
  /// In tr, this message translates to:
  /// **'Yatırım Ekle'**
  String get addInvestment;

  /// No description provided for @currencyConverter.
  ///
  /// In tr, this message translates to:
  /// **'Döviz Çevirici'**
  String get currencyConverter;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @currency.
  ///
  /// In tr, this message translates to:
  /// **'Döviz'**
  String get currency;

  /// No description provided for @crypto.
  ///
  /// In tr, this message translates to:
  /// **'Kripto'**
  String get crypto;

  /// No description provided for @buying.
  ///
  /// In tr, this message translates to:
  /// **'Alış'**
  String get buying;

  /// No description provided for @selling.
  ///
  /// In tr, this message translates to:
  /// **'Satış'**
  String get selling;

  /// No description provided for @gold.
  ///
  /// In tr, this message translates to:
  /// **'Altın'**
  String get gold;

  /// No description provided for @debt.
  ///
  /// In tr, this message translates to:
  /// **'borç'**
  String get debt;

  /// No description provided for @asset.
  ///
  /// In tr, this message translates to:
  /// **'varlık'**
  String get asset;

  /// No description provided for @updated.
  ///
  /// In tr, this message translates to:
  /// **'Güncellendi'**
  String get updated;

  /// No description provided for @loadingMarketData.
  ///
  /// In tr, this message translates to:
  /// **'Piyasa verileri yükleniyor...'**
  String get loadingMarketData;

  /// No description provided for @failedToLoadData.
  ///
  /// In tr, this message translates to:
  /// **'Veriler yüklenemedi'**
  String get failedToLoadData;

  /// No description provided for @failedToLoadMarketData.
  ///
  /// In tr, this message translates to:
  /// **'Piyasa verileri yüklenemedi'**
  String get failedToLoadMarketData;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @noCurrencyDataAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Döviz verisi mevcut değil'**
  String get noCurrencyDataAvailable;

  /// No description provided for @noGoldDataAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Altın verisi mevcut değil'**
  String get noGoldDataAvailable;

  /// No description provided for @noCryptoDataAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Kripto verisi mevcut değil'**
  String get noCryptoDataAvailable;

  /// No description provided for @showLess.
  ///
  /// In tr, this message translates to:
  /// **'Daha Az...'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In tr, this message translates to:
  /// **'Daha Fazla...'**
  String get showMore;

  /// No description provided for @currenciesAndMetals.
  ///
  /// In tr, this message translates to:
  /// **'Döviz & Metaller'**
  String get currenciesAndMetals;

  /// No description provided for @cryptoCurrencies.
  ///
  /// In tr, this message translates to:
  /// **'Kripto Para'**
  String get cryptoCurrencies;

  /// No description provided for @cryptoConverter.
  ///
  /// In tr, this message translates to:
  /// **'Kripto Para Çevirici'**
  String get cryptoConverter;

  /// No description provided for @currencyConverterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Döviz Çevirici'**
  String get currencyConverterTitle;

  /// No description provided for @metalConverter.
  ///
  /// In tr, this message translates to:
  /// **'Değerli Maden Çevirici'**
  String get metalConverter;

  /// No description provided for @loadingConverter.
  ///
  /// In tr, this message translates to:
  /// **'Çevirici yükleniyor...'**
  String get loadingConverter;

  /// No description provided for @anErrorOccurred.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get anErrorOccurred;

  /// No description provided for @assets.
  ///
  /// In tr, this message translates to:
  /// **'Varlıklar'**
  String get assets;

  /// No description provided for @debts.
  ///
  /// In tr, this message translates to:
  /// **'Borçlar'**
  String get debts;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Tema'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In tr, this message translates to:
  /// **'Aydınlık Tema'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @version.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In tr, this message translates to:
  /// **'Geliştirici'**
  String get developer;

  /// No description provided for @designer.
  ///
  /// In tr, this message translates to:
  /// **'Tasarımcı'**
  String get designer;

  /// No description provided for @goldGUMUS.
  ///
  /// In tr, this message translates to:
  /// **'Gram Gümüş'**
  String get goldGUMUS;

  /// No description provided for @goldGPL.
  ///
  /// In tr, this message translates to:
  /// **'Platin'**
  String get goldGPL;

  /// No description provided for @goldPAL.
  ///
  /// In tr, this message translates to:
  /// **'Paladyum'**
  String get goldPAL;

  /// No description provided for @goldHAS.
  ///
  /// In tr, this message translates to:
  /// **'Has Altın'**
  String get goldHAS;

  /// No description provided for @goldGRA.
  ///
  /// In tr, this message translates to:
  /// **'Gram Altın'**
  String get goldGRA;

  /// No description provided for @goldCEYREKALTIN.
  ///
  /// In tr, this message translates to:
  /// **'Çeyrek Altın'**
  String get goldCEYREKALTIN;

  /// No description provided for @goldYARIMALTIN.
  ///
  /// In tr, this message translates to:
  /// **'Yarım Altın'**
  String get goldYARIMALTIN;

  /// No description provided for @goldTAMALTIN.
  ///
  /// In tr, this message translates to:
  /// **'Tam Altın'**
  String get goldTAMALTIN;

  /// No description provided for @goldATAALTIN.
  ///
  /// In tr, this message translates to:
  /// **'Ata Altın'**
  String get goldATAALTIN;

  /// No description provided for @goldRESATALTIN.
  ///
  /// In tr, this message translates to:
  /// **'Reşat Altın'**
  String get goldRESATALTIN;

  /// No description provided for @goldCUMHURIYETALTINI.
  ///
  /// In tr, this message translates to:
  /// **'Cumhuriyet Altını'**
  String get goldCUMHURIYETALTINI;

  /// No description provided for @goldGREMSEALTIN.
  ///
  /// In tr, this message translates to:
  /// **'Gremse Altın'**
  String get goldGREMSEALTIN;

  /// No description provided for @gold14AYARALTIN.
  ///
  /// In tr, this message translates to:
  /// **'14 Ayar Altın'**
  String get gold14AYARALTIN;

  /// No description provided for @gold18AYARALTIN.
  ///
  /// In tr, this message translates to:
  /// **'18 Ayar Altın'**
  String get gold18AYARALTIN;

  /// No description provided for @goldYIA.
  ///
  /// In tr, this message translates to:
  /// **'22 Ayar Bilezik'**
  String get goldYIA;

  /// No description provided for @goldIKIBUCUKALTIN.
  ///
  /// In tr, this message translates to:
  /// **'İkibuçuk Altın'**
  String get goldIKIBUCUKALTIN;

  /// No description provided for @goldBESLIALTIN.
  ///
  /// In tr, this message translates to:
  /// **'Beşli Altın'**
  String get goldBESLIALTIN;

  /// No description provided for @currencyTRY.
  ///
  /// In tr, this message translates to:
  /// **'Türk Lirası'**
  String get currencyTRY;

  /// No description provided for @currencyUSD.
  ///
  /// In tr, this message translates to:
  /// **'Amerikan Doları'**
  String get currencyUSD;

  /// No description provided for @currencyEUR.
  ///
  /// In tr, this message translates to:
  /// **'Avro'**
  String get currencyEUR;

  /// No description provided for @currencyGBP.
  ///
  /// In tr, this message translates to:
  /// **'İngiliz Sterlini'**
  String get currencyGBP;

  /// No description provided for @currencyCHF.
  ///
  /// In tr, this message translates to:
  /// **'İsviçre Frangı'**
  String get currencyCHF;

  /// No description provided for @currencyCAD.
  ///
  /// In tr, this message translates to:
  /// **'Kanada Doları'**
  String get currencyCAD;

  /// No description provided for @currencyJPY.
  ///
  /// In tr, this message translates to:
  /// **'Japon Yeni'**
  String get currencyJPY;

  /// No description provided for @currencySAR.
  ///
  /// In tr, this message translates to:
  /// **'Arabistan Riyali'**
  String get currencySAR;

  /// No description provided for @currencyRUB.
  ///
  /// In tr, this message translates to:
  /// **'Rus Rublesi'**
  String get currencyRUB;

  /// No description provided for @currencyAED.
  ///
  /// In tr, this message translates to:
  /// **'BAE Dirhemi'**
  String get currencyAED;

  /// No description provided for @currencyKWD.
  ///
  /// In tr, this message translates to:
  /// **'Kuveyt Dinarı'**
  String get currencyKWD;

  /// No description provided for @currencyAUD.
  ///
  /// In tr, this message translates to:
  /// **'Avustralya Doları'**
  String get currencyAUD;

  /// No description provided for @currencyDKK.
  ///
  /// In tr, this message translates to:
  /// **'Danimarka Kronu'**
  String get currencyDKK;

  /// No description provided for @currencySEK.
  ///
  /// In tr, this message translates to:
  /// **'İsveç Kronu'**
  String get currencySEK;

  /// No description provided for @currencyNOK.
  ///
  /// In tr, this message translates to:
  /// **'Norveç Kronu'**
  String get currencyNOK;

  /// No description provided for @currencyNZD.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Zelanda Doları'**
  String get currencyNZD;

  /// No description provided for @currencySGD.
  ///
  /// In tr, this message translates to:
  /// **'Singapur Doları'**
  String get currencySGD;

  /// No description provided for @currencyHKD.
  ///
  /// In tr, this message translates to:
  /// **'Hong Kong Doları'**
  String get currencyHKD;

  /// No description provided for @currencyTHB.
  ///
  /// In tr, this message translates to:
  /// **'Tayland Bahtı'**
  String get currencyTHB;

  /// No description provided for @currencyPLN.
  ///
  /// In tr, this message translates to:
  /// **'Polonya Zlotisi'**
  String get currencyPLN;

  /// No description provided for @currencyCZK.
  ///
  /// In tr, this message translates to:
  /// **'Çek Korunası'**
  String get currencyCZK;

  /// No description provided for @currencyHUF.
  ///
  /// In tr, this message translates to:
  /// **'Macar Forinti'**
  String get currencyHUF;

  /// No description provided for @currencyRON.
  ///
  /// In tr, this message translates to:
  /// **'Romen Leyi'**
  String get currencyRON;

  /// No description provided for @currencyQAR.
  ///
  /// In tr, this message translates to:
  /// **'Katar Riyali'**
  String get currencyQAR;

  /// No description provided for @currencyBHD.
  ///
  /// In tr, this message translates to:
  /// **'Bahreyn Dinarı'**
  String get currencyBHD;

  /// No description provided for @currencyOMR.
  ///
  /// In tr, this message translates to:
  /// **'Umman Riyali'**
  String get currencyOMR;

  /// No description provided for @currencyINR.
  ///
  /// In tr, this message translates to:
  /// **'Hindistan Rupisi'**
  String get currencyINR;

  /// No description provided for @currencyPKR.
  ///
  /// In tr, this message translates to:
  /// **'Pakistan Rupisi'**
  String get currencyPKR;

  /// No description provided for @currencyIDR.
  ///
  /// In tr, this message translates to:
  /// **'Endonezya Rupisi'**
  String get currencyIDR;

  /// No description provided for @currencyMYR.
  ///
  /// In tr, this message translates to:
  /// **'Malezya Ringgiti'**
  String get currencyMYR;

  /// No description provided for @currencyPHP.
  ///
  /// In tr, this message translates to:
  /// **'Filipin Pesosu'**
  String get currencyPHP;

  /// No description provided for @currencyMXN.
  ///
  /// In tr, this message translates to:
  /// **'Meksika Pesosu'**
  String get currencyMXN;

  /// No description provided for @currencyBRL.
  ///
  /// In tr, this message translates to:
  /// **'Brezilya Reali'**
  String get currencyBRL;

  /// No description provided for @currencyARS.
  ///
  /// In tr, this message translates to:
  /// **'Arjantin Pesosu'**
  String get currencyARS;

  /// No description provided for @currencyCLP.
  ///
  /// In tr, this message translates to:
  /// **'Şili Pesosu'**
  String get currencyCLP;

  /// No description provided for @currencyCOP.
  ///
  /// In tr, this message translates to:
  /// **'Kolombiya Pesosu'**
  String get currencyCOP;

  /// No description provided for @currencyPEN.
  ///
  /// In tr, this message translates to:
  /// **'Peru Solü'**
  String get currencyPEN;

  /// No description provided for @currencyUYU.
  ///
  /// In tr, this message translates to:
  /// **'Uruguay Pesosu'**
  String get currencyUYU;

  /// No description provided for @currencyCRC.
  ///
  /// In tr, this message translates to:
  /// **'Kosta Rika Kolonu'**
  String get currencyCRC;

  /// No description provided for @currencyUAH.
  ///
  /// In tr, this message translates to:
  /// **'Ukrayna Grivnası'**
  String get currencyUAH;

  /// No description provided for @currencyGEL.
  ///
  /// In tr, this message translates to:
  /// **'Gürcistan Larisi'**
  String get currencyGEL;

  /// No description provided for @currencyAZN.
  ///
  /// In tr, this message translates to:
  /// **'Azerbaycan Manatı'**
  String get currencyAZN;

  /// No description provided for @currencyMKD.
  ///
  /// In tr, this message translates to:
  /// **'Makedon Dinarı'**
  String get currencyMKD;

  /// No description provided for @currencyBGN.
  ///
  /// In tr, this message translates to:
  /// **'Bulgar Levası'**
  String get currencyBGN;

  /// No description provided for @currencyBAM.
  ///
  /// In tr, this message translates to:
  /// **'Bosna-Hersek Markı'**
  String get currencyBAM;

  /// No description provided for @currencyMDL.
  ///
  /// In tr, this message translates to:
  /// **'Moldova Leyi'**
  String get currencyMDL;

  /// No description provided for @currencyALL.
  ///
  /// In tr, this message translates to:
  /// **'Arnavutluk Leki'**
  String get currencyALL;

  /// No description provided for @currencyLBP.
  ///
  /// In tr, this message translates to:
  /// **'Lübnan Lirası'**
  String get currencyLBP;

  /// No description provided for @currencyEGP.
  ///
  /// In tr, this message translates to:
  /// **'Mısır Lirası'**
  String get currencyEGP;

  /// No description provided for @currencyDZD.
  ///
  /// In tr, this message translates to:
  /// **'Cezayir Dinarı'**
  String get currencyDZD;

  /// No description provided for @currencyTND.
  ///
  /// In tr, this message translates to:
  /// **'Tunus Dinarı'**
  String get currencyTND;

  /// No description provided for @currencySYP.
  ///
  /// In tr, this message translates to:
  /// **'Suriye Lirası'**
  String get currencySYP;

  /// No description provided for @currencyISK.
  ///
  /// In tr, this message translates to:
  /// **'İzlanda Kronu'**
  String get currencyISK;

  /// No description provided for @currencyKZT.
  ///
  /// In tr, this message translates to:
  /// **'Kazakistan Tengesi'**
  String get currencyKZT;

  /// No description provided for @currencyCNY.
  ///
  /// In tr, this message translates to:
  /// **'Çin Yuanı'**
  String get currencyCNY;

  /// No description provided for @currencyTWD.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Tayvan Doları'**
  String get currencyTWD;

  /// No description provided for @currencyKRW.
  ///
  /// In tr, this message translates to:
  /// **'Güney Kore Wonu'**
  String get currencyKRW;

  /// No description provided for @currencyILS.
  ///
  /// In tr, this message translates to:
  /// **'İsrail Yeni Şekeli'**
  String get currencyILS;

  /// No description provided for @currencyIQD.
  ///
  /// In tr, this message translates to:
  /// **'Irak Dinarı'**
  String get currencyIQD;

  /// No description provided for @currencyLYD.
  ///
  /// In tr, this message translates to:
  /// **'Libya Dinarı'**
  String get currencyLYD;

  /// No description provided for @currencyIRR.
  ///
  /// In tr, this message translates to:
  /// **'İran Riyali'**
  String get currencyIRR;

  /// No description provided for @currencyMAD.
  ///
  /// In tr, this message translates to:
  /// **'Fas Dirhemi'**
  String get currencyMAD;

  /// No description provided for @currencyZAR.
  ///
  /// In tr, this message translates to:
  /// **'Güney Afrika Randı'**
  String get currencyZAR;

  /// No description provided for @currencyLKR.
  ///
  /// In tr, this message translates to:
  /// **'Sri Lanka Rupisi'**
  String get currencyLKR;

  /// No description provided for @myAssets.
  ///
  /// In tr, this message translates to:
  /// **'Varlıklarım'**
  String get myAssets;

  /// No description provided for @myDebts.
  ///
  /// In tr, this message translates to:
  /// **'Borçlarım'**
  String get myDebts;

  /// No description provided for @addAsset.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Ekle'**
  String get addAsset;

  /// No description provided for @addDebt.
  ///
  /// In tr, this message translates to:
  /// **'Borç Ekle'**
  String get addDebt;

  /// No description provided for @editAsset.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Düzenle'**
  String get editAsset;

  /// No description provided for @editDebt.
  ///
  /// In tr, this message translates to:
  /// **'Borç Düzenle'**
  String get editDebt;

  /// No description provided for @debtDetails.
  ///
  /// In tr, this message translates to:
  /// **'Borç Detayları'**
  String get debtDetails;

  /// No description provided for @amount.
  ///
  /// In tr, this message translates to:
  /// **'Miktar'**
  String get amount;

  /// No description provided for @purchasePrice.
  ///
  /// In tr, this message translates to:
  /// **'Alış Fiyatı'**
  String get purchasePrice;

  /// No description provided for @note.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get note;

  /// No description provided for @dueDate.
  ///
  /// In tr, this message translates to:
  /// **'Son Ödeme Tarihi'**
  String get dueDate;

  /// No description provided for @optional.
  ///
  /// In tr, this message translates to:
  /// **'Opsiyonel'**
  String get optional;

  /// No description provided for @exchangeType.
  ///
  /// In tr, this message translates to:
  /// **'Döviz Tipi'**
  String get exchangeType;

  /// No description provided for @selectCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Para Birimi Seç'**
  String get selectCurrency;

  /// No description provided for @selectGold.
  ///
  /// In tr, this message translates to:
  /// **'Altın Seç'**
  String get selectGold;

  /// No description provided for @selectCrypto.
  ///
  /// In tr, this message translates to:
  /// **'Kripto Seç'**
  String get selectCrypto;

  /// No description provided for @preciousMetals.
  ///
  /// In tr, this message translates to:
  /// **'Değerli Madenler'**
  String get preciousMetals;

  /// No description provided for @metal.
  ///
  /// In tr, this message translates to:
  /// **'Maden'**
  String get metal;

  /// No description provided for @totalAmount.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Miktar'**
  String get totalAmount;

  /// No description provided for @noAssetsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz varlık yok'**
  String get noAssetsYet;

  /// No description provided for @noDebtsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz borç yok'**
  String get noDebtsYet;

  /// No description provided for @deleteAsset.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Sil'**
  String get deleteAsset;

  /// No description provided for @deleteDebt.
  ///
  /// In tr, this message translates to:
  /// **'Borç Sil'**
  String get deleteDebt;

  /// No description provided for @confirmDelete.
  ///
  /// In tr, this message translates to:
  /// **'Bunu silmek istediğinizden emin misiniz?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteAsset.
  ///
  /// In tr, this message translates to:
  /// **'Bu varlığı silmek istediğinizden emin misiniz?'**
  String get confirmDeleteAsset;

  /// No description provided for @confirmDeleteDebt.
  ///
  /// In tr, this message translates to:
  /// **'Bu borcu silmek istediğinizden emin misiniz?'**
  String get confirmDeleteDebt;

  /// No description provided for @assetDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Varlık başarıyla silindi'**
  String get assetDeleted;

  /// No description provided for @debtDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Borç başarıyla silindi'**
  String get debtDeleted;

  /// No description provided for @assetAdded.
  ///
  /// In tr, this message translates to:
  /// **'Varlık başarıyla eklendi'**
  String get assetAdded;

  /// No description provided for @debtAdded.
  ///
  /// In tr, this message translates to:
  /// **'Borç başarıyla eklendi'**
  String get debtAdded;

  /// No description provided for @assetUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Varlık başarıyla güncellendi'**
  String get assetUpdated;

  /// No description provided for @debtUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Borç başarıyla güncellendi'**
  String get debtUpdated;

  /// No description provided for @failedToDeleteAsset.
  ///
  /// In tr, this message translates to:
  /// **'Varlık silinirken bir hata oluştu'**
  String get failedToDeleteAsset;

  /// No description provided for @failedToDeleteDebt.
  ///
  /// In tr, this message translates to:
  /// **'Borç silinirken bir hata oluştu'**
  String get failedToDeleteDebt;

  /// No description provided for @failedToAddAsset.
  ///
  /// In tr, this message translates to:
  /// **'Varlık eklenirken bir hata oluştu'**
  String get failedToAddAsset;

  /// No description provided for @failedToAddDebt.
  ///
  /// In tr, this message translates to:
  /// **'Borç eklenirken bir hata oluştu'**
  String get failedToAddDebt;

  /// No description provided for @failedToUpdateAsset.
  ///
  /// In tr, this message translates to:
  /// **'Varlık güncellenirken bir hata oluştu'**
  String get failedToUpdateAsset;

  /// No description provided for @failedToUpdateDebt.
  ///
  /// In tr, this message translates to:
  /// **'Borç güncellenirken bir hata oluştu'**
  String get failedToUpdateDebt;

  /// No description provided for @subscriptionRequired.
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla borç eklemek için Premium abonelik gerekli'**
  String get subscriptionRequired;

  /// No description provided for @debtLimitReached.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz kullanıcılar sadece 1 borç ekleyebilir'**
  String get debtLimitReached;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @update.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get update;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @created.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturuldu'**
  String get created;

  /// No description provided for @totalDebt.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Borç'**
  String get totalDebt;

  /// No description provided for @pleaseSelectEntity.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir birim seçiniz'**
  String get pleaseSelectEntity;

  /// No description provided for @enterValidAmount.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir miktar giriniz'**
  String get enterValidAmount;

  /// No description provided for @noteOptional.
  ///
  /// In tr, this message translates to:
  /// **'Not (Opsiyonel)'**
  String get noteOptional;

  /// No description provided for @dueDateOptional.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Tarihi (Opsiyonel)'**
  String get dueDateOptional;

  /// No description provided for @clearDueDate.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme tarihini temizle'**
  String get clearDueDate;

  /// No description provided for @selectDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih seçiniz'**
  String get selectDate;

  /// No description provided for @freeUsersCanOnlyHaveOneDebt.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz kullanıcıların yalnızca 1 borç kaydedebilir. Sınırsız borç eklemek için lütfen Premium\'a yükseltin.'**
  String get freeUsersCanOnlyHaveOneDebt;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @register.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @repeatPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get repeatPassword;

  /// No description provided for @firstName.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In tr, this message translates to:
  /// **'Telefon Numarası'**
  String get phoneNumber;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre geçersiz'**
  String get invalidEmailOrPassword;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu?'**
  String get dontHaveAnAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabınız var mı?'**
  String get alreadyHaveAccount;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen e-postanızı girin'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir e-posta girin'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen şifrenizi girin'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseRepeatPassword.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen şifrenizi tekrar girin'**
  String get pleaseRepeatPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMustBeAtLeast8Characters.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 8 karakter olmalıdır'**
  String get passwordMustBeAtLeast8Characters;

  /// No description provided for @pleaseEnterFirstName.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen adınızı girin'**
  String get pleaseEnterFirstName;

  /// No description provided for @pleaseEnterLastName.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen soyadınızı girin'**
  String get pleaseEnterLastName;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen telefon numaranızı girin'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @logoutConfirmation.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapmak istediğinizden emin misiniz?'**
  String get logoutConfirmation;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @iAccept.
  ///
  /// In tr, this message translates to:
  /// **'Kabul ediyorum'**
  String get iAccept;

  /// No description provided for @dataProtectionNotice.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Verilerin Korunması Bildirimi'**
  String get dataProtectionNotice;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @explicitConsent.
  ///
  /// In tr, this message translates to:
  /// **'Açık Rıza Metni'**
  String get explicitConsent;

  /// No description provided for @pleaseAcceptAllConsents.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için lütfen tüm onayları kabul edin'**
  String get pleaseAcceptAllConsents;

  /// No description provided for @dataProtectionNoticeText.
  ///
  /// In tr, this message translates to:
  /// **'KİŞİSEL VERİLERİN İŞLENMESİ AYDINLATMA METNİ\n\nBu aydınlatma metni, 6698 sayılı Kişisel Verilerin Korunması Kanununun (“KVKK”) 10 uncu maddesi uyarınca veri sorumlusu sıfatıyla InvesTracker tarafından hazırlanmıştır. InvesTracker, mobil uygulamanın kullanımı kapsamında kullanıcı hesaplarının oluşturulması ve yönetilmesi, finansal takip hizmetinin sunulması, uygulama fonksiyonlarının işletilmesi ve hizmet sürekliliğinin sağlanması amacıyla kişisel veri işlemektedir. Bu kapsamda ad, soyad, telefon numarası, şifre bilgisi ile kullanıcı tarafından uygulama üzerinden beyan edilen döviz, altın, kripto varlık ve borç bilgileri, uygulamanın sağladığı hizmetlerden yararlanılabilmesi için işlenen kişisel verilerdir.\n\nKişisel veriler elektronik ortamda otomatik yollarla elde edilmekte olup, kullanıcı hesabı oluşturma ve finansal veri girişleri sırasında işlenmektedir. Veriler KVKK m.5/2(c), m.5/2(ç) ve m.5/2(f) hükümlerine dayanılarak işlenmektedir. Uygulama kapsamında özel nitelikli kişisel veri işlenmemektedir.\n\nİşlenen kişisel veriler InvesTracker ekibi dışında üçüncü kişilerle paylaşılmamakta, yurt içine veya yurt dışına aktarılmamakta ve yalnızca Türkiye’de bulunan güvenli sunucularda saklanmaktadır. Yasal zorunluluk halinde ilgili kamu kurumları ile paylaşılabilir.\n\nKullanıcı hesabı aktif olduğu sürece veriler saklanır. Hesap veya veri silme talebi üzerine tüm bilgiler kalıcı olarak silinir.\n\nKVKK madde 11 kapsamında; kişisel verilerinize ilişkin bilgi talep etme, düzeltilmesini veya silinmesini isteme, işleme faaliyetlerine itiraz etme gibi haklara sahipsiniz. Taleplerinizi investrackerapp@gmail.com adresine iletebilirsiniz.'**
  String get dataProtectionNoticeText;

  /// No description provided for @privacyPolicyText.
  ///
  /// In tr, this message translates to:
  /// **'GİZLİLİK POLİTİKASI\n\nInvesTracker olarak kullanıcılarımızın kişisel verilerinin gizliliğine ve güvenliğine önem veriyoruz. Bu Gizlilik Politikası, mobil uygulamada toplanan kişisel verilerin işlenmesi, saklanması, kullanılması ve korunmasına ilişkin esasları açıklar. Uygulamada ad, soyad, telefon numarası, şifre bilgisi ve kullanıcı tarafından beyan edilen döviz, altın, kripto varlık ve borç bilgileri yalnızca finansal takip hizmetinin sunulması amacıyla işlenmektedir.\n\nVeriler güvenli sunucularda saklanmakta olup, hesap yönetimi ve uygulamanın çalışması dışında kullanılmamaktadır. Üçüncü kişilerle paylaşılmamakta, yurt içi veya yurt dışına aktarılmamaktadır. Yasal zorunluluk halinde yetkili kurumlarla paylaşım yapılabilir.\n\nKullanıcılar istedikleri zaman hesap veya veri silme talebinde bulunabilir. Tüm veriler kalıcı olarak silinir. Politika güncellemeleri uygulama üzerinden duyurulacaktır.'**
  String get privacyPolicyText;

  /// No description provided for @explicitConsentText.
  ///
  /// In tr, this message translates to:
  /// **'AÇIK RIZA METNİ\n\nInvesTracker tarafından sunulan hizmetler kapsamında mobil uygulama üzerinden beyan ettiğiniz döviz, altın, kripto varlık ve borç bilgileri finansal takip fonksiyonunun yerine getirilmesi amacıyla işlenmektedir. Bu veriler yalnızca hizmetin sunulması için kullanılmakta olup özel nitelikli kişisel veri işlenmemektedir.\n\nKullanıcı hesabının oluşturulması ve hizmetlerin yürütülmesi KVKK’da belirtilen işleme şartlarına dayansa da, finansal verilerinizin saklanması için açık rızanız gerekmektedir. Veriler Türkiye’deki güvenli sunucularda tutulmakta ve üçüncü kişilere aktarılmamaktadır. Hesap veya veri silme talebi üzerine tüm finansal veriler kalıcı olarak silinir.\n\nAçık rızanızı dilediğiniz zaman investrackerapp@gmail.com aracılığıyla geri çekebilirsiniz. Geri çekme halinde tüm verileriniz silinir.'**
  String get explicitConsentText;

  /// No description provided for @totalBalance.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Bakiye'**
  String get totalBalance;

  /// No description provided for @totalAssets.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Varlıklar'**
  String get totalAssets;

  /// No description provided for @portfolioBreakdown.
  ///
  /// In tr, this message translates to:
  /// **'Portföy Dağılımı'**
  String get portfolioBreakdown;

  /// No description provided for @noAssetsOrDebtsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir varlık ya da borç yok'**
  String get noAssetsOrDebtsYet;

  /// No description provided for @thousand.
  ///
  /// In tr, this message translates to:
  /// **'B'**
  String get thousand;

  /// No description provided for @million.
  ///
  /// In tr, this message translates to:
  /// **'M'**
  String get million;

  /// No description provided for @billion.
  ///
  /// In tr, this message translates to:
  /// **'Mr'**
  String get billion;

  /// No description provided for @deleteMyAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı Sil'**
  String get deleteMyAccount;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In tr, this message translates to:
  /// **'Profil başarıyla güncellendi'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @profileDeletedSuccessfully.
  ///
  /// In tr, this message translates to:
  /// **'Profil başarıyla silindi'**
  String get profileDeletedSuccessfully;

  /// No description provided for @failedToDeleteProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil silinirken bir hata oluştu'**
  String get failedToDeleteProfile;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil güncellenmemedi'**
  String get errorUpdatingProfile;

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get editProfile;

  /// No description provided for @preferences.
  ///
  /// In tr, this message translates to:
  /// **'Tercihler'**
  String get preferences;

  /// No description provided for @userInformation.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Bilgileri'**
  String get userInformation;

  /// No description provided for @enterPasswordToDeleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı silmek için lütfen şifrenizi girin. Bu işlem geri alınamaz.'**
  String get enterPasswordToDeleteAccount;

  /// No description provided for @warning.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı'**
  String get warning;

  /// No description provided for @areYouSureToDeleteYourAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı silmek üzeresiniz. Bu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinecektir. Emin misiniz?'**
  String get areYouSureToDeleteYourAccount;

  /// No description provided for @wordContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get wordContinue;

  /// No description provided for @changePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Değiştir'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Şifre'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre Tekrar'**
  String get confirmNewPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen mevcut şifrenizi girin'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen yeni şifrenizi girin'**
  String get pleaseEnterNewPassword;

  /// No description provided for @pleaseConfirmNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen yeni şifrenizi onaylayın'**
  String get pleaseConfirmNewPassword;

  /// No description provided for @newPasswordMustBeDifferent.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre mevcut şifreden farklı olmalıdır'**
  String get newPasswordMustBeDifferent;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In tr, this message translates to:
  /// **'Şifre başarıyla değiştirildi'**
  String get passwordChangedSuccessfully;

  /// No description provided for @failedToChangePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre değiştirilemedi'**
  String get failedToChangePassword;

  /// No description provided for @errorChangingPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre değiştirme hatası'**
  String get errorChangingPassword;

  /// No description provided for @security.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get security;

  /// No description provided for @updateRequired.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleme Gerekli'**
  String get updateRequired;

  /// No description provided for @updateRecommended.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleme Önerilir'**
  String get updateRecommended;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In tr, this message translates to:
  /// **'InvesTracker\'ı kullanmaya devam etmek için yeni bir sürüm gereklidir. Lütfen Play Store\'dan güncelleyin.'**
  String get updateRequiredMessage;

  /// No description provided for @updateRecommendedMessage.
  ///
  /// In tr, this message translates to:
  /// **'InvesTracker\'ın yeni bir sürümü mevcut. En iyi deneyim için güncellemenizi öneririz.'**
  String get updateRecommendedMessage;

  /// No description provided for @minimumVersion.
  ///
  /// In tr, this message translates to:
  /// **'Minimum sürüm'**
  String get minimumVersion;

  /// No description provided for @recommendedVersion.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen sürüm'**
  String get recommendedVersion;

  /// No description provided for @updateNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Güncelle'**
  String get updateNow;

  /// No description provided for @later.
  ///
  /// In tr, this message translates to:
  /// **'Sonra'**
  String get later;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi sıfırla'**
  String get resetPassword;

  /// No description provided for @sendVerificationCode.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodu gönder'**
  String get sendVerificationCode;

  /// No description provided for @verificationCode.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodu'**
  String get verificationCode;

  /// No description provided for @enterVerificationCode.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen doğrulama kodunu giriniz'**
  String get enterVerificationCode;

  /// No description provided for @codeMustBe6Digits.
  ///
  /// In tr, this message translates to:
  /// **'Kod 6 haneli olmalıdır'**
  String get codeMustBe6Digits;

  /// No description provided for @checkYourEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-postanızı kontrol ediniz'**
  String get checkYourEmail;

  /// No description provided for @weSentCodeTo.
  ///
  /// In tr, this message translates to:
  /// **'6 haneli bir kod gönderdik'**
  String get weSentCodeTo;

  /// No description provided for @didntReceiveCode.
  ///
  /// In tr, this message translates to:
  /// **'Kod almadınız mı? Yeni bir kod isteyin.'**
  String get didntReceiveCode;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Şifre başarıyla sıfırlandı'**
  String get resetPasswordSuccess;

  /// No description provided for @passwordResetSuccessMessage.
  ///
  /// In tr, this message translates to:
  /// **'Parolanız başarıyla sıfırlandı. Artık yeni parolanızla giriş yapabilirsiniz.'**
  String get passwordResetSuccessMessage;

  /// No description provided for @backToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Girişe Geri Dön'**
  String get backToLogin;

  /// No description provided for @verificationCodeSent.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodu e-posta adresinize gönderildi'**
  String get verificationCodeSent;

  /// No description provided for @failedToSendVerificationCode.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodu gönderilemedi'**
  String get failedToSendVerificationCode;

  /// No description provided for @enterEmailForVerification.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinizi girin, size şifrenizi sıfırlamak için bir doğrulama kodu göndereceğiz.'**
  String get enterEmailForVerification;

  /// No description provided for @failedToResetPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırlama başarısız oldu'**
  String get failedToResetPassword;

  /// No description provided for @success.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı!'**
  String get success;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @incorrectPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre hatalı. Lütfen tekrar deneyin.'**
  String get incorrectPassword;

  /// No description provided for @website.
  ///
  /// In tr, this message translates to:
  /// **'Web Sitesi'**
  String get website;

  /// No description provided for @copiedToClipboard.
  ///
  /// In tr, this message translates to:
  /// **'E-posta panoya kopyalandı'**
  String get copiedToClipboard;

  /// No description provided for @piece.
  ///
  /// In tr, this message translates to:
  /// **'Adet'**
  String get piece;

  /// No description provided for @pieces.
  ///
  /// In tr, this message translates to:
  /// **'Adet'**
  String get pieces;

  /// No description provided for @gram.
  ///
  /// In tr, this message translates to:
  /// **'Gram'**
  String get gram;

  /// No description provided for @grams.
  ///
  /// In tr, this message translates to:
  /// **'Gram'**
  String get grams;

  /// No description provided for @assetDetails.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Detayları'**
  String get assetDetails;

  /// No description provided for @lastUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Son Güncelleme'**
  String get lastUpdated;

  /// No description provided for @initialValue.
  ///
  /// In tr, this message translates to:
  /// **'İlk Değer'**
  String get initialValue;

  /// No description provided for @valueAtUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleme Anındaki Değer'**
  String get valueAtUpdate;

  /// No description provided for @currentValue.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Değer'**
  String get currentValue;

  /// No description provided for @notAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Değil'**
  String get notAvailable;

  /// No description provided for @profit.
  ///
  /// In tr, this message translates to:
  /// **'Kâr'**
  String get profit;

  /// No description provided for @loss.
  ///
  /// In tr, this message translates to:
  /// **'Zarar'**
  String get loss;

  /// No description provided for @change.
  ///
  /// In tr, this message translates to:
  /// **'Değişim'**
  String get change;

  /// No description provided for @stable.
  ///
  /// In tr, this message translates to:
  /// **'Stabil'**
  String get stable;

  /// No description provided for @debtIncreased.
  ///
  /// In tr, this message translates to:
  /// **'Borç Arttı'**
  String get debtIncreased;

  /// No description provided for @debtDecreased.
  ///
  /// In tr, this message translates to:
  /// **'Borç Azaldı'**
  String get debtDecreased;

  /// No description provided for @debtNotChanged.
  ///
  /// In tr, this message translates to:
  /// **'Borç Değişmedi'**
  String get debtNotChanged;

  /// No description provided for @debtDueDateApproachingNotificationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Borç Son Ödeme Tarihi Yaklaşıyor!'**
  String get debtDueDateApproachingNotificationTitle;

  /// Debt due date approaching notification with amount and currency
  ///
  /// In tr, this message translates to:
  /// **'{amount}{currency} değerindeki borcunuzun son ödeme tarihine 3 gün kaldı.'**
  String debtDueDateApproachingNotificationBody(double amount, String currency);

  /// No description provided for @debtDueDateNotificationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Borç Son Ödeme Tarihi Geldi!'**
  String get debtDueDateNotificationTitle;

  /// Debt due date notification with amount and currency
  ///
  /// In tr, this message translates to:
  /// **'{amount} {currency} değerindeki borcunuzun son ödeme tarihi bugün!'**
  String debtDueDateNotificationBody(double amount, String currency);

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @reminderNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma Bildirimleri'**
  String get reminderNotifications;

  /// No description provided for @reminderNotificationsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Yatırımlarınızı kontrol etmeniz için haftalık hatırlatmalar ve piyasa güncellemeleri alın'**
  String get reminderNotificationsDescription;

  /// No description provided for @debtNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Borç Ödeme Hatırlatmaları'**
  String get debtNotifications;

  /// No description provided for @debtNotificationsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Borç ödemeleriniz yaklaştığında bildirim alın'**
  String get debtNotificationsDescription;

  /// No description provided for @appReminderNotificationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yatırım Hatırlatması'**
  String get appReminderNotificationTitle;

  /// No description provided for @marketUpdateNotificationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Piyasa Güncellemesi'**
  String get marketUpdateNotificationTitle;

  /// Market update notification with currency and value
  ///
  /// In tr, this message translates to:
  /// **'{currency} güncel değeri {value} TRY'**
  String marketUpdateNotificationBody(String currency, double value);

  /// No description provided for @reminderCheckAssetValue.
  ///
  /// In tr, this message translates to:
  /// **'Varlıklarınızın ve borçlarınızın güncel değerini kontrol edin'**
  String get reminderCheckAssetValue;

  /// No description provided for @reminderReviewPortfolio.
  ///
  /// In tr, this message translates to:
  /// **'Bugün yatırım portföyünüzü gözden geçirin'**
  String get reminderReviewPortfolio;

  /// No description provided for @reminderUpdateInvestments.
  ///
  /// In tr, this message translates to:
  /// **'Yatırımlarınızı son zamanlarda güncellediniz mi?'**
  String get reminderUpdateInvestments;

  /// No description provided for @reminderTrackMarket.
  ///
  /// In tr, this message translates to:
  /// **'Son piyasa değişikliklerini takip edin'**
  String get reminderTrackMarket;

  /// No description provided for @reminderMonitorDebts.
  ///
  /// In tr, this message translates to:
  /// **'Borç ödemelerinizi takip etmeyi unutmayın'**
  String get reminderMonitorDebts;

  /// No description provided for @reminderNotificationsEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma bildirimleri açık'**
  String get reminderNotificationsEnabled;

  /// No description provided for @reminderNotificationsDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma bildirimleri kapalı'**
  String get reminderNotificationsDisabled;

  /// No description provided for @debtNotificationsEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Borç bildirimleri açık'**
  String get debtNotificationsEnabled;

  /// No description provided for @debtNotificationsDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Borç bildirimleri kapalı'**
  String get debtNotificationsDisabled;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim İzni Gerekli'**
  String get notificationPermissionRequired;

  /// No description provided for @notificationPermissionRequiredMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatmalar ve güncellemeler almak için lütfen cihaz ayarlarınızdan bildirimleri etkinleştirin.'**
  String get notificationPermissionRequiredMessage;

  /// No description provided for @notificationPermissionDeniedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni reddedildi. Bu özelliği kullanmak için lütfen cihaz ayarlarınızdan etkinleştirin.'**
  String get notificationPermissionDeniedMessage;

  /// No description provided for @notificationPermissionGranted.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni verildi'**
  String get notificationPermissionGranted;

  /// No description provided for @notificationPermissionNotGranted.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni verilmedi. Bildirimlere izin vermek için \'Etkinleştir\'e dokunun.'**
  String get notificationPermissionNotGranted;

  /// No description provided for @openSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarları Aç'**
  String get openSettings;

  /// No description provided for @enable.
  ///
  /// In tr, this message translates to:
  /// **'Etkinleştir'**
  String get enable;

  /// No description provided for @replayTour.
  ///
  /// In tr, this message translates to:
  /// **'Turu Tekrar Göster'**
  String get replayTour;

  /// No description provided for @replayTourDescription.
  ///
  /// In tr, this message translates to:
  /// **'Özellik turunu tekrar görüntüle'**
  String get replayTourDescription;

  /// No description provided for @showcaseNavHomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get showcaseNavHomeTitle;

  /// No description provided for @showcaseNavHomeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel portföy özetiniz — toplam bakiye, varlıklar ve borçlar tek bir yerde.'**
  String get showcaseNavHomeDesc;

  /// No description provided for @showcaseNavMarketTitle.
  ///
  /// In tr, this message translates to:
  /// **'Döviz Kurları'**
  String get showcaseNavMarketTitle;

  /// No description provided for @showcaseTabMarketTitle.
  ///
  /// In tr, this message translates to:
  /// **'Döviz Kurları'**
  String get showcaseTabMarketTitle;

  /// No description provided for @showcaseNavMarketDesc.
  ///
  /// In tr, this message translates to:
  /// **'Döviz, altın ve kripto için anlık kurlar. Listeyi yenilemek için aşağı çekin.'**
  String get showcaseNavMarketDesc;

  /// No description provided for @showcaseTabMarketDesc.
  ///
  /// In tr, this message translates to:
  /// **'Döviz - Maden ve Kripto arası geçiş yapın.'**
  String get showcaseTabMarketDesc;

  /// No description provided for @showcaseNavWalletTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yatırımlarım'**
  String get showcaseNavWalletTitle;

  /// No description provided for @showcaseTabWalletTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yatırımlar ve Borçlar'**
  String get showcaseTabWalletTitle;

  /// No description provided for @showcaseNavWalletDesc.
  ///
  /// In tr, this message translates to:
  /// **'Varlık ve borçlarınızı ekleyin ve yönetin. Birden fazla yatırımı tek yerden takip edin.'**
  String get showcaseNavWalletDesc;

  /// No description provided for @showcaseTabWalletDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yatırımlar ve borçlar arası geçiş yapın.'**
  String get showcaseTabWalletDesc;

  /// No description provided for @showcaseNavConverterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çevirici'**
  String get showcaseNavConverterTitle;

  /// No description provided for @showcaseCardConverterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çevirici'**
  String get showcaseCardConverterTitle;

  /// No description provided for @showcaseNavConverterDesc.
  ///
  /// In tr, this message translates to:
  /// **'Dövizler, altın türleri ve kripto paralar arasında anında dönüşüm yapın.'**
  String get showcaseNavConverterDesc;

  /// No description provided for @showcaseCardConverterDesc.
  ///
  /// In tr, this message translates to:
  /// **'Birimler arası iki yönlü çeviri yapın.'**
  String get showcaseCardConverterDesc;

  /// No description provided for @showcaseNavSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get showcaseNavSettingsTitle;

  /// No description provided for @showcaseNavSettingsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tema, dil, bildirimler ve hesap ayarlarınızı buradan düzenleyin.'**
  String get showcaseNavSettingsDesc;

  /// No description provided for @showcaseHomeChartTitle.
  ///
  /// In tr, this message translates to:
  /// **'Portföy Grafiği'**
  String get showcaseHomeChartTitle;

  /// No description provided for @showcaseHomeChartDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu grafik varlıklarınızın döviz, altın ve kripto arasındaki dağılımını gösterir. Tutarları gizlemek veya göstermek için göz ikonuna dokunun.'**
  String get showcaseHomeChartDesc;

  /// No description provided for @showcaseHomeBalanceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Bakiye'**
  String get showcaseHomeBalanceTitle;

  /// No description provided for @showcaseHomeBalanceDesc.
  ///
  /// In tr, this message translates to:
  /// **'Toplam bakiyenizi, varlıklarınızın ve borçlarınızın toplamını Türk Lirası cinsinden görüntüleyin.'**
  String get showcaseHomeBalanceDesc;

  /// No description provided for @showcaseAddAssetBoxTitle.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Ekle'**
  String get showcaseAddAssetBoxTitle;

  /// No description provided for @showcaseAddAssetBoxDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sahip olduğunuz varlığınızı kaydedin.'**
  String get showcaseAddAssetBoxDesc;

  /// No description provided for @showcaseAssetTypeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Türü'**
  String get showcaseAssetTypeTitle;

  /// No description provided for @showcaseAssetTypeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Döviz, maden veya kripto arasından varlık türünü seçin.'**
  String get showcaseAssetTypeDesc;

  /// No description provided for @showcaseAssetCodeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Seçin'**
  String get showcaseAssetCodeTitle;

  /// No description provided for @showcaseAssetCodeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Varlığınızın hangi döviz, altın türü veya kriptoda olduğunu seçin.'**
  String get showcaseAssetCodeDesc;

  /// No description provided for @showcaseAssetAmountTitle.
  ///
  /// In tr, this message translates to:
  /// **'Miktar'**
  String get showcaseAssetAmountTitle;

  /// No description provided for @showcaseAssetAmountDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu varlıktan ne kadar sahip olduğunuzu girin.'**
  String get showcaseAssetAmountDesc;

  /// No description provided for @showcaseAddDebtBoxTitle.
  ///
  /// In tr, this message translates to:
  /// **'Borç Ekle'**
  String get showcaseAddDebtBoxTitle;

  /// No description provided for @showcaseAddDebtBoxDesc.
  ///
  /// In tr, this message translates to:
  /// **'Borcunuzu kaydedin.'**
  String get showcaseAddDebtBoxDesc;

  /// No description provided for @showcaseDebtTypeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Borç Türü'**
  String get showcaseDebtTypeTitle;

  /// No description provided for @showcaseDebtTypeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Döviz, maden veya kripto arasından borç türünü seçin.'**
  String get showcaseDebtTypeDesc;

  /// No description provided for @showcaseDebtCodeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Borç Seçin'**
  String get showcaseDebtCodeTitle;

  /// No description provided for @showcaseDebtCodeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Borcunuzun hangi döviz, altın türü veya kriptoda olduğunu seçin.'**
  String get showcaseDebtCodeDesc;

  /// No description provided for @showcaseDebtAmountTitle.
  ///
  /// In tr, this message translates to:
  /// **'Borç Miktarı'**
  String get showcaseDebtAmountTitle;

  /// No description provided for @showcaseDebtAmountDesc.
  ///
  /// In tr, this message translates to:
  /// **'Borçlu olduğunuz miktarı girin.'**
  String get showcaseDebtAmountDesc;

  /// No description provided for @showcaseDebtNoteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Not ve Son Tarih'**
  String get showcaseDebtNoteTitle;

  /// No description provided for @showcaseDebtNoteDesc.
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlı olarak bu borç için kısa bir not ve son ödeme tarihi ekleyin. Ödeme tarihinden önce hatırlatma bildirimi alacaksınız.'**
  String get showcaseDebtNoteDesc;

  /// No description provided for @theme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @trueDarkMode.
  ///
  /// In tr, this message translates to:
  /// **'Tam Karanlık'**
  String get trueDarkMode;

  /// No description provided for @defaultTheme.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan Tema'**
  String get defaultTheme;
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
