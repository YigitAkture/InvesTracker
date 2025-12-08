import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/debt.dart';
import 'package:inves_tracker/core/services/debt_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/wallet/widgets/debt_accordion_item.dart';
import 'package:inves_tracker/views/wallet/widgets/add_debt_box.dart';

class DebtsTab extends StatefulWidget {
  final String userId;

  const DebtsTab({super.key, required this.userId});

  @override
  State<DebtsTab> createState() => _DebtsTabState();
}

class _DebtsTabState extends State<DebtsTab> {
  final DebtService _debtService = DebtService();
  List<Debt> _debts = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final debts = await _debtService.getUserDebts(widget.userId);
      setState(() {
        _debts = debts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Map<String, List<Debt>> _groupDebtsByCode() {
    final Map<String, List<Debt>> grouped = {};
    for (var debt in _debts) {
      if (!grouped.containsKey(debt.debtCode)) {
        grouped[debt.debtCode] = [];
      }
      grouped[debt.debtCode]!.add(debt);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary(context)),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.danger),
            SizedBox(height: 12.h),
            Text(
              l10n.anErrorOccurred,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadDebts,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    final groupedDebts = _groupDebtsByCode();

    return RefreshIndicator(
      onRefresh: _loadDebts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Accordion Items
            if (groupedDebts.isEmpty)
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Text(
                  'No debts yet',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.title(context),
                  ),
                ),
              )
            else
              ...groupedDebts.entries.map((entry) {
                return DebtAccordionItem(
                  debtCode: entry.key,
                  debts: entry.value,
                  onRefresh: _loadDebts,
                );
              }),

            SizedBox(height: 16.h),

            // Add Debt Box
            AddDebtBox(
              userId: widget.userId,
              currentDebtCount: _debts.length,
              onDebtAdded: _loadDebts,
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}