import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inves_tracker/core/utils/locale_notifier.dart';

/// Helper extension to get locale string for formatting
extension LocaleHelper on BuildContext {
  /// Get current locale as string for number formatting (e.g., 'en_US', 'tr_TR')
  String get localeString {
    final localeNotifier = Provider.of<LocaleNotifier>(this, listen: false);
    final currentLocale = localeNotifier.locale ?? Localizations.localeOf(this);
    
    // Convert to locale string format
    switch (currentLocale.languageCode) {
      case 'tr':
        return 'tr_TR';
      case 'en':
      default:
        return 'en_US';
    }
  }
}