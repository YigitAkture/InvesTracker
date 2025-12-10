import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/helpers/wallet_localization_helper.dart';
import 'package:inves_tracker/core/models/asset.dart';
import 'package:inves_tracker/core/services/asset_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/wallet/widgets/edit_asset_dialog.dart';

class AssetAccordionItem extends StatefulWidget {
  final String assetCode;
  final String assetType;
  final List<Asset> assets;
  final double? tryValue; // TRY value per unit
  final VoidCallback onRefresh;

  const AssetAccordionItem({
    super.key,
    required this.assetCode,
    required this.assetType,
    required this.assets,
    this.tryValue,
    required this.onRefresh,
  });

  @override
  State<AssetAccordionItem> createState() => _AssetAccordionItemState();
}

class _AssetAccordionItemState extends State<AssetAccordionItem> {
  bool _isExpanded = false;
  final AssetService _assetService = AssetService();

  double get _totalAmount {
    return widget.assets.fold(0.0, (sum, asset) => sum + asset.amount);
  }

  double? get _totalTryValue {
    if (widget.tryValue == null) return null;
    return _totalAmount * widget.tryValue!;
  }

  Future<void> _deleteAsset(Asset asset) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAsset),
        content: Text(l10n.confirmDeleteAsset),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _assetService.deleteAsset(asset.id);
        widget.onRefresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.assetDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.failedToDeleteAsset)),
          );
        }
      }
    }
  }

  Future<void> _editAsset(Asset asset) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditAssetDialog(asset: asset),
    );

    if (result == true) {
      widget.onRefresh();
    }
  }

  Widget _buildIcon() {
    switch (widget.assetType.toLowerCase()) {
      case 'currency':
        return ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Image.asset(
            'assets/img/flags/${widget.assetCode.toLowerCase()}.png',
            width: 40.w,
            height: 40.h,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(
                  Icons.currency_exchange,
                  size: 20.sp,
                  color: AppColors.primary(context),
                ),
              );
            },
          ),
        );
      case 'crypto':
        return ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Image.asset(
            'assets/img/cryptos/${widget.assetCode.toLowerCase()}.png',
            width: 40.w,
            height: 40.h,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.currency_bitcoin,
                  size: 20.sp,
                  color: AppColors.primary(context),
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
            color: Colors.black.withValues(alpha: 0.35),
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
                  // Asset Icon
                  _buildIcon(),
                  SizedBox(width: 12.w),
                  
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          WalletLocalizationHelper.getLocalizedName(
                            context,
                            widget.assetCode,
                            widget.assetType,
                          ),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${_totalAmount.toStringAsFixed(2)} ${widget.assetType != 'Gold' ? widget.assetCode : WalletLocalizationHelper.getLocalizedName(
                            context,
                            widget.assetCode,
                            widget.assetType,
                          )}',
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
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
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
            ...widget.assets.map((asset) {
              final assetTryValue = widget.tryValue != null 
                  ? asset.amount * widget.tryValue! 
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
                            '${l10n.amount}: ${asset.amount.toStringAsFixed(2)} ${widget.assetCode}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          if (assetTryValue != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              '≈ ${assetTryValue.toStringAsFixed(2)} TRY',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Edit Button
                    IconButton(
                      onPressed: () => _editAsset(asset),
                      icon: Icon(Icons.edit, size: 20.sp),
                      color: AppColors.primary(context),
                    ),
                    
                    // Delete Button
                    IconButton(
                      onPressed: () => _deleteAsset(asset),
                      icon: Icon(Icons.delete, size: 20.sp),
                      color: AppColors.danger,
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