import 'package:flutter/services.dart';

/// Helper class for managing gold input validation and formatting
class GoldInputHelper {
  // Private constructor to prevent instantiation
  GoldInputHelper._();

  /// Gold types that allow decimal (fractional) values
  static const List<String> _decimalAllowedGoldTypes = [
    'HAS',
    'GRA',
    '14AYARALTIN',
    '18AYARALTIN',
    'GUMUS',
    'PAL',
    'GPL',
  ];

  /// Check if a gold type allows decimal input
  static bool allowsDecimal(String goldCode) {
    return _decimalAllowedGoldTypes.contains(goldCode);
  }

  /// Get the appropriate keyboard type for a gold code
  static TextInputType getKeyboardType(String goldCode) {
    return allowsDecimal(goldCode)
        ? const TextInputType.numberWithOptions(decimal: true)
        : const TextInputType.numberWithOptions(decimal: false);
  }

  /// Get the appropriate input formatter for a gold code
  static List<TextInputFormatter> getInputFormatters(String goldCode) {
    if (allowsDecimal(goldCode)) {
      // Allow decimal values (e.g., 2.5)
      return [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ];
    } else {
      // Only allow integers (e.g., 2, 5, 10)
      return [
        FilteringTextInputFormatter.digitsOnly,
      ];
    }
  }

  /// Validate amount for a gold code
  /// Returns null if valid, error message if invalid
  static String? validateAmount(String goldCode, String amountText) {
    final amount = double.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }

    // Check if decimal is used for non-decimal gold types
    if (!allowsDecimal(goldCode) && amountText.contains('.')) {
      return 'This gold type only accepts whole numbers';
    }

    return null;
  }

  /// Format amount display based on gold type
  /// Decimal-allowed types show up to 2 decimal places
  /// Integer-only types show no decimal places
  static String formatAmount(String goldCode, double amount) {
    if (allowsDecimal(goldCode)) {
      return amount.toStringAsFixed(2);
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}