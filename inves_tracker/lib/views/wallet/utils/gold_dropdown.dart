import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';

class GoldDropdown extends StatelessWidget {
  final String code;
  const GoldDropdown({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 20.h,
          width: 20.w,
          child: Icon(
            Icons.diamond,
            size: 22.sp,
            color: AppColors.warning2,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          _getGoldNameLocalized(code, AppLocalizations.of(context)!),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  static String _getGoldNameLocalized(String code, AppLocalizations l10n) {
    switch (code) {
      case 'HAS':
        return l10n.goldHAS;
      case 'GRA':
        return l10n.goldGRA;
      case 'CEYREKALTIN':
        return l10n.goldCEYREKALTIN;
      case 'YARIMALTIN':
        return l10n.goldYARIMALTIN;
      case 'TAMALTIN':
        return l10n.goldTAMALTIN;
      case 'ATAALTIN':
        return l10n.goldATAALTIN;
      case 'RESATALTIN':
        return l10n.goldRESATALTIN;
      case 'CUMHURIYETALTINI':
        return l10n.goldCUMHURIYETALTINI;
      case 'GREMSEALTIN':
        return l10n.goldGREMSEALTIN;
      case '14AYARALTIN':
        return l10n.gold14AYARALTIN;
      case '18AYARALTIN':
        return l10n.gold18AYARALTIN;
      case 'YIA':
        return l10n.goldYIA;
      case 'IKIBUCUKALTIN':
        return l10n.goldIKIBUCUKALTIN;
      case 'BESLIALTIN':
        return l10n.goldBESLIALTIN;
      default:
        return code;
    }
  }
}