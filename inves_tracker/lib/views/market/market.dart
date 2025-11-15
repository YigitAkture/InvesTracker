import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/views/market/currency/currency_rates.dart';
import 'package:inves_tracker/views/market/gold/gold_rates.dart';

class Market extends StatefulWidget {
  const Market({super.key});

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  String updateTime = '';
  final GlobalKey<CurrencyRatesState> _currencyRatesKey = GlobalKey();

  Future<void> _handleRefresh() async {
    // Trigger refresh in CurrencyRates widget
    await _currencyRatesKey.currentState?.loadCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Enables pull-to-refresh even when content is small
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency section header
            if (updateTime.isNotEmpty)
              Padding(
              padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    'Updated: $updateTime',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
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
                  Row(
                    children: [
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
                      SizedBox(width: 12.w),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 4.h),
            
            // Currency rates list
            CurrencyRates(
              key: _currencyRatesKey,
              onUpdate: (time) {
                setState(() => updateTime = time);
              },
            ),

            
            SizedBox(height: 24.h),
            
            // Gold section (placeholder for now)
            // Uncomment when ready to implement
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
            //   child: Text(
            //     'Gold',
            //     style: TextStyle(
            //       fontSize: 16.sp,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
            // SizedBox(height: 4.h),
            // const GoldRates(),
          ],
        ),
      ),
    );
  }
}