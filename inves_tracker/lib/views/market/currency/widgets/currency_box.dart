import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/helpers/locale_helper.dart';
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/utils/price_formatter.dart';

class CurrencyBox extends StatelessWidget {
  final CurrencyData currency;

  const CurrencyBox({
    super.key,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62.h,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Flag, Code, Change indicator
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Flag image
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: Image.asset(
                    'assets/img/flags/${currency.code.toLowerCase()}.png',
                    height: 30.h,
                    width: 30.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 24.h,
                        width: 32.w,
                        decoration: BoxDecoration(
                          color: AppColors.background2(context),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Icon(
                          Icons.currency_exchange,
                          size: 16.sp,
                          color: AppColors.primary(context),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                
                // Currency code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currency.code,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        currency.getLocalizedName(context),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.title(context),
                          height: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                
                // Change indicator
                Row(
                  children: [
                    Icon(
                      currency.isIncreasing
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 20.sp,
                      color: currency.isIncreasing
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                    Text(
                      '%${currency.changeRate.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: currency.isIncreasing
                            ? AppColors.success
                            : AppColors.danger,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),
          
          // Right side: Buying and Selling prices
          Row(
            children: [
              // Buying price
              SizedBox(
                width: 76.w,
                child: Text(
                  PriceFormatter.formatNumber(currency.buying, 4, context.localeString),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              
              // Selling price
              SizedBox(
                width: 76.w,
                child: Text(
                  PriceFormatter.formatNumber(currency.selling, 4, context.localeString),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}