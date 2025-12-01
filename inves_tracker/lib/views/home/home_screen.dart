import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/home/widgets/box.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.assets,
          style: TextStyle(fontSize: 20.sp),
        ),
        SizedBox(height: 4.h),
        Box(AppColors.primary(context)),
        SizedBox(height: 12.h),
        Text(
          l10n.debts,
          style: TextStyle(fontSize: 20.sp),
        ),
        SizedBox(height: 4.h),
        Box(AppColors.secondary(context)),
      ],
    );
  }
}