import 'package:flutter/material.dart';

/// Represents a single segment in the portfolio chart
class PortfolioSegment {
  final String code;
  final String type;
  final double tryValue;
  final double percentage;
  final Color color;

  PortfolioSegment({
    required this.code,
    required this.type,
    required this.tryValue,
    required this.percentage,
    required this.color,
  });
}

/// Represents asset and debt data for a single type (e.g., USD, EUR, etc.)
class AssetDebtItem {
  final String code;
  final String type;
  final double assetAmount;
  final double debtAmount;
  final double assetTryValue;
  final double debtTryValue;
  final Color color;

  AssetDebtItem({
    required this.code,
    required this.type,
    required this.assetAmount,
    required this.debtAmount,
    required this.assetTryValue,
    required this.debtTryValue,
    required this.color,
  });

  bool get hasAsset => assetTryValue > 0;
  bool get hasDebt => debtTryValue > 0;
  
  double get ratio {
    if (debtTryValue == 0) return 1.0;
    if (assetTryValue == 0) return 0.0;
    return assetTryValue / (assetTryValue + debtTryValue);
  }
}

/// Main portfolio data container
class PortfolioData {
  final double totalAssetValue;
  final double totalDebtValue;
  final List<PortfolioSegment> segments;
  final List<AssetDebtItem> items;

  PortfolioData({
    required this.totalAssetValue,
    required this.totalDebtValue,
    required this.segments,
    required this.items,
  });

  double get totalBalance => totalAssetValue - totalDebtValue;
  
  bool get hasData => segments.isNotEmpty;
}