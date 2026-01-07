import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/debt.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';

class DebtInfoDialog extends StatelessWidget {
  final List<Debt> debts;

  const DebtInfoDialog({super.key, required this.debts});

  /// Sort debts by priority:
  /// 1. Debts with due dates (nearest first)
  /// 2. Debts without due dates (oldest created first)
  List<Debt> _getSortedDebts() {
    final sortedDebts = List<Debt>.from(debts);
    
    sortedDebts.sort((a, b) {
      // Both have due dates - sort by nearest due date first
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      
      // Only 'a' has due date - 'a' comes first
      if (a.dueDate != null && b.dueDate == null) {
        return -1;
      }
      
      // Only 'b' has due date - 'b' comes first
      if (a.dueDate == null && b.dueDate != null) {
        return 1;
      }
      
      // Neither has due date - sort by creation date (oldest first)
      return a.createdAt.compareTo(b.createdAt);
    });
    
    return sortedDebts;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sortedDebts = _getSortedDebts();
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
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
                color: AppColors.primary(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.debtDetails} - ${debts.first.debtCode}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
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

            // Content - Using sorted debts
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
                  return _DebtInfoItem(debt: debt, index: index);
                },
              ),
            ),

            // Footer - Total
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.background2(context),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
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
                    debts.fold(0.0, (sum, d) => sum + d.amount).toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtInfoItem extends StatelessWidget {
  final Debt debt;
  final int index;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  _DebtInfoItem({required this.debt, required this.index});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.background2(context),
          width: 1,
        ),
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
                debt.amount.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Note
          if (debt.note != null && debt.note!.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.note_outlined,
              label: l10n.note,
              value: debt.note!,
            ),
            SizedBox(height: 8.h),
          ],

          // Due Date
          if (debt.dueDate != null) ...[
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: l10n.dueDate,
              value: _dateFormat.format(debt.dueDate!).toString().substring(0, 10),
              valueColor: debt.dueDate!.isBefore(DateTime.now())
                  ? AppColors.danger2
                  : AppColors.warning2,
            ),
            SizedBox(height: 8.h),
          ],

          // Created Date
          _InfoRow(
            icon: Icons.access_time,
            label: l10n.created,
            value: _dateFormat.format(debt.createdAt).toString().substring(0, 10),
          ),
        ],
      ),
    );
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
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: AppColors.title(context),
        ),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.title(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}