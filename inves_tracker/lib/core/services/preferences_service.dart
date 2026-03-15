import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeKey = 'isDarkMode';
  static const String _languageKey = 'languageCode';
  static const String _debtNotificationsKey = 'debt_notifications_enabled';

  // ── Theme ──────────────────────────────────────────────────────────────────

  Future<void> saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  /// Returns null when no preference has been saved (use system default).
  Future<bool?> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey);
  }

  // ── Language ───────────────────────────────────────────────────────────────

  Future<void> saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Returns null when no preference has been saved (use system locale).
  Future<String?> getLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  /// FIX: Removes the key entirely so [getLanguagePreference] returns null
  /// and the app falls back to the device system locale.
  /// The original [LocaleNotifier.clearLocale] wrote an empty string `''`
  /// here, which is not null and causes `Locale('')` — an invalid locale.
  Future<void> clearLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
  }

  // ── Debt notifications ────────────────────────────────────────────────────

  Future<void> setDebtNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_debtNotificationsKey, enabled);
  }

  /// Returns true by default when no preference has been saved.
  Future<bool> getDebtNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_debtNotificationsKey) ?? true;
  }
}