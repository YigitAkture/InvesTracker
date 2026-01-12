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
  final Asset asset;
  final double? currentTryValue; // Current TRY value per unit

  const AssetInfoDialog({
    super.key,
    required this.asset,
    this.currentTryValue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Calculate current total value
    final currentTotalValue = currentTryValue != null 
        ? asset.amount * currentTryValue! 
        : null;

    // Calculate profit/loss
    final profitLoss = asset.initialTryValue != null && currentTotalValue != null
        ? currentTotalValue - asset.initialTryValue!
        : null;

    final isProfitable = profitLoss != null && profitLoss >= 0;

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
                      '${l10n.assetDetails} - ${WalletLocalizationHelper.getLocalizedName(context, asset.assetCode, asset.assetType)}',
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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount
                    _InfoCard(
                      icon: Icons.inventory_2_outlined,
                      label: l10n.amount,
                      value: _formatAmount(context, l10n),
                    ),
                    
                    SizedBox(height: 12.h),

                    // Created Date
                    _InfoCard(
                      icon: Icons.access_time,
                      label: l10n.created,
                      value: dateFormat.format(asset.createdAt),
                    ),

                    // Updated Date (if exists)
                    if (asset.updatedAt != null) ...[
                      SizedBox(height: 12.h),
                      _InfoCard(
                        icon: Icons.update,
                        label: l10n.lastUpdated,
                        value: dateFormat.format(asset.updatedAt!),
                      ),
                    ],

                    SizedBox(height: 12.h),

                    // Initial Value (at creation/update time)
                    if (asset.initialTryValue != null)
                      _InfoCard(
                        icon: Icons.monetization_on_outlined,
                        label: asset.updatedAt != null 
                            ? l10n.valueAtUpdate
                            : l10n.initialValue,
                        value: '${PriceFormatter.formatCurrency(asset.initialTryValue!, context.localeString)} TRY',
                      ),

                    if (asset.initialTryValue == null)
                      _InfoCard(
                        icon: Icons.info_outline,
                        label: asset.updatedAt != null 
                            ? l10n.valueAtUpdate
                            : l10n.initialValue,
                        value: l10n.notAvailable,
                        valueColor: AppColors.title(context).withValues(alpha: 0.6),
                      ),

                    SizedBox(height: 12.h),

                    // Current Value
                    if (currentTotalValue != null)
                      _InfoCard(
                        icon: Icons.account_balance_wallet_outlined,
                        label: l10n.currentValue,
                        value: '${PriceFormatter.formatCurrency(currentTotalValue, context.localeString)} TRY',
                        valueColor: AppColors.success,
                      ),

                    if (currentTotalValue == null)
                      _InfoCard(
                        icon: Icons.account_balance_wallet_outlined,
                        label: l10n.currentValue,
                        value: l10n.notAvailable,
                        valueColor: AppColors.title(context).withValues(alpha: 0.6),
                      ),
                  ],
                ),
              ),
            ),

            // Footer - Profit/Loss
            if (profitLoss != null)
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: isProfitable 
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isProfitable ? Icons.trending_up : Icons.trending_down,
                          color: isProfitable ? AppColors.success : AppColors.danger,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          isProfitable ? l10n.profit : l10n.loss,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isProfitable ? AppColors.success : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${isProfitable ? '+' : ''}${PriceFormatter.formatCurrency(profitLoss, context.localeString)} TRY',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: isProfitable ? AppColors.success : AppColors.danger,
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.background2(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.background2(context),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.primary(context)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.title(context).withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.title(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}