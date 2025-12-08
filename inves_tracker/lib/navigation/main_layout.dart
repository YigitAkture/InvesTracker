import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/shared/custom_app_bar.dart';
import 'package:inves_tracker/views/converter/converter_screen.dart';
import 'package:inves_tracker/views/market/market_screen.dart';
import 'package:inves_tracker/views/home/home_screen.dart';
import 'package:inves_tracker/views/settings/settings_screen.dart';
import 'package:inves_tracker/views/wallet/wallet_screen.dart';
import '../shared/custom_bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  String userId = '1bfe063c-1405-44c8-9e36-11dce55e96d0'; // TODO: This should come from auth/user management

  List<Widget> get _screens => [
        const HomeScreen(),
        const MarketScreen(),
        WalletScreen(userId: userId),
        const ConverterScreen(),
        const SettingsScreen(),
      ];

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final List<String> pageTitles = [
      l10n.myWallet,
      l10n.exchangeRates,
      l10n.addInvestment,
      l10n.currencyConverter,
      l10n.settings,
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: pageTitles[_currentIndex],
      ),
      backgroundColor: AppColors.background(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}