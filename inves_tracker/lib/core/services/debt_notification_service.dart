import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Service for managing debt payment notifications
/// Handles scheduling, cancellation, and timezone-aware notifications
class DebtNotificationService {
  static final DebtNotificationService _instance =
      DebtNotificationService._internal();
  factory DebtNotificationService() => _instance;
  DebtNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service
  /// Must be called before any other operations
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Get and set local timezone
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timezoneInfo.identifier;

    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
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

    // Request permissions (iOS)
    await _requestPermissions();

    _initialized = true;
  }

  /// Request notification permissions (mainly for iOS)
  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle navigation based on payload
    // Example: Navigate to debt details screen
    if (response.payload != null) {
      // Parse payload and navigate
      // Navigator logic would go here
    }
  }

  /// Schedule notifications for a debt based on business rules
  ///
  /// Rules:
  /// 1. Same day: No notification
  /// 2. ≤ 2 days: One notification on due date
  /// 3. > 2 days: Two notifications (3 days before + due date)
  Future<void> scheduleDebtNotifications({
    required String debtId,
    required DateTime createdAt,
    required DateTime dueDate,
    required String debtDescription,
    required AppLocalizations l10n,
    required double amount,
    required String currency,
  }) async {
    if (!_initialized) {
      throw StateError('DebtNotificationService must be initialized first');
    }

    // Cancel any existing notifications for this debt
    await cancelDebtNotifications(debtId);

    // Convert to local timezone-aware dates
    final tz.TZDateTime createdTz = _toTZDateTime(createdAt);
    final tz.TZDateTime dueDateTz = _toTZDateTime(dueDate);

    // Calculate difference in days (whole days, ignoring time)
    final int daysDifference = _calculateDaysDifference(createdTz, dueDateTz);

    // Rule 1: Same day - no notification
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

    // Rule 2: 2 days or less - one notification on due date
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

    // Rule 3: More than 2 days - two notifications
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
  }

  /// Convert DateTime to timezone-aware TZDateTime using device's local timezone
  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    // If already timezone-aware, use it
    if (dateTime.isUtc) {
      return tz.TZDateTime.from(dateTime, tz.local);
    }

    // Convert local DateTime to TZDateTime in device's timezone
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

  /// Calculate difference in calendar days between two dates
  /// Ignores time component, only counts full days
  int _calculateDaysDifference(tz.TZDateTime start, tz.TZDateTime end) {
    // Normalize to midnight for accurate day counting
    final startDate = tz.TZDateTime(
      tz.local,
      start.year,
      start.month,
      start.day,
    );

    final endDate = tz.TZDateTime(tz.local, end.year, end.month, end.day);

    return endDate.difference(startDate).inDays;
  }

  /// Schedule reminder notification (3 days before due date)
  Future<void> _scheduleReminderNotification({
    required String debtId,
    required tz.TZDateTime dueDate,
    required String description,
    required AppLocalizations l10n,
    required double amount,
    required String currency,
  }) async {
    // Calculate 3 days before due date at 9 AM
    final reminderDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day - 3,
      9, // 9 AM
      0,
      0,
    );

    // Only schedule if reminder date is in the future
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

    // Unique ID for reminder notification (debtId hash + 1)
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
  }

  /// Schedule due date notification
  Future<void> _scheduleDueDateNotification({
    required String debtId,
    required tz.TZDateTime dueDate,
    required String description,
    required AppLocalizations l10n,
    required double amount,
    required String currency,
  }) async {
    // Schedule for 8 AM on due date
    final notificationDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      14, // 8 AM
      42,
      0,
    );

    // Only schedule if due date is in the future
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
          color: Color(0xFFFF5252), // Red color for urgency
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

    // Unique ID for due date notification (debtId hash + 2)
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
  }

  /// Generate unique notification ID from debt ID
  int _generateNotificationId(String debtId, {required bool isReminder}) {
    // Use hashCode for consistent ID generation
    // Add offset to distinguish reminder vs due date notifications
    final baseId = debtId.hashCode.abs();
    return isReminder ? baseId + 1 : baseId + 2;
  }

  /// Cancel all notifications for a specific debt
  Future<void> cancelDebtNotifications(String debtId) async {
    final reminderId = _generateNotificationId(debtId, isReminder: true);
    final dueDateId = _generateNotificationId(debtId, isReminder: false);

    await _notifications.cancel(id: reminderId);
    await _notifications.cancel(id: dueDateId);
  }

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get list of pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Reschedule all notifications (useful after timezone change or app restart)
  Future<void> rescheduleNotifications(
    List<Map<String, dynamic>> debts,
    AppLocalizations l10n,
  ) async {
    await cancelAllNotifications();

    for (final debt in debts) {
      if (debt['dueDate'] != null) {
        await scheduleDebtNotifications(
          debtId: debt['id'],
          createdAt: debt['createdAt'],
          dueDate: debt['dueDate'],
          debtDescription: debt['description'],
          l10n: l10n,
          amount: debt['amount'],
          currency: debt['currency'],
        );
      }
    }
  }
}