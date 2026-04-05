import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/utils/locale_notifier.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class LanguageSettingItem extends StatelessWidget {
  const LanguageSettingItem({super.key});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              Icon(
                Icons.language,
                color: AppColors.primary(context),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.language,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _LanguageButton(
                flagAsset: 'assets/img/flags/try.png',
                languageName: 'Türkçe',
                isSelected: _isTurkish(localeNotifier, context),
                onTap: () => localeNotifier.setLocale(const Locale('tr')),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _LanguageButton(
                flagAsset: 'assets/img/flags/gbp.png',
                languageName: 'English',
                isSelected: _isEnglish(localeNotifier, context),
                onTap: () => localeNotifier.setLocale(const Locale('en')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isEnglish(LocaleNotifier localeNotifier, BuildContext context) {
    final currentLocale = localeNotifier.locale;
    if (currentLocale == null) {
      return Localizations.localeOf(context).languageCode == 'en';
    }
    return currentLocale.languageCode == 'en';
  }

  bool _isTurkish(LocaleNotifier localeNotifier, BuildContext context) {
    final currentLocale = localeNotifier.locale;
    if (currentLocale == null) {
      return Localizations.localeOf(context).languageCode == 'tr';
    }
    return currentLocale.languageCode == 'tr';
  }
}

class _LanguageButton extends StatefulWidget {
  final String flagAsset;
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.flagAsset,
    required this.languageName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<_LanguageButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Pure numeric tweens — no Colors, no context needed during setup
  late Animation<double> _progressAnim;
  late Animation<double> _flagScaleAnim;
  late Animation<double> _fontSizeAnim;
  late Animation<double> _fontWeightAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // 0.0 → 1.0 general progress, used to lerp colors inside build()
    _progressAnim   = Tween<double>(begin: 0, end: 1).animate(curve);
    _flagScaleAnim  = Tween<double>(begin: 0.72, end: 1.0).animate(curve);
    _fontSizeAnim   = Tween<double>(begin: 12, end: 16).animate(curve);
    _fontWeightAnim = Tween<double>(begin: 0, end: 1).animate(curve);

    // Snap to the correct initial state with no animation
    if (widget.isSelected) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_LanguageButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected == oldWidget.isSelected) return;

    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  FontWeight _lerpFontWeight(double t) {
    // FontWeight.w600 = index 4, FontWeight.w800 = index 6
    final index = (4 + (t * 2)).round().clamp(4, 6);
    return FontWeight.values[index];
  }

  @override
  Widget build(BuildContext context) {
    // Read inherited widgets here — always safe during the build phase
    final primaryColor = AppColors.primary(context);
    final bg2Color     = AppColors.background2(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _progressAnim.value;

          // Lerp colors inside build() so no inherited widget is ever
          // accessed outside a normal build call
          final borderColor = Color.lerp(
            Colors.transparent,
            primaryColor,
            t,
          )!;
          final bgColor = Color.lerp(
            bg2Color,
            primaryColor.withValues(alpha: 0.10),
            t,
          )!;

          return Container(
            // Fixed height keeps the layout perfectly stable
            height: 110.h,
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: borderColor, width: 2.w),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fixed-size box holds the space; Transform.scale moves
                // only the pixels, never the layout
                SizedBox(
                  width: 56.w,
                  height: 42.h,
                  child: Center(
                    child: Transform.scale(
                      scale: _flagScaleAnim.value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.asset(
                          widget.flagAsset,
                          width: 40.w,
                          height: 40.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: bg2Color,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.flag,
                              size: 24.sp,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  widget.languageName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _fontSizeAnim.value.sp,
                    fontWeight: _lerpFontWeight(_fontWeightAnim.value),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}