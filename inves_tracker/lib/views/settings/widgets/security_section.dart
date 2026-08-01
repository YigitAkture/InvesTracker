import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/l10n/app_localizations.dart';
import 'package:inves_tracker/views/settings/widgets/change_password_dialog.dart';
import 'package:inves_tracker/views/settings/widgets/delete_account_dialog.dart';
import 'package:inves_tracker/views/settings/widgets/setting_card.dart';

class SecuritySection extends StatefulWidget {
  const SecuritySection({super.key});

  @override
  State<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends State<SecuritySection> {
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  Future<void> _deleteAccount() async {
    await showDialog(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingCard(
      child: Column(
        children: [
          InkWell(
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
                Icon(Icons.arrow_forward_ios, size: 18.sp, color: Colors.grey),
              ],
            ),
          ),
          Divider(
            height: 24.h,
            color: AppColors.background2(context).withValues(alpha: 0.5),
          ),

          // Delete Account Button
          InkWell(
            onTap: _deleteAccount,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.danger, width: 1.5.w),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_forever_outlined,
                    color: AppColors.danger,
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.deleteMyAccount,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
