import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/models/gold_data.dart';
import 'package:inves_tracker/core/models/crypto_data.dart';
import 'package:inves_tracker/core/models/market_response.dart';

class MarketService {
  static const String _baseUrl = 'https://finans.truncgil.com/v4/today.json';
  
  static const List<String> _allCurrencies = [
    'USD', 'EUR', 'GBP', 'CHF', 'CAD', 'JPY', 'SAR', 
    'RUB', 'AED', 'KWD', 'AUD', 'DKK', 'SEK', 'NOK'
  ];

  static const List<String> _allGolds = [
    'HAS', 'GRA', 'CEYREKALTIN', 'YARIMALTIN', 'TAMALTIN', 'ATAALTIN',
    'RESATALTIN', 'CUMHURIYETALTINI', 'GREMSEALTIN', '14AYARALTIN',
    '18AYARALTIN', 'YIA', 'IKIBUCUKALTIN', 'BESLIALTIN'
  ];

  static const List<String> _allCryptos = [
    'BTC', 'ETH', 'USDT', 'XRP', 'BNB', 'SOL', 'USDC', 'STETH',
    'DOGE', 'TRX', 'ADA', 'WSTETH', 'WBTC', 'HYPE', 'TON',
    'LINK', 'BCH', 'AVAX', 'XLM', 'SUI', 'DOT', 'UNI',
    'ZEC', 'LTC', 'XMR', 'CRO', 'NEAR', 'WETH', 'LEO',
    'MNT', 'PYUSD', 'USDS', 'USDE', 'M', 'CBBTC', 'WEETH',
    'SUSDE', 'SUSDS', 'TAO', 'WBETH', 'BSC-USD', 'USDT0', 'CC'
  ];


  Future<MarketResponse> fetchMarketData() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Extract update time
        String updateTime = 'N/A';
        if (data.containsKey('Update_Date')) {
          updateTime = _formatTime(data['Update_Date']);
        }
        
        // Extract currencies
        final currencyList = _allCurrencies
            .where((code) => data.containsKey(code))
            .map((code) => CurrencyData.fromJson(code, data[code]))
            .toList();
        
        // Extract golds
        final goldList = _allGolds
            .where((code) => data.containsKey(code))
            .map((code) => GoldData.fromJson(code, data[code]))
            .toList();
        
        // Extract cryptos
        final cryptoList = _allCryptos
            .where((code) => data.containsKey(code))
            .map((code) => CryptoData.fromJson(code, data[code]))
            .toList();
        
        return MarketResponse(
          currencies: currencyList,
          golds: goldList,
          cryptos: cryptoList,
          updateTime: updateTime,
        );
      } else {
        throw Exception('Failed to load market data');
      }
    } catch (e) {
      throw Exception('Error fetching market data: $e');
    }
  }

  static String _formatTime(String dateTimeString) {
    try {
      final parts = dateTimeString.split(' ');
      if (parts.length == 2) {
        return parts[1]; // Return just the time part: "17:05:01"
      }
      return dateTimeString;
    } catch (e) {
      return 'N/A';
    }
  }
}