import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/helpers/gold_input_helper.dart';
import 'package:inves_tracker/core/helpers/locale_helper.dart';
import 'package:inves_tracker/core/models/gold_data.dart';
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/utils/price_formatter.dart';
import 'package:inves_tracker/core/utils/regex_separator_input_formatter.dart';
import 'package:inves_tracker/core/l10n/app_localizations.dart';
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
  final TextEditingController _goldController = TextEditingController(
    text: '1',
  );
  final TextEditingController _currencyController = TextEditingController();
  bool _isEditingGold = true;
  late String _locale;
  bool _initialized = false;

  double _parse(String text) {
    final thousandSep = _locale == 'tr_TR' ? '.' : ',';
    final decimalSep = _locale == 'tr_TR' ? ',' : '.';
    return double.tryParse(
          text.replaceAll(thousandSep, '').replaceAll(decimalSep, '.'),
        ) ??
        0.0;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _goldController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = context.localeString;
    if (!_initialized) {
      _initialized = true;
      _calculateFromGold();
    }
  }

  void _onGoldTypeChanged(String newGoldCode) {
    setState(() {
      _selectedGold = newGoldCode;

      // If the current amount contains decimal but new gold type doesn't allow it,
      // remove the decimal part ONLY when editing gold field
      if (!GoldInputHelper.allowsDecimal(newGoldCode) && _isEditingGold) {
        final currentAmount = _parse(_goldController.text);
        if (currentAmount != 0.0) {
          _goldController.text = currentAmount.toInt().toString();
        }
      }

      if (_isEditingGold) {
        _calculateFromGold();
      } else {
        _calculateFromCurrency();
      }
    });
  }

  void _calculateFromGold() {
    final amount = _parse(_goldController.text);

    if (amount == 0.0) {
      setState(() {
        _currencyController.text = '0.00';
      });
      return;
    }

    // Get gold price in TRY
    final goldRate = _getGoldRate(_selectedGold);
    final currencyRate = _getCurrencyRate(_selectedCurrency);

    if (goldRate == null || currencyRate == null) {
      setState(() {
        _currencyController.text = '0.00';
      });
      return;
    }

    // Convert: amount in gold -> TRY -> selected currency
    final amountInTRY = amount * goldRate;
    final convertedAmount = amountInTRY / currencyRate;

    setState(() {
      _currencyController.text = PriceFormatter.formatCurrency(
        convertedAmount,
        _locale,
      );
    });
  }

  void _calculateFromCurrency() {
    final amount = _parse(_currencyController.text);

    if (amount == 0.0) {
      setState(() {
        _goldController.text = '0.00';
      });
      return;
    }

    // Get gold price in TRY
    final goldRate = _getGoldRate(_selectedGold);
    final currencyRate = _getCurrencyRate(_selectedCurrency);

    if (goldRate == null || currencyRate == null) {
      setState(() {
        _goldController.text = '0.00';
      });
      return;
    }

    // Convert: amount in currency -> TRY -> gold
    final amountInTRY = amount * currencyRate;
    final convertedAmount = amountInTRY / goldRate;

    // Always display result with decimal places when converting from currency
    // This allows showing precise values even for integer-only gold types
    setState(() {
      _goldController.text = PriceFormatter.formatCurrency(
        convertedAmount,
        _locale,
      );
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

  Widget _buildGoldRow({required bool isEditable}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GoldDropdown(
            golds: widget.golds,
            selectedCode: _selectedGold,
            onChanged: _onGoldTypeChanged,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 3,
          child: isEditable
              ? TextField(
                  controller: _goldController,
                  keyboardType: GoldInputHelper.getKeyboardType(_selectedGold),
                  inputFormatters: [
                    RegexSeparatorInputFormatter(
                      allowDecimal: GoldInputHelper.allowsDecimal(
                        _selectedGold,
                      ),
                      locale: _locale,
                    ),
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
                  onChanged: (value) {
                    if (_isEditingGold) {
                      _calculateFromGold();
                    }
                  },
                  onTap: () {
                    _goldController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _goldController.text.length),
                    );
                  },
                )
              : Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background2(context),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    _goldController.text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCurrencyRow({required bool isEditable}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CurrencyDropdown(
            currencies: widget.currencies,
            selectedCode: _selectedCurrency,
            onChanged: (value) {
              setState(() {
                _selectedCurrency = value;
                if (_isEditingGold) {
                  _calculateFromGold();
                } else {
                  _calculateFromCurrency();
                }
              });
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 3,
          child: isEditable
              ? TextField(
                  controller: _currencyController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    RegexSeparatorInputFormatter(
                      allowDecimal: true,
                      locale: _locale,
                    ),
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
                  onChanged: (value) {
                    if (!_isEditingGold) {
                      _calculateFromCurrency();
                    }
                  },
                  onTap: () {
                    _currencyController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _currencyController.text.length),
                    );
                  },
                )
              : Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background2(context),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    _currencyController.text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ConverterCard(
      title: l10n.metalConverter,
      child: Column(
        children: [
          // Top row (editable)
          _isEditingGold
              ? _buildGoldRow(isEditable: true)
              : _buildCurrencyRow(isEditable: true),

          SizedBox(height: 12.h),

          // Swap Button
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEditingGold = !_isEditingGold;

                  // When switching to gold input (from currency to gold)
                  // Handle integer-only gold types
                  if (_isEditingGold &&
                      !GoldInputHelper.allowsDecimal(_selectedGold)) {
                    final currentAmount = _parse(_goldController.text);
                    if (currentAmount != 0.0 &&
                        _goldController.text.contains('.')) {
                      // Round to nearest integer
                      final roundedAmount = currentAmount.round();
                      _goldController.text = roundedAmount.toString();

                      // Recalculate the currency value based on the rounded gold amount
                      _calculateFromGold();
                    }
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_vert,
                  size: 28.sp,
                  color: AppColors.warning,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Bottom row (read-only result)
          _isEditingGold
              ? _buildCurrencyRow(isEditable: false)
              : _buildGoldRow(isEditable: false),
        ],
      ),
    );
  }
}
