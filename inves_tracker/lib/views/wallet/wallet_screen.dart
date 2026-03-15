import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/showcase/showcase_helper.dart';
import 'package:inves_tracker/core/showcase/showcase_keys.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/wallet/widgets/assets_tab.dart';
import 'package:inves_tracker/views/wallet/widgets/debts_tab.dart';

class WalletScreen extends StatefulWidget {
  final String userId;

  const WalletScreen({super.key, required this.userId});

  @override
  State<WalletScreen> createState() => WalletScreenState();
}

/// Public state so MainLayout can call [switchToDebtsTab] during the tour,
/// ensuring DebtsTab (and its Showcase-wrapped widgets) are in the tree
/// before ShowcaseView tries to locate their RenderBoxes.
class WalletScreenState extends State<WalletScreen> {
  int _selectedTab = 0;

  /// Called by MainLayout after the last Add-Asset showcase step completes.
  /// Switches to the Debts tab so the Add-Debt widgets are built and in the
  /// widget tree before ShowcaseView highlights them.
  void switchToDebtsTab() {
    if (_selectedTab != 1) {
      setState(() => _selectedTab = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showcaseKeys = ShowcaseKeys.of(context);

    Widget tabSwitcher = _buildTabSwitcher(context, l10n);

    if (showcaseKeys != null) {
      tabSwitcher = ShowcaseHelper.wrap(
        key: showcaseKeys.walletTabSwitcher,
        title: l10n.showcaseNavWalletTitle,
        description: l10n.showcaseNavWalletDesc,
        child: tabSwitcher,
      );
    }

    return Column(
      children: [
        tabSwitcher,
        SizedBox(height: 8.h),
        Expanded(
          child: _selectedTab == 0
              ? AssetsTab(userId: widget.userId)
              : DebtsTab(userId: widget.userId),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background2(context),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.foreground(context),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _tabButton(
                context, l10n.assets, 0, AppColors.primary(context),
              ),
            ),
            Expanded(
              child: _tabButton(
                context, l10n.debts, 1, AppColors.secondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(
    BuildContext context,
    String label,
    int index,
    Color activeColor,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: _selectedTab == index
              ? activeColor.withValues(alpha: 0.8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _selectedTab == index
                ? Colors.white
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
          ),
        ),
      ),
    );
  }
}