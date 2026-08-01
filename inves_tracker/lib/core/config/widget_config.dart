import 'package:inves_tracker/core/l10n/app_localizations.dart';

/// Widget Configuration
/// Centralized definition of widget data structure and item selection
class WidgetConfig {
  // Exactly 4 currencies to display
  static const List<String> currencies = ['USD', 'EUR', 'GBP', 'CHF'];

  // Exactly 4 gold types to display
  static const List<GoldType> golds = [
    GoldType.gram,
    GoldType.quarter,
    GoldType.half,
    GoldType.full,
  ];

  // Exactly 4 cryptocurrencies to display
  static const List<String> cryptos = ['BTC', 'ETH', 'USDT', 'BNB'];

  /// Map gold API codes to enum values
  static GoldType? goldTypeFromCode(String code) {
    switch (code.toUpperCase()) {
      case 'GRA':
        return GoldType.gram;
      case 'CEYREKALTIN':
        return GoldType.quarter;
      case 'YARIMALTIN':
        return GoldType.half;
      case 'TAMALTIN':
        return GoldType.full;
      default:
        return null;
    }
  }

  /// Map enum to API code
  static String goldTypeToCode(GoldType type) {
    switch (type) {
      case GoldType.gram:
        return 'GRA';
      case GoldType.quarter:
        return 'CEYREKALTIN';
      case GoldType.half:
        return 'YARIMALTIN';
      case GoldType.full:
        return 'TAMALTIN';
    }
  }
}

/// Enum for gold types with semantic meaning
enum GoldType {
  gram, // Gram Gold (GRA)
  quarter, // Quarter Gold (CEYREKALTIN)
  half, // Half Gold (YARIMALTIN)
  full, // Full Gold (TAMALTIN)
}

/// Extension for localized gold names
extension GoldTypeLocalization on GoldType {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case GoldType.gram:
        return l10n.goldGRA;
      case GoldType.quarter:
        return l10n.goldCEYREKALTIN;
      case GoldType.half:
        return l10n.goldYARIMALTIN;
      case GoldType.full:
        return l10n.goldTAMALTIN;
    }
  }

  /// Get short display code (for widget)
  String get displayCode {
    switch (this) {
      case GoldType.gram:
        return 'GRA';
      case GoldType.quarter:
        return 'CEYR';
      case GoldType.half:
        return 'YARI';
      case GoldType.full:
        return 'TAM';
    }
  }
}

/// Widget item data structure
class WidgetItemData {
  final String code;
  final String displayName;
  final double buyingPrice;
  final double sellingPrice;
  final double change; // Positive or negative from API

  WidgetItemData({
    required this.code,
    required this.displayName,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.change,
  });

  /// Is the price increasing? (change >= 0)
  bool get isIncreasing => change >= 0.0;

  /// Absolute change percentage for display
  double get changePercentage => change.abs();

  /// Convert to JSON for widget storage
  Map<String, dynamic> toJson() => {
    'code': code,
    'name': displayName,
    'buying': buyingPrice,
    'selling': sellingPrice,
    'change': change, // Store raw change value
  };

  /// Create from JSON
  factory WidgetItemData.fromJson(Map<String, dynamic> json) => WidgetItemData(
    code: json['code'] as String,
    displayName: json['name'] as String,
    buyingPrice: (json['buying'] as num).toDouble(),
    sellingPrice: (json['selling'] as num).toDouble(),
    change: (json['change'] as num).toDouble(),
  );
}

/// Crypto-specific widget data
class WidgetCryptoData {
  final String code;
  final String displayName;
  final double usdPrice;
  final double sellingUsd;
  final double change;

  WidgetCryptoData({
    required this.code,
    required this.displayName,
    required this.usdPrice,
    required this.sellingUsd,
    required this.change,
  });

  bool get isIncreasing => change >= 0.0;
  double get changePercentage => change.abs();

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': displayName,
    'usdPrice': usdPrice,
    'sellingUsd': sellingUsd,
    'change': change,
  };

  factory WidgetCryptoData.fromJson(Map<String, dynamic> json) =>
      WidgetCryptoData(
        code: json['code'] as String,
        displayName: json['name'] as String,
        usdPrice: (json['usdPrice'] as num).toDouble(),
        sellingUsd: (json['sellingUsd'] as num).toDouble(),
        change: (json['change'] as num).toDouble(),
      );
}
