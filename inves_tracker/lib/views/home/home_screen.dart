import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/views/home/widgets/box.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assets', style: TextStyle(
              fontSize: 16.sp
            ),
          ),
          SizedBox(height: 4.h),
          Box(AppColors.teal),
          SizedBox(height: 12.h),
          Text('Debts', style: TextStyle(
              fontSize: 16.sp
            ),
          ),
          SizedBox(height: 4.h),
          Box(AppColors.pink),
        ]
      ),
    );
  }
}