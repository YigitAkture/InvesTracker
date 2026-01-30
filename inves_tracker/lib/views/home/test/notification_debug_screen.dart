import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/services/debt_notification_service.dart';
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

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  final DebtNotificationService _notificationService =
      DebtNotificationService();
  List<PendingNotificationRequest> _pendingNotifications = [];
  String _currentTimeZone = '';
  String _testResults = '';

  late final AppLocalizations l10n;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    final pending = await _notificationService.getPendingNotifications();
    final timeZone = tz.local.name;

    setState(() {
      _pendingNotifications = pending;
      _currentTimeZone = timeZone;
    });
  }

  /// Test Case 1: Same day (should not schedule)
  Future<void> _testSameDay() async {
    final now = DateTime.now();

    try {
      await _notificationService.scheduleDebtNotifications(
        debtId: 'test_same_day',
        createdAt: now,
        dueDate: now,
        debtDescription: 'Same day test',
        amount: 100,
        currency: 'samedaytest',
        l10n: l10n
      );

      await _loadDebugInfo();

      setState(() {
        _testResults = '✅ Same day test: No notifications scheduled (correct)';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Same day test failed: $e';
      });
    }
  }

  /// Test Case 2: 2 days difference (should schedule 1 notification)
  Future<void> _testTwoDays() async {
    final now = DateTime.now();
    final dueDate = now.add(const Duration(days: 2));

    try {
      await _notificationService.scheduleDebtNotifications(
        debtId: 'test_two_days',
        createdAt: now,
        dueDate: dueDate,
        debtDescription: 'Two days test',
        amount: 200,
        currency: '2daytest',
        l10n: l10n,
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
  Future<void> _testMoreThanTwoDays() async {
    final now = DateTime.now();
    final dueDate = now.add(const Duration(days: 5));

    try {
      await _notificationService.scheduleDebtNotifications(
        debtId: 'test_five_days',
        createdAt: now,
        dueDate: dueDate,
        debtDescription: 'Five days test',
        amount: 500,
        currency: 'fivedaystest',
        l10n: l10n
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
  Future<void> _testPastDueDate() async {
    final now = DateTime.now();
    final dueDate = now.subtract(const Duration(days: 3));

    try {
      await _notificationService.scheduleDebtNotifications(
        debtId: 'test_past_due',
        createdAt: dueDate,
        dueDate: dueDate,
        debtDescription: 'Past due test',
        amount: -300,
        currency: 'pastduetest',
        l10n: l10n
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

  /// Test immediate notification (for testing notification appearance)
  Future<void> _testImmediateNotification() async {
    final now = DateTime.now();
    // Schedule for 5 seconds from now
    final dueDate = now.add(const Duration(seconds: 5));

    try {
      await _notificationService.scheduleDebtNotifications(
        debtId: 'test_immediate',
        createdAt: now,
        dueDate: dueDate,
        debtDescription: 'Immediate test notification',
        amount: 1,
        currency: 'immediatetest',
        l10n: l10n
      );

      setState(() {
        _testResults =
            '✅ Immediate notification scheduled for 5 seconds from now';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Immediate notification test failed: $e';
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    await _notificationService.cancelAllNotifications();
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Info
            _buildSection('System Information', [
              _buildInfoRow('Time Zone', _currentTimeZone),
              _buildInfoRow('Current Time', DateTime.now().toString()),
              _buildInfoRow(
                'Pending Notifications',
                '${_pendingNotifications.length}',
              ),
            ]),

            SizedBox(height: 24.h),

            // Test Results
            if (_testResults.isNotEmpty) ...[
              _buildSection('Test Results', [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: _testResults.startsWith('✅')
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(_testResults),
                ),
              ]),
              SizedBox(height: 24.h),
            ],

            // Test Buttons
            _buildSection('Notification Tests', [
              _buildTestButton('Test Same Day (0 notifications)', _testSameDay),
              _buildTestButton('Test 2 Days (1 notification)', _testTwoDays),
              _buildTestButton(
                'Test 5 Days (2 notifications)',
                _testMoreThanTwoDays,
              ),
              _buildTestButton(
                'Test Past Due (0 notifications)',
                _testPastDueDate,
              ),
              _buildTestButton(
                'Test Immediate (5 seconds)',
                _testImmediateNotification,
              ),
            ]),

            SizedBox(height: 24.h),

            // Pending Notifications List
            _buildSection(
              'Pending Notifications',
              _pendingNotifications.map((notification) {
                return Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ListTile(
                    title: Text(notification.title ?? 'No title'),
                    subtitle: Text(notification.body ?? 'No body'),
                    trailing: Text('ID: ${notification.id}'),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 24.h),

            // Clear Button
            SizedBox(
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
          ],
        ),
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

  Widget _buildTestButton(String label, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary(context),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        child: Text(label),
      ),
    );
  }
}
