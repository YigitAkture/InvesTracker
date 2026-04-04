import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Light Theme.
///
/// Uses [AppColors.primaryLight] as [primaryColor] so that
/// [AppColors._modeFromBrightness] identifies it correctly.
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryLight,              // ← identity marker
  scaffoldBackgroundColor: AppColors.backgroundLight,
  colorScheme: const ColorScheme.light(
    primary:   AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    surface:   AppColors.foregroundLight,
    error:     AppColors.danger,
  ),
  textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundLight,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  cardColor: AppColors.foregroundLight,
  dividerColor: AppColors.background2Light,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.black),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
      return AppColors.titleLight;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight.withValues(alpha: 0.4);
      }
      return AppColors.background2Light;
    }),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.background2Light,
  ),
);