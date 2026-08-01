import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/utils/theme_notifier.dart';
import 'package:inves_tracker/core/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ThemeSettingItem extends StatelessWidget {
  const ThemeSettingItem({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final l10n = AppLocalizations.of(context)!;

    final options = [
      _ThemeOption(
        mode: AppThemeMode.light,
        label: l10n.lightMode,
        icon: Icons.light_mode_outlined,
      ),
      _ThemeOption(
        mode: AppThemeMode.defaultDark,
        label: l10n.defaultTheme, // "Default" dark (navy)
        icon: Icons.contrast,
      ),
      _ThemeOption(
        mode: AppThemeMode.trueDark,
        label: l10n.darkMode, // New label — add to your ARB files
        icon: Icons.bedtime_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label row ──────────────────────────────────────────────
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.secondary(context).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                _iconForMode(themeNotifier.currentMode),
                color: AppColors.secondary(context),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              l10n.theme,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // ── Three-way segmented selector ───────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppColors.background2(context),
            borderRadius: BorderRadius.circular(14.r),
          ),
          padding: EdgeInsets.all(4.r),
          child: Row(
            children: options.map((opt) {
              final isSelected = themeNotifier.currentMode == opt.mode;
              return Expanded(
                child: GestureDetector(
                  onTap: () => themeNotifier.setThemeMode(opt.mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.foreground(context)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 6.r,
                                offset: Offset(0, 2.h),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          opt.icon,
                          size: 22.sp,
                          color: isSelected
                              ? AppColors.secondary(context)
                              : AppColors.title(context),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          opt.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.secondary(context)
                                : AppColors.title(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _iconForMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode_outlined;
      case AppThemeMode.defaultDark:
        return Icons.contrast;
      case AppThemeMode.trueDark:
        return Icons.bedtime_outlined;
    }
  }
}

class _ThemeOption {
  final AppThemeMode mode;
  final String label;
  final IconData icon;

  const _ThemeOption({
    required this.mode,
    required this.label,
    required this.icon,
  });
}
