import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/gold_data.dart';
import 'package:inves_tracker/core/utils/price_formatter.dart';

class GoldBox extends StatelessWidget {
  final GoldData gold;

  const GoldBox({
    super.key,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
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
          // Left side: Gold icon, Name, Change indicator
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Gold icon
                SizedBox(
                  height: 30.h,
                  width: 30.w,
                  child: Icon(
                    Icons.diamond,
                    size: 30.sp,
                    color: AppColors.warning2,
                  ),
                ),
                SizedBox(width: 10.w),
                
                // Gold name
                Expanded(
                  child: Text(
                    gold.getLocalizedName(context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                
                // Change indicator
                Row(
                  children: [
                    Icon(
                      gold.isIncreasing
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 20.sp,
                      color: gold.isIncreasing
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                    Text(
                      '%${gold.changeRate.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: gold.isIncreasing
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
                  PriceFormatter.formatNumber(gold.buying),
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
                  PriceFormatter.formatNumber(gold.selling),
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