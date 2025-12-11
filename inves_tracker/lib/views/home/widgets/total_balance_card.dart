import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/views/home/models/portfolio_data.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';

class TotalBalanceCard extends StatefulWidget {
  final PortfolioData portfolioData;

  const TotalBalanceCard({super.key, required this.portfolioData});

  @override
  State<TotalBalanceCard> createState() => _TotalBalanceCardState();
}

class _TotalBalanceCardState extends State<TotalBalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPositive = widget.portfolioData.totalBalance > 0;
    final isZero = widget.portfolioData.totalBalance == 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isZero
              ? [
                  AppColors.title(context).withValues(alpha: 0.2),
                  AppColors.title(context).withValues(alpha: 0.1),
                ]
              : isPositive
              ? [
                  AppColors.success.withValues(alpha: 0.2),
                  AppColors.success.withValues(alpha: 0.1),
                ]
              : [
                  AppColors.danger.withValues(alpha: 0.2),
                  AppColors.danger.withValues(alpha: 0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isZero
              ? AppColors.title(context)
              : isPositive
              ? AppColors.success.withValues(alpha: 0.8)
              : AppColors.danger.withValues(alpha: 0.8),
          width: 3.w,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isZero
                        ? AppColors.title(context)
                        : isPositive
                        ? AppColors.success
                        : AppColors.danger)
                    .withValues(alpha: 0.1),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isZero
                    ? Icons.trending_flat
                    : isPositive
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: isZero ? AppColors.title(context) : isPositive ? AppColors.success : AppColors.danger,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.totalBalance,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.title(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final animatedValue =
                  widget.portfolioData.totalBalance * _animation.value;
              return Text(
                '${isZero
                    ? ''
                    : isPositive
                    ? '+'
                    : '-'} ₺${_formatNumber(animatedValue.abs())}',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: isZero
                      ? AppColors.title(context)
                      : isPositive
                      ? AppColors.success
                      : AppColors.danger,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8.r,
                      offset: Offset(0, 2.5.h),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 16.h),
          Divider(color: AppColors.background2(context), thickness: 1),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoColumn(
                label: l10n.assets,
                value: widget.portfolioData.totalAssetValue,
                color: AppColors.primary(context),
                progress: _animation.value,
              ),
              Container(
                width: 1.w,
                height: 40.h,
                color: AppColors.background2(context),
              ),
              _InfoColumn(
                label: l10n.debts,
                value: widget.portfolioData.totalDebtValue,
                color: AppColors.secondary(context),
                progress: _animation.value,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return value.toStringAsFixed(2);
    }
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double progress;

  const _InfoColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.title(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          '₺${_formatNumber(value * progress)}',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return value.toStringAsFixed(2);
    }
  }
}
