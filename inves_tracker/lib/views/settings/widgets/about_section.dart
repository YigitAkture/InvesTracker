import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/settings/widgets/info_row.dart';
import 'package:inves_tracker/views/settings/widgets/setting_card.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingCard(
      child: Column(
        children: [
          InfoRow(
            icon: Icons.info_outline,
            label: l10n.version,
            value: '0.1.0',
            iconColor: AppColors.primary(context),
          ),
          Divider(
            height: 24.h,
            color: AppColors.background2(context).withValues(alpha: 0.5),
          ),
          InfoRow(
            icon: Icons.code,
            label: l10n.developer,
            value: 'InvesTracker Team',
            iconColor: AppColors.secondary(context),
          ),
        ],
      ),
    );
  }
}