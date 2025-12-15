import 'package:intl/intl.dart';

/// Utility class for formatting numbers with thousand separators
class PriceFormatter {
  // Private constructor to prevent instantiation
  PriceFormatter._();

  /// Format a number with thousand separators and specified decimal places
  /// 
  /// Examples:
  /// - formatNumber(5935.54, 2) → "5,935.54"
  /// - formatNumber(1234567.89, 2) → "1,234,567.89"
  /// - formatNumber(999.5, 2) → "999.50"
  static String formatNumber(double value, [int decimalPlaces = 2]) {
    if (decimalPlaces == 0) {
      final formatter = NumberFormat('#,##0', 'en_US');
      return formatter.format(value);
    }
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}', 'en_US');
    return formatter.format(value);
  }

  /// Format a number with automatic decimal places (removes trailing zeros)
  /// 
  /// Examples:
  /// - formatNumberAuto(5935.54) → "5,935.54"
  /// - formatNumberAuto(1000.00) → "1,000"
  /// - formatNumberAuto(999.5) → "999.5"
  static String formatNumberAuto(double value) {
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return formatter.format(value);
  }

  /// Format currency with thousand separators (2 decimal places)
  /// 
  /// Examples:
  /// - formatCurrency(5935.54) → "5,935.54"
  /// - formatCurrency(1234567.89) → "1,234,567.89"
  static String formatCurrency(double value) {
    return formatNumber(value, 2);
  }

  /// Format price with appropriate decimal places based on value
  /// - Values >= 1000: no decimals
  /// - Values >= 1: 2 decimals
  /// - Values >= 0.001: 4 decimals
  /// - Values < 0.001: 6 decimals
  /// 
  /// Examples:
  /// - formatPrice(5935.54) → "5,936"
  /// - formatPrice(35.54) → "35.54"
  /// - formatPrice(0.0543) → "0.0543"
  /// - formatPrice(0.000123) → "0.000123"
  static String formatPrice(double value) {
    if (value >= 1000) {
      return formatNumber(value, 0);
    } else if (value >= 1) {
      return formatNumber(value, 2);
    } else if (value >= 0.001) {
      return formatNumber(value, 4);
    } else {
      return formatNumber(value, 6);
    }
  }

  /// Format large numbers with K, M, B suffixes
  /// Used in charts and summaries for better readability
  /// 
  /// Examples:
  /// - formatCompact(1500, "K") → "1.5K"
  /// - formatCompact(2500000, "M") → "2.5M"
  static String formatCompact(double value, String suffix) {
    final formatter = NumberFormat('#,##0.#', 'en_US');
    return '${formatter.format(value)}$suffix';
  }
}