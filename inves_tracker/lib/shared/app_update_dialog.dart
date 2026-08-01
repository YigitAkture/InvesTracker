import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/version_check_service.dart';
import 'package:inves_tracker/core/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateDialog extends StatelessWidget {
  final String updateUrl;
  final String minimumVersion; // shown for force-update
  final String recommendedVersion; // shown for soft-update
  final bool forceUpdate;

  const AppUpdateDialog({
    super.key,
    required this.updateUrl,
    this.minimumVersion = '',
    this.recommendedVersion = '',
    this.forceUpdate = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayVersion = forceUpdate ? minimumVersion : recommendedVersion;

    return PopScope(
      canPop: !forceUpdate,
      onPopInvokedWithResult: (didPop, result) {
        if (forceUpdate && !didPop) {
          SystemNavigator.pop();
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.system_update_alt,
              color: AppColors.primary(context),
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                forceUpdate ? l10n.updateRequired : l10n.updateRecommended,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              forceUpdate
                  ? l10n.updateRequiredMessage
                  : l10n.updateRecommendedMessage,
              style: TextStyle(fontSize: 15.sp, height: 1.4),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary(context),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${forceUpdate ? l10n.minimumVersion : l10n.recommendedVersion}: $displayVersion',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Left button: exit app (force) or continue (soft) ──────────
              ElevatedButton.icon(
                onPressed: () async {
                  if (forceUpdate) {
                    SystemNavigator.pop();
                  } else {
                    // Mark as seen so it won't appear again for this version
                    if (recommendedVersion.isNotEmpty) {
                      await VersionCheckService.markRecommendedVersionSeen(
                        recommendedVersion,
                      );
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger3,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                icon: Icon(
                  forceUpdate ? Icons.close : Icons.arrow_forward,
                  size: 16.sp,
                ),
                label: Text(
                  forceUpdate ? l10n.later : l10n.wordContinue,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // ── Right button: open Play Store ──────────────────────────────
              ElevatedButton.icon(
                onPressed: () async {
                  if (!forceUpdate && recommendedVersion.isNotEmpty) {
                    await VersionCheckService.markRecommendedVersionSeen(
                      recommendedVersion,
                    );
                  }
                  await _launchStore(updateUrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                icon: Icon(Icons.download, size: 16.sp),
                label: Text(
                  l10n.updateNow,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchStore(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> show(
    BuildContext context, {
    required String updateUrl,
    String minimumVersion = '',
    String recommendedVersion = '',
    bool forceUpdate = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (context) => AppUpdateDialog(
        updateUrl: updateUrl,
        minimumVersion: minimumVersion,
        recommendedVersion: recommendedVersion,
        forceUpdate: forceUpdate,
      ),
    );
  }
}
