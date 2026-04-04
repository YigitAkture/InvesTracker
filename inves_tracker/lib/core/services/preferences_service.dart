import 'package:shared_preferences/shared_preferences.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';

class PreferencesService {
  // ── Keys ──────────────────────────────────────────────────────────────────
  static const String _themeKey              = 'isDarkMode';     // legacy
  static const String _themeModeKey          = 'themeMode';      // new
  static const String _languageKey           = 'languageCode';
  static const String _debtNotificationsKey  = 'debt_notifications_enabled';

  // ── Theme Mode (new 3-way) ────────────────────────────────────────────────

  Future<void> saveThemeModePreference(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  /// Returns null when no preference has been saved (fall back to system).
  Future<AppThemeMode?> getThemeModePreference() async {
    final prefs = await SharedPreferences.getInstance();

    // Prefer the new key
    final stored = prefs.getString(_themeModeKey);
    if (stored != null) {
      return AppThemeMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => AppThemeMode.defaultDark,
      );
    }

    // Migrate from legacy bool key
    final legacy = prefs.getBool(_themeKey);
    if (legacy != null) {
      final migrated =
          legacy ? AppThemeMode.defaultDark : AppThemeMode.light;
      // Write new key so we don't migrate again
      await prefs.setString(_themeModeKey, migrated.name);
      return migrated;
    }

    return null; // system default
  }

  // ── Legacy bool API (kept for backward-compat) ────────────────────────────

  Future<void> saveThemePreference(bool isDarkMode) async {
    await saveThemeModePreference(
      isDarkMode ? AppThemeMode.defaultDark : AppThemeMode.light,
    );
  }

  Future<bool?> getThemePreference() async {
    final mode = await getThemeModePreference();
    if (mode == null) return null;
    return mode != AppThemeMode.light;
  }

  // ── Language ──────────────────────────────────────────────────────────────

  Future<void> saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  Future<String?> getLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  Future<void> clearLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
  }

  // ── Debt notifications ────────────────────────────────────────────────────

  Future<void> setDebtNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_debtNotificationsKey, enabled);
  }

  Future<bool> getDebtNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_debtNotificationsKey) ?? true;
  }
}