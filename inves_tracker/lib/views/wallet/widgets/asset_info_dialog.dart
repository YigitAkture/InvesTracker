import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/helpers/gold_input_helper.dart';
import 'package:inves_tracker/core/helpers/locale_helper.dart';
import 'package:inves_tracker/core/helpers/wallet_localization_helper.dart';
import 'package:inves_tracker/core/models/asset.dart';
import 'package:inves_tracker/core/utils/price_formatter.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';

class AssetInfoDialog extends StatelessWidget {
  final List<Asset> assets;
  final double? currentTryValue; // Current TRY value per unit

  const AssetInfoDialog({
    super.key,
    required this.assets,
    this.currentTryValue,
  });

  List<Asset> _getSortedAssets() {
    final sortedAssets = List<Asset>.from(assets);
    // Sort by creation date (oldest first)
    sortedAssets.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sortedAssets;
  }

  double get _totalAmount {
    return assets.fold(0.0, (sum, a) => sum + a.amount);
  }

  double? get _totalInitialValue {
    // Sum of all initial values (if available)
    final validInitialValues = assets
        .where((a) => a.initialTryValue != null)
        .map((a) => a.initialTryValue!)
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
    final sortedAssets = _getSortedAssets();

    // Calculate profit/loss
    final profitLoss = _totalInitialValue != null && _totalCurrentValue != null
        ? _totalCurrentValue! - _totalInitialValue!
        : null;

    // Calculate percentage change
    final percentageChange =
        _totalInitialValue != null &&
            _totalInitialValue! > 0 &&
            profitLoss != null
        ? (profitLoss / _totalInitialValue!) * 100
        : null;

    final isProfitable = profitLoss != null && profitLoss > 0;
    final isZero = profitLoss != null && profitLoss == 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(16.r),
        ),
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
                  Expanded(
                    child: Text(
                      '${l10n.assetDetails} - ${WalletLocalizationHelper.getLocalizedName(context, assets.first.assetCode, assets.first.assetType)}',
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
                itemCount: sortedAssets.length,
                separatorBuilder: (context, index) => Divider(
                  thickness: 2.r,
                  radius: BorderRadius.circular(3.r),
                  height: 30.h,
                  color: AppColors.primary(context).withValues(alpha: 0.25),
                ),
                itemBuilder: (context, index) {
                  final asset = sortedAssets[index];
                  return _AssetInfoItem(
                    asset: asset,
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
                  // Total Assets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.totalAmount}:',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        assets.first.assetType.toLowerCase() == 'gold'
                            ? _formatGoldTotal(context, l10n)
                            : '${PriceFormatter.formatCurrency(_totalAmount, context.localeString)} ${assets.first.assetCode}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
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
                            : isProfitable
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.danger.withValues(alpha: 0.1),
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
                                    : isProfitable
                                    ? Icons.trending_up
                                    : Icons.trending_down,

                                color: isZero
                                    ? AppColors.title(context)
                                    : isProfitable
                                    ? AppColors.success
                                    : AppColors.danger,
                                size: 18.sp,
                              ),

                              SizedBox(width: 8.w),
                              Text(
                                isZero
                                    ? l10n.stable
                                    : isProfitable
                                    ? l10n.profit
                                    : l10n.loss,

                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isZero
                                      ? AppColors.title(context)
                                      : isProfitable
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isProfitable ? '+' : ''}${PriceFormatter.formatCurrency(profitLoss, context.localeString)} TRY',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,

                                  color: isZero
                                      ? AppColors.title(context)
                                      : isProfitable
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                              if (percentageChange != null) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  '${isProfitable ? '+' : ''}${percentageChange.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isZero
                                        ? AppColors.title(context)
                                        : isProfitable
                                        ? AppColors.success
                                        : AppColors.danger,
                                  ),
                                ),
                              ],
                            ],
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
      assets.first.assetCode,
      totalAmount,
    );
    final isDecimalType = GoldInputHelper.allowsDecimal(assets.first.assetCode);
    final unit = isDecimalType
        ? (totalAmount == 1 ? l10n.gram : l10n.grams)
        : (totalAmount == 1 ? l10n.piece : l10n.pieces);
    return '$formattedAmount $unit';
  }
}

class _AssetInfoItem extends StatelessWidget {
  final Asset asset;
  final int index;
  final double? currentTryValue;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  _AssetInfoItem({
    required this.asset,
    required this.index,
    this.currentTryValue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Calculate current value
    final currentValue = currentTryValue != null
        ? asset.amount * currentTryValue!
        : null;

    // Calculate change
    final valueChange = asset.initialTryValue != null && currentValue != null
        ? currentValue - asset.initialTryValue!
        : null;

    // Calculate percentage change
    final percentageChange =
        asset.initialTryValue != null &&
            asset.initialTryValue! > 0 &&
            valueChange != null
        ? (valueChange / asset.initialTryValue!) * 100
        : null;

    final isProfitable = valueChange != null && valueChange > 0;
    final isZero = valueChange != null && valueChange == 0;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.background2(context), width: 1.r),
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
                  color: AppColors.primary(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${l10n.asset[0].toUpperCase()}${l10n.asset.substring(1).toLowerCase()} #${index + 1}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary(context),
                  ),
                ),
              ),
              Text(
                _formatAmount(context, l10n),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Created Date
          _InfoRow(
            icon: Icons.access_time,
            label: l10n.created,
            value: _dateFormat.format(asset.createdAt),
          ),

          // Updated Date (if exists)
          if (asset.updatedAt != null) ...[
            SizedBox(height: 8.h),
            _InfoRow(
              icon: Icons.update,
              label: l10n.lastUpdated,
              value: _dateFormat.format(asset.updatedAt!),
            ),
          ],

          SizedBox(height: 8.h),

          // Initial Value
          if (asset.initialTryValue != null)
            _InfoRow(
              icon: Icons.monetization_on_outlined,
              label: asset.updatedAt != null
                  ? l10n.valueAtUpdate
                  : l10n.initialValue,
              value:
                  '${PriceFormatter.formatCurrency(asset.initialTryValue!, context.localeString)} TRY',
            ),

          if (asset.initialTryValue == null)
            _InfoRow(
              icon: Icons.info_outline,
              label: asset.updatedAt != null
                  ? l10n.valueAtUpdate
                  : l10n.initialValue,
              value: l10n.notAvailable,
              valueColor: AppColors.title(context).withValues(alpha: 0.6),
            ),

          SizedBox(height: 8.h),

          // Current Value
          if (currentValue != null)
            _InfoRow(
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.currentValue,
              value:
                  '${PriceFormatter.formatCurrency(currentValue, context.localeString)} TRY',
              valueColor: AppColors.success,
            ),

          if (currentValue == null)
            _InfoRow(
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.currentValue,
              value: l10n.notAvailable,
              valueColor: AppColors.title(context).withValues(alpha: 0.6),
            ),

          // Value Change with Percentage
          if (valueChange != null) ...[
            SizedBox(height: 8.h),
            _InfoRow(
              icon: isZero
                  ? Icons.trending_flat
                  : isProfitable
                  ? Icons.trending_up
                  : Icons.trending_down,

              label: l10n.change,
              value: percentageChange != null
                  ? '${isProfitable ? '+' : ''}${PriceFormatter.formatCurrency(valueChange, context.localeString)} TRY (${isProfitable ? '+' : ''}${percentageChange.toStringAsFixed(2)}%)'
                  : '${isProfitable ? '+' : ''}${PriceFormatter.formatCurrency(valueChange, context.localeString)} TRY',
              valueColor: isZero
                  ? AppColors.title(context)
                  : isProfitable
                  ? AppColors.success
                  : AppColors.danger,
            ),
          ],
        ],
      ),
    );
  }

  String _formatAmount(BuildContext context, AppLocalizations l10n) {
    final assetType = asset.assetType.toLowerCase();
    final assetCode = asset.assetCode;
    final amount = asset.amount;

    if (assetType == 'gold') {
      final formattedAmount = GoldInputHelper.formatAmount(assetCode, amount);
      final isDecimalType = GoldInputHelper.allowsDecimal(assetCode);
      final unit = isDecimalType
          ? (amount == 1 ? l10n.gram : l10n.grams)
          : (amount == 1 ? l10n.piece : l10n.pieces);
      return '$formattedAmount $unit';
    } else {
      return '${PriceFormatter.formatCurrency(amount, context.localeString)} $assetCode';
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