import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/shared/banner_add.dart';
import 'package:inves_tracker/views/market/currency/widgets/currency_box.dart';

class CurrencyRates extends StatefulWidget {
  final List<CurrencyData> currencies;
  
  const CurrencyRates({
    super.key,
    required this.currencies,
  });

  @override
  State<CurrencyRates> createState() => CurrencyRatesState();
}

class CurrencyRatesState extends State<CurrencyRates> {
  bool _showAll = false;

  void _toggleShowAll() {
    setState(() {
      _showAll = !_showAll;
    });
  }

  List<CurrencyData> _getDisplayedCurrencies() {
    if (_showAll) {
      return widget.currencies;
    } else {
      // Show only first 4 currencies (default ones)
      const defaultCodes = ['USD', 'EUR', 'GBP', 'CHF'];
      return widget.currencies
          .where((currency) => defaultCodes.contains(currency.code))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.currencies.isEmpty) {
      return Container(
        height: 100.h,
        alignment: Alignment.center,
        child: Text(
          l10n.noCurrencyDataAvailable,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      );
    }

    final displayedCurrencies = _getDisplayedCurrencies();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Currency list
        Column(
          children: displayedCurrencies
              .map((currency) => CurrencyBox(currency: currency))
              .toList(),
        ),

        // Show More/Less button
        if (widget.currencies.length > 4)
          Padding(
            padding: EdgeInsets.only(top: 4.h, right: 4.w),
            child: TextButton(
              onPressed: _toggleShowAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _showAll ? l10n.showLess : l10n.showMore,
                    style: TextStyle(
                      fontSize: 13.sp,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    _showAll
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),

          // Banner Ad
          SizedBox(height: 8.h),
          const Center(child: BannerAdd()),
          SizedBox(height: 8.h),
      ],
    );
  }
}