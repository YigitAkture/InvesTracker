import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/light_theme.dart';
import '../theme/default_dark_theme.dart';
import '../theme/true_dark_theme.dart';
import '../constants/app_colors.dart';
import '../services/preferences_service.dart';

class ThemeNotifier extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();

  AppThemeMode? _mode;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  AppThemeMode get currentMode {
    if (_mode != null) return _mode!;
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark
        ? AppThemeMode.defaultDark
        : AppThemeMode.light;
  }

  bool get isDarkMode => currentMode != AppThemeMode.light;

  ThemeData get currentTheme {
    switch (currentMode) {
      case AppThemeMode.trueDark:    return trueDarkTheme;
      case AppThemeMode.defaultDark: return defaultDarkTheme;
      case AppThemeMode.light:       return lightTheme;
    }
  }

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await _preferencesService.getThemeModePreference();
    _mode = saved;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    await _preferencesService.saveThemeModePreference(mode);
    notifyListeners();
  }

  // ── Legacy helpers kept for backward-compat if anything calls them ────────

  Future<void> setTheme(bool isDark) async {
    await setThemeMode(isDark ? AppThemeMode.defaultDark : AppThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final next = currentMode == AppThemeMode.light
        ? AppThemeMode.defaultDark
        : AppThemeMode.light;
    await setThemeMode(next);
  }
}