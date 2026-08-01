// Showcase tour order (interleaved nav icon + screen content):
//
//  Step  Key
//  ────  ─────────────────────────────────────────────────────────────────────
//   0    navHome              → highlight Home icon (stay on Home)
//   1    homeChart            → portfolio donut chart
//   2    homeBalance          → total balance card
//                               ↓ onComplete(2) → navigate to Market
//   3    navMarket            → highlight Market icon (now on Market)
//   4    marketTabSwitcher    → currency/crypto tab switcher
//                               ↓ onComplete(4) → navigate to Wallet
//   5    navWallet            → highlight Wallet icon (now on Wallet)
//   6    walletTabSwitcher    → assets/debts tab switcher
//   7    walletAddAssetBox    → Add Asset card header
//   8    walletAddAssetType   → type selector
//   9    walletAddAssetCode   → asset dropdown
//  10    walletAddAssetAmount → amount field
//  11    walletAddAsset       → "Add Asset" button
//  12    walletAddDebtBox     → Add Debt card header
//  13    walletAddDebtType    → type selector
//  14    walletAddDebtCode    → debt dropdown
//  15    walletAddDebtAmount  → amount field
//  16    walletAddDebtNote    → note + due-date
//  17    walletAddDebt        → "Add Debt" button
//                               ↓ onComplete(17) → navigate to Converter
//  18    navConverter         → highlight Converter icon (now on Converter)
//  19    converterSwap        → currency converter card
//                               ↓ onComplete(19) → jumpToPage(4) [instant]
//  20    navSettings          → highlight Settings icon (now on Settings)
//                               ← onFinish / markSeen
//
// Close button:
//   A bare X icon (FloatingActionWidget) is shown in the top-right corner
//   throughout the entire tour.  It calls ShowcaseView.get().dismiss() which
//   triggers onDismiss → markSeen(), so the tour won't replay next launch.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/auth_service.dart';
import 'package:inves_tracker/core/services/showcase_service.dart';
import 'package:inves_tracker/core/showcase/showcase_helper.dart';
import 'package:inves_tracker/core/showcase/showcase_keys.dart';
import 'package:inves_tracker/core/l10n/app_localizations.dart';
import 'package:inves_tracker/shared/custom_app_bar.dart';
import 'package:inves_tracker/views/converter/converter_screen.dart';
import 'package:inves_tracker/views/market/market_screen.dart';
import 'package:inves_tracker/views/home/home_screen.dart';
import 'package:inves_tracker/views/settings/settings_screen.dart';
import 'package:inves_tracker/views/wallet/wallet_screen.dart';
import 'package:showcaseview/showcaseview.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key, this.startShowcase = false});
  final bool startShowcase;

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  // ── Services ─────────────────────────────────────────────────────────────
  final AuthService _authService = AuthService();
  final ShowcaseService _showcaseService = ShowcaseService();

  // ── Navigation ────────────────────────────────────────────────────────────
  late PageController _pageController;
  int _currentIndex = 0;
  String? _userId;
  bool _isLoading = true;

  // ── ShowcaseView ──────────────────────────────────────────────────────────
  late ShowcaseView _showcaseView;

  // ── WalletScreen key ──────────────────────────────────────────────────────
  final _walletScreenKey = GlobalKey<WalletScreenState>();

  // ── Showcase GlobalKeys ───────────────────────────────────────────────────
  final _navHomeKey = GlobalKey();
  final _navMarketKey = GlobalKey();
  final _navWalletKey = GlobalKey();
  final _navConverterKey = GlobalKey();
  final _navSettingsKey = GlobalKey();
  final _homeChartKey = GlobalKey();
  final _homeBalanceKey = GlobalKey();
  final _marketTabKey = GlobalKey();
  final _walletTabKey = GlobalKey();
  final _walletAddAssetBoxKey = GlobalKey();
  final _walletAddAssetTypeKey = GlobalKey();
  final _walletAddAssetCodeKey = GlobalKey();
  final _walletAddAssetAmountKey = GlobalKey();
  final _walletAddAssetKey = GlobalKey();
  final _walletAddDebtBoxKey = GlobalKey();
  final _walletAddDebtTypeKey = GlobalKey();
  final _walletAddDebtCodeKey = GlobalKey();
  final _walletAddDebtAmountKey = GlobalKey();
  final _walletAddDebtNoteKey = GlobalKey();
  final _walletAddDebtKey = GlobalKey();
  final _converterSwapKey = GlobalKey();

  // ── Tour key list ─────────────────────────────────────────────────────────

  List<GlobalKey> _allKeys() => [
    _navHomeKey, //  0
    _homeChartKey, //  1
    _homeBalanceKey, //  2
    _navMarketKey, //  3
    _marketTabKey, //  4
    _navWalletKey, //  5
    _walletTabKey, //  6
    _walletAddAssetBoxKey, //  7
    _walletAddAssetTypeKey, //  8
    _walletAddAssetCodeKey, //  9
    _walletAddAssetAmountKey, // 10
    _walletAddAssetKey, // 11
    _walletAddDebtBoxKey, // 12
    _walletAddDebtTypeKey, // 13
    _walletAddDebtCodeKey, // 14
    _walletAddDebtAmountKey, // 15
    _walletAddDebtNoteKey, // 16
    _walletAddDebtKey, // 17
    _navConverterKey, // 18
    _converterSwapKey, // 19
    _navSettingsKey, // 20
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _showcaseView = ShowcaseView.register(
      onComplete: _onStepComplete,
      onFinish: _onTourFinish,
      // onDismiss fires when the user taps the close button (dismiss()).
      // Mark the tour as seen so it won't auto-start again next launch.
      // OnDismissCallback signature: void Function(GlobalKey?)
      onDismiss: _onTourDismiss,
      enableAutoScroll: true,
      // ── Global close button ──────────────────────────────────────────────
      // A bare X icon in the top-right corner, visible on every step.
      globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
        right: 28.w,
        top: 56.h,
        child: _CloseTourButton(),
      ),
    );
    _loadUserId();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _showcaseView.unregister();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final userId = await _authService.getCurrentUserId();
    if (!mounted) return;
    setState(() {
      _userId = userId;
      _isLoading = false;
    });
    if (widget.startShowcase) {
      _scheduleShowcase();
    } else {
      final seen = await _showcaseService.hasSeen();
      if (!seen && mounted) _scheduleShowcase();
    }
  }

  // ── Showcase control ──────────────────────────────────────────────────────

  void _scheduleShowcase() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _startTourFromHome();
      });
    });
  }

  void startShowcaseManually() {
    if (!mounted) return;
    _startTourFromHome();
  }

  void _startTourFromHome() {
    void launch() {
      if (!mounted) return;
      _showcaseView.startShowCase(_allKeys());
    }

    if (_currentIndex == 0) {
      launch();
      return;
    }

    _pageController
        .animateToPage(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        )
        .then((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) => launch());
        });
  }

  void _onStepComplete(int? index, GlobalKey key) {
    if (index == null) return;

    // After the last Add-Asset step, switch to Debts tab so DebtsTab widgets
    // are mounted before step 12 fires.
    if (index == 11 && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _walletScreenKey.currentState?.switchToDebtsTab();
      });
      return;
    }

    final targetPage = _pageForCompletedStep(index);
    if (targetPage == null || !mounted) return;

    if (targetPage == 4) {
      // Step 19 → Settings: use jumpToPage (instant) to avoid racing with
      // onFinish when step 20 (the last step) completes.
      _pageController.jumpToPage(4);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  int? _pageForCompletedStep(int completedIndex) {
    switch (completedIndex) {
      case 2:
        return 1; // homeBalance   → Market
      case 4:
        return 2; // marketTab     → Wallet
      case 17:
        return 3; // walletAddDebt → Converter
      case 19:
        return 4; // converterSwap → Settings (jumpToPage)
      default:
        return null;
    }
  }

  /// Tour completed naturally (all steps finished).
  void _onTourFinish() {
    _showcaseService.markSeen();

    // Navigate back to HomeScreen only on natural completion.
    // _CloseTourButton calls dismiss() → _onTourDismiss, so it never reaches here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  /// Tour dismissed early via the close button.
  /// Also mark as seen so it doesn't auto-replay on next launch.
  ///
  /// OnDismissCallback signature: void Function(GlobalKey?)
  /// [key] is the showcase key that was active when the user dismissed.
  void _onTourDismiss(GlobalKey? key) {
    _showcaseService.markSeen();
  }

  // ── Screens ───────────────────────────────────────────────────────────────

  List<Widget> get _screens => [
    HomeScreen(userId: _userId ?? ''),
    const MarketScreen(),
    WalletScreen(key: _walletScreenKey, userId: _userId ?? ''),
    const ConverterScreen(),
    const SettingsScreen(),
  ];

  void _onNavBarTap(int index) => _pageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  void _onPageChanged(int index) => setState(() => _currentIndex = index);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary(context)),
        ),
      );
    }

    final showcaseKeys = ShowcaseKeys(
      navHome: _navHomeKey,
      navMarket: _navMarketKey,
      navWallet: _navWalletKey,
      navConverter: _navConverterKey,
      navSettings: _navSettingsKey,
      homeChart: _homeChartKey,
      homeBalance: _homeBalanceKey,
      marketTabSwitcher: _marketTabKey,
      walletTabSwitcher: _walletTabKey,
      walletAddAssetBox: _walletAddAssetBoxKey,
      walletAddAssetType: _walletAddAssetTypeKey,
      walletAddAssetCode: _walletAddAssetCodeKey,
      walletAddAssetAmount: _walletAddAssetAmountKey,
      walletAddAsset: _walletAddAssetKey,
      walletAddDebtBox: _walletAddDebtBoxKey,
      walletAddDebtType: _walletAddDebtTypeKey,
      walletAddDebtCode: _walletAddDebtCodeKey,
      walletAddDebtAmount: _walletAddDebtAmountKey,
      walletAddDebtNote: _walletAddDebtNoteKey,
      walletAddDebt: _walletAddDebtKey,
      converterSwap: _converterSwapKey,
    );

    final pageTitles = [
      l10n.myWallet,
      l10n.exchangeRates,
      l10n.addInvestment,
      l10n.currencyConverter,
      l10n.settings,
    ];

    return ShowcaseKeysScope(
      keys: showcaseKeys,
      child: Scaffold(
        appBar: CustomAppBar(title: pageTitles[_currentIndex]),
        backgroundColor: AppColors.background(context),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _screens,
          ),
        ),
        bottomNavigationBar: _ShowcasedBottomNav(
          currentIndex: _currentIndex,
          onTap: _onNavBarTap,
          keys: (
            home: _navHomeKey,
            market: _navMarketKey,
            wallet: _navWalletKey,
            converter: _navConverterKey,
            settings: _navSettingsKey,
          ),
          l10n: l10n,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Close Tour button
//
// Rendered as a globalFloatingActionWidget in the top-right corner.
// Intentionally minimal — just a bare X icon with no button chrome.
// Calls ShowcaseView.get().dismiss() which triggers onDismiss → markSeen().
// ─────────────────────────────────────────────────────────────────────────────

class _CloseTourButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ShowcaseView.get().dismiss(),
      child: Icon(Icons.close_rounded, color: Colors.white, size: 26.sp),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Showcased bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

typedef _NavKeys = ({
  GlobalKey home,
  GlobalKey market,
  GlobalKey wallet,
  GlobalKey converter,
  GlobalKey settings,
});

class _ShowcasedBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final _NavKeys keys;
  final AppLocalizations l10n;

  const _ShowcasedBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.keys,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      (
        key: keys.home,
        icon: Icons.home_outlined,
        title: l10n.showcaseNavHomeTitle,
        desc: l10n.showcaseNavHomeDesc,
      ),
      (
        key: keys.market,
        icon: Icons.trending_up,
        title: l10n.showcaseNavMarketTitle,
        desc: l10n.showcaseNavMarketDesc,
      ),
      (
        key: keys.wallet,
        icon: Icons.add_circle_outline,
        title: l10n.showcaseNavWalletTitle,
        desc: l10n.showcaseNavWalletDesc,
      ),
      (
        key: keys.converter,
        icon: Icons.currency_exchange_outlined,
        title: l10n.showcaseNavConverterTitle,
        desc: l10n.showcaseNavConverterDesc,
      ),
      (
        key: keys.settings,
        icon: Icons.settings,
        title: l10n.showcaseNavSettingsTitle,
        desc: l10n.showcaseNavSettingsDesc,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = currentIndex == i;
              final selectColor = AppColors.primary(context);

              return ShowcaseHelper.wrap(
                key: item.key,
                title: item.title,
                description: item.desc,
                circular: true,
                targetPadding: const EdgeInsets.all(4),
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      item.icon,
                      size: 24.sp,
                      color: isSelected
                          ? selectColor
                          : (isDark ? Colors.white : Colors.black54),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
