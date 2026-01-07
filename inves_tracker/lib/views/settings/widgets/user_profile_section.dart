import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/auth_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/settings/widgets/setting_card.dart';
import 'package:inves_tracker/views/settings/widgets/edit_profile_dialog.dart';
import 'package:inves_tracker/views/settings/widgets/delete_account_dialog.dart';

class UserProfileSection extends StatefulWidget {
  const UserProfileSection({super.key});

  @override
  State<UserProfileSection> createState() => _UserProfileSectionState();
}

class _UserProfileSectionState extends State<UserProfileSection> {
  final AuthService _authService = AuthService();
  Map<String, String?> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final userData = await _authService.getCurrentUserData();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  Future<void> _editProfile() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditProfileDialog(
        currentFirstName: _userData['firstName'] ?? '',
        currentLastName: _userData['lastName'] ?? '',
        currentEmail: _userData['email'] ?? '',
      ),
    );

    if (result == true) {
      _loadUserData();
    }
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

    if (_isLoading) {
      return SettingCard(
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary(context),
          ),
        ),
      );
    }

    return SettingCard(
      child: Column(
        children: [
          // User Info Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.person_outline,
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
                      '${_userData['firstName'] ?? ''} ${_userData['lastName'] ?? ''}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _userData['email'] ?? '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.title(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _editProfile,
                icon: Icon(
                  Icons.edit_outlined,
                  size: 22.sp,
                  color: AppColors.primary(context),
                ),
              ),
            ],
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
                border: Border.all(
                  color: AppColors.danger,
                  width: 1.5.w,
                ),
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