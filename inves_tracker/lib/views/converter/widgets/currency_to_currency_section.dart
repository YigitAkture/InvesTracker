import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/utils/price_formatter.dart';
import 'package:inves_tracker/core/utils/regex_separator_input_formatter.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/converter/widgets/converter_card.dart';
import 'package:inves_tracker/views/converter/widgets/currency_dropdown.dart';

class CurrencyToCurrencySection extends StatefulWidget {
  final List<CurrencyData> currencies;

  const CurrencyToCurrencySection({
    super.key,
    required this.currencies,
  });

  @override
  State<CurrencyToCurrencySection> createState() =>
      _CurrencyToCurrencySectionState();
}

class _CurrencyToCurrencySectionState
    extends State<CurrencyToCurrencySection> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'TRY';
  final TextEditingController _amountController =
      TextEditingController(text: '1');
  // Replaces the raw double _result — now stored as formatted text
  final TextEditingController _resultController = TextEditingController();

  double _parse(String text) =>
      double.tryParse(text.replaceAll(',', '')) ?? 0.0;

  @override
  void initState() {
    super.initState();
    _calculateConversion();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _calculateConversion() {
    final amount = _parse(_amountController.text);

    if (amount == 0.0) {
      setState(() => _resultController.text = '0.00');
      return;
    }

    final fromRate = _getCurrencyRate(_fromCurrency);
    final toRate = _getCurrencyRate(_toCurrency);

    if (fromRate == null || toRate == null) {
      setState(() => _resultController.text = '0.00');
      return;
    }

    final amountInTRY = amount * fromRate;
    final convertedAmount = amountInTRY / toRate;

    setState(() {
      _resultController.text = PriceFormatter.formatCurrency(convertedAmount);
    });
  }

  double? _getCurrencyRate(String code) {
    if (code == 'TRY') return 1.0;
    final currency = widget.currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => widget.currencies.first,
    );
    return currency.buying;
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _calculateConversion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ConverterCard(
      title: l10n.currencyConverterTitle,
      child: Column(
        children: [
          // From Currency
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CurrencyDropdown(
                  currencies: widget.currencies,
                  selectedCode: _fromCurrency,
                  onChanged: (value) {
                    setState(() {
                      _fromCurrency = value;
                      _calculateConversion();
                    });
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    RegexSeparatorInputFormatter(allowDecimal: true),
                  ],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 14.h,
                    ),
                    filled: true,
                    fillColor: AppColors.background2(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _calculateConversion(),
                  onTap: () {
                    _amountController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _amountController.text.length),
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Center(
            child: GestureDetector(
              onTap: _swapCurrencies,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_vert,
                  size: 28.sp,
                  color: AppColors.primary(context),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // To Currency (read-only result)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CurrencyDropdown(
                  currencies: widget.currencies,
                  selectedCode: _toCurrency,
                  onChanged: (value) {
                    setState(() {
                      _toCurrency = value;
                      _calculateConversion();
                    });
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background2(context),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    _resultController.text,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
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
}