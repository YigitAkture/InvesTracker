import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/shared/custom_app_bar.dart';
import 'package:inves_tracker/views/market/market.dart';
import 'package:inves_tracker/views/home/home_screen.dart';
import '../shared/custom_bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // Page titles corresponding to each screen
  final List<String> _pageTitles = [
    'My Wallet',
    'Exhange Rates',
    'Add Investment',
    'Investment History',
    'Profile',
  ];

  // Replace these placeholder widgets with your actual screens
  final List<Widget> _screens = [
    const HomeScreen(),
    const Market(),
    const AddInvestmentScreen(),
    const AlertsScreen(),
    const ProfileScreen(),
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _pageTitles[_currentIndex],
      ),
      backgroundColor: AppColors.background(context),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
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

// Placeholder screens - Replace these with your actual screen implementations
class AddInvestmentScreen extends StatelessWidget {
  const AddInvestmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Add Investment Screen')),
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Alerts Screen')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Profile Screen')),
    );
  }
}