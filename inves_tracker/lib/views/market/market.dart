import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/views/market/currency/currency_rates.dart';
import 'package:inves_tracker/views/market/gold/gold_rates.dart';

class Market extends StatelessWidget {
  const Market({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Currency'),
                SizedBox(height: 32.h),
                Wrap(
                  children: [
                    Text('Buying'),
                    SizedBox(width: 30.w),
                    Text('Selling'),
                  ],
                )
              ],
            ),
          ),
          CurrencyRates(),
          SizedBox(height: 8.h),
          GoldRates(),
        ],
      ),
    );
  }
}