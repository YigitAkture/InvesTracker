import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/crypto_data.dart';
import 'package:inves_tracker/core/models/currency_data.dart';
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
  State<CryptoToCurrencySection> createState() => _CryptoToCurrencySectionState();
}

class _CryptoToCurrencySectionState extends State<CryptoToCurrencySection> {
  String _selectedCrypto = 'BTC';
  String _selectedCurrency = 'TRY';
  final TextEditingController _cryptoController = TextEditingController(text: '1');
  final TextEditingController _currencyController = TextEditingController();
  bool _isEditingCrypto = true;

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
    final amount = double.tryParse(_cryptoController.text) ?? 0.0;
    
    if (amount == 0.0) {
      _currencyController.text = '0.00';
      return;
    }

    // Get crypto price in TRY
    final cryptoRate = _getCryptoRate(_selectedCrypto);
    final currencyRate = _getCurrencyRate(_selectedCurrency);

    if (cryptoRate == null || currencyRate == null) {
      _currencyController.text = '0.00';
      return;
    }

    // Convert: amount in crypto -> TRY -> selected currency
    final amountInTRY = amount * cryptoRate;
    final convertedAmount = amountInTRY / currencyRate;

    _currencyController.text = convertedAmount.toStringAsFixed(2);
  }

  void _calculateFromCurrency() {
    final amount = double.tryParse(_currencyController.text) ?? 0.0;
    
    if (amount == 0.0) {
      _cryptoController.text = '0.00';
      return;
    }

    // Get crypto price in TRY
    final cryptoRate = _getCryptoRate(_selectedCrypto);
    final currencyRate = _getCurrencyRate(_selectedCurrency);

    if (cryptoRate == null || currencyRate == null) {
      _cryptoController.text = '0.00';
      return;
    }

    // Convert: amount in currency -> TRY -> crypto
    final amountInTRY = amount * currencyRate;
    final convertedAmount = amountInTRY / cryptoRate;

    _cryptoController.text = convertedAmount.toStringAsFixed(6);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ConverterCard(
      title: l10n.cryptoToCurrency,
      child: Column(
        children: [
          // Crypto Input
          Row(
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
                flex: 4,
                child: TextField(
                  controller: _cryptoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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
                  onTap: () {
                    setState(() => _isEditingCrypto = true);
                  },
                  onChanged: (value) {
                    if (_isEditingCrypto) {
                      _calculateFromCrypto();
                    }
                  },
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
                color: AppColors.pink.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.height,
                size: 28.sp,
                color: AppColors.pink,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Currency Input
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
                child: TextField(
                  controller: _currencyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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
                  onTap: () {
                    setState(() => _isEditingCrypto = false);
                  },
                  onChanged: (value) {
                    if (!_isEditingCrypto) {
                      _calculateFromCurrency();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}