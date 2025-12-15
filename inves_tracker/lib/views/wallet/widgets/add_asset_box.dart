import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/asset_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/wallet/utils/crypto_dropdown.dart';
import 'package:inves_tracker/views/wallet/utils/currency_dropdown.dart';
import 'package:inves_tracker/views/wallet/utils/gold_dropdown.dart';

enum ExchangeType { currency, gold, crypto }

class AddAssetBox extends StatefulWidget {
  final String userId;
  final VoidCallback onAssetAdded;

  const AddAssetBox({
    super.key,
    required this.userId,
    required this.onAssetAdded,
  });

  @override
  State<AddAssetBox> createState() => _AddAssetBoxState();
}

class _AddAssetBoxState extends State<AddAssetBox> {
  final AssetService _assetService = AssetService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();
  
  ExchangeType _selectedType = ExchangeType.currency;
  String? _selectedCode;
  bool _isLoading = false;
  bool _isExpanded = true;

  // Define available codes for each type
  final Map<ExchangeType, List<String>> _codesByType = {
    ExchangeType.currency: [
      'TRY', 'USD', 'EUR', 'GBP', 'CHF', 'CAD', 'JPY', 'SAR', 
      'RUB', 'AED', 'KWD', 'AUD', 'DKK', 'SEK', 'NOK'
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
    _purchasePriceController.dispose();
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

  Future<void> _addAsset() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectCode), showCloseIcon: true),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterValidAmount), showCloseIcon: true),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _assetService.createAsset(
        widget.userId,
        assetType: _getTypeApiName(_selectedType),
        assetCode: _selectedCode!,
        amount: amount,
      );

      if (mounted) {
        _amountController.clear();
        _purchasePriceController.clear();
        setState(() {
          _selectedCode = null;
          _isLoading = false;
        });
        widget.onAssetAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.assetAdded), showCloseIcon: true),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToAddAsset}: $e'), showCloseIcon: true),
        );
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
          // Header Row (Always Visible)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.addAsset,
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

          // Collapsible Content
          if (_isExpanded) ...[
            Divider(height: 1, color: AppColors.background2(context)),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exchange Type Selector
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
                                  ? AppColors.primary(context).withValues(alpha: 0.15)
                                  : AppColors.background2(context),
                              borderRadius: BorderRadius.circular(8.r),
                              border: isSelected
                                  ? Border.all(color: AppColors.primary(context), width: 2)
                                  : null,
                            ),
                            child: Text(
                              _getTypeName(type, l10n),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? AppColors.primary(context) : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 12.h),

                  // Code Dropdown
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

                  // Amount Input
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
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

                  SizedBox(height: 16.h),

                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addAsset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
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
                              l10n.addAsset,
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
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