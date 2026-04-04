import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:inves_tracker/app.dart';
import 'package:inves_tracker/core/services/debt_notification_service.dart';
import 'package:inves_tracker/core/services/reminder_notification_service.dart';
import 'package:inves_tracker/core/services/home_widget_service.dart';
import 'package:inves_tracker/core/utils/theme_notifier.dart';
import 'package:inves_tracker/core/utils/locale_notifier.dart';
import 'package:inves_tracker/core/utils/visibility_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

/// Background callback for home widget updates
/// This runs in a separate isolate and can update widget even when app is closed
@pragma('vm:entry-point')
void backgroundCallback(Uri? uri) async {
  // Handle background widget update
  await HomeWidgetService.backgroundCallback(uri);
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Mobile Ads (non-blocking)
  MobileAds.instance.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize notifications and widgets in background (non-blocking)
  // This prevents blocking app launch if permissions aren't granted yet
  _initializeBackgroundServices();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ChangeNotifierProvider(create: (_) => VisibilityNotifier()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(412, 915),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final themeNotifier = Provider.of<ThemeNotifier>(context);
          
          if (!themeNotifier.isLoaded) {
            return ColoredBox(
              color: themeNotifier.currentTheme.scaffoldBackgroundColor,
              child: const SizedBox.expand(),
            );
          }
          return ColoredBox(
            color: themeNotifier.currentTheme.scaffoldBackgroundColor,
            child: const MyApp(),
          );
        },
      ),
    ),
  );
}

/// Initialize background services asynchronously without blocking app launch
/// This runs after the app UI is already starting to render
void _initializeBackgroundServices() {
  // Use a short delay to ensure app UI starts rendering first
  Future.delayed(const Duration(milliseconds: 500), () async {
    // Initialize Debt Notification Service
    try {
      await DebtNotificationService().initialize();
      debugPrint('✓ Debt notification service initialized');
    } catch (e) {
      debugPrint('✗ Failed to initialize debt notifications: $e');
      // Continue - don't crash the app
    }

    // Initialize Reminder Notification Service
    try {
      await ReminderNotificationService().rescheduleIfNeeded();
      debugPrint('✓ Reminder notification service initialized');
    } catch (e) {
      debugPrint('✗ Failed to initialize reminder notifications: $e');
      // Continue - don't crash the app
    }

    // Register background callback for home widget
    try {
      HomeWidget.registerInteractivityCallback(backgroundCallback);
      debugPrint('✓ Home widget callback registered');
    } catch (e) {
      debugPrint('✗ Failed to register home widget callback: $e');
      // Continue - don't crash the app
    }

    // Initialize WorkManager
    try {
      await Workmanager().initialize(backgroundCallback);
      debugPrint('✓ WorkManager initialized');
    } catch (e) {
      debugPrint('✗ Failed to initialize WorkManager: $e');
      // Continue - don't crash the app
    }
  });
}