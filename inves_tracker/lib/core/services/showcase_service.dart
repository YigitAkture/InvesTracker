import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the first-time onboarding showcase has been seen.
/// Call [markSeen] after the tour completes, [hasSeen] before starting.
class ShowcaseService {
  static const String _seenKey = 'onboarding_showcase_seen';

  /// Returns true if the user has already seen the showcase tour.
  Future<bool> hasSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey) ?? false;
  }

  /// Marks the showcase as seen so it won't auto-trigger again.
  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
  }

  /// Resets the "seen" state — useful for letting users replay the tour
  /// from the Settings screen.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seenKey);
  }
}