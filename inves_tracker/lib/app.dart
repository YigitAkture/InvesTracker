import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:inves_tracker/core/services/auth_service.dart';
import 'package:inves_tracker/core/services/debt_notification_service.dart';
import 'package:inves_tracker/core/services/debt_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/auth/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:inves_tracker/core/utils/theme_notifier.dart';
import 'package:inves_tracker/core/utils/locale_notifier.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final DebtNotificationService _notificationService = DebtNotificationService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - reschedule notifications
      // This handles timezone changes and ensures notifications are up-to-date
      _rescheduleNotificationsIfNeeded();
    }
  }

  Future<void> _initializeApp() async {
    // Remove splash screen after delay
    await _notificationService.initialize();
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();
  }

  /// Reschedule notifications when app resumes
  /// This handles edge cases like:
  /// - Timezone changes (travel, DST)
  /// - System time changes
  /// - Notification cancellation by OS
  Future<void> _rescheduleNotificationsIfNeeded() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) return;

      final userId = await _authService.getCurrentUserId();
      if (userId == null) return;

      // Import your enhanced debt service here
      final debtService = DebtService();
      await debtService.rescheduleAllNotifications(userId);

      debugPrint('Notifications rescheduled successfully');
    } catch (e) {
      debugPrint('Failed to reschedule notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return MaterialApp(
      title: 'InvesTracker',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.currentTheme,
      locale: localeNotifier.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.2,
        );
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: scale),
          child: child!,
        );
      },
      supportedLocales: const [Locale('en'), Locale('tr')],
      home: const AuthWrapper(),
    );
  }
}