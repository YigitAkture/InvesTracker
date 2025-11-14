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
          CurrencyRates(),
          SizedBox(height: 8.h),
          GoldRates(),
        ],
      ),
    );
  }
}