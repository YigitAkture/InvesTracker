import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/views/market/currency/widgets/currency_box.dart';

class CurrencyRates extends StatefulWidget {
  const CurrencyRates({super.key});

  @override
  State<CurrencyRates> createState() => _CurrencyRatesState();
}

class _CurrencyRatesState extends State<CurrencyRates> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CurrencyBox(),
        TextButton(
          onPressed: () {},
          child: Text('See More...', 
            style: TextStyle(
              fontSize: 12.sp,
              decoration: TextDecoration.underline,
            ),
          )
        ),
      ],
    );
  }
}