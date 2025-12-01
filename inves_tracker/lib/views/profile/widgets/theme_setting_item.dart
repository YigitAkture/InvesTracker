import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/utils/theme_notifier.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ThemeSettingItem extends StatelessWidget {
  const ThemeSettingItem({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primary(context),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              l10n.darkMode,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Switch(
          value: themeNotifier.isDarkMode,
          onChanged: (value) {
            themeNotifier.setTheme(value);
          },
          activeThumbColor: AppColors.primary(context),
        ),
      ],
    );
  }
}