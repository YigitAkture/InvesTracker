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

  Future<void> _initializeApp() async {
    // Initialize notification service
    await _notificationService.initialize();

    // Remove splash screen after delay
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();

    // Initialize widget after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _homeWidgetService.initialize(context);
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

          // Update widget when locale changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _homeWidgetService.updateWidgetData(context);
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