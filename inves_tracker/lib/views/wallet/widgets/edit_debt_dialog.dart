import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/helpers/gold_input_helper.dart';
import 'package:inves_tracker/core/helpers/wallet_localization_helper.dart';
import 'package:inves_tracker/core/models/debt.dart';
import 'package:inves_tracker/core/services/debt_service.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';

class EditDebtDialog extends StatefulWidget {
  final Debt debt;

  const EditDebtDialog({super.key, required this.debt});

  @override
  State<EditDebtDialog> createState() => _EditDebtDialogState();
}

class _EditDebtDialogState extends State<EditDebtDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final DebtService _debtService = DebtService();
  final MarketService _marketService = MarketService();
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  static const int _maxNoteLength = 56;

  @override
  void initState() {
    super.initState();
    // Format the initial value based on debt type
    if (widget.debt.debtType.toLowerCase() == 'gold') {
      _amountController.text = GoldInputHelper.formatAmount(
        widget.debt.debtCode,
        widget.debt.amount,
      );
    } else {
      _amountController.text = widget.debt.amount.toString();
    }
    _noteController.text = widget.debt.note ?? '';
    _selectedDueDate = widget.debt.dueDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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

  /// Calculate currentTryValue = tryValue * amount
  Future<double?> _calculateCurrentTryValue(double amount) async {
    try {
      final marketData = await _marketService.fetchMarketData();
      final debtType = widget.debt.debtType.toLowerCase();
      final debtCode = widget.debt.debtCode;
      
      switch (debtType) {
        case 'currency':
          if (debtCode == 'TRY') return amount * 1.0;
          final currency = marketData.currencies.firstWhere(
            (c) => c.code == debtCode,
            orElse: () => throw Exception('Currency not found'),
          );
          return amount * currency.buying;
        
        case 'gold':
          final gold = marketData.golds.firstWhere(
            (g) => g.code == debtCode,
            orElse: () => throw Exception('Gold not found'),
          );
          return amount * gold.selling;
        
        case 'crypto':
          final crypto = marketData.cryptos.firstWhere(
            (c) => c.code == debtCode,
            orElse: () => throw Exception('Crypto not found'),
          );
          return amount * crypto.tryPrice;
        
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateDebt() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterValidAmount), showCloseIcon: true),
      );
      return;
    }

    // Additional validation for gold types
    if (widget.debt.debtType.toLowerCase() == 'gold') {
      final validationError = GoldInputHelper.validateAmount(
        widget.debt.debtCode,
        _amountController.text,
      );
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
      // Calculate currentTryValue = tryValue * amount
      final currentTryValue = await _calculateCurrentTryValue(amount);

      if (currentTryValue == null) {
        throw Exception('Failed to calculate current TRY value');
      }

      await _debtService.updateDebt(
        widget.debt.id,
        amount: amount,
        currentTryValue: currentTryValue, // Send calculated value
        note: _noteController.text.isEmpty ? null : _noteController.text,
        dueDate: _selectedDueDate,
      );
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.debtUpdated, style: TextStyle(color: Colors.black)), 
            showCloseIcon: true,
            backgroundColor: AppColors.success2,
            closeIconColor: Colors.black,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToUpdateDebt}: $e', style: TextStyle(color: Colors.black)), 
            showCloseIcon: true,
            backgroundColor: AppColors.danger3,
            closeIconColor: Colors.black,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isGold = widget.debt.debtType.toLowerCase() == 'gold';
    
    return AlertDialog(
      title: Text(l10n.editDebt),
      content: SizedBox(
        width: double.maxFinite,
        height: 350.h,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                WalletLocalizationHelper.getLocalizedName(
                  context,
                  widget.debt.debtCode,
                  widget.debt.debtType,
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.danger,
                ),
              ),
              SizedBox(height: 16.h),
              
              // Amount
              TextField(
                controller: _amountController,
                // Dynamic keyboard type and formatters for gold
                keyboardType: isGold
                    ? GoldInputHelper.getKeyboardType(widget.debt.debtCode)
                    : const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: isGold
                    ? GoldInputHelper.getInputFormatters(widget.debt.debtCode)
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
              
              // Note
              TextField(
                controller: _noteController,
                maxLines: 3,
                maxLength: _maxNoteLength,
                buildCounter: (BuildContext context, {
                  required int currentLength,
                  required int? maxLength,
                  required bool isFocused,
                }) {
                  return Text(
                    '$currentLength/$maxLength',
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
              
              // Due Date
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
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDueDate != null
                        ? _selectedDueDate!.toString().substring(0, 10)
                        : l10n.selectDate,
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
                  label: Text(l10n.clearDueDate),
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateDebt,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(context),
            foregroundColor: Colors.white,
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
              : Text(l10n.update),
        ),
      ],
    );
  }
}