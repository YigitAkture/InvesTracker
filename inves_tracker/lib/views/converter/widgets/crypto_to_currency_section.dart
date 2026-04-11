import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/crypto_data.dart';
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/utils/price_formatter.dart';
import 'package:inves_tracker/core/utils/regex_separator_input_formatter.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/converter/widgets/converter_card.dart';
import 'package:inves_tracker/views/converter/widgets/crypto_dropdown.dart';
import 'package:inves_tracker/views/converter/widgets/currency_dropdown.dart';

class CryptoToCurrencySection extends StatefulWidget {
  final List<CryptoData> cryptos;
  final List<CurrencyData> currencies;

  const CryptoToCurrencySection({
    super.key,
    required this.cryptos,
    required this.currencies,
  });

  @override
  State<CryptoToCurrencySection> createState() =>
      _CryptoToCurrencySectionState();
}

class _CryptoToCurrencySectionState extends State<CryptoToCurrencySection> {
  String _selectedCrypto = 'BTC';
  String _selectedCurrency = 'TRY';
  final TextEditingController _cryptoController = TextEditingController(text: '1');
  final TextEditingController _currencyController = TextEditingController();
  bool _isEditingCrypto = true;

  double _parse(String text) =>
      double.tryParse(text.replaceAll(',', '')) ?? 0.0;

  @override
  void initState() {
    super.initState();
    _calculateFromCrypto();
  }

  @override
  void dispose() {
    _cryptoController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _calculateFromCrypto() {
    final amount = _parse(_cryptoController.text);

    if (amount == 0.0) {
      setState(() => _currencyController.text = '0.00');
      return;
    }

    final cryptoRate = _getCryptoRate(_selectedCrypto);
    final currencyRate = _getCurrencyRate(_selectedCurrency);

    if (cryptoRate == null || currencyRate == null) {
      setState(() => _currencyController.text = '0.00');
      return;
    }

    final amountInTRY = amount * cryptoRate;
    final convertedAmount = amountInTRY / currencyRate;

    setState(() {
      _currencyController.text = PriceFormatter.formatCurrency(convertedAmount);
    });
  }

  void _calculateFromCurrency() {
    final amount = _parse(_currencyController.text);

    if (amount == 0.0) {
      setState(() => _cryptoController.text = '0.00');
      return;
    }

    final cryptoRate = _getCryptoRate(_selectedCrypto);
    final currencyRate = _getCurrencyRate(_selectedCurrency);

    if (cryptoRate == null || currencyRate == null) {
      setState(() => _cryptoController.text = '0.00');
      return;
    }

    final amountInTRY = amount * currencyRate;
    final convertedAmount = amountInTRY / cryptoRate;

    setState(() {
      // Crypto results need more decimal places for precision
      _cryptoController.text = PriceFormatter.formatNumber(convertedAmount, 6);
    });
  }

  double? _getCryptoRate(String code) {
    final crypto = widget.cryptos.firstWhere(
      (c) => c.code == code,
      orElse: () => widget.cryptos.first,
    );
    return crypto.tryPrice;
  }

  double? _getCurrencyRate(String code) {
    if (code == 'TRY') return 1.0;
    final currency = widget.currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => widget.currencies.first,
    );
    return currency.buying;
  }

  Widget _buildCryptoRow({required bool isEditable}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CryptoDropdown(
            cryptos: widget.cryptos,
            selectedCode: _selectedCrypto,
            onChanged: (value) {
              setState(() {
                _selectedCrypto = value;
                if (_isEditingCrypto) {
                  _calculateFromCrypto();
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
                  controller: _cryptoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    RegexSeparatorInputFormatter(allowDecimal: true),
                  ],
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
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
                  onChanged: (_) {
                    if (_isEditingCrypto) _calculateFromCrypto();
                  },
                  onTap: () {
                    _cryptoController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _cryptoController.text.length),
                    );
                  },
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.background2(context),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    _cryptoController.text,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
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
                if (_isEditingCrypto) {
                  _calculateFromCrypto();
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    RegexSeparatorInputFormatter(allowDecimal: true),
                  ],
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
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
                  onChanged: (_) {
                    if (!_isEditingCrypto) _calculateFromCurrency();
                  },
                  onTap: () {
                    _currencyController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _currencyController.text.length),
                    );
                  },
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.background2(context),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    _currencyController.text,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
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
      title: l10n.cryptoConverter,
      child: Column(
        children: [
          _isEditingCrypto
              ? _buildCryptoRow(isEditable: true)
              : _buildCurrencyRow(isEditable: true),

          SizedBox(height: 12.h),

          Center(
            child: GestureDetector(
              onTap: () {
                setState(() => _isEditingCrypto = !_isEditingCrypto);
              },
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.pink.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.swap_vert, size: 28.sp, color: AppColors.pink),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          _isEditingCrypto
              ? _buildCurrencyRow(isEditable: false)
              : _buildCryptoRow(isEditable: false),
        ],
      ),
    );
  }
}