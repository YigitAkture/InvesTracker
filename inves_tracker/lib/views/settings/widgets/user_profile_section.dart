import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/auth_service.dart';
import 'package:inves_tracker/views/settings/widgets/setting_card.dart';
import 'package:inves_tracker/views/settings/widgets/edit_profile_dialog.dart';

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

  @override
  Widget build(BuildContext context) {

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
        ],
      ),
    );
  }
}