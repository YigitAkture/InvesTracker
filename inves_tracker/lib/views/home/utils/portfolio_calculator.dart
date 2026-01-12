import 'package:inves_tracker/core/models/asset.dart';
import 'package:inves_tracker/core/models/debt.dart';
import 'package:inves_tracker/core/models/market_response.dart';
import 'package:inves_tracker/views/home/models/portfolio_data.dart';
import 'package:inves_tracker/core/utils/asset_colors.dart';

class PortfolioCalculator {
  static PortfolioData calculatePortfolio({
    required List<Asset> assets,
    required List<Debt> debts,
    required MarketResponse marketData,
  }) {
    // Group assets and debts by code
    final Map<String, Map<String, dynamic>> groupedData = {};

    // Process assets
    for (var asset in assets) {
      final key = '${asset.assetType}_${asset.assetCode}';
      if (!groupedData.containsKey(key)) {
        groupedData[key] = {
          'code': asset.assetCode,
          'type': asset.assetType,
          'assetAmount': 0.0,
          'debtAmount': 0.0,
        };
      }
      groupedData[key]!['assetAmount'] = 
          (groupedData[key]!['assetAmount'] as double) + asset.amount;
    }

    // Process debts
    for (var debt in debts) {
      final key = '${debt.debtType}_${debt.debtCode}';
      if (!groupedData.containsKey(key)) {
        groupedData[key] = {
          'code': debt.debtCode,
          'type': debt.debtType,
          'assetAmount': 0.0,
          'debtAmount': 0.0,
        };
      }
      groupedData[key]!['debtAmount'] = 
          (groupedData[key]!['debtAmount'] as double) + debt.amount;
    }

    // Calculate TRY values
    double totalAssetValue = 0.0;
    double totalDebtValue = 0.0;
    final List<AssetDebtItem> items = [];

    groupedData.forEach((key, data) {
      final code = data['code'] as String;
      final type = data['type'] as String;
      final assetAmount = data['assetAmount'] as double;
      final debtAmount = data['debtAmount'] as double;

      final tryRate = _getTryRate(code, type, marketData);
      final assetTryValue = assetAmount * tryRate;
      final debtTryValue = debtAmount * tryRate;

      totalAssetValue += assetTryValue;
      totalDebtValue += debtTryValue;

      if (assetTryValue > 0 || debtTryValue > 0) {
        items.add(AssetDebtItem(
          code: code,
          type: type,
          assetAmount: assetAmount,
          debtAmount: debtAmount,
          assetTryValue: assetTryValue,
          debtTryValue: debtTryValue,
          color: AssetColors.getColorForAsset(code, type),
        ));
      }
    });

    // Sort items by total value (asset + debt)
    items.sort((a, b) {
      final totalA = a.assetTryValue + a.debtTryValue;
      final totalB = b.assetTryValue + b.debtTryValue;
      return totalB.compareTo(totalA);
    });

    // Create chart segments (only from assets, not debts)
    final List<PortfolioSegment> segments = [];
    if (totalAssetValue > 0) {
      for (var item in items) {
        if (item.assetTryValue > 0) {
          segments.add(PortfolioSegment(
            code: item.code,
            type: item.type,
            tryValue: item.assetTryValue,
            percentage: (item.assetTryValue / totalAssetValue) * 100,
            color: item.color,
          ));
        }
      }
    }

    return PortfolioData(
      totalAssetValue: totalAssetValue,
      totalDebtValue: totalDebtValue,
      segments: segments,
      items: items,
    );
  }

  static double _getTryRate(
    String code,
    String type,
    MarketResponse marketData,
  ) {
    switch (type.toLowerCase()) {
      case 'currency':
        if (code == 'TRY') return 1.0;
        final currency = marketData.currencies.firstWhere(
          (c) => c.code == code,
          orElse: () => marketData.currencies.first,
        );
        return currency.buying;

      case 'gold':
        final gold = marketData.golds.firstWhere(
          (g) => g.code == code,
          orElse: () => marketData.golds.first,
        );
        return gold.selling;

      case 'crypto':
        final crypto = marketData.cryptos.firstWhere(
          (c) => c.code == code,
          orElse: () => marketData.cryptos.first,
        );
        return crypto.tryPrice;

      default:
        return 0.0;
    }
  }
}