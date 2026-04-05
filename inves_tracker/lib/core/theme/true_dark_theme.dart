import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// True Dark Theme — AMOLED-friendly near-black palette.
///
/// Uses [AppColors.primaryTrueDark] as [primaryColor] so that
/// [AppColors._modeFromBrightness] can distinguish this theme from
/// [defaultDarkTheme] without an extra Provider lookup.
final ThemeData trueDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryTrueDark,           // ← identity marker
  scaffoldBackgroundColor: AppColors.backgroundTrueDark,
  colorScheme: const ColorScheme.dark(
    primary:   AppColors.primaryTrueDark,
    secondary: AppColors.secondaryTrueDark,
    surface:   AppColors.foregroundTrueDark,
    error:     AppColors.danger,
  ),
  textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundTrueDark,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardColor: AppColors.foregroundTrueDark,
  dividerColor: AppColors.background2TrueDark,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.white),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primaryTrueDark;
      return AppColors.titleTrueDark;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryTrueDark.withValues(alpha: 0.4);
      }
      return AppColors.background2TrueDark;
    }),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.background2TrueDark,
  ),
);