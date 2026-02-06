import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/settings/widgets/info_row.dart';
import 'package:inves_tracker/views/settings/widgets/setting_card.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  void _showDeveloperInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline,
                color: AppColors.secondary(context), size: 24.sp),
            SizedBox(width: 12.w),
            Text('InvesTracker Team', style: TextStyle(fontSize: 20.sp)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            _buildInfoItem(
              context,
              icon: Icons.code_outlined,
              label: '${l10n.developer} & ${l10n.designer}',
              value: 'Yiğit Aktüre\nNisa Dost',
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
        Icon(icon, color: AppColors.primary(context), size: 20.sp),
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
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
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
            value: _appVersion.isEmpty ? '-' : _appVersion,
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
              icon: Icon(Icons.info_outline,
                  size: 24.sp, color: AppColors.secondary(context)),
              onPressed: () => _showDeveloperInfo(context),
            ),
          ),
          Divider(
            height: 24.h,
            color: AppColors.background2(context).withValues(alpha: 0.5),
          ),
          InfoRow(
            icon: Icons.language,
            label: l10n.website,
            value: 'yigitakture.github.io',
            iconColor: AppColors.primary(context),
            trailingWidget: IconButton(
              icon: Icon(Icons.open_in_new,
                  size: 24.sp, color: AppColors.primary(context)),
              onPressed: () async {
                final url = Uri.parse('https://yigitakture.github.io/');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
          Divider(
            height: 24.h,
            color: AppColors.background2(context).withValues(alpha: 0.5),
          ),
          InfoRow(
            icon: Icons.email_outlined,
            label: l10n.email,
            value: 'investrackerapp@gmail.com',
            iconColor: AppColors.secondary(context),
            trailingWidget: IconButton(
              icon: Icon(Icons.copy,
                  size: 24.sp, color: AppColors.secondary(context)),
              onPressed: () {
                Clipboard.setData(
                    const ClipboardData(text: 'investrackerapp@gmail.com'));

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.copiedToClipboard),
                    backgroundColor: AppColors.primary(context),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
