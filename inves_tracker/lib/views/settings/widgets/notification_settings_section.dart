import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/reminder_notification_service.dart';
import 'package:inves_tracker/core/services/preferences_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
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

  bool _reminderEnabled = true;
  bool _debtEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final reminderEnabled = await _reminderService.areRemindersEnabled();
    final debtEnabled = await _preferencesService.getDebtNotificationsEnabled();

    setState(() {
      _reminderEnabled = reminderEnabled;
      _debtEnabled = debtEnabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleReminderNotifications(bool value) async {
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
          // Reminder Notifications Toggle
          _NotificationToggleItem(
            icon: Icons.notifications_active_outlined,
            title: l10n.reminderNotifications,
            description: l10n.reminderNotificationsDescription,
            value: _reminderEnabled,
            onChanged: _toggleReminderNotifications,
            iconColor: AppColors.secondary(context),
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

  const _NotificationToggleItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
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
        Switch(value: value, onChanged: onChanged, activeColor: iconColor),
      ],
    );
  }
}
