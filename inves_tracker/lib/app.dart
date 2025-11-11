import 'package:flutter/material.dart';
import 'package:inves_tracker/views/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:inves_tracker/core/utils/theme_notifier.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'InvesTracker',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.currentTheme,
      home: const HomeScreen(),
    );
  }
}