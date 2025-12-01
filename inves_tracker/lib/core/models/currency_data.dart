import 'package:flutter/material.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';

class CurrencyData {
  final String code;
  final double buying;
  final double selling;
  final double changeRate;
  final bool isIncreasing;

  CurrencyData({
    required this.code,
    required this.buying,
    required this.selling,
    required this.changeRate,
    required this.isIncreasing,
  });

  // Get localized name based on context
  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _getCurrencyNameLocalized(code, l10n);
  }

  factory CurrencyData.fromJson(String code, Map<String, dynamic> json) {
    final buying = (json['Buying'] ?? 0.0).toDouble();
    final change = (json['Change'] ?? 0.0).toDouble();
    
    return CurrencyData(
      code: code,
      buying: buying,
      selling: (json['Selling'] ?? 0.0).toDouble(),
      changeRate: change.abs(),
      isIncreasing: change >= 0,
    );
  }

  static String _getCurrencyNameLocalized(String code, AppLocalizations l10n) {
    switch (code) {
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
}