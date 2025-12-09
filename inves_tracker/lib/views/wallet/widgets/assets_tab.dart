import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/asset.dart';
import 'package:inves_tracker/core/services/asset_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/wallet/widgets/asset_accordion_item.dart';
import 'package:inves_tracker/views/wallet/widgets/add_asset_box.dart';

class AssetsTab extends StatefulWidget {
  final String userId;

  const AssetsTab({super.key, required this.userId});

  @override
  State<AssetsTab> createState() => _AssetsTabState();
}

class _AssetsTabState extends State<AssetsTab> {
  final AssetService _assetService = AssetService();
  List<Asset> _assets = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final assets = await _assetService.getUserAssets(widget.userId);
      setState(() {
        _assets = assets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Map<String, List<Asset>> _groupAssetsByCode() {
    final Map<String, List<Asset>> grouped = {};
    for (var asset in _assets) {
      if (!grouped.containsKey(asset.assetCode)) {
        grouped[asset.assetCode] = [];
      }
      grouped[asset.assetCode]!.add(asset);
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
              onPressed: _loadAssets,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    final groupedAssets = _groupAssetsByCode();

    return RefreshIndicator(
      onRefresh: _loadAssets,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Accordion Items
            if (groupedAssets.isEmpty)
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Text(
                  l10n.noAssetsYet,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.title(context),
                  ),
                ),
              )
            else
              ...groupedAssets.entries.map((entry) {
                return AssetAccordionItem(
                  assetCode: entry.key,
                  assets: entry.value,
                  onRefresh: _loadAssets,
                );
              }),

            SizedBox(height: 16.h),

            // Add Asset Box
            AddAssetBox(
              userId: widget.userId,
              onAssetAdded: _loadAssets,
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}