import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/crypto_data.dart';
import 'package:inves_tracker/core/utils/price_formatter.dart';

class CryptoBox extends StatelessWidget {
  final CryptoData crypto;

  const CryptoBox({
    super.key,
    required this.crypto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h, // Increased height slightly
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h), // Increased vertical padding
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
          // Left side: Crypto icon, Code/Name, Change indicator
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Crypto icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: Image.asset(
                    'assets/img/cryptos/${crypto.code.toLowerCase()}.png',
                    height: 30.h,
                    width: 30.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 30.h,
                        width: 30.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary(context).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Icon(
                          Icons.currency_bitcoin,
                          size: 18.sp,
                          color: AppColors.primary(context),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                
                // Crypto code and name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                    children: [
                      Text(
                        crypto.code,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.2, // Control line height
                        ),
                      ),
                      SizedBox(height: 2.h), // Small spacing
                      Text(
                        crypto.name,
                        style: TextStyle(
                          fontSize: 11.sp, // Slightly smaller
                          color: AppColors.title(context),
                          height: 1.1, // Tighter line height
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                
                // Change indicator
                Row(
                  children: [
                    Icon(
                      crypto.isIncreasing
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 20.sp,
                      color: crypto.isIncreasing
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                    Text(
                      '%${crypto.changeRate.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: crypto.isIncreasing
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
          
          // Right side: Buying and Selling prices (USD Price)
          Row(
            children: [
              // USD Price
              SizedBox(
                width: 70.w,
                child: Text(
                  PriceFormatter.formatPrice(crypto.usdPrice),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              
              // USD Selling Price
              SizedBox(
                width: 70.w,
                child: Text(
                  PriceFormatter.formatPrice(crypto.sellingUsd),
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