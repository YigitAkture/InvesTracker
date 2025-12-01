import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/utils/locale_notifier.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class LanguageSettingItem extends StatelessWidget {
  const LanguageSettingItem({super.key});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Flag icon instead of language icon
            Padding(
              padding: EdgeInsets.all(8.r),
              child: Image.asset(
                _getFlagAsset(localeNotifier),
                height: 32.h,
                width: 32.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if flag image not found
                  return Icon(
                    Icons.language,
                    color: AppColors.secondary(context),
                    size: 24.sp,
                  );
                },
              ),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.language,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _getCurrentLanguage(context, localeNotifier),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.title(context),
                  ),
                ),
              ],
            ),
          ],
        ),
        Switch(
          value: _isTurkish(localeNotifier),
          onChanged: (value) {
            if (value) {
              localeNotifier.setLocale(const Locale('tr'));
            } else {
              localeNotifier.setLocale(const Locale('en'));
            }
          },
          activeThumbColor: AppColors.secondary(context),
        ),
      ],
    );
  }

  String _getFlagAsset(LocaleNotifier localeNotifier) {
    final currentLocale = localeNotifier.locale;
    if (currentLocale == null) {
      // Use system locale - default to English flag
      return 'assets/img/flags/gbp.png';
    }

    if (currentLocale.languageCode == 'tr') {
      return 'assets/img/flags/try.png';
    } else {
      return 'assets/img/flags/gbp.png';
    }
  }

  String _getCurrentLanguage(
    BuildContext context,
    LocaleNotifier localeNotifier,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale =
        localeNotifier.locale ?? Localizations.localeOf(context);

    if (currentLocale.languageCode == 'tr') {
      return l10n.turkish;
    } else {
      return l10n.english;
    }
  }

  bool _isTurkish(LocaleNotifier localeNotifier) {
    final currentLocale = localeNotifier.locale;
    if (currentLocale == null) {
      // Use system locale - default to English
      return false;
    }
    return currentLocale.languageCode == 'tr';
  }
}
