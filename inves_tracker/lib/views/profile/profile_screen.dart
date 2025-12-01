import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/profile/widgets/section_header.dart';
import 'package:inves_tracker/views/profile/widgets/setting_card.dart';
import 'package:inves_tracker/views/profile/widgets/theme_setting_item.dart';
import 'package:inves_tracker/views/profile/widgets/language_setting_item.dart';
import 'package:inves_tracker/views/profile/widgets/about_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Section Header
            SectionHeader(title: l10n.settings),
            SizedBox(height: 8.h),

            // Dark Mode Setting Card
            const SettingCard(
              child: ThemeSettingItem(),
            ),
            SizedBox(height: 12.h),

            // Language Setting Card
            const SettingCard(
              child: LanguageSettingItem(),
            ),
            SizedBox(height: 32.h),

            // About Section Header
            SectionHeader(title: l10n.about),
            SizedBox(height: 8.h),

            // About Section Card
            const AboutSection(),
          ],
        ),
      ),
    );
  }
}