import 'package:flutter/material.dart';

/// Holds every [GlobalKey] used by the showcase tour.
///
/// Wrap the widget tree with [ShowcaseKeysScope] (done inside [MainLayout])
/// so that any descendant screen can call [ShowcaseKeys.of(context)] to
/// receive the keys it needs for its own [Showcase] widgets.
class ShowcaseKeys {
  // ── Bottom navigation bar items ──────────────────────────────────────────
  final GlobalKey navHome;
  final GlobalKey navMarket;
  final GlobalKey navWallet;
  final GlobalKey navConverter;
  final GlobalKey navSettings;

  // ── Home screen ───────────────────────────────────────────────────────────
  final GlobalKey homeChart;
  final GlobalKey homeBalance;

  // ── Market screen ─────────────────────────────────────────────────────────
  final GlobalKey marketTabSwitcher;

  // ── Wallet screen — tab switcher ──────────────────────────────────────────
  final GlobalKey walletTabSwitcher;

  // ── Add Asset sub-steps ───────────────────────────────────────────────────
  final GlobalKey walletAddAssetBox;    // the whole collapsible card header
  final GlobalKey walletAddAssetType;   // currency / metal / crypto selector
  final GlobalKey walletAddAssetCode;   // the dropdown (which asset)
  final GlobalKey walletAddAssetAmount; // the amount text field
  final GlobalKey walletAddAsset;       // the "Add Asset" submit button

  // ── Add Debt sub-steps ────────────────────────────────────────────────────
  final GlobalKey walletAddDebtBox;     // the whole collapsible card header
  final GlobalKey walletAddDebtType;    // currency / metal / crypto selector
  final GlobalKey walletAddDebtCode;    // the dropdown (which debt)
  final GlobalKey walletAddDebtAmount;  // the amount text field
  final GlobalKey walletAddDebtNote;    // note + due-date fields row
  final GlobalKey walletAddDebt;        // the "Add Debt" submit button

  // ── Converter screen ──────────────────────────────────────────────────────
  final GlobalKey converterSwap;

  ShowcaseKeys({
    required this.navHome,
    required this.navMarket,
    required this.navWallet,
    required this.navConverter,
    required this.navSettings,
    required this.homeChart,
    required this.homeBalance,
    required this.marketTabSwitcher,
    required this.walletTabSwitcher,
    required this.walletAddAssetBox,
    required this.walletAddAssetType,
    required this.walletAddAssetCode,
    required this.walletAddAssetAmount,
    required this.walletAddAsset,
    required this.walletAddDebtBox,
    required this.walletAddDebtType,
    required this.walletAddDebtCode,
    required this.walletAddDebtAmount,
    required this.walletAddDebtNote,
    required this.walletAddDebt,
    required this.converterSwap,
  });

  /// Returns the [ShowcaseKeys] from the nearest [ShowcaseKeysScope] ancestor.
  static ShowcaseKeys? of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ShowcaseKeysScope>();
    return scope?.keys;
  }
}

/// An [InheritedWidget] that exposes [ShowcaseKeys] to the widget subtree.
class ShowcaseKeysScope extends InheritedWidget {
  final ShowcaseKeys keys;

  const ShowcaseKeysScope({
    super.key,
    required this.keys,
    required super.child,
  });

  @override
  bool updateShouldNotify(ShowcaseKeysScope oldWidget) => false;
}