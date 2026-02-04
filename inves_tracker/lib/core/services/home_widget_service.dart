import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:inves_tracker/core/models/market_response.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:workmanager/workmanager.dart';

/// Service for managing Home Screen Widget data and updates
/// Handles data serialization, localization, platform-specific widget updates,
/// and background refresh without launching the app
class HomeWidgetService {
  static final HomeWidgetService _instance = HomeWidgetService._internal();
  factory HomeWidgetService() => _instance;
  HomeWidgetService._internal();

  final MarketService _marketService = MarketService();

  // Widget update keys
  static const String _widgetDataKey = 'widget_data';
  static const String _widgetLocaleKey = 'widget_locale';
  static const String _lastUpdateKey = 'last_update';

  // Background task name
  static const String _backgroundTaskName = 'widgetBackgroundUpdate';

  /// Initialize widget with current app state
  Future<void> initialize(BuildContext context) async {
    try {
      // Get current locale
      final locale = Localizations.localeOf(context);
      await _saveLocale(locale.languageCode);

      // Fetch and update market data
      await updateWidgetData(context);

      // Setup background periodic updates (Android only)
      await _setupBackgroundUpdates();

      debugPrint('Home widget initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize home widget: $e');
    }
  }

  /// Setup background periodic updates using WorkManager
  /// This allows the widget to update even when the app is closed
  Future<void> _setupBackgroundUpdates() async {
    try {
      // Register periodic task for widget updates (every 30 minutes)
      await Workmanager().registerPeriodicTask(
        _backgroundTaskName,
        _backgroundTaskName,
        frequency: const Duration(minutes: 30),
        constraints: Constraints(
          networkType: NetworkType.connected, // Requires internet
        ),
      );

      debugPrint('Background widget updates registered');
    } catch (e) {
      debugPrint('Failed to setup background updates: $e');
    }
  }

  /// Update widget with fresh market data
  /// Call this whenever market data is refreshed or locale changes
  Future<void> updateWidgetData(BuildContext context) async {
    try {
      // Fetch fresh market data
      final marketData = await _marketService.fetchMarketData();

      // Get localizations
      final l10n = AppLocalizations.of(context)!;
      final locale = Localizations.localeOf(context);

      // Prepare widget data with all three categories
      final widgetData = _prepareWidgetData(marketData, l10n);

      // Save to shared preferences (accessible by widget)
      await HomeWidget.saveWidgetData<String>(
        _widgetDataKey,
        jsonEncode(widgetData),
      );

      await _saveLocale(locale.languageCode);

      await HomeWidget.saveWidgetData<String>(
        _lastUpdateKey,
        DateTime.now().toIso8601String(),
      );

      // Update widget UI on both platforms
      await _updatePlatformWidget();

      debugPrint('Widget data updated successfully');
    } catch (e) {
      debugPrint('Failed to update widget data: $e');
    }
  }

  /// Prepare market data for widget consumption
  /// Creates a lightweight, serialized format optimized for widget display
  /// Returns top 5 currencies, 3 precious metals, and 3 cryptocurrencies
  Map<String, dynamic> _prepareWidgetData(
    MarketResponse marketData,
    AppLocalizations l10n,
  ) {
    // Select top 5 currencies for widget display
    final topCurrencies = marketData.currencies.take(5).map((currency) {
      return {
        'code': currency.code,
        'name': _getCurrencyLocalizedName(currency.code, l10n),
        'buying': currency.buying,
        'selling': currency.selling,
        'changeRate': currency.changeRate,
        'isIncreasing': currency.isIncreasing,
      };
    }).toList();

    // Select top 3 precious metals for widget display
    final topGolds = marketData.golds.take(3).map((gold) {
      return {
        'code': gold.code,
        'name': _getGoldLocalizedName(gold.code, l10n),
        'buying': gold.buying,
        'selling': gold.selling,
        'changeRate': gold.changeRate,
        'isIncreasing': gold.isIncreasing,
      };
    }).toList();

    // Select top 3 cryptos for widget display
    final topCryptos = marketData.cryptos.take(3).map((crypto) {
      return {
        'code': crypto.code,
        'name': crypto.name,
        'usdPrice': crypto.usdPrice,
        'sellingUsd': crypto.sellingUsd,
        'changeRate': crypto.changeRate,
        'isIncreasing': crypto.isIncreasing,
      };
    }).toList();

    return {
      'currencies': topCurrencies,
      'golds': topGolds,
      'cryptos': topCryptos,
      'updateTime': marketData.updateTime,
      // Localized labels (so widget doesn't need l10n logic)
      'labels': {
        'currency': l10n.currency,
        'gold': l10n.gold,
        'crypto': l10n.crypto,
        'buying': l10n.buying,
        'selling': l10n.selling,
        'change': l10n.change,
        'updated': l10n.updated,
      },
    };
  }

  /// Get localized currency name
  String _getCurrencyLocalizedName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'USD':
        return l10n.currencyUSD;
      case 'EUR':
        return l10n.currencyEUR;
      case 'GBP':
        return l10n.currencyGBP;
      case 'CHF':
        return l10n.currencyCHF;
      case 'CAD':
        return l10n.currencyCAD;
      case 'JPY':
        return l10n.currencyJPY;
      case 'SAR':
        return l10n.currencySAR;
      case 'RUB':
        return l10n.currencyRUB;
      case 'AED':
        return l10n.currencyAED;
      case 'KWD':
        return l10n.currencyKWD;
      default:
        return code;
    }
  }

  /// Get localized gold name
  String _getGoldLocalizedName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'HAS':
        return l10n.goldHAS;
      case 'GRA':
        return l10n.goldGRA;
      case 'CEYREKALTIN':
        return l10n.goldCEYREKALTIN;
      case 'YARIMALTIN':
        return l10n.goldYARIMALTIN;
      case 'TAMALTIN':
        return l10n.goldTAMALTIN;
      case 'ATAALTIN':
        return l10n.goldATAALTIN;
      case 'RESATALTIN':
        return l10n.goldRESATALTIN;
      case 'CUMHURIYETALTINI':
        return l10n.goldCUMHURIYETALTINI;
      case 'GREMSEALTIN':
        return l10n.goldGREMSEALTIN;
      case '14AYARALTIN':
        return l10n.gold14AYARALTIN;
      case '18AYARALTIN':
        return l10n.gold18AYARALTIN;
      case 'GUMUS':
        return l10n.goldGUMUS;
      case 'GPL':
        return l10n.goldGPL;
      case 'PAL':
        return l10n.goldPAL;
      default:
        return code;
    }
  }

  /// Save current locale for widget
  Future<void> _saveLocale(String languageCode) async {
    await HomeWidget.saveWidgetData<String>(_widgetLocaleKey, languageCode);
  }

  /// Update widget UI on platform
  Future<void> _updatePlatformWidget() async {
    try {
      // Android
      await HomeWidget.updateWidget(
        name: 'HomeWidgetProvider',
        androidName: 'HomeWidgetProvider',
      );

      // iOS (if needed in future)
      await HomeWidget.updateWidget(name: 'HomeWidget', iOSName: 'HomeWidget');
    } catch (e) {
      debugPrint('Failed to update platform widget: $e');
    }
  }

  /// Register background callback for periodic widget updates
  /// This allows the widget to refresh even when app is closed
  static Future<void> backgroundCallback(Uri? uri) async {
    try {
      debugPrint('Widget background callback triggered');

      // This runs in background isolate
      // Fetch fresh market data
      final marketService = MarketService();
      final marketData = await marketService.fetchMarketData();

      // Get saved locale
      final locale =
          await HomeWidget.getWidgetData<String>(_widgetLocaleKey) ?? 'en';

      // Create basic labels (without full l10n context in background)
      final labels = _getBasicLabels(locale);

      // Prepare simplified data for all three categories
      final widgetData = {
        'currencies': marketData.currencies
            .take(5)
            .map(
              (c) => {
                'code': c.code,
                'buying': c.buying,
                'selling': c.selling,
                'changeRate': c.changeRate,
                'isIncreasing': c.isIncreasing,
              },
            )
            .toList(),
        'golds': marketData.golds
            .take(3)
            .map(
              (g) => {
                'code': g.code,
                'buying': g.buying,
                'selling': g.selling,
                'changeRate': g.changeRate,
                'isIncreasing': g.isIncreasing,
              },
            )
            .toList(),
        'cryptos': marketData.cryptos
            .take(3)
            .map(
              (c) => {
                'code': c.code,
                'usdPrice': c.usdPrice,
                'sellingUsd': c.sellingUsd,
                'changeRate': c.changeRate,
                'isIncreasing': c.isIncreasing,
              },
            )
            .toList(),
        'updateTime': marketData.updateTime,
        'labels': labels,
      };

      await HomeWidget.saveWidgetData<String>(
        _widgetDataKey,
        jsonEncode(widgetData),
      );

      await HomeWidget.saveWidgetData<String>(
        _lastUpdateKey,
        DateTime.now().toIso8601String(),
      );

      // Update widget
      await HomeWidget.updateWidget(
        name: 'HomeWidgetProvider',
        androidName: 'HomeWidgetProvider',
        iOSName: 'HomeWidget',
      );

      debugPrint('Background widget update completed');
    } catch (e) {
      debugPrint('Background widget update failed: $e');
    }
  }

  /// Get basic labels for background updates
  static Map<String, String> _getBasicLabels(String locale) {
    if (locale == 'tr') {
      return {
        'currency': 'Döviz',
        'gold': 'Altın',
        'crypto': 'Kripto',
        'buying': 'Alış',
        'selling': 'Satış',
        'change': 'Değişim',
        'updated': 'Güncellendi',
      };
    }
    return {
      'currency': 'Currency',
      'gold': 'Gold',
      'crypto': 'Crypto',
      'buying': 'Buying',
      'selling': 'Selling',
      'change': 'Change',
      'updated': 'Updated',
    };
  }

  /// Check if widget needs update (call on app resume)
  Future<bool> shouldUpdate() async {
    try {
      final lastUpdate = await HomeWidget.getWidgetData<String>(_lastUpdateKey);
      if (lastUpdate == null) return true;

      final lastUpdateTime = DateTime.parse(lastUpdate);
      final now = DateTime.now();

      // Update if last update was more than 30 minutes ago
      return now.difference(lastUpdateTime).inMinutes > 30;
    } catch (e) {
      return true; // Update on error
    }
  }
}