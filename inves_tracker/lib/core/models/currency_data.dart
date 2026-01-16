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

  // Factory for backend API response
  factory CurrencyData.fromBackend(Map<String, dynamic> json) {
    final change = (json['change'] ?? 0.0).toDouble();
    
    return CurrencyData(
      code: json['code'] ?? '',
      buying: (json['buying'] ?? 0.0).toDouble(),
      selling: (json['selling'] ?? 0.0).toDouble(),
      changeRate: change.abs(),
      isIncreasing: change >= 0,
    );
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
      case 'NZD':
        return l10n.currencyNZD;
      case 'SGD':
        return l10n.currencySGD;
      case 'HKD':
        return l10n.currencyHKD;
      case 'THB':
        return l10n.currencyTHB;
      case 'PLN':
        return l10n.currencyPLN;
      case 'CZK':
        return l10n.currencyCZK;
      case 'HUF':
        return l10n.currencyHUF;
      case 'RON':
        return l10n.currencyRON;
      case 'QAR':
        return l10n.currencyQAR;
      case 'BHD':
        return l10n.currencyBHD;
      case 'OMR':
        return l10n.currencyOMR;
      case 'IQD':
        return l10n.currencyIQD;
      case 'LYD':
        return l10n.currencyLYD;
      case 'IRR':
        return l10n.currencyIRR;
      case 'LKR':
        return l10n.currencyLKR;
      case 'INR':
        return l10n.currencyINR;
      case 'PKR':
        return l10n.currencyPKR;
      case 'IDR':
        return l10n.currencyIDR;
      case 'MYR':
        return l10n.currencyMYR;
      case 'PHP':
        return l10n.currencyPHP;
      case 'MXN':
        return l10n.currencyMXN;
      case 'BRL':
        return l10n.currencyBRL;
      case 'ARS':
        return l10n.currencyARS;
      case 'CLP':
        return l10n.currencyCLP;
      case 'COP':
        return l10n.currencyCOP;
      case 'PEN':
        return l10n.currencyPEN;
      case 'UYU':
        return l10n.currencyUYU;
      case 'CRC':
        return l10n.currencyCRC;
      case 'UAH':
        return l10n.currencyUAH;
      case 'GEL':
        return l10n.currencyGEL;
      case 'AZN':
        return l10n.currencyAZN;
      case 'MKD':
        return l10n.currencyMKD;
      case 'BGN':
        return l10n.currencyBGN;
      case 'BAM':
        return l10n.currencyBAM;
      case 'MDL':
        return l10n.currencyMDL;
      case 'ALL':
        return l10n.currencyALL;
      case 'LBP':
        return l10n.currencyLBP;
      case 'EGP':
        return l10n.currencyEGP;
      case 'DZD':
        return l10n.currencyDZD;
      case 'TND':
        return l10n.currencyTND;
      case 'SYP':
        return l10n.currencySYP;
      case 'ISK':
        return l10n.currencyISK;
      case 'KZT':
        return l10n.currencyKZT;
      case 'CNY':
        return l10n.currencyCNY;
      case 'TWD':
        return l10n.currencyTWD;
      case 'KRW':
        return l10n.currencyKRW;
      default:
        return code;
    }
  }
}