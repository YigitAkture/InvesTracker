import 'package:flutter/material.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';

class WalletLocalizationHelper {
  /// Get localized name for asset/debt code based on type
  static String getLocalizedName(
    BuildContext context,
    String code,
    String type,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (type.toLowerCase()) {
      case 'currency':
        return _getCurrencyName(code, l10n);
      case 'gold':
        return _getGoldName(code, l10n);
      case 'crypto':
        return code; // Crypto codes are displayed as-is
      default:
        return code;
    }
  }

  static String _getCurrencyName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'TRY':
        return l10n.currencyTRY;
      case 'USD':
        return l10n.currencyUSD;
      case 'EUR':
        return l10n.currencyEUR;
      case 'GBP':
        return l10n.currencyGBP;
      case 'CHF':
        return l10n.currencyCHF;
      case 'CAD':
        return l10n.currencyCAD;
      case 'JPY':
        return l10n.currencyJPY;
      case 'SAR':
        return l10n.currencySAR;
      case 'RUB':
        return l10n.currencyRUB;
      case 'AED':
        return l10n.currencyAED;
      case 'KWD':
        return l10n.currencyKWD;
      case 'AUD':
        return l10n.currencyAUD;
      case 'DKK':
        return l10n.currencyDKK;
      case 'SEK':
        return l10n.currencySEK;
      case 'NOK':
        return l10n.currencyNOK;
      default:
        return code;
    }
  }

  static String _getGoldName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'HAS':
        return l10n.goldHAS;
      case 'GRA':
        return l10n.goldGRA;
      case 'CEYREKALTIN':
        return l10n.goldCEYREKALTIN;
      case 'YARIMALTIN':
        return l10n.goldYARIMALTIN;
      case 'TAMALTIN':
        return l10n.goldTAMALTIN;
      case 'ATAALTIN':
        return l10n.goldATAALTIN;
      case 'RESATALTIN':
        return l10n.goldRESATALTIN;
      case 'CUMHURIYETALTINI':
        return l10n.goldCUMHURIYETALTINI;
      case 'GREMSEALTIN':
        return l10n.goldGREMSEALTIN;
      case '14AYARALTIN':
        return l10n.gold14AYARALTIN;
      case '18AYARALTIN':
        return l10n.gold18AYARALTIN;
      case 'YIA':
        return l10n.goldYIA;
      case 'IKIBUCUKALTIN':
        return l10n.goldIKIBUCUKALTIN;
      case 'BESLIALTIN':
        return l10n.goldBESLIALTIN;
      default:
        return code;
    }
  }
}