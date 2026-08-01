import 'package:flutter/material.dart';
import 'package:inves_tracker/core/l10n/app_localizations.dart';

class GoldData {
  final String code;
  final double buying;
  final double selling;
  final double changeRate;
  final bool isIncreasing;

  GoldData({
    required this.code,
    required this.buying,
    required this.selling,
    required this.changeRate,
    required this.isIncreasing,
  });

  // Get localized name based on context
  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _getGoldNameLocalized(code, l10n);
  }

  // Factory for backend API response
  factory GoldData.fromBackend(Map<String, dynamic> json) {
    final change = (json['change'] ?? 0.0).toDouble();

    return GoldData(
      code: json['code'] ?? '',
      buying: (json['buying'] ?? 0.0).toDouble(),
      selling: (json['selling'] ?? 0.0).toDouble(),
      changeRate: change.abs(),
      isIncreasing: change >= 0,
    );
  }

  factory GoldData.fromJson(String code, Map<String, dynamic> json) {
    final buying = (json['Buying'] ?? 0.0).toDouble();
    final change = (json['Change'] ?? 0.0).toDouble();

    return GoldData(
      code: code,
      buying: buying,
      selling: (json['Selling'] ?? 0.0).toDouble(),
      changeRate: change.abs(),
      isIncreasing: change >= 0,
    );
  }

  static String _getGoldNameLocalized(String code, AppLocalizations l10n) {
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
      case 'GUMUS':
        return l10n.goldGUMUS;
      case 'PAL':
        return l10n.goldPAL;
      case 'GPL':
        return l10n.goldGPL;
      default:
        return code;
    }
  }
}
