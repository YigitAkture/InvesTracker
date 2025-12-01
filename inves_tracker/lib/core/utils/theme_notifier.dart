import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/light_theme.dart';
import '../theme/dark_theme.dart';
import '../services/preferences_service.dart';

class ThemeNotifier extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();
  bool? _isDarkMode;
  
  bool get isDarkMode {
    if (_isDarkMode == null) {
      // Use system theme if no preference is saved
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _isDarkMode!;
  }

  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDarkMode = await _preferencesService.getThemePreference();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final currentTheme = isDarkMode;
    _isDarkMode = !currentTheme;
    await _preferencesService.saveThemePreference(_isDarkMode!);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode == isDark) return;
    
    _isDarkMode = isDark;
    await _preferencesService.saveThemePreference(isDark);
    notifyListeners();
  }
}