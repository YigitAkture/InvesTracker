// ─── market_screen.dart (showcase-aware version) ───────────────────────────
// Only the tab-switcher container is modified; all other code is identical to
// the original.  Search for "// SHOWCASE" comments to find the changes.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/models/gold_data.dart';
import 'package:inves_tracker/core/models/crypto_data.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/core/services/home_widget_service.dart';
import 'package:inves_tracker/core/showcase/showcase_helper.dart';
import 'package:inves_tracker/core/showcase/showcase_keys.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/market/currency/currency_rates.dart';
import 'package:inves_tracker/views/market/gold/gold_rates.dart';
import 'package:inves_tracker/views/market/crypto/crypto_rates.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketService _marketService = MarketService();
  final HomeWidgetService _homeWidgetService = HomeWidgetService();

  List<CurrencyData> _currencies = [];
  List<GoldData> _golds = [];
  List<CryptoData> _cryptos = [];
  String _updateTime = '';
  bool _isLoading = true;
  bool _hasError = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _marketService.fetchMarketData();
      setState(() {
        _currencies = response.currencies;
        _golds = response.golds;
        _cryptos = response.cryptos;
        _updateTime = response.updateTime;
        _isLoading = false;
      });

      if (mounted) {
        await _homeWidgetService.updateWidgetData(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) return _buildLoadingState(l10n);
    if (_hasError) return _buildErrorState(l10n);

    // SHOWCASE: look up the market tab key.
    final showcaseKeys = ShowcaseKeys.of(context);

    Widget tabSwitcher = _buildTabSwitcher(l10n);

    if (showcaseKeys != null) {
      tabSwitcher = ShowcaseHelper.wrap(
        key: showcaseKeys.marketTabSwitcher,
        title: l10n.showcaseNavMarketTitle,
        description: l10n.showcaseNavMarketDesc,
        child: tabSwitcher,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMarketData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            if (_updateTime.isNotEmpty) _buildUpdateTimeRow(l10n),
            tabSwitcher, // ← showcased
            SizedBox(height: 8.h),
            if (_selectedTab == 0)
              _buildCurrencyAndGoldContent(l10n)
            else
              _buildCryptoContent(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher(AppLocalizations l10n) {
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
            Expanded(child: _tabButton(l10n.currenciesAndMetals, 0)),
            Expanded(child: _tabButton(l10n.cryptoCurrencies, 1)),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: _selectedTab == index
              ? AppColors.primary(context).withValues(alpha: 0.8)
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

  Widget _buildUpdateTimeRow(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.access_time,
              size: 14.sp, color: AppColors.title(context)),
          SizedBox(width: 4.w),
          Text(
            '${l10n.updated}: $_updateTime',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.title(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyAndGoldContent(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(l10n.currency, l10n),
        SizedBox(height: 4.h),
        CurrencyRates(currencies: _currencies),
        SizedBox(height: 24.h),
        _sectionHeader(l10n.metal, l10n),
        SizedBox(height: 4.h),
        GoldRates(golds: _golds),
      ],
    );
  }

  Widget _buildCryptoContent(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(l10n.currency, l10n),
        SizedBox(height: 4.h),
        CryptoRates(cryptos: _cryptos),
      ],
    );
  }

  Widget _sectionHeader(String title, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          Row(
            children: [
              _headerCell(l10n.change, 70.w),
              SizedBox(width: 8.w),
              _headerCell(l10n.buying, 70.w),
              SizedBox(width: 16.w),
              _headerCell(l10n.selling, 70.w),
              SizedBox(width: 16.w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, double width) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: TextAlign.end,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.title(context),
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary(context)),
          SizedBox(height: 12.h),
          Text(l10n.loadingMarketData,
              style: TextStyle(
                  fontSize: 14.sp, color: AppColors.title(context))),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48.sp, color: AppColors.danger),
            SizedBox(height: 12.h),
            Text(l10n.failedToLoadMarketData,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.title(context))),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadMarketData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text(l10n.retry,
                  style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
      ),
    );
  }
}