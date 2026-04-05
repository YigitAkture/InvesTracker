import 'package:flutter/material.dart';

/// Supported app themes
enum AppThemeMode { light, defaultDark, trueDark }

class AppColors {
  // ─── Static / Semantic Colors (theme-agnostic) ────────────────────────────

  static const Color danger  = Color(0xFFDC0E0E);
  static const Color danger2 = Color(0xFFCB0404);
  static const Color danger3 = Color(0xFFC34141);

  static const Color success  = Color(0xFF78C841);
  static const Color success2 = Color(0xFF5CB338);

  static const Color warning  = Color(0xFFFCCD2A);
  static const Color warning2 = Color(0xFFFFC145);

  static const Color teal   = Color(0xFF00F5FF);
  static const Color orange = Color(0xFFFF7F3F);
  static const Color melon  = Color(0xFFEDF492);
  static const Color pink   = Color(0xFFE83C91);
  static const Color purple = Color(0xFF9C50CC);
  static const Color grey   = Color(0xFF505050);

  // ─── Light Theme Palette ─────────────────────────────────────────────────

  static const Color primaryLight    = Color(0xFF1B5448);
  static const Color secondaryLight  = Color(0xFFFF7F3F);
  static const Color backgroundLight  = Color(0xFFD4D4D4);
  static const Color background2Light = Color(0xFFE6E6E6);
  static const Color foregroundLight  = Color(0xFFF3F3F3);
  static const Color titleLight       = Color(0xFF333333);

  // ─── Default Dark Theme Palette (navy-indigo, your current dark) ─────────

  static const Color primaryDefault    = Color(0xFF49C0FF);
  static const Color secondaryDefault  = Color(0xFFEC3B80);
  static const Color backgroundDefault  = Color(0xFF27283D);
  static const Color background2Default = Color(0xFF2D2D47);
  static const Color foregroundDefault  = Color(0xFF41415D);
  static const Color titleDefault       = Color(0xFFA5A5A5);

  // ─── True Dark Theme Palette (AMOLED-friendly deep blacks) ───────────────
  //
  // Design intent:
  //   • Base:       Near-pure black with a barely-perceptible cool tint
  //   • Surface:    Slightly lighter — just enough to distinguish layers
  //   • Card:       Raised surface with subtle blue-grey warmth
  //   • Primary:    Softer cyan-teal — high contrast on black but not harsh
  //   • Secondary:  Warm coral-rose — vibrant accent that pops on dark fields
  //   • Title:      Mid-grey for secondary labels — readable, not blinding

  static const Color primaryTrueDark    = Color(0xFF4469EB);   // soft sky-blue 7289DA
  static const Color secondaryTrueDark  = Color(0xFFFF5C8D);   // vivid rose
  static const Color backgroundTrueDark  = Color(0xFF1E2124);  // near-black w/ blue undertone
  static const Color background2TrueDark = Color(0xFF36393E);  // slightly lighter base
  static const Color foregroundTrueDark  = Color(0xFF424549);  // card surface
  static const Color titleTrueDark       = Color(0xFF8E8EA8);  // muted lavender-grey label

  // ─── Dynamic Getters (BuildContext-based) ─────────────────────────────────

  static AppThemeMode _modeFromBrightness(BuildContext context) {
    final theme = Theme.of(context);
    // We tag each ThemeData with a unique primaryColor so we can distinguish
    // the three modes without a Provider here.
    final color = theme.primaryColor;
    if (color == primaryTrueDark)    return AppThemeMode.trueDark;
    if (color == primaryDefault)     return AppThemeMode.defaultDark;
    return AppThemeMode.light;
  }

  static Color primary(BuildContext context) {
    switch (_modeFromBrightness(context)) {
      case AppThemeMode.trueDark:   return primaryTrueDark;
      case AppThemeMode.defaultDark: return primaryDefault;
      case AppThemeMode.light:      return primaryLight;
    }
  }

  static Color secondary(BuildContext context) {
    switch (_modeFromBrightness(context)) {
      case AppThemeMode.trueDark:   return secondaryTrueDark;
      case AppThemeMode.defaultDark: return secondaryDefault;
      case AppThemeMode.light:      return secondaryLight;
    }
  }

  static Color background(BuildContext context) {
    switch (_modeFromBrightness(context)) {
      case AppThemeMode.trueDark:   return backgroundTrueDark;
      case AppThemeMode.defaultDark: return backgroundDefault;
      case AppThemeMode.light:      return backgroundLight;
    }
  }

  static Color background2(BuildContext context) {
    switch (_modeFromBrightness(context)) {
      case AppThemeMode.trueDark:   return background2TrueDark;
      case AppThemeMode.defaultDark: return background2Default;
      case AppThemeMode.light:      return background2Light;
    }
  }

  static Color foreground(BuildContext context) {
    switch (_modeFromBrightness(context)) {
      case AppThemeMode.trueDark:   return foregroundTrueDark;
      case AppThemeMode.defaultDark: return foregroundDefault;
      case AppThemeMode.light:      return foregroundLight;
    }
  }

  static Color title(BuildContext context) {
    switch (_modeFromBrightness(context)) {
      case AppThemeMode.trueDark:   return titleTrueDark;
      case AppThemeMode.defaultDark: return titleDefault;
      case AppThemeMode.light:      return titleLight;
    }
  }

  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}