import 'package:intl/intl.dart';

/// Utility class for formatting numbers with thousand separators
class PriceFormatter {
  // Private constructor to prevent instantiation
  PriceFormatter._();

  /// Format a number with thousand separators and specified decimal places
  /// 
  /// Examples:
  /// - formatNumber(5935.54, 2, 'en_US') → "5,935.54"
  /// - formatNumber(5935.54, 2, 'tr_TR') → "5.935,54"
  static String formatNumber(double value, [int decimalPlaces = 2, String? locale]) {
    // Use en_US as default if no locale specified
    final localeToUse = locale ?? 'en_US';
    
    if (decimalPlaces == 0) {
      final formatter = NumberFormat('#,##0', localeToUse);
      return formatter.format(value);
    }
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}', localeToUse);
    return formatter.format(value);
  }

  /// Format a number with automatic decimal places (removes trailing zeros)
  /// 
  /// Examples:
  /// - formatNumberAuto(5935.54, 'en_US') → "5,935.54"
  /// - formatNumberAuto(1000.00, 'en_US') → "1,000"
  /// - formatNumberAuto(5935.54, 'tr_TR') → "5.935,54"
  static String formatNumberAuto(double value, [String? locale]) {
    final localeToUse = locale ?? 'en_US';
    final formatter = NumberFormat('#,##0.##', localeToUse);
    return formatter.format(value);
  }

  /// Format currency with thousand separators (2 decimal places)
  /// 
  /// Examples:
  /// - formatCurrency(5935.54, 'en_US') → "5,935.54"
  /// - formatCurrency(5935.54, 'tr_TR') → "5.935,54"
  static String formatCurrency(double value, [String? locale]) {
    return formatNumber(value, 2, locale);
  }

  /// Format price with appropriate decimal places based on value
  /// - Values >= 1000: no decimals
  /// - Values >= 1: 2 decimals
  /// - Values >= 0.001: 4 decimals
  /// - Values < 0.001: 5 decimals
  static String formatPrice(double value, [String? locale]) {
    if (value >= 1000) {
      return formatNumber(value, 0, locale);
    } else if (value >= 1) {
      return formatNumber(value, 2, locale);
    } else if (value >= 0.001) {
      return formatNumber(value, 4, locale);
    } else {
      return formatNumber(value, 5, locale);
    }
  }

  /// Format large numbers with K, M, B suffixes
  /// Used in charts and summaries for better readability
  static String formatCompact(double value, String suffix, [String? locale]) {
    final localeToUse = locale ?? 'en_US';
    final formatter = NumberFormat('#,##0.#', localeToUse);
    return '${formatter.format(value)}$suffix';
  }
}