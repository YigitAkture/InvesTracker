import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/debt.dart';
import 'package:inves_tracker/core/services/debt_service.dart';
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
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.debt.amount.toString();
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

  Future<void> _updateDebt() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterValidAmount), showCloseIcon: true),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _debtService.updateDebt(
        widget.debt.id,
        amount: amount,
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
    return AlertDialog(
      title: Text(l10n.editDebt),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.debt.debtCode,
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
            SizedBox(height: 12.h),
            
            // Note
            TextField(
              controller: _noteController,
              maxLines: 3,
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