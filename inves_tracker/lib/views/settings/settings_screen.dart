import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/settings/widgets/section_header.dart';
import 'package:inves_tracker/views/settings/widgets/setting_card.dart';
import 'package:inves_tracker/views/settings/widgets/theme_setting_item.dart';
import 'package:inves_tracker/views/settings/widgets/language_setting_item.dart';
import 'package:inves_tracker/views/settings/widgets/logout_setting_item.dart';
import 'package:inves_tracker/views/settings/widgets/about_section.dart';
import 'package:inves_tracker/views/settings/widgets/user_profile_section.dart';
import 'package:inves_tracker/views/settings/widgets/change_password_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),

                // Dark Mode Setting Card
                const SettingCard(child: ThemeSettingItem()),
                SizedBox(height: 12.h),

                // Language Setting Card
                const SettingCard(child: LanguageSettingItem()),
                SizedBox(height: 12.h),

                // User Profile Section
                SectionHeader(title: l10n.userInformation),
                SizedBox(height: 8.h),
                const UserProfileSection(),
                SizedBox(height: 12.h),

                // Change Password Section
                SectionHeader(title: l10n.security),
                SizedBox(height: 8.h),
                SettingCard(
                  child: InkWell(
                    onTap: () => _showChangePasswordDialog(context),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: AppColors.secondary(context).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.lock_reset,
                            color: AppColors.secondary(context),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          l10n.changePassword,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text(context),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18.sp,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // About Section Header
                SectionHeader(title: l10n.about),
                SizedBox(height: 8.h),

                // About Section Card
                const AboutSection(),

                SizedBox(height: 18.h),

                // Logout Setting Card
                const Expanded(child: SizedBox()),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.foreground(context),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.danger,
                      width: 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: const LogoutSettingItem(),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}