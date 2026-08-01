import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inves_tracker/core/utils/localization_manager.dart';
import 'package:inves_tracker/core/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Service for managing debt payment notifications
class DebtNotificationService {
  static final DebtNotificationService _instance =
      DebtNotificationService._internal();
  factory DebtNotificationService() => _instance;
  DebtNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final LocalizationManager _localizationManager = LocalizationManager();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Get and set local timezone with fallback
      String timeZoneName;
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        timeZoneName = timezoneInfo.identifier;
      } catch (e) {
        timeZoneName = 'UTC';
      }

      tz.setLocalLocation(tz.getLocation(timeZoneName));

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions (iOS) - non-blocking
      _requestPermissions();

      _initialized = true;
    } catch (e) {
      _initialized = true;
      rethrow;
    }
  }

  /// Request notification permissions (mainly for iOS)
  void _requestPermissions() {
    Future.microtask(() async {
      try {
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        await androidPlugin?.requestNotificationsPermission();

        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        // Fail silently
      }
    });
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      // Handle navigation
    }
  }

  /// Schedule notifications for a debt
  Future<void> scheduleDebtNotifications({
    required String debtId,
    required DateTime createdAt,
    required DateTime dueDate,
    required String debtDescription,
    required double amount,
    required String currency,
  }) async {
    if (!_initialized) {
      throw StateError('DebtNotificationService must be initialized first');
    }

    try {
      final AppLocalizations l10n = _localizationManager.current;

      await cancelDebtNotifications(debtId);

      final tz.TZDateTime createdTz = _toTZDateTime(createdAt);
      final tz.TZDateTime dueDateTz = _toTZDateTime(dueDate);

      final int daysDifference = _calculateDaysDifference(createdTz, dueDateTz);

      if (daysDifference == 0) {
        await _scheduleDueDateNotification(
          debtId: debtId,
          dueDate: dueDateTz,
          description: debtDescription,
          l10n: l10n,
          amount: amount,
          currency: currency,
        );
        return;
      }

      if (daysDifference <= 2) {
        await _scheduleDueDateNotification(
          debtId: debtId,
          dueDate: dueDateTz,
          description: debtDescription,
          l10n: l10n,
          amount: amount,
          currency: currency,
        );
        return;
      }

      await _scheduleReminderNotification(
        debtId: debtId,
        dueDate: dueDateTz,
        description: debtDescription,
        l10n: l10n,
        amount: amount,
        currency: currency,
      );

      await _scheduleDueDateNotification(
        debtId: debtId,
        dueDate: dueDateTz,
        description: debtDescription,
        l10n: l10n,
        amount: amount,
        currency: currency,
      );
    } catch (e) {
      rethrow;
    }
  }

  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    if (dateTime.isUtc) {
      return tz.TZDateTime.from(dateTime, tz.local);
    }

    return tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }

  int _calculateDaysDifference(tz.TZDateTime start, tz.TZDateTime end) {
    final startDate = tz.TZDateTime(
      tz.local,
      start.year,
      start.month,
      start.day,
    );

    final endDate = tz.TZDateTime(tz.local, end.year, end.month, end.day);

    return endDate.difference(startDate).inDays;
  }

  Future<void> _scheduleReminderNotification({
    required String debtId,
    required tz.TZDateTime dueDate,
    required String description,
    required AppLocalizations l10n,
    required double amount,
    required String currency,
  }) async {
    try {
      final reminderDate = tz.TZDateTime(
        tz.local,
        dueDate.year,
        dueDate.month,
        dueDate.day - 3,
        9,
        0,
        0,
      );

      final now = tz.TZDateTime.now(tz.local);
      if (reminderDate.isBefore(now)) {
        return;
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'debt_reminders',
            'Debt Reminders',
            channelDescription: 'Notifications for upcoming debt payments',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final int notificationId = _generateNotificationId(
        debtId,
        isReminder: true,
      );

      await _notifications.zonedSchedule(
        id: notificationId,
        title: l10n.debtDueDateApproachingNotificationTitle,
        body: l10n.debtDueDateApproachingNotificationBody(amount, currency),
        scheduledDate: reminderDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'debt:$debtId',
      );
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> _scheduleDueDateNotification({
    required String debtId,
    required tz.TZDateTime dueDate,
    required String description,
    required AppLocalizations l10n,
    required double amount,
    required String currency,
  }) async {
    try {
      final notificationDate = tz.TZDateTime(
        tz.local,
        dueDate.year,
        dueDate.month,
        dueDate.day,
        8,
        0,
        0,
      );

      final now = tz.TZDateTime.now(tz.local);
      if (notificationDate.isBefore(now)) {
        return;
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'debt_reminders',
            'Debt Reminders',
            channelDescription: 'Notifications for upcoming debt payments',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFFFF5252),
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final int notificationId = _generateNotificationId(
        debtId,
        isReminder: false,
      );

      await _notifications.zonedSchedule(
        id: notificationId,
        title: l10n.debtDueDateNotificationTitle,
        body: l10n.debtDueDateNotificationBody(amount, currency),
        scheduledDate: notificationDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'debt:$debtId',
      );
    } catch (e) {
      // Fail silently
    }
  }

  int _generateNotificationId(String debtId, {required bool isReminder}) {
    final baseId = debtId.hashCode.abs();
    return isReminder ? baseId + 1 : baseId + 2;
  }

  Future<void> cancelDebtNotifications(String debtId) async {
    try {
      final reminderId = _generateNotificationId(debtId, isReminder: true);
      final dueDateId = _generateNotificationId(debtId, isReminder: false);

      await _notifications.cancel(id: reminderId);
      await _notifications.cancel(id: dueDateId);
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      // Fail silently
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      return [];
    }
  }

  Future<void> rescheduleNotifications(List<Map<String, dynamic>> debts) async {
    try {
      await cancelAllNotifications();

      for (final debt in debts) {
        if (debt['dueDate'] != null) {
          await scheduleDebtNotifications(
            debtId: debt['id'],
            createdAt: debt['createdAt'],
            dueDate: debt['dueDate'],
            debtDescription: debt['description'],
            amount: debt['amount'],
            currency: debt['currency'],
          );
        }
      }
    } catch (e) {
      // Fail silently
    }
  }
}
