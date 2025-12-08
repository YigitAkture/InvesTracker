import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/wallet/widgets/assets_tab.dart';
import 'package:inves_tracker/views/wallet/widgets/debts_tab.dart';

class WalletScreen extends StatefulWidget {
  final String userId; // Pass from auth/user management

  const WalletScreen({
    super.key,
    required this.userId,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Tab Switcher
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0.w),
          decoration: BoxDecoration(
            color: AppColors.background2(context),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.foreground(context),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                // Assets Tab
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? AppColors.primary(context).withValues(alpha: 0.25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        l10n.assets,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 0
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
                // Debts Tab
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? AppColors.primary(context).withValues(alpha: 0.25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        l10n.debts,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 1
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 8.h),

        // Tab Content
        Expanded(
          child: _selectedTab == 0
              ? AssetsTab(userId: widget.userId)
              : DebtsTab(userId: widget.userId),
        ),
      ],
    );
  }
}