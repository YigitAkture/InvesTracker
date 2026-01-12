import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/helpers/gold_input_helper.dart';
import 'package:inves_tracker/core/models/gold_data.dart';
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/converter/widgets/converter_card.dart';
import 'package:inves_tracker/views/converter/widgets/gold_dropdown.dart';
import 'package:inves_tracker/views/converter/widgets/currency_dropdown.dart';

class GoldToCurrencySection extends StatefulWidget {
  final List<GoldData> golds;
  final List<CurrencyData> currencies;

  const GoldToCurrencySection({
    super.key,
    required this.golds,
    required this.currencies,
  });

  @override
  State<GoldToCurrencySection> createState() => _GoldToCurrencySectionState();
}

class _GoldToCurrencySectionState extends State<GoldToCurrencySection> {
  String _selectedGold = 'GRA';
  String _selectedCurrency = 'TRY';
  final TextEditingController _amountController = TextEditingController(text: '1');
  double _result = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateConversion();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onGoldTypeChanged(String newGoldCode) {
    setState(() {
      _selectedGold = newGoldCode;
      
      // If the current amount contains decimal but new gold type doesn't allow it,
      // remove the decimal part
      if (!GoldInputHelper.allowsDecimal(newGoldCode)) {
        final currentAmount = double.tryParse(_amountController.text);
        if (currentAmount != null) {
          _amountController.text = currentAmount.toInt().toString();
        }
      }
      
      _calculateConversion();
    });
  }

  void _calculateConversion() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    if (amount == 0.0) {
      setState(() => _result = 0.0);
      return;
    }

    // Get gold price in TRY
    final goldRate = _getGoldRate(_selectedGold);
    final currencyRate = _getCurrencyRate(_selectedCurrency);

    if (goldRate == null || currencyRate == null) {
      setState(() => _result = 0.0);
      return;
    }

    // Convert: amount in gold -> TRY -> selected currency
    final amountInTRY = amount * goldRate;
    final convertedAmount = amountInTRY / currencyRate;

    setState(() {
      _result = convertedAmount;
    });
  }

  double? _getGoldRate(String code) {
    final gold = widget.golds.firstWhere(
      (g) => g.code == code,
      orElse: () => widget.golds.first,
    );
    
    return gold.selling;
  }

  double? _getCurrencyRate(String code) {
    if (code == 'TRY') return 1.0;
    
    final currency = widget.currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => widget.currencies.first,
    );
    
    return currency.buying;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ConverterCard(
      title: l10n.metalToCurrency,
      child: Column(
        children: [
          // Gold Input
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GoldDropdown(
                  golds: widget.golds,
                  selectedCode: _selectedGold,
                  onChanged: _onGoldTypeChanged,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _amountController,
                  // Dynamic keyboard type based on selected gold
                  keyboardType: GoldInputHelper.getKeyboardType(_selectedGold),
                  // Dynamic input formatters based on selected gold
                  inputFormatters: GoldInputHelper.getInputFormatters(_selectedGold),
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
                  onChanged: (value) => _calculateConversion(),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Arrow Icon
          Center(
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_downward,
                size: 28.sp,
                color: AppColors.warning,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Currency Output
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CurrencyDropdown(
                  currencies: widget.currencies,
                  selectedCode: _selectedCurrency,
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value;
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
                    _result.toStringAsFixed(2),
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