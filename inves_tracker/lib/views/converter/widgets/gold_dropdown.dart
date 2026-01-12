import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/gold_data.dart';
import 'package:inves_tracker/core/constants/asset_colors.dart';

class GoldDropdown extends StatelessWidget {
  final List<GoldData> golds;
  final String selectedCode;
  final ValueChanged<String> onChanged;

  const GoldDropdown({
    super.key,
    required this.golds,
    required this.selectedCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          items: golds.map((gold) {
            return DropdownMenuItem<String>(
              value: gold.code,
              child: Row(
                children: [
                  SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: Icon(
                      Icons.diamond,
                      size: 22.sp,
                      color: AssetColors.getColorForAsset(gold.code, 'gold'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      gold.getLocalizedName(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
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