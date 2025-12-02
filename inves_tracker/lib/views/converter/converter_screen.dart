import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/core/models/market_response.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/converter/widgets/currency_to_currency_section.dart';
import 'package:inves_tracker/views/converter/widgets/gold_to_currency_section.dart';
import 'package:inves_tracker/views/converter/widgets/crypto_to_currency_section.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final MarketService _marketService = MarketService();
  MarketResponse? _marketData;
  bool _isLoading = true;
  bool _hasError = false;

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
        _marketData = response;
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
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return _buildLoadingState(l10n);
    }

    if (_hasError || _marketData == null) {
      return _buildErrorState(l10n);
    }

    return RefreshIndicator(
      onRefresh: _loadMarketData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            children: [
              // Currency to Currency Section
              CurrencyToCurrencySection(
                currencies: _marketData!.currencies,
              ),
              
              SizedBox(height: 20.h),
              
              // Gold to Currency Section
              GoldToCurrencySection(
                golds: _marketData!.golds,
                currencies: _marketData!.currencies,
              ),
              
              SizedBox(height: 20.h),
              
              // Crypto to Currency Section
              CryptoToCurrencySection(
                cryptos: _marketData!.cryptos,
                currencies: _marketData!.currencies,
              ),
              
              SizedBox(height: 20.h),
            ],
          ),
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
          Text(
            l10n.loadingConverter,
            style: TextStyle(fontSize: 14.sp, color: AppColors.title(context)),
          ),
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
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.danger),
            SizedBox(height: 12.h),
            Text(
              l10n.failedToLoadMarketData,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.title(context)),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadMarketData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(l10n.retry, style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
      ),
    );
  }
}