import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:inves_tracker/core/services/http_client.dart';

class VersionCheckService {
  static bool _isChecking = false;

  /// Check app version on startup
  static Future<Map<String, dynamic>?> checkVersion() async {
    // Prevent multiple simultaneous checks
    if (_isChecking) return null;
    _isChecking = true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Use dedicated version check endpoint
      // This endpoint is NOT in the skip list
      final client = HttpClient();
      final response = await client.get('Version/check').timeout(
        const Duration(seconds: 5),
      );

      _isChecking = false;

      // Check if update is required (426 status)
      if (response.statusCode == 426) {
        final data = json.decode(response.body);
        return {
          'updateRequired': true,
          'forceUpdate': data['forceUpdate'] ?? true,
          'updateUrl': data['updateUrl'] ?? '',
          'minimumVersion': data['minimumVersion'] ?? '',
          'currentVersion': currentVersion,
        };
      }

      // 200 OK - version is supported
      return {'updateRequired': false};
    } catch (e) {
      _isChecking = false;
      if (e is AppUpdateRequiredException) {
        return {
          'updateRequired': true,
          'forceUpdate': e.forceUpdate,
          'updateUrl': e.updateUrl,
          'minimumVersion': e.minimumVersion,
        };
      }
      // If check fails, don't block the app
      return null;
    }
  }
}