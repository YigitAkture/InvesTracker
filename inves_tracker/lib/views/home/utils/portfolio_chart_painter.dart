import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/views/home/models/portfolio_data.dart';

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
    final maxRadius = math.min(size.width, size.height) / 2;
    
    // Define ring dimensions (responsive)
    final outerRingThickness = 4.w; // Thinnest
    final secondRingThickness = 10.w; // Slightly thicker
    final chartRingThickness = 12.w; // Thickest (the actual chart)
    final circleRadius = 98.w; // Center circle radius
    
    // Define gaps
    final gapBetweenOuterAndSecond = 8.w;
    
    // Calculate ring positions from outside to inside
    final outerRingRadius = maxRadius - (outerRingThickness / 2);
    final secondRingRadius = outerRingRadius - (outerRingThickness / 2) - gapBetweenOuterAndSecond - (secondRingThickness / 2);
    final chartRingRadius = secondRingRadius - (secondRingThickness / 2) - (chartRingThickness / 2);
    
    // 1. Draw outer ring (thinnest, outermost)
    final outerRingPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRingThickness;
    
    canvas.drawCircle(center, outerRingRadius, outerRingPaint);
    
    // 2. Draw second ring (slightly thicker)
    final secondRingPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = secondRingThickness;
    
    canvas.drawCircle(center, secondRingRadius, secondRingPaint);
    
    // 3. Draw center circle (filled)
    final circlePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, circleRadius, circlePaint);
    
    // 4. Draw chart segments (if data exists)
    if (segments.isEmpty) return;
    
    double startAngle = -math.pi / 2; // Start from top
    
    for (var segment in segments) {
      final sweepAngle = (segment.percentage / 100) * 2 * math.pi * progress;
      
      final chartPaint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = chartRingThickness
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: chartRingRadius),
        startAngle,
        sweepAngle,
        false,
        chartPaint,
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