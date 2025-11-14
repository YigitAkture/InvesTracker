import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/utils/theme_notifier.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return AppBar(
      backgroundColor: AppColors.foreground(context),
      elevation: 0,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
      ),
      actions: [
        IconButton(
          icon: Icon(
            themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          ),
          onPressed: () => themeNotifier.toggleTheme(),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(2.h),
        child: Container(
          height: 1.h,
          color: AppColors.background2(context).withValues(alpha: 0.1),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(45.h);
}
