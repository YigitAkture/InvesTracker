import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/crypto_data.dart';

class CryptoBox extends StatelessWidget {
  final CryptoData crypto;

  const CryptoBox({
    super.key,
    required this.crypto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
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
                Container(
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
                ),
                SizedBox(width: 10.w),
                
                // Crypto code and name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        crypto.code,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        crypto.name,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
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
          
          // Right side: Buying and Selling prices (TRY Price)
          Row(
            children: [
              // TRY Price (displayed as both buying and selling)
              SizedBox(
                width: 70.w,
                child: Text(
                  _formatPrice(crypto.tryPrice),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              
              // TRY Price again (for consistency with layout)
              SizedBox(
                width: 70.w,
                child: Text(
                  _formatPrice(crypto.tryPrice),
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

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(0);
    } else if (price >= 1) {
      return price.toStringAsFixed(2);
    } else {
      return price.toStringAsFixed(4);
    }
  }
}