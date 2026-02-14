import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/services/debt_notification_service.dart';
import 'package:inves_tracker/core/services/reminder_notification_service.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;

/// Debug screen for testing notification functionality
/// Use this in development to verify notification scheduling
class NotificationDebugScreen extends StatefulWidget {
  const NotificationDebugScreen({super.key});

  @override
  State<NotificationDebugScreen> createState() =>
      _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen>
    with SingleTickerProviderStateMixin {
  final DebtNotificationService _debtNotificationService =
      DebtNotificationService();
  final ReminderNotificationService _reminderNotificationService =
      ReminderNotificationService();
  final MarketService _marketService = MarketService();

  List<PendingNotificationRequest> _pendingNotifications = [];
  String _currentTimeZone = '';
  String _testResults = '';

  late TabController _tabController;
  bool _reminderEnabled = true;
  bool _isLoadingMarketData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDebugInfo();
    _checkReminderStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDebugInfo() async {
    final pending = await _debtNotificationService.getPendingNotifications();
    final timeZone = tz.local.name;

    setState(() {
      _pendingNotifications = pending;
      _currentTimeZone = timeZone;
    });
  }

  Future<void> _checkReminderStatus() async {
    final enabled = await _reminderNotificationService.areRemindersEnabled();
    setState(() {
      _reminderEnabled = enabled;
    });
  }

  // ========================================
  // DEBT NOTIFICATION TESTS
  // ========================================

  /// Test Case 1: Same day (should schedule 1 notification on due date)
  Future<void> _testDebtSameDay() async {
    final now = DateTime.now();

    try {
      await _debtNotificationService.scheduleDebtNotifications(
        debtId: 'test_same_day',
        createdAt: now,
        dueDate: now,
        debtDescription: 'Same day test',
        amount: 100,
        currency: 'USD',
      );

      await _loadDebugInfo();

      setState(() {
        _testResults =
            '✅ Same day test: 1 notification scheduled for today (correct)';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Same day test failed: $e';
      });
    }
  }

  /// Test Case 2: 2 days difference (should schedule 1 notification)
  Future<void> _testDebtTwoDays() async {
    final now = DateTime.now();
    final dueDate = now.add(const Duration(days: 2));

    try {
      await _debtNotificationService.scheduleDebtNotifications(
        debtId: 'test_two_days',
        createdAt: now,
        dueDate: dueDate,
        debtDescription: 'Two days test',
        amount: 200,
        currency: 'EUR',
      );

      await _loadDebugInfo();

      setState(() {
        _testResults = '✅ Two days test: 1 notification scheduled (correct)';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Two days test failed: $e';
      });
    }
  }

  /// Test Case 3: More than 2 days (should schedule 2 notifications)
  Future<void> _testDebtMoreThanTwoDays() async {
    final now = DateTime.now();
    final dueDate = now.add(const Duration(days: 5));

    try {
      await _debtNotificationService.scheduleDebtNotifications(
        debtId: 'test_five_days',
        createdAt: now,
        dueDate: dueDate,
        debtDescription: 'Five days test',
        amount: 500,
        currency: 'GBP',
      );

      await _loadDebugInfo();

      setState(() {
        _testResults = '✅ Five days test: 2 notifications scheduled (correct)';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Five days test failed: $e';
      });
    }
  }

  /// Test Case 4: Past due date (should not schedule)
  Future<void> _testDebtPastDueDate() async {
    final now = DateTime.now();
    final dueDate = now.subtract(const Duration(days: 3));

    try {
      await _debtNotificationService.scheduleDebtNotifications(
        debtId: 'test_past_due',
        createdAt: dueDate,
        dueDate: dueDate,
        debtDescription: 'Past due test',
        amount: 300,
        currency: 'TRY',
      );

      await _loadDebugInfo();

      setState(() {
        _testResults = '✅ Past due test: No notifications scheduled (correct)';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Past due test failed: $e';
      });
    }
  }

  /// Test immediate debt notification (for testing notification appearance)
  Future<void> _testDebtImmediateNotification() async {
    try {
      final l10n = AppLocalizations.of(context)!;

      // Schedule directly without using the service to avoid time constraints
      final notificationTime = tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 3));

      const androidDetails = AndroidNotificationDetails(
        'debt_reminders',
        'Debt Reminders',
        channelDescription: 'Notifications for upcoming debt payments',
        importance: Importance.max,
        priority: Priority.high,
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

      await FlutterLocalNotificationsPlugin().zonedSchedule(
        id: 9999, // Use unique test ID outside normal range
        title: l10n.debtDueDateNotificationTitle,
        body: l10n.debtDueDateNotificationBody(1000.0, 'USD'),
        scheduledDate: notificationTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'debt:test_immediate',
      );

      await _loadDebugInfo();

      setState(() {
        _testResults =
            '✅ Immediate debt notification scheduled for 10 seconds from now';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Immediate notification test failed: $e';
      });
    }
  }

  // ========================================
  // REMINDER NOTIFICATION TESTS
  // ========================================

  /// Test: Schedule weekly reminders (3 random notifications)
  Future<void> _testScheduleWeeklyReminders() async {
    try {
      // Check if reminders are enabled first
      final enabled = await _reminderNotificationService.areRemindersEnabled();

      if (!enabled) {
        setState(() {
          _testResults =
              '⚠️ Reminders are disabled! Enable reminders first, then try scheduling.';
        });
        return;
      }

      setState(() {
        _testResults = 'Scheduling weekly reminders...';
      });

      await _reminderNotificationService.scheduleWeeklyReminders();
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Give time to schedule
      await _loadDebugInfo();

      final reminderNotifications = _pendingNotifications.where((n) {
        return n.id >= 10000 && n.id < 30000;
      }).toList();

      if (reminderNotifications.isEmpty) {
        setState(() {
          _testResults =
              '⚠️ No reminders were scheduled.\n'
              'This might happen if:\n'
              '1. This week\'s reminders were already scheduled\n'
              '2. All scheduled times are in the past\n\n'
              'Try using "Clear All Notifications" first, then try again.';
        });
      } else {
        // Sort by ID to show them in order
        reminderNotifications.sort((a, b) => a.id.compareTo(b.id));

        final details = reminderNotifications
            .map((n) {
              final type = n.id >= 20000 ? 'Market Update' : 'App Reminder';
              return '  • ID ${n.id} ($type)';
            })
            .join('\n');

        setState(() {
          _testResults =
              '✅ Weekly reminders scheduled: ${reminderNotifications.length} notifications\n\n'
              '$details';
        });
      }
    } catch (e) {
      setState(() {
        _testResults = '❌ Schedule weekly reminders failed: $e';
      });
    }
  }

  /// Test: Immediate reminder notification (app reminder)
  Future<void> _testImmediateAppReminder() async {
    try {
      // Check if reminders are enabled
      final enabled = await _reminderNotificationService.areRemindersEnabled();

      if (!enabled) {
        setState(() {
          _testResults =
              '⚠️ Reminders are disabled! Enable reminders first to test.';
        });
        return;
      }

      // Get random reminder message
      final l10n = AppLocalizations.of(context)!;
      final messages = [
        l10n.reminderCheckAssetValue,
        l10n.reminderReviewPortfolio,
        l10n.reminderUpdateInvestments,
        l10n.reminderTrackMarket,
        l10n.reminderMonitorDebts,
      ];
      final randomMessage = messages[Random().nextInt(messages.length)];

      final notificationTime = tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 3));

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

      await FlutterLocalNotificationsPlugin().zonedSchedule(
        id: 10999, // Use unique test ID
        title: l10n.appReminderNotificationTitle,
        body: randomMessage,
        scheduledDate: notificationTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'reminder',
      );

      await _loadDebugInfo();

      setState(() {
        _testResults =
            '✅ Immediate app reminder scheduled for 3 seconds from now\nMessage: $randomMessage';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Immediate app reminder test failed: $e';
      });
    }
  }

  /// Test: Immediate market update notification
  Future<void> _testImmediateMarketUpdate() async {
    try {
      // Check if reminders are enabled
      final enabled = await _reminderNotificationService.areRemindersEnabled();

      if (!enabled) {
        setState(() {
          _testResults =
              '⚠️ Reminders are disabled! Enable reminders first to test.';
        });
        return;
      }

      setState(() {
        _isLoadingMarketData = true;
        _testResults = 'Fetching market data...';
      });

      // Fetch real market data
      final marketData = await _marketService.fetchMarketData();

      // Get random mainstream currency
      const mainCurrencies = ['USD', 'EUR', 'GBP', 'CHF', 'CAD', 'JPY'];
      final availableCurrencies = marketData.currencies
          .where((c) => mainCurrencies.contains(c.code))
          .toList();

      if (availableCurrencies.isEmpty) {
        setState(() {
          _isLoadingMarketData = false;
          _testResults = '❌ No currencies available in market data';
        });
        return;
      }

      final randomCurrency =
          availableCurrencies[Random().nextInt(availableCurrencies.length)];

      final notificationTime = tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 3));

      final l10n = AppLocalizations.of(context)!;

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

      await FlutterLocalNotificationsPlugin().zonedSchedule(
        id: 20999, // Use unique test ID
        title: l10n.marketUpdateNotificationTitle,
        body: l10n.marketUpdateNotificationBody(
          randomCurrency.code,
          randomCurrency.selling,
        ),
        scheduledDate: notificationTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'market_update:${randomCurrency.code}',
      );

      await _loadDebugInfo();

      setState(() {
        _isLoadingMarketData = false;
        _testResults =
            '✅ Immediate market update scheduled for 3 seconds from now\n'
            'Currency: ${randomCurrency.code} - ${randomCurrency.selling.toStringAsFixed(2)} TRY';
      });
    } catch (e) {
      setState(() {
        _isLoadingMarketData = false;
        _testResults = '❌ Immediate market update test failed: $e';
      });
    }
  }

  /// Test: Enable/Disable reminder notifications
  Future<void> _testToggleReminders(bool enabled) async {
    try {
      await _reminderNotificationService.setRemindersEnabled(enabled);
      await _checkReminderStatus();
      await _loadDebugInfo();

      final reminderCount = _pendingNotifications.where((n) {
        return n.id >= 10000 && n.id < 30000;
      }).length;

      setState(() {
        if (enabled) {
          _testResults =
              '✅ Reminders enabled\n'
              'Scheduled notifications: $reminderCount\n'
              'Note: If count is 0, use "Schedule Weekly Reminders" button';
        } else {
          _testResults =
              '✅ Reminders disabled\n'
              'All reminder notifications cancelled\n'
              'Remaining reminder notifications: $reminderCount';
        }
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Toggle reminders failed: $e';
      });
    }
  }

  /// Test: Reschedule if needed (weekly check)
  Future<void> _testRescheduleIfNeeded() async {
    try {
      await _reminderNotificationService.rescheduleIfNeeded();
      await _loadDebugInfo();

      setState(() {
        _testResults =
            '✅ Reschedule check completed - notifications may have been updated';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Reschedule if needed test failed: $e';
      });
    }
  }

  // ========================================
  // SHARED FUNCTIONS
  // ========================================

  Future<void> _clearAllNotifications() async {
    await _debtNotificationService.cancelAllNotifications();
    await _reminderNotificationService.cancelAllReminders();
    await _loadDebugInfo();

    setState(() {
      _testResults = '✅ All notifications cleared';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Debug'),
        backgroundColor: AppColors.primary(context),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Debt Notifications'),
            Tab(text: 'Reminder Notifications'),
          ],
        ),
      ),
      body: Column(
        children: [
          // System Info (shared across tabs)
          Container(
            padding: EdgeInsets.all(16.r),
            color: AppColors.foreground(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Information',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildInfoRow('Time Zone', _currentTimeZone),
                _buildInfoRow('Current Time', DateTime.now().toString()),
                _buildInfoRow(
                  'Pending Notifications',
                  '${_pendingNotifications.length}',
                ),
                _buildInfoRow(
                  'Reminders Status',
                  _reminderEnabled ? 'Enabled' : 'Disabled',
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Test Results (shared across tabs)
          if (_testResults.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              color: _testResults.startsWith('✅')
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.danger.withValues(alpha: 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Results',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(_testResults),
                ],
              ),
            ),

          Divider(height: 1),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Debt Notifications Tab
                _buildDebtNotificationsTab(),

                // Reminder Notifications Tab
                _buildReminderNotificationsTab(),
              ],
            ),
          ),

          // Clear All Button (shared)
          Container(
            padding: EdgeInsets.all(16.r),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _clearAllNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: const Text('Clear All Notifications'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtNotificationsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Debt Notification Tests', [
            _buildTestButton(
              'Test Same Day (1 notification)',
              _testDebtSameDay,
            ),
            _buildTestButton('Test 2 Days (1 notification)', _testDebtTwoDays),
            _buildTestButton(
              'Test 5 Days (2 notifications)',
              _testDebtMoreThanTwoDays,
            ),
            _buildTestButton(
              'Test Past Due (0 notifications)',
              _testDebtPastDueDate,
            ),
            _buildTestButton(
              'Test Immediate (10 seconds)',
              _testDebtImmediateNotification,
            ),
          ]),
          SizedBox(height: 24.h),
          _buildPendingNotificationsList(10000, 10000),
        ],
      ),
    );
  }

  Widget _buildReminderNotificationsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Reminder Notification Tests', [
            _buildTestButton(
              'Schedule Weekly Reminders (up to 3 notifications)',
              _testScheduleWeeklyReminders,
            ),
            _buildTestButton(
              'Test Immediate App Reminder (10 seconds)',
              _testImmediateAppReminder,
            ),
            _buildTestButton(
              _isLoadingMarketData
                  ? 'Loading Market Data...'
                  : 'Test Immediate Market Update (10 seconds)',
              _isLoadingMarketData ? () {} : _testImmediateMarketUpdate,
              isLoading: _isLoadingMarketData,
            ),
            _buildTestButton('Reschedule If Needed', _testRescheduleIfNeeded),
          ]),
          SizedBox(height: 24.h),
          _buildSection('Reminder Settings', [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: _reminderEnabled
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _reminderEnabled
                      ? AppColors.success
                      : AppColors.danger,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _reminderEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: _reminderEnabled
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      _reminderEnabled
                          ? 'Reminders are currently ENABLED'
                          : 'Reminders are currently DISABLED',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _reminderEnabled
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            _buildTestButton(
              _reminderEnabled ? 'Disable Reminders' : 'Enable Reminders',
              () => _testToggleReminders(!_reminderEnabled),
            ),
          ]),
          SizedBox(height: 24.h),
          _buildPendingNotificationsList(10000, 30000),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(
    String label,
    VoidCallback onPressed, {
    bool isLoading = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary(context),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          disabledBackgroundColor: AppColors.primary(
            context,
          ).withValues(alpha: 0.5),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }

  Widget _buildPendingNotificationsList(int minId, int maxId) {
    final filteredNotifications = _pendingNotifications.where((n) {
      return n.id >= minId && n.id < maxId;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Notifications (${filteredNotifications.length})',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        if (filteredNotifications.isEmpty)
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Text(
              'No pending notifications',
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          ...filteredNotifications.map((notification) {
            return Card(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                title: Text(notification.title ?? 'No title'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.body ?? 'No body'),
                    SizedBox(height: 4.h),
                    Text(
                      'ID: ${notification.id}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}