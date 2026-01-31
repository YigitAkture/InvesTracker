import 'package:flutter/material.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';

/// Global localization manager that provides access to localized strings
/// without requiring BuildContext. This enables services, background tasks,
/// and other non-UI code to use localization.
class LocalizationManager {
  static final LocalizationManager _instance = LocalizationManager._internal();
  factory LocalizationManager() => _instance;
  LocalizationManager._internal();

  /// Current app localizations
  AppLocalizations? _currentLocalizations;

  /// Current locale
  Locale _currentLocale = const Locale('en');

  /// Get current localizations
  /// Throws if not initialized - ensure updateLocalizations is called during app startup
  AppLocalizations get current {
    if (_currentLocalizations == null) {
      throw StateError(
        'LocalizationManager not initialized. Call updateLocalizations() during app startup.',
      );
    }
    return _currentLocalizations!;
  }

  /// Get current locale
  Locale get currentLocale => _currentLocale;

  /// Update current localizations and locale
  /// Should be called whenever locale changes
  void updateLocalizations(AppLocalizations localizations, Locale locale) {
    _currentLocalizations = localizations;
    _currentLocale = locale;
    debugPrint('LocalizationManager updated to locale: ${locale.languageCode}');
  }

  /// Check if localizations are initialized
  bool get isInitialized => _currentLocalizations != null;

  /// Create localizations for a specific locale
  /// Useful for generating notifications in user's preferred language
  static Future<AppLocalizations> createLocalization(Locale locale) async {
    return await AppLocalizations.delegate.load(locale);
  }
}