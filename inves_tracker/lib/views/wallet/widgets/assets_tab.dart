import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/asset.dart';
import 'package:inves_tracker/core/services/asset_service.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/core/models/market_response.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/shared/banner_add.dart';
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
  final MarketService _marketService = MarketService();
  List<Asset> _assets = [];
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
      final assetsResult = await _assetService.getUserAssets(widget.userId);
      final marketResult = await _marketService.fetchMarketData();
      
      setState(() {
        _assets = assetsResult;
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

  double? _getTryValue(String assetCode, String assetType) {
    if (_marketData == null) return null;

    switch (assetType.toLowerCase()) {
      case 'currency':
        if (assetCode == 'TRY') return 1.0;
        final currency = _marketData!.currencies.firstWhere(
          (c) => c.code == assetCode,
          orElse: () => _marketData!.currencies.first,
        );
        return currency.buying;
      
      case 'gold':
        final gold = _marketData!.golds.firstWhere(
          (g) => g.code == assetCode,
          orElse: () => _marketData!.golds.first,
        );
        return gold.selling;
      
      case 'crypto':
        final crypto = _marketData!.cryptos.firstWhere(
          (c) => c.code == assetCode,
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

    final groupedAssets = _groupAssetsByCode();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Ad
            const Center(child: BannerAdd()),
            SizedBox(height: 16.h),

            // Add Asset Box
            AddAssetBox(
              userId: widget.userId,
              onAssetAdded: _loadData,
            ),

            SizedBox(height: 24.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                l10n.myAssets,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.title(context),
                ),
              ),
            ),

            SizedBox(height: 16.h),

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
                final assetType = entry.value.first.assetType;
                final tryValue = _getTryValue(entry.key, assetType);
                
                return AssetAccordionItem(
                  assetCode: entry.key,
                  assetType: assetType,
                  assets: entry.value,
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