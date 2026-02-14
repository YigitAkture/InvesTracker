import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:inves_tracker/core/models/market_response.dart';
import 'package:inves_tracker/core/services/market_service.dart';
import 'package:inves_tracker/core/config/widget_config.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';

/// REFACTORED: Clean home widget service
/// - Uses exactly 4 items per category
/// - Proper gold localization
/// - Simplified change calculations (no redundant fields)
/// - Language-only updates to preserve change values
class HomeWidgetService {
  static final HomeWidgetService _instance = HomeWidgetService._internal();
  factory HomeWidgetService() => _instance;
  HomeWidgetService._internal();

  final MarketService _marketService = MarketService();

  static const String _widgetDataKey = 'widget_data';
  static const String _widgetLocaleKey = 'widget_locale';
  static const String _lastUpdateKey = 'last_update';

  /// Initialize widget with current app state
  Future<void> initialize(BuildContext context) async {
    try {
      // Capture context-dependent values BEFORE any await
      final locale = Localizations.localeOf(context);

      await _saveLocale(locale.languageCode);

      // Re-check mount state not needed here since we captured locale already,
      // but we need context again for updateWidgetData — so pass captured values.
      await _updateWidgetDataInternal(locale);

      debugPrint('✓ Home widget initialized (4 items per category)');
    } catch (e) {
      debugPrint('✗ Failed to initialize home widget: $e');
    }
  }

  /// Update widget with fresh market data
  Future<void> updateWidgetData(BuildContext context) async {
    try {
      // Capture context-dependent values BEFORE any await
      final l10n = AppLocalizations.of(context)!;
      final locale = Localizations.localeOf(context);

      await _updateWidgetDataInternal(locale, l10n: l10n);

      debugPrint('✓ Widget updated: 4 currencies, 4 golds, 4 cryptos');
    } catch (e) {
      debugPrint('✗ Failed to update widget: $e');
    }
  }

  /// Internal implementation that doesn't need BuildContext
  Future<void> _updateWidgetDataInternal(
    Locale locale, {
    AppLocalizations? l10n,
  }) async {
    final marketData = await _marketService.fetchMarketData();

    // If l10n wasn't provided, fall back to locale-based labels
    final widgetData = l10n != null
        ? _prepareWidgetData(marketData, l10n)
        : _prepareWidgetDataFromLocale(marketData, locale.languageCode);

    await HomeWidget.saveWidgetData<String>(
      _widgetDataKey,
      jsonEncode(widgetData),
    );

    await _saveLocale(locale.languageCode);
    await HomeWidget.saveWidgetData<String>(
      _lastUpdateKey,
      DateTime.now().toIso8601String(),
    );

    await _updatePlatformWidget();
  }

  /// Update ONLY widget language/labels without fetching fresh market data
  /// This preserves existing market data including change values
  Future<void> updateWidgetLanguage(BuildContext context) async {
    try {
      // Capture context-dependent values BEFORE any await
      final l10n = AppLocalizations.of(context)!;
      final locale = Localizations.localeOf(context);

      // Get existing widget data
      final existingData = await HomeWidget.getWidgetData<String>(
        _widgetDataKey,
      );

      if (existingData == null) {
        // No existing data, do full update using already-captured values
        debugPrint('No existing widget data, performing full update');
        await _updateWidgetDataInternal(locale, l10n: l10n);
        return;
      }

      // Parse existing data
      final data = jsonDecode(existingData) as Map<String, dynamic>;

      // Update only the localized parts while preserving market data
      final updatedData = {
        'currencies': _updateCurrencyNames(data['currencies'] as List, l10n),
        'golds': _updateGoldNames(data['golds'] as List, l10n),
        'cryptos': data['cryptos'], // Crypto names don't change with locale
        'updateTime': data['updateTime'], // Preserve existing update time
        'labels': _getLabels(l10n), // Update labels to new language
      };

      await HomeWidget.saveWidgetData<String>(
        _widgetDataKey,
        jsonEncode(updatedData),
      );

      await _saveLocale(locale.languageCode);

      await _updatePlatformWidget();

      debugPrint(
        '✓ Widget language updated to ${locale.languageCode} (data preserved)',
      );
    } catch (e) {
      debugPrint('✗ Failed to update widget language: $e');
      // Fallback to full update — context may no longer be valid here,
      // so we cannot safely call updateWidgetData(context) in a catch block.
      // Log the error and let the caller retry if needed.
    }
  }

  /// Update currency display names while preserving all other data
  List<Map<String, dynamic>> _updateCurrencyNames(
    List<dynamic> currencies,
    AppLocalizations l10n,
  ) {
    return currencies.map((item) {
      final currency = item as Map<String, dynamic>;
      final code = currency['code'] as String;

      return {
        'code': code,
        'name': _getCurrencyName(code, l10n), // Update name
        'buying': currency['buying'], // Preserve
        'selling': currency['selling'], // Preserve
        'change': currency['change'], // PRESERVE CHANGE VALUE
      };
    }).toList();
  }

  /// Update gold display names while preserving all other data
  List<Map<String, dynamic>> _updateGoldNames(
    List<dynamic> golds,
    AppLocalizations l10n,
  ) {
    return golds.map((item) {
      final gold = item as Map<String, dynamic>;
      final code = gold['code'] as String;

      GoldType? goldType;
      switch (code) {
        case 'GRA':
          goldType = GoldType.gram;
          break;
        case 'CEYR':
          goldType = GoldType.quarter;
          break;
        case 'YARI':
          goldType = GoldType.half;
          break;
        case 'TAM':
          goldType = GoldType.full;
          break;
      }

      return {
        'code': code,
        'name': goldType != null ? goldType.localizedName(l10n) : code,
        'buying': gold['buying'], // Preserve
        'selling': gold['selling'], // Preserve
        'change': gold['change'], // PRESERVE CHANGE VALUE
      };
    }).toList();
  }

  /// Prepare widget data with exactly 4 items per category (with l10n)
  Map<String, dynamic> _prepareWidgetData(
    MarketResponse marketData,
    AppLocalizations l10n,
  ) {
    return {
      'currencies': _extractCurrencies(marketData, l10n),
      'golds': _extractGolds(marketData, l10n),
      'cryptos': _extractCryptos(marketData),
      'updateTime': marketData.updateTime,
      'labels': _getLabels(l10n),
    };
  }

  /// Prepare widget data using locale string only (fallback for initialize)
  Map<String, dynamic> _prepareWidgetDataFromLocale(
    MarketResponse marketData,
    String locale,
  ) {
    return {
      'currencies': _extractBackgroundCurrencies(marketData),
      'golds': _extractBackgroundGolds(marketData, locale),
      'cryptos': _extractBackgroundCryptos(marketData),
      'updateTime': marketData.updateTime,
      'labels': _getBasicLabels(locale),
    };
  }

  /// Extract exactly 4 currencies: USD, EUR, GBP, CHF
  List<Map<String, dynamic>> _extractCurrencies(
    MarketResponse marketData,
    AppLocalizations l10n,
  ) {
    final result = <Map<String, dynamic>>[];

    for (final code in WidgetConfig.currencies) {
      try {
        final currency = marketData.currencies.firstWhere(
          (c) => c.code == code,
        );

        final item = WidgetItemData(
          code: currency.code,
          displayName: _getCurrencyName(currency.code, l10n),
          buyingPrice: currency.buying,
          sellingPrice: currency.selling,
          change: currency.changeRate,
        );

        result.add(item.toJson());

        debugPrint(
          'Currency ${item.code}: change=${item.change}, '
          'isIncreasing=${item.isIncreasing}',
        );
      } catch (e) {
        debugPrint('⚠ Currency $code not found in API response');
      }
    }

    return result;
  }

  /// Extract exactly 4 golds: Gram, Quarter, Half, Full
  List<Map<String, dynamic>> _extractGolds(
    MarketResponse marketData,
    AppLocalizations l10n,
  ) {
    final result = <Map<String, dynamic>>[];

    for (final goldType in WidgetConfig.golds) {
      try {
        final apiCode = WidgetConfig.goldTypeToCode(goldType);
        final gold = marketData.golds.firstWhere((g) => g.code == apiCode);

        final item = WidgetItemData(
          code: goldType.displayCode,
          displayName: goldType.localizedName(l10n),
          buyingPrice: gold.buying,
          sellingPrice: gold.selling,
          change: gold.changeRate,
        );

        result.add(item.toJson());

        debugPrint(
          'Gold ${item.code} (${item.displayName}): change=${item.change}, '
          'isIncreasing=${item.isIncreasing}',
        );
      } catch (e) {
        debugPrint('⚠ Gold type $goldType not found in API response');
      }
    }

    return result;
  }

  /// Extract exactly 4 cryptos: BTC, ETH, USDT, BNB
  List<Map<String, dynamic>> _extractCryptos(MarketResponse marketData) {
    final result = <Map<String, dynamic>>[];

    for (final code in WidgetConfig.cryptos) {
      try {
        final crypto = marketData.cryptos.firstWhere((c) => c.code == code);

        final item = WidgetCryptoData(
          code: crypto.code,
          displayName: crypto.name,
          usdPrice: crypto.usdPrice,
          sellingUsd: crypto.selling,
          change: crypto.changeRate,
        );

        result.add(item.toJson());

        debugPrint(
          'Crypto ${item.code}: usd=${item.usdPrice}, '
          'change=${item.change}, isIncreasing=${item.isIncreasing}',
        );
      } catch (e) {
        debugPrint('⚠ Crypto $code not found in API response');
      }
    }

    return result;
  }

  /// Get localized currency name
  String _getCurrencyName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'USD':
        return l10n.currencyUSD;
      case 'EUR':
        return l10n.currencyEUR;
      case 'GBP':
        return l10n.currencyGBP;
      case 'CHF':
        return l10n.currencyCHF;
      default:
        return code;
    }
  }

  /// Get localized labels
  Map<String, String> _getLabels(AppLocalizations l10n) => {
    'currency': l10n.currency,
    'gold': l10n.gold,
    'crypto': l10n.crypto,
    'code': 'Code',
    'buying': l10n.buying,
    'selling': l10n.selling,
    'change': l10n.change,
    'updated': l10n.updated,
  };

  Future<void> _saveLocale(String languageCode) async {
    await HomeWidget.saveWidgetData<String>(_widgetLocaleKey, languageCode);
  }

  Future<void> _updatePlatformWidget() async {
    try {
      await HomeWidget.updateWidget(
        name: 'HomeWidget',
        androidName: 'HomeWidget',
        iOSName: 'HomeWidget',
      );
    } catch (e) {
      debugPrint('✗ Failed to update platform widget: $e');
    }
  }

  /// Background callback for periodic updates (runs in isolate)
  static Future<void> backgroundCallback(Uri? uri) async {
    try {
      debugPrint('Widget background update started');

      final marketService = MarketService();
      final marketData = await marketService.fetchMarketData();

      final locale =
          await HomeWidget.getWidgetData<String>(_widgetLocaleKey) ?? 'en';
      final labels = _getBasicLabels(locale);

      final widgetData = {
        'currencies': _extractBackgroundCurrencies(marketData),
        'golds': _extractBackgroundGolds(marketData, locale),
        'cryptos': _extractBackgroundCryptos(marketData),
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

      await HomeWidget.updateWidget(
        name: 'HomeWidget',
        androidName: 'HomeWidget',
        iOSName: 'HomeWidget',
      );

      debugPrint('✓ Background widget update completed');
    } catch (e) {
      debugPrint('✗ Background update failed: $e');
    }
  }

  /// Extract currencies for background update (no l10n context)
  static List<Map<String, dynamic>> _extractBackgroundCurrencies(
    MarketResponse marketData,
  ) {
    final result = <Map<String, dynamic>>[];

    for (final code in WidgetConfig.currencies) {
      try {
        final currency = marketData.currencies.firstWhere(
          (c) => c.code == code,
        );
        result.add({
          'code': currency.code,
          'name': currency.code,
          'buying': currency.buying,
          'selling': currency.selling,
          'change': currency.changeRate,
        });
      } catch (_) {}
    }

    return result;
  }

  /// Extract golds for background update with localized names
  static List<Map<String, dynamic>> _extractBackgroundGolds(
    MarketResponse marketData,
    String locale,
  ) {
    final result = <Map<String, dynamic>>[];

    for (final goldType in WidgetConfig.golds) {
      try {
        final apiCode = WidgetConfig.goldTypeToCode(goldType);
        final gold = marketData.golds.firstWhere((g) => g.code == apiCode);

        result.add({
          'code': goldType.displayCode,
          'name': _getGoldNameForLocale(goldType, locale),
          'buying': gold.buying,
          'selling': gold.selling,
          'change': gold.changeRate,
        });
      } catch (_) {}
    }

    return result;
  }

  /// Extract cryptos for background update
  static List<Map<String, dynamic>> _extractBackgroundCryptos(
    MarketResponse marketData,
  ) {
    final result = <Map<String, dynamic>>[];

    for (final code in WidgetConfig.cryptos) {
      try {
        final crypto = marketData.cryptos.firstWhere((c) => c.code == code);
        result.add({
          'code': crypto.code,
          'name': crypto.name,
          'usdPrice': crypto.usdPrice,
          'sellingUsd': crypto.selling,
          'change': crypto.changeRate,
        });
      } catch (_) {}
    }

    return result;
  }

  /// Get gold name for locale (without full l10n context)
  static String _getGoldNameForLocale(GoldType type, String locale) {
    if (locale == 'tr') {
      switch (type) {
        case GoldType.gram:
          return 'Gram Altın';
        case GoldType.quarter:
          return 'Çeyrek Altın';
        case GoldType.half:
          return 'Yarım Altın';
        case GoldType.full:
          return 'Tam Altın';
      }
    } else {
      switch (type) {
        case GoldType.gram:
          return 'Gram Gold';
        case GoldType.quarter:
          return 'Quarter Gold';
        case GoldType.half:
          return 'Half Gold';
        case GoldType.full:
          return 'Full Gold';
      }
    }
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

  /// Check if widget needs update
  Future<bool> shouldUpdate() async {
    try {
      final lastUpdate = await HomeWidget.getWidgetData<String>(_lastUpdateKey);
      if (lastUpdate == null) return true;

      final lastUpdateTime = DateTime.parse(lastUpdate);
      final now = DateTime.now();

      return now.difference(lastUpdateTime).inMinutes > 30;
    } catch (e) {
      return true;
    }
  }
}