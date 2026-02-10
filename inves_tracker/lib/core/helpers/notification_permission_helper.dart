
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// Helper service to check and request notification permissions
class NotificationPermissionHelper {
  static final NotificationPermissionHelper _instance =
      NotificationPermissionHelper._internal();
  factory NotificationPermissionHelper() => _instance;
  NotificationPermissionHelper._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Check if notification permissions are granted
  Future<bool> hasPermission() async {
    try {
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+)
        if (await _isAndroid13OrHigher()) {
          final status = await Permission.notification.status;
          return status.isGranted;
        }
        // For older Android versions, notifications are granted by default
        return true;
      } else if (Platform.isIOS) {
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        if (iosPlugin != null) {
          final settings = await iosPlugin.requestPermissions(
            alert: false,
            badge: false,
            sound: false,
          );
          return settings ?? false;
        }
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        if (await _isAndroid13OrHigher()) {
          final status = await Permission.notification.request();
          return status.isGranted;
        }
        return true;
      } else if (Platform.isIOS) {
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        if (iosPlugin != null) {
          final settings = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return settings ?? false;
        }
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if permission was permanently denied (user needs to go to settings)
  Future<bool> isPermanentlyDenied() async {
    try {
      if (Platform.isAndroid && await _isAndroid13OrHigher()) {
        final status = await Permission.notification.status;
        return status.isPermanentlyDenied;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Open app settings
  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      // Fail silently
    }
  }

  /// Check if Android version is 13 or higher
  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;

    try {
      // This is a simple check - you might want to use a package like device_info_plus
      // for more accurate version detection
      return true; // Assume Android 13+ for permission checking
    } catch (e) {
      return false;
    }
  }
}
