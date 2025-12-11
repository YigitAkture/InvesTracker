import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/views/home/models/portfolio_data.dart';

class PortfolioChart extends StatefulWidget {
  final PortfolioData portfolioData;

  const PortfolioChart({
    super.key,
    required this.portfolioData,
  });

  @override
  State<PortfolioChart> createState() => _PortfolioChartState();
}

class _PortfolioChartState extends State<PortfolioChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
                    backgroundColor: AppColors.background2(context),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Assets',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.title(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '₺${_formatNumber(widget.portfolioData.totalAssetValue * _animation.value)}',
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
            Wrap(
              spacing: 16.w,
              runSpacing: 12.h,
              alignment: WrapAlignment.center,
              children: widget.portfolioData.segments.map((segment) {
                return _LegendItem(
                  color: segment.color,
                  code: segment.code,
                  percentage: segment.percentage,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
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
          '$code ${percentage.toStringAsFixed(1)}%',
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

class PortfolioChartPainter extends CustomPainter {
  final List<PortfolioSegment> segments;
  final double progress;
  final Color backgroundColor;

  PortfolioChartPainter({
    required this.segments,
    required this.progress,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.9;

    // Draw background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius - innerRadius;


    // Outter ring
    canvas.drawCircle(
      center,
      radius,
      bgPaint,
    );

    // inner ring
    canvas.drawCircle(
      center,
      innerRadius * 0.9,
      bgPaint,
    );

    if (segments.isEmpty) return;

    // Draw segments
    double startAngle = -math.pi / 2; // Start from top

    for (var segment in segments) {
      final sweepAngle = (segment.percentage / 100) * 2 * math.pi * progress;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(PortfolioChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.segments != segments;
  }
}