import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/models/gold_data.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/views/market/currency/currency_rates.dart';
import 'package:inves_tracker/views/market/gold/gold_rates.dart';

class Market extends StatefulWidget {
  const Market({super.key});

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  final MarketService _marketService = MarketService();
  
  List<CurrencyData> _currencies = [];
  List<GoldData> _golds = [];
  String _updateTime = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Single API call to fetch both currencies and gold
      final response = await _marketService.fetchMarketData();
      setState(() {
        _currencies = response.currencies;
        _golds = response.golds;
        _updateTime = response.updateTime;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load market data';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadMarketData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Update time header
            if (_updateTime.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      'Updated: $_updateTime',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

            // Currency Section Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Currency',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70.w,
                          child: Text(
                            'Change',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 70.w,
                          child: Text(
                            'Buying',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        SizedBox(
                          width: 70.w,
                          child: Text(
                            'Selling',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Currency rates list
            CurrencyRates(currencies: _currencies),

            SizedBox(height: 24.h),

            // Gold Section Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gold',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70.w,
                          child: Text(
                            'Change',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 70.w,
                          child: Text(
                            'Buying',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        SizedBox(
                          width: 70.w,
                          child: Text(
                            'Selling',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Gold rates list
            GoldRates(golds: _golds),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary(context)),
          SizedBox(height: 12.h),
          Text(
            'Loading market data...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.danger),
            SizedBox(height: 12.h),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
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
              child: Text('Retry', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
      ),
    );
  }
}