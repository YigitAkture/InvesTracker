import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';

class CurrencyBox extends StatelessWidget {
  const CurrencyBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      width: 390.w,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        borderRadius: BorderRadius.circular(10.r)
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/img/flags/usd.png',
            height: 24.h,
            width: 24.w,
          ),
        ],
      ),
    );
  }
}