import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';

class CryptoDropdown extends StatelessWidget {
  final String code;

  const CryptoDropdown({
    super.key,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.asset(
            'assets/img/cryptos/${code.toLowerCase()}.png',
            height: 20.h,
            width: 20.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 20.h,
                width: 20.w,
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.currency_bitcoin,
                  size: 14.sp,
                  color: AppColors.primary(context),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          code,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}