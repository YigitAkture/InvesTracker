import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/helpers/gold_input_helper.dart';
import 'package:inves_tracker/core/helpers/wallet_localization_helper.dart';
import 'package:inves_tracker/core/models/asset.dart';
import 'package:inves_tracker/core/services/asset_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';

class EditAssetDialog extends StatefulWidget {
  final Asset asset;

  const EditAssetDialog({super.key, required this.asset});

  @override
  State<EditAssetDialog> createState() => _EditAssetDialogState();
}

class _EditAssetDialogState extends State<EditAssetDialog> {
  final TextEditingController _amountController = TextEditingController();
  final AssetService _assetService = AssetService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Format the initial value based on asset type
    if (widget.asset.assetType.toLowerCase() == 'gold') {
      _amountController.text = GoldInputHelper.formatAmount(
        widget.asset.assetCode,
        widget.asset.amount,
      );
    } else {
      _amountController.text = widget.asset.amount.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _updateAsset() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterValidAmount, style: TextStyle(color: Colors.black)), 
          showCloseIcon: true,
          closeIconColor: Colors.black,
          backgroundColor: AppColors.warning2,
        ),
      );
      return;
    }

    // Additional validation for gold types
    if (widget.asset.assetType.toLowerCase() == 'gold') {
      final validationError = GoldInputHelper.validateAmount(
        widget.asset.assetCode,
        _amountController.text,
      );
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError, style: TextStyle(color: Colors.black)), 
            showCloseIcon: true,
            closeIconColor: Colors.black,
            backgroundColor: AppColors.warning2,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      await _assetService.updateAsset(widget.asset.id, amount, 0);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.assetUpdated, style: TextStyle(color: Colors.black)), 
            showCloseIcon: true,
            closeIconColor: Colors.black,
            backgroundColor: AppColors.success2,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToUpdateAsset}: $e', style: TextStyle(color: Colors.black)), 
            showCloseIcon: true,
            closeIconColor: Colors.black,
            backgroundColor: AppColors.danger3,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isGold = widget.asset.assetType.toLowerCase() == 'gold';
    
    return AlertDialog(
      title: Text(l10n.editAsset),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            WalletLocalizationHelper.getLocalizedName(
              context,
              widget.asset.assetCode,
              widget.asset.assetType,
            ),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary(context),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _amountController,
            // Dynamic keyboard type and formatters for gold
            keyboardType: isGold
                ? GoldInputHelper.getKeyboardType(widget.asset.assetCode)
                : const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: isGold
                ? GoldInputHelper.getInputFormatters(widget.asset.assetCode)
                : [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
            decoration: InputDecoration(
              labelText: l10n.amount,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              filled: true,
              fillColor: AppColors.background2(context),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateAsset,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(context),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.update),
        ),
      ],
    );
  }
}