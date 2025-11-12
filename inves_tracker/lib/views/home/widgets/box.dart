import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';

class Box extends StatelessWidget {
  const Box(this.color, {super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390.w,
      height: 220.h,
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        borderRadius: BorderRadius.only(topRight: Radius.circular(35.r), bottomLeft: Radius.circular(35.r), bottomRight: Radius.circular(35.r)),
        border: Border(
          left: BorderSide(color: color, width: 1.2.w),
          top: BorderSide(color: color, width: 1.2.w),
          right: BorderSide(color: color, width: 1.2.w),
          bottom: BorderSide(color: color, width: 1.2.w),
        )
      ),
    );
  }
}