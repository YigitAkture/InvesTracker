import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/core/utils/localization_manager.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service for managing app reminder and market update notifications
/// Handles weekly random reminders and occasional market value updates
class ReminderNotificationService {
  static final ReminderNotificationService _instance =
      ReminderNotificationService._internal();
  factory ReminderNotificationService() => _instance;
  ReminderNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final LocalizationManager _localizationManager = LocalizationManager();
  final MarketService _marketService = MarketService();

  // Preferences keys
  static const String _reminderEnabledKey = 'reminder_notifications_enabled';
  static const String _lastScheduledWeekKey = 'last_scheduled_week';

  // Configuration
  static const int _notificationsPerWeek = 3;
  static const int _marketUpdateFrequency = 3; // 1 in 3 notifications will be market updates
  
  // Notification IDs (must not conflict with debt notifications)
  static const int _reminderBaseId = 10000;
  static const int _marketUpdateBaseId = 20000;

  // Mainstream currencies for market updates
  static const List<String> _mainCurrencies = [
    'USD', 'EUR', 'GBP', 'CHF', 'CAD', 'JPY',
  ];

  // Reminder message keys (to be localized)
  static const List<String> _reminderMessageKeys = [
    'checkAssetValue',
    'reviewPortfolio',
    'updateInvestments',
    'trackMarket',
    'monitorDebts',
  ];

  /// Check if reminder notifications are enabled
  Future<bool> areRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderEnabledKey) ?? true; // Default: enabled
  }

  /// Set reminder notifications enabled/disabled
  Future<void> setRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, enabled);

    if (enabled) {
      await scheduleWeeklyReminders();
    } else {
      await cancelAllReminders();
    }
  }

  /// Schedule notifications for the current week
  Future<void> scheduleWeeklyReminders() async {
    final isEnabled = await areRemindersEnabled();
    if (!isEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final currentWeek = _getWeekNumber(now);
    final lastScheduledWeek = prefs.getInt(_lastScheduledWeekKey);

    // Only schedule if we haven't scheduled for this week yet
    if (lastScheduledWeek == currentWeek) return;

    // Cancel existing reminders
    await cancelAllReminders();

    // Generate random times for this week
    final notificationTimes = _generateRandomTimesForWeek(now);

    final l10n = _localizationManager.current;

    for (int i = 0; i < notificationTimes.length; i++) {
      final notificationTime = notificationTimes[i];
      
      // Skip if time is in the past
      if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) continue;

      // Determine if this should be a market update
      final isMarketUpdate = Random().nextInt(_marketUpdateFrequency) == 0;

      if (isMarketUpdate) {
        await _scheduleMarketUpdateNotification(
          notificationTime,
          _marketUpdateBaseId + i,
          l10n,
        );
      } else {
        await _scheduleReminderNotification(
          notificationTime,
          _reminderBaseId + i,
          l10n,
        );
      }
    }

    // Mark this week as scheduled
    await prefs.setInt(_lastScheduledWeekKey, currentWeek);
  }

  /// Schedule a general reminder notification
  Future<void> _scheduleReminderNotification(
    tz.TZDateTime scheduledTime,
    int notificationId,
    AppLocalizations l10n,
  ) async {
    // Randomly select a reminder message
    final messageKey = _reminderMessageKeys[
      Random().nextInt(_reminderMessageKeys.length)
    ];

    final title = l10n.appReminderNotificationTitle;
    final body = _getReminderMessage(messageKey, l10n);

    const androidDetails = AndroidNotificationDetails(
      'app_reminders',
      'App Reminders',
      channelDescription: 'Periodic reminders to check your investments',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'reminder',
    );
  }

  /// Schedule a market update notification with current currency value
  Future<void> _scheduleMarketUpdateNotification(
    tz.TZDateTime scheduledTime,
    int notificationId,
    AppLocalizations l10n,
  ) async {
    try {
      // Fetch current market data
      final marketData = await _marketService.fetchMarketData();
      
      // Randomly select a mainstream currency
      final selectedCode = _mainCurrencies[
        Random().nextInt(_mainCurrencies.length)
      ];
      
      final currency = marketData.currencies.firstWhere(
        (c) => c.code == selectedCode,
        orElse: () => marketData.currencies.first,
      );

      final title = l10n.marketUpdateNotificationTitle;
      final body = l10n.marketUpdateNotificationBody(
        currency.code,
        currency.selling,
      );

      const androidDetails = AndroidNotificationDetails(
        'market_updates',
        'Market Updates',
        channelDescription: 'Updates on current market values',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'market_update:${currency.code}',
      );

    } catch (e) {
      // If market data fetch fails, schedule a regular reminder instead
      await _scheduleReminderNotification(scheduledTime, notificationId, l10n);
    }
  }

  /// Generate random notification times for the current week
  List<tz.TZDateTime> _generateRandomTimesForWeek(DateTime now) {
    final times = <tz.TZDateTime>[];
    final random = Random();
    
    // Get start and end of current week
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    // Generate random times
    while (times.length < _notificationsPerWeek) {
      // Random day in the week (0-6)
      final dayOffset = random.nextInt(7);
      
      // Random hour between 9 AM and 9 PM
      final hour = 9 + random.nextInt(12);
      
      // Random minute
      final minute = random.nextInt(60);

      final notificationTime = tz.TZDateTime(
        tz.local,
        weekStart.year,
        weekStart.month,
        weekStart.day + dayOffset,
        hour,
        minute,
      );

      // Only add if in future and not too close to existing times
      if (notificationTime.isAfter(tz.TZDateTime.now(tz.local)) &&
          notificationTime.isBefore(tz.TZDateTime.from(weekEnd, tz.local)) &&
          !_isTooCloseToExisting(notificationTime, times)) {
        times.add(notificationTime);
      }
    }

    return times..sort();
  }

  /// Check if a time is too close to existing notification times
  bool _isTooCloseToExisting(
    tz.TZDateTime time,
    List<tz.TZDateTime> existing,
  ) {
    const minHoursBetween = 8;
    
    for (final existingTime in existing) {
      final difference = time.difference(existingTime).abs();
      if (difference.inHours < minHoursBetween) {
        return true;
      }
    }
    
    return false;
  }

  /// Get the week number of the year
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

  /// Get localized reminder message based on key
  String _getReminderMessage(String key, AppLocalizations l10n) {
    switch (key) {
      case 'checkAssetValue':
        return l10n.reminderCheckAssetValue;
      case 'reviewPortfolio':
        return l10n.reminderReviewPortfolio;
      case 'updateInvestments':
        return l10n.reminderUpdateInvestments;
      case 'trackMarket':
        return l10n.reminderTrackMarket;
      case 'monitorDebts':
        return l10n.reminderMonitorDebts;
      default:
        return l10n.reminderCheckAssetValue;
    }
  }

  /// Cancel all reminder and market update notifications
  Future<void> cancelAllReminders() async {
    // Cancel reminder notifications
    for (int i = 0; i < _notificationsPerWeek; i++) {
      await _notifications.cancel(id: _reminderBaseId + i);
      await _notifications.cancel(id: _marketUpdateBaseId + i);
    }
  }

  /// Reschedule notifications (call weekly or on app restart)
  Future<void> rescheduleIfNeeded() async {
    final isEnabled = await areRemindersEnabled();
    if (!isEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final currentWeek = _getWeekNumber(now);
    final lastScheduledWeek = prefs.getInt(_lastScheduledWeekKey);

    // Schedule if new week or never scheduled
    if (lastScheduledWeek == null || lastScheduledWeek != currentWeek) {
      await scheduleWeeklyReminders();
    }
  }
}