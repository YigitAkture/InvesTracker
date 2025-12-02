import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/models/gold_data.dart';
import 'package:inves_tracker/core/models/crypto_data.dart';
import 'package:inves_tracker/core/models/market_response.dart';

class MarketService {
  static const String _baseUrl = 'https://finance.truncgil.com/api/today.json';
  
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
    'DOGE', 'TRX', 'ADA', 'SHIB', 'WSTETH', 'WBTC', 'HYPE', 'TON',
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
        
        // Extract update time from Meta_Data
        String updateTime = 'N/A';
        if (data.containsKey('Meta_Data') && data['Meta_Data']['Update_Date'] != null) {
          updateTime = _formatTime(data['Meta_Data']['Update_Date']);
        }
        
        // Get the Rates object
        final Map<String, dynamic> rates = data['Rates'] ?? {};
        
        // Extract currencies
        final currencyList = _allCurrencies
            .where((code) => rates.containsKey(code))
            .map((code) => CurrencyData.fromJson(code, rates[code]))
            .toList();
        
        // Extract golds
        final goldList = _allGolds
            .where((code) => rates.containsKey(code))
            .map((code) => GoldData.fromJson(code, rates[code]))
            .toList();
        
        // Extract cryptos
        final cryptoList = _allCryptos
            .where((code) => rates.containsKey(code))
            .map((code) => CryptoData.fromJson(code, rates[code]))
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
        return parts[1]; // Return just the time part: "15:26:02"
      }
      return dateTimeString;
    } catch (e) {
      return 'N/A';
    }
  }
}