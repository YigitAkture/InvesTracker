import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class LocaleNotifier extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();
  Locale? _locale;

  Locale? get locale => _locale;

  LocaleNotifier() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final savedLanguage = await _preferencesService.getLanguagePreference();
    // Only set a locale if the saved value is a non-empty language code.
    if (savedLanguage != null && savedLanguage.isNotEmpty) {
      _locale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _preferencesService.saveLanguagePreference(locale.languageCode);
    notifyListeners();
  }

  /// Clears the saved locale preference and reverts to the system locale.
  ///
  /// FIX: The original implementation wrote an empty string `''` via
  /// [saveLanguagePreference], which caused [getLanguagePreference] to return
  /// `''` on next launch and ultimately produced an invalid `Locale('')`.
  /// Instead we remove the key entirely so [getLanguagePreference] returns
  /// `null` and the app falls back to the system locale.
  Future<void> clearLocale() async {
    _locale = null;
    await _preferencesService.clearLanguagePreference();
    notifyListeners();
  }
}