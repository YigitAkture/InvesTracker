import 'package:flutter/material.dart';

class AppColors {

  // --- Static Colors ---
  static const Color danger = Color(0xFFDC0E0E);
  static const Color danger2 = Color(0xFFCB0404);
  static const Color danger3 = Color(0xFFC34141);

  static const Color success = Color(0xFF78C841);
  static const Color success2 = Color(0xFF5CB338);

  static const Color warning = Color(0xFFFCCD2A);
  static const Color warning2 = Color(0xFFFFC145);

  static const Color teal = Color(0xFF00F5FF);
  static const Color orange = Color(0xFFFF7F3F);
  static const Color melon = Color(0xFFEDF492);
  static const Color pink = Color(0xFFE83C91);
  static const Color purple = Color(0xFF9C50CC);
  static const Color grey = Color(0xFF505050);

  // --- Light Colors ---
  static const Color primaryLight = Color(0xFF004042);
  static const Color secondaryLight = Color(0xFFFF7F3F);
  static const Color backgroundLight = Color(0xFFBABABA);
  static const Color backgroundLight2 = Color(0xFFDEDEDE);
  static const Color foregroundLight = Color(0xFFF3F3F3);
  static const Color titleLight = Color(0xFF333333);

  // --- Dark Colors ---
  static const Color primaryDark = Color(0xFF00F5FF);
  static const Color secondaryDark = Color(0xFFE83C91);
  static const Color backgroundDark = Color(0xFF27283D);
  static const Color backgroundDark2 = Color(0xFF2D2D47);
  static const Color foregroundDark = Color(0xFF41415D);
  static const Color titleDark = Color(0xFFA5A5A5);
  

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

  static Color background2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark2
        : backgroundLight2;
  }

  static Color foreground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? foregroundDark
        : foregroundLight;
  }

  static Color title(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? titleDark
        : titleLight;
  }
}
