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
    if (savedLanguage != null) {
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

  Future<void> clearLocale() async {
    _locale = null;
    final prefs = await _preferencesService.getLanguagePreference();
    if (prefs != null) {
      await _preferencesService.saveLanguagePreference('');
    }
    notifyListeners();
  }
}