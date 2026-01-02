import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/settings/widgets/info_row.dart';
import 'package:inves_tracker/views/settings/widgets/setting_card.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  void _showDeveloperInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.secondary(context),
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'InvesTracker Team',
              style: TextStyle(fontSize: 20.sp),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(
              context,
              icon: Icons.person_outline,
              label: l10n.developer,
              value: 'Yiğit Aktüre',
            ),
            SizedBox(height: 16.h),
            _buildInfoItem(
              context,
              icon: Icons.design_services_outlined,
              label: l10n.designer,
              value: 'Nisa Dost',
            ),
            SizedBox(height: 16.h),
            _buildInfoItem(
              context,
              icon: Icons.email_outlined,
              label: l10n.email,
              value: 'investrackerapp@gmail.com',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primary(context),
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingCard(
      child: Column(
        children: [
          InfoRow(
            icon: Icons.info_outline,
            label: l10n.version,
            value: '0.1.2',
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
            trailingWidget: IconButton(
              icon: Icon(
                Icons.info_outline,
                size: 24.sp,
                color: AppColors.secondary(context),
              ),
              onPressed: () => _showDeveloperInfo(context),
            ),
          ),
        ],
      ),
    );
  }
}