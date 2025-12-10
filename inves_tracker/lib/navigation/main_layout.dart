import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/auth_service.dart';
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
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await _authService.getCurrentUserId();
    setState(() {
      _userId = userId;
      _isLoading = false;
    });
  }

  List<Widget> get _screens => [
        HomeScreen(userId: _userId ?? ''),
        const MarketScreen(),
        WalletScreen(userId: _userId ?? ''),
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
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary(context),
          ),
        ),
      );
    }

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