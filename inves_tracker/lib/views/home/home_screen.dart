import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/asset_service.dart';
import 'package:inves_tracker/core/services/debt_service.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/core/models/asset.dart';
import 'package:inves_tracker/core/models/debt.dart';
import 'package:inves_tracker/core/models/market_response.dart';
import 'package:inves_tracker/core/utils/visibility_notifier.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/shared/banner_add.dart';
// import 'package:inves_tracker/views/home/test/notification_debug_screen.dart';
import 'package:inves_tracker/views/home/widgets/portfolio_chart.dart';
import 'package:inves_tracker/views/home/widgets/total_balance_card.dart';
import 'package:inves_tracker/views/home/widgets/asset_debt_details.dart';
import 'package:inves_tracker/views/home/utils/portfolio_calculator.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AssetService _assetService = AssetService();
  final DebtService _debtService = DebtService();
  final MarketService _marketService = MarketService();

  List<Asset> _assets = [];
  List<Debt> _debts = [];
  MarketResponse? _marketData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final assetsResult = await _assetService.getUserAssets(widget.userId);
      final debtsResult = await _debtService.getUserDebts(widget.userId);
      final marketResult = await _marketService.fetchMarketData();

      setState(() {
        _assets = assetsResult;
        _debts = debtsResult;
        _marketData = marketResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibilityNotifier = Provider.of<VisibilityNotifier>(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary(context),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: AppColors.danger,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.failedToLoadData,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.title(context),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    // Calculate portfolio data
    final portfolioData = PortfolioCalculator.calculatePortfolio(
      assets: _assets,
      debts: _debts,
      marketData: _marketData!,
    );

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            children: [
              // Banner Ad
              const BannerAdd(),
              
              SizedBox(height: 24.h),
              
              // Portfolio Chart with Visibility Button
              Stack(
                children: [
                  // Chart (centered)
                  PortfolioChart(
                    portfolioData: portfolioData,
                    isVisible: visibilityNotifier.isBalanceVisible,
                  ),
                  
                  // Visibility Toggle Button (top right)
                  Positioned(
                    top: 0,
                    right: 8.w,
                    child: Material(
                      elevation: 3,
                      shape: const CircleBorder(),
                      color: AppColors.foreground(context),
                      child: InkWell(
                        onTap: () => visibilityNotifier.toggleVisibility(),
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Icon(
                            visibilityNotifier.isBalanceVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primary(context),
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // // !!!! TEST SCREEN - REMOVE BEFORE PRODUCTION !!!!!
              // SizedBox(height: 24.h),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: () => Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const NotificationDebugScreen(),
              //       ),
              //     ),
              //     child: Text('Test Notifications'),
              //   ),
              // ),

              // // !!!! END OF TEST SCREEN !!!!!

              SizedBox(height: 24.h),

              // Total Balance Card
              TotalBalanceCard(
                portfolioData: portfolioData,
                isVisible: visibilityNotifier.isBalanceVisible,
              ),
              
              SizedBox(height: 24.h),
              
              // Asset/Debt Details
              AssetDebtDetails(
                portfolioData: portfolioData,
                isVisible: visibilityNotifier.isBalanceVisible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}