import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Default Dark Theme — navy-indigo palette (your original dark theme).
///
/// Uses [AppColors.primaryDefault] as [primaryColor] so that
/// [AppColors._modeFromBrightness] can distinguish it from [trueDarkTheme].
final ThemeData defaultDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryDefault,            // ← identity marker
  scaffoldBackgroundColor: AppColors.backgroundDefault,
  colorScheme: const ColorScheme.dark(
    primary:   AppColors.primaryDefault,
    secondary: AppColors.secondaryDefault,
    surface:   AppColors.foregroundDefault,
    error:     AppColors.danger,
  ),
  textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundDefault,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardColor: AppColors.foregroundDefault,
  dividerColor: AppColors.background2Default,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.white),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primaryDefault;
      return AppColors.titleDefault;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryDefault.withValues(alpha: 0.4);
      }
      return AppColors.background2Default;
    }),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.background2Default,
  ),
);