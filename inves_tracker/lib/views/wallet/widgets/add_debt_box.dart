import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/helpers/gold_input_helper.dart';
import 'package:inves_tracker/core/services/debt_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/wallet/utils/crypto_dropdown.dart';
import 'package:inves_tracker/views/wallet/utils/currency_dropdown.dart';
import 'package:inves_tracker/views/wallet/utils/gold_dropdown.dart';

enum ExchangeType { currency, gold, crypto }

class AddDebtBox extends StatefulWidget {
  final String userId;
  final int currentDebtCount;
  final VoidCallback onDebtAdded;

  const AddDebtBox({
    super.key,
    required this.userId,
    required this.currentDebtCount,
    required this.onDebtAdded,
  });

  @override
  State<AddDebtBox> createState() => _AddDebtBoxState();
}

class _AddDebtBoxState extends State<AddDebtBox> {
  final DebtService _debtService = DebtService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  static const int _maxNoteLength = 56;

  ExchangeType _selectedType = ExchangeType.currency;
  String? _selectedCode;
  DateTime? _selectedDueDate;
  bool _isLoading = false;
  bool _isExpanded = true;

  final Map<ExchangeType, List<String>> _codesByType = {
    ExchangeType.currency: [
      'TRY', 'USD', 'EUR', 'GBP', 'CHF', 'CAD', 'RUB', 'AED', 'AUD', 'DKK', 'SEK', 
      'NOK', 'ISK', 'JPY', 'SGD', 'NZD', 'HKD', 'THB', 'PLN', 'CZK', 'HUF', 'RON', 
      'QAR', 'SAR', 'BHD', 'OMR', 'KWD', 'IQD', 'LYD', 'IRR', 'LKR', 'INR', 'PKR', 
      'IDR', 'MYR', 'PHP', 'MXN', 'BRL', 'ARS', 'CLP', 'COP', 'PEN', 'UYU', 'CRC', 
      'UAH', 'GEL', 'AZN', 'MKD', 'BGN', 'BAM', 'MDL', 'ALL', 'LBP', 'EGP', 'DZD', 
      'TND', 'SYP', 'KZT', 'CNY', 'TWD'
    ],
    ExchangeType.gold: [
      'HAS', 'GRA', 'CEYREKALTIN', 'YARIMALTIN', 'TAMALTIN',
      'ATAALTIN', 'RESATALTIN', 'CUMHURIYETALTINI', 'GREMSEALTIN',
      '14AYARALTIN', '18AYARALTIN', 'YIA', 'IKIBUCUKALTIN', 'BESLIALTIN'
    ],
    ExchangeType.crypto: [
      'BTC', 'ETH', 'USDT', 'XRP', 'BNB', 'SOL', 'USDC', 'STETH',
      'DOGE', 'TRX', 'ADA', 'SHIB', 'WSTETH', 'WBTC', 'HYPE', 'TON',
      'LINK', 'BCH', 'AVAX', 'XLM', 'SUI', 'DOT', 'UNI',
      'ZEC', 'LTC', 'XMR', 'CRO', 'NEAR', 'WETH', 'LEO',
      'MNT', 'PYUSD', 'USDS', 'USDE', 'CBBTC', 'WEETH',
      'SUSDE', 'SUSDS', 'TAO', 'WBETH', 'CC'
    ],
  };

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _getTypeName(ExchangeType type, AppLocalizations l10n) {
    switch (type) {
      case ExchangeType.currency:
        return l10n.currency;
      case ExchangeType.gold:
        return l10n.gold;
      case ExchangeType.crypto:
        return l10n.crypto;
    }
  }

  String _getTypeApiName(ExchangeType type) {
    switch (type) {
      case ExchangeType.currency:
        return 'Currency';
      case ExchangeType.gold:
        return 'Gold';
      case ExchangeType.crypto:
        return 'Crypto';
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _addDebt() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectEntity, style: TextStyle(color: Colors.black)), 
          showCloseIcon: true,
          closeIconColor: Colors.black,
          backgroundColor: AppColors.warning2,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterValidAmount, style: TextStyle(color: Colors.black)), 
          showCloseIcon: true,
          closeIconColor: Colors.black,
          backgroundColor: AppColors.warning2,
        ),
      );
      return;
    }

    // Additional validation for gold types
    if (_selectedType == ExchangeType.gold) {
      final validationError = GoldInputHelper.validateAmount(_selectedCode!, _amountController.text);
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError, style: TextStyle(color: Colors.black)), 
            showCloseIcon: true,
            closeIconColor: Colors.black,
            backgroundColor: AppColors.warning2,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      await _debtService.createDebt(
        widget.userId,
        debtType: _getTypeApiName(_selectedType),
        debtCode: _selectedCode!,
        amount: amount,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        dueDate: _selectedDueDate,
      );

      if (mounted) {
        _amountController.clear();
        _noteController.clear();
        setState(() {
          _selectedCode = null;
          _selectedDueDate = null;
          _isLoading = false;
        });
        widget.onDebtAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.debtAdded, style: TextStyle(color: Colors.black)), 
            showCloseIcon: true,
            backgroundColor: AppColors.success2,
            closeIconColor: Colors.black,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        if (e.toString().contains('one debt record')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.subscriptionRequired),
              content: Text(l10n.freeUsersCanOnlyHaveOneDebt),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add debt: $e', style: TextStyle(color: Colors.white)), 
              showCloseIcon: true,
              backgroundColor: AppColors.danger3,
              closeIconColor: Colors.white,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.addDebt,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            Divider(height: 1, color: AppColors.background2(context)),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: ExchangeType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = type;
                              _selectedCode = null;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.secondary(context).withValues(alpha: 0.15)
                                  : AppColors.background2(context),
                              borderRadius: BorderRadius.circular(8.r),
                              border: isSelected
                                  ? Border.all(color: AppColors.secondary(context), width: 2)
                                  : null,
                            ),
                            child: Text(
                              _getTypeName(type, l10n),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.w500,
                                color:
                                    isSelected ? AppColors.secondary(context) : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 12.h),

                  Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: AppColors.background2(context),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCode,
                      alignment: Alignment.centerLeft,
                      dropdownColor: AppColors.background2(context),
                      menuMaxHeight: 450.h,
                      borderRadius: BorderRadius.circular(12.r),
                      items: _codesByType[_selectedType]!.map((code) {
                        return DropdownMenuItem<String>(
                          value: code,
                          child: IntrinsicWidth(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_selectedType == ExchangeType.currency)
                                  CurrencyDropdown(code: code)
                                else if (_selectedType == ExchangeType.gold)
                                  GoldDropdown(code: code)
                                else
                                  CryptoDropdown(code: code),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: _getTypeName(_selectedType, l10n),
                        filled: true,
                        fillColor: AppColors.background2(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onChanged: (value) => setState(() => _selectedCode = value),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  TextField(
                    controller: _amountController,
                    // Dynamic keyboard type based on selected type and code
                    keyboardType: _selectedType == ExchangeType.gold && _selectedCode != null
                        ? GoldInputHelper.getKeyboardType(_selectedCode!)
                        : const TextInputType.numberWithOptions(decimal: true),
                    // Dynamic input formatters based on selected type and code
                    inputFormatters: _selectedType == ExchangeType.gold && _selectedCode != null
                        ? GoldInputHelper.getInputFormatters(_selectedCode!)
                        : [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                    decoration: InputDecoration(
                      labelText: l10n.amount,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      filled: true,
                      fillColor: AppColors.background2(context),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    maxLength: _maxNoteLength,
                    buildCounter: (
                      BuildContext context, {
                      required int currentLength,
                      required int? maxLength,
                      required bool isFocused,
                    }) {
                      return Text(
                        "$currentLength/$maxLength",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: currentLength >= _maxNoteLength
                              ? AppColors.danger
                              : AppColors.title(context),
                        ),
                      );
                    },
                    decoration: InputDecoration(
                      labelText: l10n.noteOptional,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      filled: true,
                      fillColor: AppColors.background2(context),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  InkWell(
                    onTap: _selectDueDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.dueDateOptional,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        filled: true,
                        fillColor: AppColors.background2(context),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDueDate != null
                            ? _dateFormat.format(_selectedDueDate!)
                            : l10n.selectDate,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color:
                              _selectedDueDate != null ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  if (_selectedDueDate != null) ...[
                    SizedBox(height: 8.h),
                    TextButton.icon(
                      onPressed: () => setState(() => _selectedDueDate = null),
                      icon: Icon(Icons.clear, size: 16.sp),
                      label: Text(l10n.clearDueDate),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondary(context),
                      ),
                    ),
                  ],

                  SizedBox(height: 16.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addDebt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary(context),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.addDebt,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
