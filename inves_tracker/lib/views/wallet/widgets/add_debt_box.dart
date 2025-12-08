import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/debt_service.dart';

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
  
  ExchangeType _selectedType = ExchangeType.currency;
  String? _selectedCode;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  final Map<ExchangeType, List<String>> _codesByType = {
    ExchangeType.currency: [
      'USD', 'EUR', 'GBP', 'CHF', 'CAD', 'JPY', 'SAR', 
      'RUB', 'AED', 'KWD', 'AUD', 'DKK', 'SEK', 'NOK'
    ],
    ExchangeType.gold: [
      'HAS', 'GRA', 'CEYREKALTIN', 'YARIMALTIN', 'TAMALTIN', 
      'ATAALTIN', 'RESATALTIN', 'CUMHURIYETALTINI', 'GREMSEALTIN',
      '14AYARALTIN', '18AYARALTIN', 'YIA', 'IKIBUCUKALTIN', 'BESLIALTIN'
    ],
    ExchangeType.crypto: [
      'BTC', 'ETH', 'USDT', 'XRP', 'BNB', 'SOL', 'USDC', 'ADA',
      'DOGE', 'TRX', 'SHIB', 'DOT', 'UNI', 'LTC', 'XMR', 'NEAR'
    ],
  };

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _getTypeName(ExchangeType type) {
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
    if (_selectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a code')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _debtService.createDebt(
        widget.userId,
        debtType: _getTypeName(_selectedType),
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
          const SnackBar(content: Text('Debt added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Check if error is about debt limit
        if (e.toString().contains('one debt record')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Subscription Required'),
              content: Text(
                'Free users can only have 1 debt. Please upgrade to Premium to add unlimited debts.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add debt: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Debt',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),

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
                          ? AppColors.danger.withValues(alpha: 0.15)
                          : AppColors.background2(context),
                      borderRadius: BorderRadius.circular(8.r),
                      border: isSelected
                          ? Border.all(color: AppColors.danger, width: 2)
                          : null,
                    ),
                    child: Text(
                      _getTypeName(type),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.danger : null,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 12.h),

          // Code Dropdown
          DropdownButtonFormField<String>(
            value: _selectedCode,
            decoration: InputDecoration(
              labelText: 'Select ${_getTypeName(_selectedType)}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              filled: true,
              fillColor: AppColors.background2(context),
            ),
            items: _codesByType[_selectedType]!.map((code) {
              return DropdownMenuItem(value: code, child: Text(code));
            }).toList(),
            onChanged: (value) => setState(() => _selectedCode = value),
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
              labelText: 'Amount',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              filled: true,
              fillColor: AppColors.background2(context),
            ),
          ),

          SizedBox(height: 12.h),

          // Note Input (Optional)
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Note (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              filled: true,
              fillColor: AppColors.background2(context),
            ),
          ),

          SizedBox(height: 12.h),

          // Due Date Selector (Optional)
          InkWell(
            onTap: _selectDueDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Due Date (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                filled: true,
                fillColor: AppColors.background2(context),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _selectedDueDate != null
                    ? _selectedDueDate!.toString().substring(0, 10)
                    : 'Select date',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _selectedDueDate != null ? null : Colors.grey,
                ),
              ),
            ),
          ),

          if (_selectedDueDate != null) ...[
            SizedBox(height: 8.h),
            TextButton.icon(
              onPressed: () => setState(() => _selectedDueDate = null),
              icon: Icon(Icons.clear, size: 16.sp),
              label: Text('Clear due date'),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            ),
          ],

          SizedBox(height: 16.h),

          // Add Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addDebt,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
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
                      'Add Debt',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}