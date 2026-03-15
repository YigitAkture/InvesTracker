// ─── settings_screen.dart (showcase-aware version) ──────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/showcase_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/navigation/main_layout.dart';
import 'package:inves_tracker/views/settings/widgets/section_header.dart';
import 'package:inves_tracker/views/settings/widgets/security_section.dart';
import 'package:inves_tracker/views/settings/widgets/setting_card.dart';
import 'package:inves_tracker/views/settings/widgets/theme_setting_item.dart';
import 'package:inves_tracker/views/settings/widgets/language_setting_item.dart';
import 'package:inves_tracker/views/settings/widgets/logout_setting_item.dart';
import 'package:inves_tracker/views/settings/widgets/about_section.dart';
import 'package:inves_tracker/views/settings/widgets/user_profile_section.dart';
import 'package:inves_tracker/views/settings/widgets/notification_settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Theme card — no showcase wrap (nav bar icon is enough for Settings).
    const Widget themeCard = SettingCard(child: ThemeSettingItem());

    // Language card — no showcase wrap.
    const Widget langCard = SettingCard(child: LanguageSettingItem());

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                SectionHeader(title: l10n.userInformation),
                SizedBox(height: 8.h),
                const UserProfileSection(),
                SizedBox(height: 12.h),

                // Preferences
                SectionHeader(title: l10n.preferences),
                SizedBox(height: 8.h),
                themeCard, // ← showcased
                SizedBox(height: 12.h),
                langCard,  // ← showcased
                SizedBox(height: 12.h),

                // Notifications
                SectionHeader(title: l10n.notifications),
                SizedBox(height: 8.h),
                const NotificationSettingsSection(),
                SizedBox(height: 12.h),

                // Security
                SectionHeader(title: l10n.security),
                SizedBox(height: 8.h),
                const SecuritySection(),
                SizedBox(height: 12.h),

                // About
                SectionHeader(title: l10n.about),
                SizedBox(height: 8.h),
                const AboutSection(),
                SizedBox(height: 18.h),

                // ── Replay Tour button ──────────────────────────────────────
                _ReplayTourButton(),
                SizedBox(height: 12.h),

                // Logout
                const Expanded(child: SizedBox()),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.foreground(context),
                    borderRadius: BorderRadius.circular(16.r),
                    border:
                        Border.all(color: AppColors.danger, width: 1.5.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: const LogoutSettingItem(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Replay Tour button ────────────────────────────────────────────────────

class _ReplayTourButton extends StatelessWidget {
  final ShowcaseService _showcaseService = ShowcaseService();

  _ReplayTourButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () async {
        // Reset the "seen" flag so the tour will fire automatically next time,
        // then trigger it immediately via MainLayout's public method.
        await _showcaseService.reset();

        if (!context.mounted) return;

        // Walk up the tree to find MainLayout's state and call startShowcaseManually.
        final mainLayoutState =
            context.findAncestorStateOfType<_MainLayoutState>();
        if (mainLayoutState != null) {
          mainLayoutState.startShowcaseManually();
        } else {
          // Fallback: push a fresh MainLayout with showcase enabled.
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const MainLayout(startShowcase: true),
            ),
            (route) => false,
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.foreground(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primary(context).withValues(alpha: 0.6),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color:
                    AppColors.primary(context).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.tour_outlined,
                color: AppColors.primary(context),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.replayTour,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10n.replayTourDescription,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.title(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 18.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Expose the private state type so _ReplayTourButton can reach it via
// findAncestorStateOfType.  This is safe because both live in the same library.
typedef _MainLayoutState = MainLayoutState;