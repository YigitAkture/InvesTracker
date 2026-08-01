import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/reminder_notification_service.dart';
import 'package:inves_tracker/core/services/preferences_service.dart';
import 'package:inves_tracker/core/helpers/notification_permission_helper.dart';
import 'package:inves_tracker/core/l10n/app_localizations.dart';
import 'package:inves_tracker/views/settings/widgets/setting_card.dart';

class NotificationSettingsSection extends StatefulWidget {
  const NotificationSettingsSection({super.key});

  @override
  State<NotificationSettingsSection> createState() =>
      _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState
    extends State<NotificationSettingsSection> {
  final ReminderNotificationService _reminderService =
      ReminderNotificationService();
  final PreferencesService _preferencesService = PreferencesService();
  final NotificationPermissionHelper _permissionHelper =
      NotificationPermissionHelper();

  bool _reminderEnabled = true;
  bool _debtEnabled = true;
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    // Check notification permission first
    final hasPermission = await _permissionHelper.hasPermission();

    // Load preferences
    final reminderEnabled = await _reminderService.areRemindersEnabled();
    final debtEnabled = await _preferencesService.getDebtNotificationsEnabled();

    setState(() {
      _hasPermission = hasPermission;
      // If no permission, force toggles to be off
      _reminderEnabled = hasPermission && reminderEnabled;
      _debtEnabled = hasPermission && debtEnabled;
      _isLoading = false;
    });

    // If permission was revoked, update preferences to match
    if (!hasPermission) {
      if (reminderEnabled) {
        await _reminderService.setRemindersEnabled(false);
      }
      if (debtEnabled) {
        await _preferencesService.setDebtNotificationsEnabled(false);
      }
    }
  }

  Future<void> _toggleReminderNotifications(bool value) async {
    // If trying to enable, check permission first
    if (value && !_hasPermission) {
      await _handlePermissionRequest();
      return;
    }

    setState(() => _reminderEnabled = value);
    await _reminderService.setRemindersEnabled(value);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? l10n.reminderNotificationsEnabled
                : l10n.reminderNotificationsDisabled,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary(context),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleDebtNotifications(bool value) async {
    // If trying to enable, check permission first
    if (value && !_hasPermission) {
      await _handlePermissionRequest();
      return;
    }

    setState(() => _debtEnabled = value);
    await _preferencesService.setDebtNotificationsEnabled(value);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? l10n.debtNotificationsEnabled
                : l10n.debtNotificationsDisabled,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary(context),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handlePermissionRequest() async {
    final l10n = AppLocalizations.of(context)!;

    // Check if permanently denied
    final isPermanentlyDenied = await _permissionHelper.isPermanentlyDenied();

    if (isPermanentlyDenied) {
      // Show dialog to open settings
      _showPermissionDialog(
        title: l10n.notificationPermissionRequired,
        message: l10n.notificationPermissionDeniedMessage,
        showSettingsButton: true,
      );
      return;
    }

    // Request permission
    final granted = await _permissionHelper.requestPermission();

    if (granted) {
      // Permission granted, reload settings
      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.notificationPermissionGranted,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Permission denied
      if (mounted) {
        _showPermissionDialog(
          title: l10n.notificationPermissionRequired,
          message: l10n.notificationPermissionRequiredMessage,
          showSettingsButton: false,
        );
      }
    }
  }

  void _showPermissionDialog({
    required String title,
    required String message,
    required bool showSettingsButton,
  }) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.notifications_off,
              color: AppColors.warning,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 18.sp)),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          if (showSettingsButton)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _permissionHelper.openSettings();
              },
              child: Text(l10n.openSettings),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return SettingCard(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary(context)),
        ),
      );
    }

    return SettingCard(
      child: Column(
        children: [
          // Permission warning banner (shown if no permission)
          if (!_hasPermission)
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      l10n.notificationPermissionNotGranted,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _handlePermissionRequest,
                    child: Text(
                      l10n.enable,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Reminder Notifications Toggle
          _NotificationToggleItem(
            icon: Icons.notifications_active_outlined,
            title: l10n.reminderNotifications,
            description: l10n.reminderNotificationsDescription,
            value: _reminderEnabled,
            onChanged: _toggleReminderNotifications,
            iconColor: AppColors.secondary(context),
            enabled: _hasPermission,
          ),

          Divider(
            height: 24.h,
            color: AppColors.background2(context).withValues(alpha: 0.5),
          ),

          // Debt Notifications Toggle
          _NotificationToggleItem(
            icon: Icons.calendar_today_outlined,
            title: l10n.debtNotifications,
            description: l10n.debtNotificationsDescription,
            value: _debtEnabled,
            onChanged: _toggleDebtNotifications,
            iconColor: AppColors.primary(context),
            enabled: _hasPermission,
          ),
        ],
      ),
    );
  }
}

class _NotificationToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final Function(bool) onChanged;
  final Color iconColor;
  final bool enabled;

  const _NotificationToggleItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    required this.iconColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.title(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return HSLColor.fromColor(iconColor)
                    .withLightness(
                      (HSLColor.fromColor(iconColor).lightness - 0.05).clamp(
                        0.0,
                        1.0,
                      ),
                    )
                    .toColor();
              }
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return iconColor.withValues(alpha: 0.4);
              }
              return null; // default
            }),
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return iconColor;
              }
              return iconColor.withValues(alpha: 0.4);
            }),
          ),
        ],
      ),
    );
  }
}
