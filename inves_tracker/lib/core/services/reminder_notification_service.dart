import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/core/utils/localization_manager.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Service for managing app reminder and market update notifications
class ReminderNotificationService {
  static final ReminderNotificationService _instance =
      ReminderNotificationService._internal();
  factory ReminderNotificationService() => _instance;
  ReminderNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final LocalizationManager _localizationManager = LocalizationManager();
  final MarketService _marketService = MarketService();

  bool _isInitialized = false;

  static const String _reminderEnabledKey = 'reminder_notifications_enabled';
  static const String _lastScheduledWeekKey = 'last_scheduled_week';

  static const int _notificationsPerWeek = 3;
  static const int _marketUpdateFrequency = 3;

  static const int _reminderBaseId = 10000;
  static const int _marketUpdateBaseId = 20000;

  static const List<String> _mainCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'CHF',
    'CAD',
    'JPY',
  ];

  static const List<String> _reminderMessageKeys = [
    'checkAssetValue',
    'reviewPortfolio',
    'updateInvestments',
    'trackMarket',
    'monitorDebts',
  ];

  Future<void> _initializeTimezone() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

      _isInitialized = true;
    } catch (e) {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.UTC);
      _isInitialized = true;
    }
  }

  Future<bool> areRemindersEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_reminderEnabledKey) ?? true;
    } catch (e) {
      return true;
    }
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reminderEnabledKey, enabled);

      if (enabled) {
        await scheduleWeeklyReminders();
      } else {
        await cancelAllReminders();
      }
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> scheduleWeeklyReminders() async {
    try {
      await _initializeTimezone();

      final isEnabled = await areRemindersEnabled();
      if (!isEnabled) return;

      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final currentWeek = _getWeekNumber(now);
      final lastScheduledWeek = prefs.getInt(_lastScheduledWeekKey);

      if (lastScheduledWeek == currentWeek) return;

      await cancelAllReminders();

      final notificationTimes = _generateRandomTimesForWeek(now);

      final l10n = _localizationManager.current;

      for (int i = 0; i < notificationTimes.length; i++) {
        final notificationTime = notificationTimes[i];

        if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) continue;

        try {
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
        } catch (e) {
          continue;
        }
      }

      await prefs.setInt(_lastScheduledWeekKey, currentWeek);
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> _scheduleReminderNotification(
    tz.TZDateTime scheduledTime,
    int notificationId,
    AppLocalizations l10n,
  ) async {
    try {
      final messageKey =
          _reminderMessageKeys[Random().nextInt(_reminderMessageKeys.length)];

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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _scheduleMarketUpdateNotification(
    tz.TZDateTime scheduledTime,
    int notificationId,
    AppLocalizations l10n,
  ) async {
    try {
      final marketData = await _marketService.fetchMarketData();

      final selectedCode =
          _mainCurrencies[Random().nextInt(_mainCurrencies.length)];

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
      await _scheduleReminderNotification(scheduledTime, notificationId, l10n);
    }
  }

  List<tz.TZDateTime> _generateRandomTimesForWeek(DateTime now) {
    final times = <tz.TZDateTime>[];
    final random = Random();

    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    int attempts = 0;
    while (times.length < _notificationsPerWeek && attempts < 50) {
      attempts++;

      final dayOffset = random.nextInt(7);
      final hour = 9 + random.nextInt(12);
      final minute = random.nextInt(60);

      final notificationTime = tz.TZDateTime(
        tz.local,
        weekStart.year,
        weekStart.month,
        weekStart.day + dayOffset,
        hour,
        minute,
      );

      if (notificationTime.isAfter(tz.TZDateTime.now(tz.local)) &&
          notificationTime.isBefore(tz.TZDateTime.from(weekEnd, tz.local)) &&
          !_isTooCloseToExisting(notificationTime, times)) {
        times.add(notificationTime);
      }
    }

    return times..sort();
  }

  bool _isTooCloseToExisting(tz.TZDateTime time, List<tz.TZDateTime> existing) {
    const minHoursBetween = 8;

    for (final existingTime in existing) {
      final difference = time.difference(existingTime).abs();
      if (difference.inHours < minHoursBetween) {
        return true;
      }
    }

    return false;
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

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

  Future<void> cancelAllReminders() async {
    try {
      for (int i = 0; i < _notificationsPerWeek; i++) {
        await _notifications.cancel(id: _reminderBaseId + i);
        await _notifications.cancel(id: _marketUpdateBaseId + i);
      }
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> rescheduleIfNeeded() async {
    try {
      await _initializeTimezone();

      final isEnabled = await areRemindersEnabled();
      if (!isEnabled) return;

      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final currentWeek = _getWeekNumber(now);
      final lastScheduledWeek = prefs.getInt(_lastScheduledWeekKey);

      if (lastScheduledWeek == null || lastScheduledWeek != currentWeek) {
        await scheduleWeeklyReminders();
      }
    } catch (e) {
      // Fail silently
    }
  }
}