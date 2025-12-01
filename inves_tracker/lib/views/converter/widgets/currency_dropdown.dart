import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/currency_data.dart';

class CurrencyDropdown extends StatelessWidget {
  final List<CurrencyData> currencies;
  final String selectedCode;
  final ValueChanged<String> onChanged;

  const CurrencyDropdown({
    super.key,
    required this.currencies,
    required this.selectedCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Add TRY manually if not in the list
    final allCurrencies = [...currencies];
    if (!allCurrencies.any((c) => c.code == 'TRY')) {
      allCurrencies.insert(
        0,
        CurrencyData(
          code: 'TRY',
          name: 'Turkish Lira',
          buying: 1.0,
          selling: 1.0,
          changeRate: 0.0,
          isIncreasing: true,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.background2(context),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCode,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 20.sp,
            color: AppColors.primary(context),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          dropdownColor: AppColors.foreground(context),
          items: allCurrencies.map((currency) {
            return DropdownMenuItem<String>(
              value: currency.code,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Image.asset(
                      'assets/img/flags/${currency.code.toLowerCase()}.png',
                      height: 20.h,
                      width: 28.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 20.h,
                          width: 28.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary(context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Icon(
                            Icons.currency_exchange,
                            size: 14.sp,
                            color: AppColors.primary(context),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(currency.code),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}