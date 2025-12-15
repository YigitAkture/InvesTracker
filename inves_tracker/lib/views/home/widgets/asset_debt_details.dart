import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/helpers/wallet_localization_helper.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/home/models/portfolio_data.dart';

class AssetDebtDetails extends StatefulWidget {
  final PortfolioData portfolioData;

  const AssetDebtDetails({
    super.key,
    required this.portfolioData,
  });

  @override
  State<AssetDebtDetails> createState() => _AssetDebtDetailsState();
}

class _AssetDebtDetailsState extends State<AssetDebtDetails> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
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
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    color: AppColors.primary(context),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      l10n.portfolioBreakdown,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          if (_isExpanded) ...[
            Divider(height: 1, color: AppColors.background2(context)),
            
            if (widget.portfolioData.items.isEmpty)
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Text(
                  l10n.noAssetsOrDebtsYet,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.title(context),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                itemCount: widget.portfolioData.items.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  return _AssetDebtRow(
                    item: widget.portfolioData.items[index],
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}

class _AssetDebtRow extends StatelessWidget {
  final AssetDebtItem item;

  const _AssetDebtRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and name
          Row(
            children: [
              _buildIcon(context),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  WalletLocalizationHelper.getLocalizedName(
                    context,
                    item.code,
                    item.type,
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Bars
          if (item.hasAsset)
            _BarRow(
              label: l10n.asset[0].toUpperCase() + l10n.asset.substring(1),
              amount: item.assetAmount,
              tryValue: item.assetTryValue,
              code: item.code,
              type: item.type,
              color: item.color,
              ratio: item.hasDebt ? item.ratio : 1.0,
            ),
          
          if (item.hasAsset && item.hasDebt)
            SizedBox(height: 8.h),
          
          if (item.hasDebt)
            _BarRow(
              label: l10n.debt[0].toUpperCase() + l10n.debt.substring(1),
              amount: item.debtAmount,
              tryValue: item.debtTryValue,
              code: item.code,
              type: item.type,
              color: AppColors.secondary(context),
              ratio: item.hasAsset ? (1 - item.ratio) : 1.0,
            ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    switch (item.type.toLowerCase()) {
      case 'currency':
        return ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Image.asset(
            'assets/img/flags/${item.code.toLowerCase()}.png',
            width: 32.w,
            height: 32.h,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(
                  Icons.currency_exchange,
                  size: 16.sp,
                  color: item.color,
                ),
              );
            },
          ),
        );
      case 'crypto':
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Image.asset(
            'assets/img/cryptos/${item.code.toLowerCase()}.png',
            width: 32.w,
            height: 32.h,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.currency_bitcoin,
                  size: 16.sp,
                  color: item.color,
                ),
              );
            },
          ),
        );
      case 'gold':
      default:
        return Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.monetization_on,
            size: 20.sp,
            color: item.color,
          ),
        );
    }
  }
}

class _BarRow extends StatefulWidget {
  final String label;
  final double amount;
  final double tryValue;
  final String code;
  final String type;
  final Color color;
  final double ratio;

  const _BarRow({
    required this.label,
    required this.amount,
    required this.tryValue,
    required this.code,
    required this.type,
    required this.color,
    required this.ratio,
  });

  @override
  State<_BarRow> createState() => _BarRowState();
}

class _BarRowState extends State<_BarRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate bar width with minimum width
    final maxWidth = MediaQuery.of(context).size.width - 120.w;
    final minWidth = 80.w;
    final calculatedWidth = (maxWidth * widget.ratio).clamp(minWidth, maxWidth);

    return Row(
      children: [
        // Label
        SizedBox(
          width: 50.w,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.title(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        SizedBox(width: 8.w),
        
        // Bar
        Expanded(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Background
                  Container(
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: AppColors.background2(context),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  
                  // Colored bar
                  Container(
                    height: 32.h,
                    width: calculatedWidth * _animation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color,
                          widget.color.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.3),
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      '₺${_formatNumber(widget.tryValue)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatNumber(double value) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}${l10n.billion}';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}${l10n.million}';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}${l10n.thousand}';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}