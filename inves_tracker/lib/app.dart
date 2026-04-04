import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:inves_tracker/core/services/auth_service.dart';
import 'package:inves_tracker/core/services/debt_notification_service.dart';
import 'package:inves_tracker/core/services/debt_service.dart';
import 'package:inves_tracker/core/services/reminder_notification_service.dart';
import 'package:inves_tracker/core/services/home_widget_service.dart';
import 'package:inves_tracker/core/utils/localization_manager.dart';
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
  final DebtNotificationService _notificationService =
      DebtNotificationService();
  final AuthService _authService = AuthService();
  final LocalizationManager _localizationManager = LocalizationManager();
  final HomeWidgetService _homeWidgetService = HomeWidgetService();

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
      // App came to foreground
      _onAppResumed();
    }
  }

  /// Handle app resume - update notifications and widgets
  Future<void> _onAppResumed() async {
    // Reschedule notifications if needed
    ReminderNotificationService().rescheduleIfNeeded();
    _rescheduleNotificationsIfNeeded();

    // Update widget if needed
    _updateWidgetIfNeeded();
  }

  /// OPTIMIZED: Initialize app without blocking on notifications
  /// Removes splash screen immediately, then initializes services in background
  Future<void> _initializeApp() async {
    // Remove splash screen after short delay - DON'T wait for notifications
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();

    // Initialize notification service asynchronously (non-blocking)
    _initializeNotifications();

    // Initialize widget after first frame (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeWidget();
      }
    });
  }

  /// Initialize notifications in background without blocking UI
  void _initializeNotifications() {
    Future.microtask(() async {
      try {
        await _notificationService.initialize();
        debugPrint('✓ Debt notifications initialized in app.dart');
      } catch (e) {
        debugPrint('✗ Failed to initialize notifications in app.dart: $e');
        // Continue - notifications are not critical for app launch
      }
    });
  }

  /// Initialize widget in background without blocking UI
  void _initializeWidget() {
    Future.microtask(() async {
      try {
        await _homeWidgetService.initialize(context);
        debugPrint('✓ Home widget initialized');
      } catch (e) {
        debugPrint('✗ Failed to initialize widget: $e');
        // Continue - widget is not critical for app launch
      }
    });
  }

  /// Reschedule notifications when app resumes
  Future<void> _rescheduleNotificationsIfNeeded() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) return;

      final userId = await _authService.getCurrentUserId();
      if (userId == null) return;

      final debtService = DebtService();
      await debtService.rescheduleAllNotifications(userId);

      debugPrint('Notifications rescheduled successfully');
    } catch (e) {
      debugPrint('Failed to reschedule notifications: $e');
    }
  }

  /// Update widget if needed (when data is stale)
  Future<void> _updateWidgetIfNeeded() async {
    try {
      final shouldUpdate = await _homeWidgetService.shouldUpdate();
      if (shouldUpdate && mounted) {
        await _homeWidgetService.updateWidgetData(context);
        debugPrint('Widget updated on app resume');
      }
    } catch (e) {
      debugPrint('Failed to update widget: $e');
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
      themeAnimationDuration: const Duration(milliseconds: 400),
      themeAnimationCurve: Curves.easeInOut,
      locale: localeNotifier.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // CRITICAL: Update LocalizationManager whenever locale changes
        final locale = Localizations.localeOf(context);
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          _localizationManager.updateLocalizations(l10n, locale);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _homeWidgetService.updateWidgetLanguage(context).catchError((e) {
                debugPrint(
                  'Failed to update widget language on locale change: $e',
                );
              });
            }
          });
        }

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