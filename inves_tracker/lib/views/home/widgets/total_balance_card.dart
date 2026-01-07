import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/utils/price_formatter.dart';
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
  late final AnimationController _controller;
  late final Animation<double> _animation;

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
  void didUpdateWidget(covariant TotalBalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If portfolio data changed — restart animation so children get new progress
    if (oldWidget.portfolioData.totalBalance != widget.portfolioData.totalBalance ||
        oldWidget.portfolioData.totalAssetValue != widget.portfolioData.totalAssetValue ||
        oldWidget.portfolioData.totalDebtValue != widget.portfolioData.totalDebtValue) {
      _controller
        ..reset()
        ..forward();
    }
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
            color: (isZero
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
      // Make the entire content reactive to the animation
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // progress value from 0 -> 1 while animation runs
          final progress = _animation.value;
          final animatedTotal = widget.portfolioData.totalBalance * progress;
          final animatedAssets = widget.portfolioData.totalAssetValue * progress;
          final animatedDebts = widget.portfolioData.totalDebtValue * progress;

          return Column(
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
                    color: isZero
                        ? AppColors.title(context)
                        : isPositive
                            ? AppColors.success
                            : AppColors.danger,
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

              // Animated total balance text (driven by the same controller)
              Text(
                '${isZero ? '' : isPositive ? '+' : '-'} ${formatNumber(animatedTotal.abs(), l10n)}₺',
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
              ),

              SizedBox(height: 16.h),
              Divider(color: AppColors.background2(context), thickness: 1),
              SizedBox(height: 16.h),

              // Asset / Debt info — now rebuilds with animation progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoColumn(
                    label: l10n.assets,
                    value: animatedAssets,
                    color: AppColors.primary(context),
                  ),
                  Container(
                    width: 1.w,
                    height: 40.h,
                    color: AppColors.background2(context),
                  ),
                  _InfoColumn(
                    label: l10n.debts,
                    value: animatedDebts,
                    color: AppColors.secondary(context),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _InfoColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          '${formatNumber(value, l10n)}₺',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

String formatNumber(double value, AppLocalizations l10n) {
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(2)}${l10n.billion}';
  } else if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(2)}${l10n.million}';
  } else if (value >= 100000) {
    return '${(value / 1000).toStringAsFixed(2)}${l10n.thousand}';
  } else if (value < 100000) {
    return PriceFormatter.formatNumber(value, 2);
  } else {
    return value.toStringAsFixed(0);
  }
}
