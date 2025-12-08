import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/home/widgets/box.dart';
import 'package:inves_tracker/views/wallet/wallet_screen.dart';
import 'package:inves_tracker/shared/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // TODO: Replace with actual user ID from authentication
  static const String _testUserId = '1bfe063c-1405-44c8-9e36-11dce55e96d0';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Assets Box - Navigate to Wallet (Assets Tab)
        Text(
          l10n.assets,
          style: TextStyle(fontSize: 20.sp),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: CustomAppBar(title: l10n.myWallet),
                  backgroundColor: AppColors.background(context),
                  body: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: const WalletScreen(userId: _testUserId),
                  ),
                ),
              ),
            );
          },
          child: Box(AppColors.primary(context)),
        ),
        
        SizedBox(height: 12.h),
        
        // Debts Box - Navigate to Wallet (Debts Tab)
        Text(
          l10n.debts,
          style: TextStyle(fontSize: 20.sp),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: CustomAppBar(title: l10n.myWallet),
                  backgroundColor: AppColors.background(context),
                  body: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: const WalletScreen(userId: _testUserId),
                  ),
                ),
              ),
            );
          },
          child: Box(AppColors.secondary(context)),
        ),
        
        SizedBox(height: 16.h),
        
        // Info text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            'Tap boxes to view and manage your assets and debts',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.title(context),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}