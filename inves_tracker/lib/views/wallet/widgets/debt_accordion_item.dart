import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/debt.dart';
import 'package:inves_tracker/core/services/debt_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/wallet/widgets/edit_debt_dialog.dart';
import 'package:inves_tracker/views/wallet/widgets/debt_info_dialog.dart';

class DebtAccordionItem extends StatefulWidget {
  final String debtCode;
  final String debtType;
  final List<Debt> debts;
  final double? tryValue; // TRY value per unit
  final VoidCallback onRefresh;

  const DebtAccordionItem({
    super.key,
    required this.debtCode,
    required this.debtType,
    required this.debts,
    this.tryValue,
    required this.onRefresh,
  });

  @override
  State<DebtAccordionItem> createState() => _DebtAccordionItemState();
}

class _DebtAccordionItemState extends State<DebtAccordionItem> {
  bool _isExpanded = false;
  final DebtService _debtService = DebtService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  double get _totalAmount {
    return widget.debts.fold(0.0, (sum, debt) => sum + debt.amount);
  }

  double? get _totalTryValue {
    if (widget.tryValue == null) return null;
    return _totalAmount * widget.tryValue!;
  }

  Future<void> _deleteDebt(Debt debt) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDebt),
        content: Text(l10n.confirmDeleteDebt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary(context)),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _debtService.deleteDebt(debt.id);
        widget.onRefresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.debtDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.failedToDeleteDebt)),
          );
        }
      }
    }
  }

  Future<void> _editDebt(Debt debt) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditDebtDialog(debt: debt),
    );

    if (result == true) {
      widget.onRefresh();
    }
  }

  void _showDebtInfo() {
    showDialog(
      context: context,
      builder: (context) => DebtInfoDialog(debts: widget.debts),
    );
  }

  Widget _buildIcon() {
    switch (widget.debtType.toLowerCase()) {
      case 'currency':
        return ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Image.asset(
            'assets/img/flags/${widget.debtCode.toLowerCase()}.png',
            width: 40.w,
            height: 40.h,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.secondary(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(
                  Icons.currency_exchange,
                  size: 20.sp,
                  color: AppColors.secondary(context),
                ),
              );
            },
          ),
        );
      case 'crypto':
        return ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Image.asset(
            'assets/img/cryptos/${widget.debtCode.toLowerCase()}.png',
            width: 40.w,
            height: 40.h,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.secondary(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.currency_bitcoin,
                  size: 20.sp,
                  color: AppColors.secondary(context),
                ),
              );
            },
          ),
        );
      case 'gold':
      default:
        return Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.monetization_on,
            size: 24.sp,
            color: AppColors.warning,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                children: [
                  // Debt Icon
                  _buildIcon(),
                  SizedBox(width: 12.w),
                  
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.debtCode,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${_totalAmount.toStringAsFixed(2)} ${widget.debtCode} (${widget.debts.length} ${l10n.debt}${l10n.english == 'English' && widget.debts.length > 1 ? 's' : ''})',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.title(context),
                          ),
                        ),
                        if (_totalTryValue != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            '≈ ${_totalTryValue!.toStringAsFixed(2)} TRY',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.secondary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Info Button
                  IconButton(
                    onPressed: _showDebtInfo,
                    icon: Icon(Icons.info_outline, size: 20.sp),
                    color: AppColors.primary(context),
                  ),
                  
                  // Expand Icon
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isExpanded)
            ...widget.debts.map((debt) {
              final debtTryValue = widget.tryValue != null 
                  ? debt.amount * widget.tryValue! 
                  : null;
              
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.background2(context),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.amount}: ${debt.amount.toStringAsFixed(2)} ${widget.debtCode}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          if (debtTryValue != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              '≈ ${debtTryValue.toStringAsFixed(2)} TRY',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (debt.note != null && debt.note!.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              '${l10n.note}: ${debt.note}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.title(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (debt.dueDate != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              '${l10n.dueDate}: ${_dateFormat.format(debt.dueDate!)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Edit Button
                    IconButton(
                      onPressed: () => _editDebt(debt),
                      icon: Icon(Icons.edit, size: 20.sp),
                      color: AppColors.primary(context),
                    ),
                    
                    // Delete Button
                    IconButton(
                      onPressed: () => _deleteDebt(debt),
                      icon: Icon(Icons.delete, size: 20.sp),
                      color: AppColors.secondary(context),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}