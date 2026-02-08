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
///
/// FIXED: Uses "change" field from API (not "changeRate")
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

  // OPTIMIZED: Define widget-specific data requirements
  static const List<String> _widgetCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'CHF',
  ];
  static const List<String> _widgetGolds = [
    'GRA',
    'HAS',
    'CEYREKALTIN',
  ]; // Gram, Has, Quarter
  static const List<String> _widgetCryptos = [
    'BTC',
    'ETH',
    'USDT',
  ]; // Bitcoin, Ethereum, Tether

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

      // OPTIMIZED: Prepare widget data with only the required instruments
      final widgetData = _prepareOptimizedWidgetData(marketData, l10n);

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

      debugPrint(
        'Widget data updated successfully (${widgetData['currencies'].length} currencies, ${widgetData['golds'].length} golds, ${widgetData['cryptos'].length} cryptos)',
      );
    } catch (e) {
      debugPrint('Failed to update widget data: $e');
    }
  }

  /// OPTIMIZED: Prepare market data for widget consumption
  /// Creates a lightweight, serialized format optimized for widget display
  /// Returns only the specific instruments: 5 currencies, 3 golds, 3 cryptos
  /// FIX: Uses "change" field from API and calculates isIncreasing
  Map<String, dynamic> _prepareOptimizedWidgetData(
    MarketResponse marketData,
    AppLocalizations l10n,
  ) {
    // Filter and order currencies: USD, EUR, GBP, CAD, CHF
    final filteredCurrencies = _filterAndOrderItems(
      marketData.currencies,
      _widgetCurrencies,
      (currency) => currency.code,
      (currency) {
        // FIX: API uses "change" field, calculate isIncreasing from sign
        // Zero or positive = green, only negative = red
        final change = currency
            .changeRate; // Your model might call it changeRate but API sends "change"
        final isIncreasing = change >= 0.0;
        final changeRate = change.abs();

        debugPrint(
          'Currency ${currency.code}: change=$change, changeRate=$changeRate, isIncreasing=$isIncreasing',
        );
        return {
          'code': currency.code,
          'name': _getCurrencyLocalizedName(currency.code, l10n),
          'buying': currency.buying,
          'selling': currency.selling,
          'changeRate': changeRate,
          'isIncreasing': isIncreasing,
        };
      },
    );

    // Filter and order golds: GRA, HAS, CEYREKALTIN
    final filteredGolds = _filterAndOrderItems(
      marketData.golds,
      _widgetGolds,
      (gold) => gold.code,
      (gold) {
        // FIX: API uses "change" field, calculate isIncreasing from sign
        final change = gold
            .changeRate; // Your model might call it changeRate but API sends "change"
        final isIncreasing = change >= 0.0;
        final changeRate = change.abs();

        debugPrint(
          'Gold ${gold.code}: change=$change, changeRate=$changeRate, isIncreasing=$isIncreasing',
        );
        return {
          'code': gold.code,
          'name': _getGoldLocalizedName(gold.code, l10n),
          'buying': gold.buying,
          'selling': gold.selling,
          'changeRate': changeRate,
          'isIncreasing': isIncreasing,
        };
      },
    );

    // Filter and order cryptos: BTC, ETH, USDT
    final filteredCryptos = _filterAndOrderItems(
      marketData.cryptos,
      _widgetCryptos,
      (crypto) => crypto.code,
      (crypto) {
        // FIX: API uses "change" field, calculate isIncreasing from sign
        final change = crypto
            .changeRate; // Your model might call it changeRate but API sends "change"
        final isIncreasing = change >= 0.0;
        final changeRate = change.abs();

        debugPrint(
          'Crypto ${crypto.code}: usdPrice=${crypto.usdPrice}, sellingUsd=${crypto.sellingUsd}, change=$change, changeRate=$changeRate, isIncreasing=$isIncreasing',
        );
        return {
          'code': crypto.code,
          'name': crypto.name,
          'usdPrice': crypto.usdPrice,
          'sellingUsd': crypto.sellingUsd,
          'changeRate': changeRate,
          'isIncreasing': isIncreasing,
        };
      },
    );

    return {
      'currencies': filteredCurrencies,
      'golds': filteredGolds,
      'cryptos': filteredCryptos,
      'updateTime': marketData.updateTime,
      'labels': {
        'currency': l10n.currency,
        'gold': l10n.gold,
        'crypto': l10n.crypto,
        'code': 'Code',
        'buying': l10n.buying,
        'selling': l10n.selling,
        'change': l10n.change,
        'updated': l10n.updated,
      },
    };
  }

  /// Generic helper to filter and order items based on a predefined list
  List<Map<String, dynamic>> _filterAndOrderItems<T>(
    List<T> allItems,
    List<String> requiredCodes,
    String Function(T) getCode,
    Map<String, dynamic> Function(T) mapToJson,
  ) {
    // Create a map for quick lookup
    final itemMap = <String, T>{};
    for (final item in allItems) {
      final code = getCode(item);
      if (requiredCodes.contains(code)) {
        itemMap[code] = item;
      }
    }

    // Return items in the specified order
    final result = <Map<String, dynamic>>[];
    for (final code in requiredCodes) {
      final item = itemMap[code];
      if (item != null) {
        result.add(mapToJson(item));
      }
    }

    return result;
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
        name: 'HomeWidget',
        androidName: 'HomeWidget',
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

      // OPTIMIZED: Prepare simplified data with only required instruments
      // FIX: Uses "change" field from API
      final widgetData = {
        'currencies': _extractFilteredItems(
          marketData.currencies,
          _widgetCurrencies,
          (c) => c.code,
          (c) {
            final change = c.changeRate; // API sends "change"
            final isIncreasing = change >= 0.0;
            final changeRate = change.abs();
            return {
              'code': c.code,
              'buying': c.buying,
              'selling': c.selling,
              'changeRate': changeRate,
              'isIncreasing': isIncreasing,
            };
          },
        ),
        'golds': _extractFilteredItems(
          marketData.golds,
          _widgetGolds,
          (g) => g.code,
          (g) {
            final change = g.changeRate; // API sends "change"
            final isIncreasing = change >= 0.0;
            final changeRate = change.abs();
            return {
              'code': g.code,
              'buying': g.buying,
              'selling': g.selling,
              'changeRate': changeRate,
              'isIncreasing': isIncreasing,
            };
          },
        ),
        'cryptos': _extractFilteredItems(
          marketData.cryptos,
          _widgetCryptos,
          (c) => c.code,
          (c) {
            final change = c.changeRate; // API sends "change"
            final isIncreasing = change >= 0.0;
            final changeRate = change.abs();
            return {
              'code': c.code,
              'usdPrice': c.usdPrice,
              'sellingUsd': c.sellingUsd,
              'changeRate': changeRate,
              'isIncreasing': isIncreasing,
            };
          },
        ),
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
        name: 'HomeWidget',
        androidName: 'HomeWidget',
        iOSName: 'HomeWidget',
      );

      debugPrint('Background widget update completed');
    } catch (e) {
      debugPrint('Background widget update failed: $e');
    }
  }

  /// Helper for background callback to filter items
  static List<Map<String, dynamic>> _extractFilteredItems<T>(
    List<T> allItems,
    List<String> requiredCodes,
    String Function(T) getCode,
    Map<String, dynamic> Function(T) mapToJson,
  ) {
    final itemMap = <String, T>{};
    for (final item in allItems) {
      final code = getCode(item);
      if (requiredCodes.contains(code)) {
        itemMap[code] = item;
      }
    }

    final result = <Map<String, dynamic>>[];
    for (final code in requiredCodes) {
      final item = itemMap[code];
      if (item != null) {
        result.add(mapToJson(item));
      }
    }

    return result;
  }

  /// Get basic labels for background updates
  static Map<String, String> _getBasicLabels(String locale) {
    if (locale == 'tr') {
      return {
        'currency': 'Döviz',
        'gold': 'Altın',
        'crypto': 'Kripto',
        'code': 'Kod',
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
      'code': 'Code',
      'buying': 'Buy',
      'selling': 'Sell',
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