import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inves_tracker/core/services/http_client.dart';

class VersionCheckService {
  static const String _seenRecommendedVersionKey = 'seen_recommended_version';
  static bool _isChecking = false;

  /// Check app version on startup.
  ///
  /// Returns a map with one of these shapes:
  ///   { 'updateRequired': false }                          — all good
  ///   { 'updateRequired': true,  'forceUpdate': true,  … } — must update
  ///   { 'updateRequired': true,  'forceUpdate': false, … } — soft update (show once)
  ///   null                                                  — network error, ignore
  static Future<Map<String, dynamic>?> checkVersion() async {
    if (_isChecking) return null;
    _isChecking = true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final client = HttpClient();
      final response = await client
          .get('Version/check')
          .timeout(const Duration(seconds: 5));

      _isChecking = false;

      // ── Force update (middleware-driven 426) ──────────────────────────────
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

      // ── Soft update check (200 OK) ────────────────────────────────────────
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recommendedVersion = data['recommendedVersion'] as String? ?? '';
        final updateUrl = data['updateUrl'] as String? ?? '';

        if (recommendedVersion.isNotEmpty &&
            _isVersionLower(currentVersion, recommendedVersion)) {
          // Only show the popup once per recommendedVersion value
          final alreadySeen = await _hasSeenRecommendedVersion(recommendedVersion);
          if (!alreadySeen) {
            return {
              'updateRequired': true,
              'forceUpdate': false,
              'updateUrl': updateUrl,
              'recommendedVersion': recommendedVersion,
              'currentVersion': currentVersion,
            };
          }
        }
      }

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
      return null;
    }
  }

  /// Call this after the user dismisses (or acts on) the soft-update dialog
  /// so we never show it again for this recommendedVersion.
  static Future<void> markRecommendedVersionSeen(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_seenRecommendedVersionKey, version);
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  static Future<bool> _hasSeenRecommendedVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_seenRecommendedVersionKey) == version;
  }

  /// Returns true when [current] < [target] using semantic versioning.
  static bool _isVersionLower(String current, String target) {
    final c = _parse(current);
    final t = _parse(target);
    for (var i = 0; i < 3; i++) {
      if (c[i] < t[i]) return true;
      if (c[i] > t[i]) return false;
    }
    return false; // equal
  }

  static List<int> _parse(String version) {
    final parts = version.split('.');
    return List.generate(3, (i) => i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0);
  }
}