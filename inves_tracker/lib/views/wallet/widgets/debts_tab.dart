import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/debt.dart';
import 'package:inves_tracker/core/services/debt_service.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/core/models/market_response.dart';
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
  final MarketService _marketService = MarketService();
  List<Debt> _debts = [];
  MarketResponse? _marketData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final debtsResult = await _debtService.getUserDebts(widget.userId);
      final marketResult = await _marketService.fetchMarketData();
      
      setState(() {
        _debts = debtsResult;
        _marketData = marketResult;
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

  double? _getTryValue(String debtCode, String debtType) {
    if (_marketData == null) return null;

    switch (debtType.toLowerCase()) {
      case 'currency':
        if (debtCode == 'TRY') return 1.0;
        final currency = _marketData!.currencies.firstWhere(
          (c) => c.code == debtCode,
          orElse: () => _marketData!.currencies.first,
        );
        return currency.buying;
      
      case 'gold':
        final gold = _marketData!.golds.firstWhere(
          (g) => g.code == debtCode,
          orElse: () => _marketData!.golds.first,
        );
        return gold.selling;
      
      case 'crypto':
        final crypto = _marketData!.cryptos.firstWhere(
          (c) => c.code == debtCode,
          orElse: () => _marketData!.cryptos.first,
        );
        return crypto.tryPrice;
      
      default:
        return null;
    }
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
              onPressed: _loadData,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    final groupedDebts = _groupDebtsByCode();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Add Debt Box
            AddDebtBox(
              userId: widget.userId,
              currentDebtCount: _debts.length,
              onDebtAdded: _loadData,
            ),

            SizedBox(height: 24.h),

            // Accordion Items
            if (groupedDebts.isEmpty)
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Text(
                  l10n.noDebtsYet,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.title(context),
                  ),
                ),
              )
            else
              ...groupedDebts.entries.map((entry) {
                final debtType = entry.value.first.debtType;
                final tryValue = _getTryValue(entry.key, debtType);
                
                return DebtAccordionItem(
                  debtCode: entry.key,
                  debtType: debtType,
                  debts: entry.value,
                  tryValue: tryValue,
                  onRefresh: _loadData,
                );
              }),
          ],
        ),
      ),
    );
  }
}