import 'package:flutter/material.dart';

class AppColors {
  // --- Light Colors ---
  static final Color primaryLight = Colors.blue[300]!;
  static final Color secondaryLight = Colors.orange[600]!;
  static final Color backgroundLight = Colors.grey[200]!;

  // --- Dark Colors ---
  static const Color primaryDark = Colors.blueAccent;
  static const Color secondaryDark = Colors.orange;
  static const Color backgroundDark = Color(0xFF121212);

  // --- Dynamic Getters ---
  static Color primary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryDark
        : primaryLight;
  }

  static Color secondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? secondaryDark
        : secondaryLight;
  }

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }
}
