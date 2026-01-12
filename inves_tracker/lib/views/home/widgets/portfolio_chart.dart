import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/helpers/locale_helper.dart';
import 'package:inves_tracker/core/helpers/wallet_localization_helper.dart';
import 'package:inves_tracker/core/utils/price_formatter.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/home/models/portfolio_data.dart';
import 'package:inves_tracker/views/home/utils/portfolio_chart_painter.dart';

class PortfolioChart extends StatefulWidget {
  final PortfolioData portfolioData;
  final bool isVisible;

  const PortfolioChart({
    super.key,
    required this.portfolioData,
    required this.isVisible,
  });

  @override
  State<PortfolioChart> createState() => _PortfolioChartState();
}

class _PortfolioChartState extends State<PortfolioChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
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
    final hasMoreThan5 = widget.portfolioData.segments.length > 5;
    final displayedSegments = _isExpanded || !hasMoreThan5
        ? widget.portfolioData.segments
        : widget.portfolioData.segments.take(5).toList();

    return Container(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          // Chart
          SizedBox(
            width: 280.w,
            height: 280.h,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: PortfolioChartPainter(
                    segments: widget.portfolioData.segments,
                    progress: _animation.value,
                    backgroundColor: AppColors.foreground(context),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.totalAssets,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.title(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.isVisible
                              ? '₺${_formatNumber(widget.portfolioData.totalAssetValue * _animation.value, l10n)}'
                              : '••,•• ₺',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Legend
          if (widget.portfolioData.segments.isNotEmpty)
            Column(
              children: [
                Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  alignment: WrapAlignment.center,
                  children: displayedSegments.map((segment) {
                    return _LegendItem(
                      color: segment.color,
                      code: segment.type != 'Gold'
                          ? segment.code
                          : WalletLocalizationHelper.getLocalizedName(
                              context, segment.code, segment.type),
                      percentage: segment.percentage,
                    );
                  }).toList(),
                ),
                
                // Show More/Less Button
                if (hasMoreThan5)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isExpanded ? l10n.showLess : l10n.showMore,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary(context),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16.sp,
                              color: AppColors.primary(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatNumber(double value, AppLocalizations l10n) {
    if (value >= 1000000000) {
      return '${PriceFormatter.formatCurrency(value / 1000000000, context.localeString)}${l10n.billion}';
    } else if (value >= 1000000) {
      return '${PriceFormatter.formatCurrency(value / 1000000, context.localeString)}${l10n.million}';
    } else if (value >= 1000) {
      return '${PriceFormatter.formatCurrency(value / 1000, context.localeString)}${l10n.thousand}';
    } else {
      return PriceFormatter.formatNumber(value, 0, context.localeString);
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String code;
  final double percentage;

  const _LegendItem({
    required this.color,
    required this.code,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          '$code ${percentage > 0.09 ? percentage.toStringAsFixed(1) : '< 0.1'}%',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.text(context),
          ),
        ),
      ],
    );
  }
}