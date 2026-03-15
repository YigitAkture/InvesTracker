import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:showcaseview/showcaseview.dart';

/// A helper that wraps a [child] in a [Showcase] widget with the app's
/// brand colours and consistent typography.
///
/// Usage:
/// ```dart
/// ShowcaseHelper.wrap(
///   key: _myKey,
///   title: 'Market Rates',
///   description: 'Browse live exchange rates here.',
///   child: myWidget,
/// );
/// ```
class ShowcaseHelper {
  ShowcaseHelper._();

  // ── Brand colours ─────────────────────────────────────────────────────────
  // Deep green tooltip matches AppColors.primaryLight so it looks consistent
  // in both light and dark themes without needing a BuildContext here.
  static const Color _tooltipBg = Color(0xFF1B5448);
  static const Color _tooltipTextColor = Colors.white;
  static const Color _titleColor = Color(0xFFEDF492); // AppColors.melon

  /// Wraps [child] in a [Showcase] with consistent InvesTracker styling.
  ///
  /// Parameters that map to the v5.0.1 [Showcase] API:
  /// - [targetPadding]     : extra space added around the highlighted widget.
  ///                         NOTE: the old `overlayPadding` parameter was
  ///                         removed in v5 — the correct name is `targetPadding`.
  /// - [targetShapeBorder] : circle for nav icons, rounded rect for cards.
  /// - [tooltipBorderRadius] : rounds the tooltip bubble corners.
  /// - [movingAnimationDuration] : controls the bouncing tooltip animation.
  static Widget wrap({
    required GlobalKey key,
    required String title,
    required String description,
    required Widget child,
    /// Use a circular spotlight (true) or rounded-rect (false, default).
    bool circular = false,
    /// Space between the highlight border and the widget edge.
    /// Replaces the old `overlayPadding` parameter from pre-v5 versions.
    EdgeInsets targetPadding = const EdgeInsets.all(8),
  }) {
    return Showcase(
      key: key,
      title: title,
      description: description,
      // ── Target highlight shape ───────────────────────────────────────────
      targetShapeBorder: circular
          ? const CircleBorder()
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.r)),
            ),
      targetPadding: targetPadding,
      // ── Tooltip appearance ───────────────────────────────────────────────
      tooltipBackgroundColor: _tooltipBg,
      textColor: _tooltipTextColor,
      titleTextStyle: TextStyle(
        color: _titleColor,
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
      ),
      descTextStyle: TextStyle(
        color: _tooltipTextColor,
        fontSize: 13.sp,
        height: 1.4,
      ),
      tooltipBorderRadius: BorderRadius.circular(12.r),
      // ── Animation ────────────────────────────────────────────────────────
      blurValue: 1.5,
      movingAnimationDuration: const Duration(milliseconds: 350),
      child: child,
    );
  }
}