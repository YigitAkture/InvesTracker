import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/models/gold_data.dart';
import 'package:inves_tracker/core/models/crypto_data.dart';
import 'package:inves_tracker/core/models/market_response.dart';
import 'package:inves_tracker/core/services/api_service.dart';

class MarketService {
  final ApiService _apiService = ApiService();

  static const List<String> _allCurrencies = [
    "USD", "EUR", "GBP", "CHF", "CAD", "RUB", "AED", "AUD", "DKK", "SEK", "NOK",
    "ISK", "JPY", "SGD", "NZD", "HKD", "THB", "PLN", "CZK", "HUF", "RON", "QAR", 
    "SAR", "BHD", "OMR", "KWD", "IQD", "LYD", "IRR", "LKR", "INR", "PKR", "IDR", 
    "MYR", "PHP", "MXN", "BRL", "ARS", "CLP", "COP", "PEN", "UYU", "CRC", "UAH", 
    "GEL", "AZN", "MKD", "BGN", "BAM", "MDL", "ALL", "LBP", "EGP", "DZD", "TND", 
    "SYP", "KZT", "CNY", "TWD"
  ];

  static const List<String> _allGolds = [
    'HAS', 'GRA', 'CEYREKALTIN', 'YARIMALTIN', 'TAMALTIN', 'ATAALTIN',
    'RESATALTIN', 'CUMHURIYETALTINI', 'GREMSEALTIN', '14AYARALTIN',
    '18AYARALTIN', 'YIA', 'IKIBUCUKALTIN', 'BESLIALTIN'
  ];

  static const List<String> _allCryptos = [
    'BTC', 'ETH', 'USDT', 'XRP', 'BNB', 'SOL', 'USDC', 'STETH',
    'DOGE', 'TRX', 'ADA', 'SHIB', 'WSTETH', 'WBTC', 'HYPE', 'TON',
    'LINK', 'BCH', 'AVAX', 'XLM', 'SUI', 'DOT', 'UNI',
    'ZEC', 'LTC', 'XMR', 'CRO', 'NEAR', 'WETH', 'LEO',
    'MNT', 'PYUSD', 'USDS', 'USDE', 'CBBTC', 'WEETH',
    'SUSDE', 'SUSDS', 'TAO', 'WBETH', 'CC'
  ];

  Future<MarketResponse> fetchMarketData() async {
    try {
      final response = await _apiService
          .get('MarketData')
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check if the backend is running.',
              );
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Extract update time
        String updateTime = 'N/A';
        if (data.containsKey('updateTime') && data['updateTime'] != null) {
          updateTime = _formatTime(data['updateTime']);
        }

        // Extract and filter currencies
        final List<dynamic> currenciesJson = data['currencies'] ?? [];
        final currencyList = currenciesJson
            .map((json) => CurrencyData.fromBackend(json))
            .where((currency) => _allCurrencies.contains(currency.code))
            .toList();

        currencyList.sort(
          (a, b) => _allCurrencies
              .indexOf(a.code)
              .compareTo(_allCurrencies.indexOf(b.code)),
        );

        // Extract and filter golds
        final List<dynamic> goldsJson = data['golds'] ?? [];
        final goldList = goldsJson
            .map((json) => GoldData.fromBackend(json))
            .where((gold) => _allGolds.contains(gold.code))
            .toList();

        goldList.sort(
          (a, b) =>
              _allGolds.indexOf(a.code).compareTo(_allGolds.indexOf(b.code)),
        );

        // Extract and filter cryptos
        final List<dynamic> cryptosJson = data['cryptos'] ?? [];
        final cryptoList = cryptosJson
            .map((json) => CryptoData.fromBackend(json))
            .where((crypto) => _allCryptos.contains(crypto.code))
            .toList();

        cryptoList.sort(
          (a, b) => _allCryptos
              .indexOf(a.code)
              .compareTo(_allCryptos.indexOf(b.code)),
        );

        return MarketResponse(
          currencies: currencyList,
          golds: goldList,
          cryptos: cryptoList,
          updateTime: updateTime,
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'API endpoint not found. Please check the backend URL.',
        );
      } else if (response.statusCode == 500) {
        throw Exception('Backend server error. Please check the backend logs.');
      } else {
        throw Exception(
          'Failed to load market data. Status: ${response.statusCode}',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Network error: Unable to connect to backend. Make sure the backend is running on http://localhost:5033',
      );
    } catch (e) {
      throw Exception('Error fetching market data: $e');
    }
  }

  static String _formatTime(String dateTimeString) {
    try {
      // Backend returns format like "2024-12-04 15:26:02"
      final parts = dateTimeString.split(' ');
      if (parts.length == 2) {
        return parts[1]; // Return just the time part: "15:26:02"
      }
      return dateTimeString;
    } catch (e) {
      return 'N/A';
    }
  }
}
