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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language label
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              Icon(
                Icons.language,
                color: AppColors.secondary(context),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.language,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Language buttons row
        Row(
          children: [
            // English button
            Expanded(
              child: _LanguageButton(
                flagAsset: 'assets/img/flags/gbp.png',
                languageName: 'English',
                isSelected: _isEnglish(localeNotifier, context),
                onTap: () {
                  localeNotifier.setLocale(const Locale('en'));
                },
              ),
            ),
            SizedBox(width: 12.w),
            
            // Turkish button
            Expanded(
              child: _LanguageButton(
                flagAsset: 'assets/img/flags/try.png',
                languageName: 'Türkçe',
                isSelected: _isTurkish(localeNotifier, context),
                onTap: () {
                  localeNotifier.setLocale(const Locale('tr'));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isEnglish(LocaleNotifier localeNotifier, BuildContext context) {
    final currentLocale = localeNotifier.locale;
    if (currentLocale == null) {
      final systemLocale = Localizations.localeOf(context);
      return systemLocale.languageCode == 'en';
    }
    return currentLocale.languageCode == 'en';
  }

  bool _isTurkish(LocaleNotifier localeNotifier, BuildContext context) {
    final currentLocale = localeNotifier.locale;
    if (currentLocale == null) {
      final systemLocale = Localizations.localeOf(context);
      return systemLocale.languageCode == 'tr';
    }
    return currentLocale.languageCode == 'tr';
  }
}

class _LanguageButton extends StatelessWidget {
  final String flagAsset;
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.flagAsset,
    required this.languageName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary(context).withValues(alpha: 0.1)
              : AppColors.background2(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary(context)
                : Colors.transparent,
            width: 2.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flag image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                flagAsset,
                height: 40.h,
                width: 40.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 40.h,
                    width: 56.w,
                    decoration: BoxDecoration(
                      color: AppColors.background2(context),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.flag,
                      size: 24.sp,
                      color: AppColors.secondary(context),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
            
            // Language name
            Text(
              languageName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.secondary(context)
                    : Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}