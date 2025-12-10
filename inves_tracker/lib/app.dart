import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/auth/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:inves_tracker/core/utils/theme_notifier.dart';
import 'package:inves_tracker/core/utils/locale_notifier.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      home: const AuthWrapper(),
    );
  }
}