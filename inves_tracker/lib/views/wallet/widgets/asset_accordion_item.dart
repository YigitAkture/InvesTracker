import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/asset.dart';
import 'package:inves_tracker/core/services/asset_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/wallet/widgets/edit_asset_dialog.dart';

class AssetAccordionItem extends StatefulWidget {
  final String assetCode;
  final List<Asset> assets;
  final VoidCallback onRefresh;

  const AssetAccordionItem({
    super.key,
    required this.assetCode,
    required this.assets,
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
                  // Asset Code/Icon
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        widget.assetCode,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary(context),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.assetCode,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Total: ${_totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.title(context),
                          ),
                        ),
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
                            '${l10n.amount}: ${asset.amount.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${l10n.purchasePrice}: ${asset.purchasePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.title(context),
                            ),
                          ),
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