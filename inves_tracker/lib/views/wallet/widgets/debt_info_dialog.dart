// inves_tracker/lib/views/wallet/widgets/debt_info_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/helpers/gold_input_helper.dart';
import 'package:inves_tracker/core/helpers/locale_helper.dart';
import 'package:inves_tracker/core/helpers/wallet_localization_helper.dart';
import 'package:inves_tracker/core/models/debt.dart';
import 'package:inves_tracker/core/utils/price_formatter.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';

class DebtInfoDialog extends StatelessWidget {
  final List<Debt> debts;
  final double? currentTryValue; // Current TRY value per unit

  const DebtInfoDialog({
    super.key,
    required this.debts,
    this.currentTryValue,
  });

  List<Debt> _getSortedDebts() {
    final sortedDebts = List<Debt>.from(debts);

    sortedDebts.sort((a, b) {
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null && b.dueDate == null) {
        return -1;
      }
      if (a.dueDate == null && b.dueDate != null) {
        return 1;
      }
      return a.createdAt.compareTo(b.createdAt);
    });

    return sortedDebts;
  }

  double get _totalAmount {
    return debts.fold(0.0, (sum, d) => sum + d.amount);
  }

  double? get _totalInitialValue {
    // Sum of all initial values (if available)
    final validInitialValues = debts
        .where((d) => d.initialTryValue != null)
        .map((d) => d.initialTryValue!)
        .toList();
    
    if (validInitialValues.isEmpty) return null;
    return validInitialValues.reduce((a, b) => a + b);
  }

  double? get _totalCurrentValue {
    if (currentTryValue == null) return null;
    return _totalAmount * currentTryValue!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sortedDebts = _getSortedDebts();

    // Calculate profit/loss
    final profitLoss = _totalInitialValue != null && _totalCurrentValue != null
        ? _totalCurrentValue! - _totalInitialValue!
        : null;

    final isIncreased = profitLoss != null && profitLoss > 0;
    final isZero = profitLoss != null && profitLoss == 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.secondary(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.debtDetails} - ${WalletLocalizationHelper.getLocalizedName(context, debts.first.debtCode, debts.first.debtType)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 24.sp),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.all(16.r),
                itemCount: sortedDebts.length,
                separatorBuilder: (context, index) => Divider(
                  height: 24.h,
                  color: AppColors.background2(context),
                ),
                itemBuilder: (context, index) {
                  final debt = sortedDebts[index];
                  return _DebtInfoItem(
                    debt: debt,
                    index: index,
                    currentTryValue: currentTryValue,
                  );
                },
              ),
            ),

            // Footer - Total + Profit/Loss
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.background2(context),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Column(
                children: [
                  // Total Debt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.totalDebt}:',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        debts.first.debtType.toLowerCase() == 'gold'
                            ? _formatGoldTotal(context, l10n)
                            : '${PriceFormatter.formatCurrency(_totalAmount, context.localeString)} ${debts.first.debtCode}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),

                  // Value Change (if available)
                  if (profitLoss != null) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isZero 
                        ? AppColors.title(context).withValues(alpha: 0.1) 
                        : isIncreased 
                            ? AppColors.danger.withValues(alpha: 0.1)
                            : AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isZero 
                                ? Icons.trending_flat 
                                : isIncreased 
                                  ? Icons.trending_up 
                                  : Icons.trending_down,
                                color: isZero 
                                ? AppColors.title(context) 
                                : isIncreased 
                                  ? AppColors.danger 
                                  : AppColors.success,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text( 
                                isZero
                                ? l10n.debtNotChanged
                                : isIncreased 
                                  ? l10n.debtIncreased 
                                  : l10n.debtDecreased,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isZero 
                                  ? AppColors.title(context) 
                                  : isIncreased 
                                    ? AppColors.danger 
                                    : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(isIncreased ? '+' : '')}${PriceFormatter.formatCurrency(profitLoss, context.localeString)} TRY',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: isZero 
                                ? AppColors.title(context) 
                                : isIncreased 
                                  ? AppColors.danger 
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatGoldTotal(BuildContext context, AppLocalizations l10n) {
    final totalAmount = _totalAmount;
    final formattedAmount = GoldInputHelper.formatAmount(
      debts.first.debtCode,
      totalAmount,
    );
    final isDecimalType = GoldInputHelper.allowsDecimal(debts.first.debtCode);
    final unit = isDecimalType
        ? (totalAmount == 1 ? l10n.gram : l10n.grams)
        : (totalAmount == 1 ? l10n.piece : l10n.pieces);
    return '$formattedAmount $unit';
  }
}

class _DebtInfoItem extends StatelessWidget {
  final Debt debt;
  final int index;
  final double? currentTryValue;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  _DebtInfoItem({
    required this.debt,
    required this.index,
    this.currentTryValue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Calculate current value
    final currentValue = currentTryValue != null 
        ? debt.amount * currentTryValue! 
        : null;

    // Calculate change
    final valueChange = debt.initialTryValue != null && currentValue != null
        ? currentValue - debt.initialTryValue!
        : null;

    final isIncreased = valueChange != null && valueChange > 0;
    final isZero = valueChange != null && valueChange == 0;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.background2(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with index
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${l10n.debt[0].toUpperCase()}${l10n.debt.substring(1).toLowerCase()} #${index + 1}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary(context),
                  ),
                ),
              ),
              Text(
                _formatAmount(context, l10n),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Created Date
          _InfoRow(
            icon: Icons.access_time,
            label: l10n.created,
            value: _dateFormat.format(debt.createdAt),
          ),

          // Updated Date (if exists)
          if (debt.updatedAt != null) ...[
            SizedBox(height: 8.h),
            _InfoRow(
              icon: Icons.update,
              label: l10n.lastUpdated,
              value: _dateFormat.format(debt.updatedAt!),
            ),
          ],

          SizedBox(height: 8.h),

          // Initial Value
          if (debt.initialTryValue != null)
            _InfoRow(
              icon: Icons.monetization_on_outlined,
              label: debt.updatedAt != null ? l10n.valueAtUpdate : l10n.initialValue,
              value: '${PriceFormatter.formatCurrency(debt.initialTryValue!, context.localeString)} TRY',
            ),

          if (debt.initialTryValue == null)
            _InfoRow(
              icon: Icons.info_outline,
              label: debt.updatedAt != null ? l10n.valueAtUpdate : l10n.initialValue,
              value: l10n.notAvailable,
              valueColor: AppColors.title(context).withValues(alpha: 0.6),
            ),

          SizedBox(height: 8.h),

          // Current Value
          if (currentValue != null)
            _InfoRow(
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.currentValue,
              value: '${PriceFormatter.formatCurrency(currentValue, context.localeString)} TRY',
              valueColor: AppColors.danger,
            ),

          if (currentValue == null)
            _InfoRow(
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.currentValue,
              value: l10n.notAvailable,
              valueColor: AppColors.title(context).withValues(alpha: 0.6),
            ),

          // Value Change
          if (valueChange != null) ...[
            SizedBox(height: 8.h),
            _InfoRow(
              icon: isZero 
              ? Icons.trending_flat
              : isIncreased 
                ? Icons.trending_up 
                : Icons.trending_down,
              label: l10n.change,
              value: '${isIncreased ? '+' : ''}${PriceFormatter.formatCurrency(valueChange, context.localeString)} TRY',
              valueColor: isZero 
                ? AppColors.title(context) 
                : isIncreased 
                  ? AppColors.danger 
                  : AppColors.success,
            ),
          ],

          // Note
          if (debt.note != null && debt.note!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _InfoRow(
              icon: Icons.note_outlined,
              label: l10n.note,
              value: debt.note!,
            ),
          ],

          // Due Date
          if (debt.dueDate != null) ...[
            SizedBox(height: 8.h),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: l10n.dueDate,
              value: _dateFormat.format(debt.dueDate!),
              valueColor: debt.dueDate!.isBefore(DateTime.now())
                  ? AppColors.danger2
                  : AppColors.warning2,
            ),
          ],
        ],
      ),
    );
  }

  String _formatAmount(BuildContext context, AppLocalizations l10n) {
    final debtType = debt.debtType.toLowerCase();
    final debtCode = debt.debtCode;
    final amount = debt.amount;
    
    if (debtType == 'gold') {
      final formattedAmount = GoldInputHelper.formatAmount(debtCode, amount);
      final isDecimalType = GoldInputHelper.allowsDecimal(debtCode);
      final unit = isDecimalType 
          ? (amount == 1 ? l10n.gram : l10n.grams)
          : (amount == 1 ? l10n.piece : l10n.pieces);
      return '$formattedAmount $unit';
    } else {
      return '${PriceFormatter.formatCurrency(amount, context.localeString)} $debtCode';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: AppColors.title(context)),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.title(context),
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}