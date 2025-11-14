import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/models/currency_response.dart';

class CurrencyService {
  static const String _baseUrl = 'https://finans.truncgil.com/v4/today.json';
  
  static const List<String> _defaultCurrencies = ['USD', 'EUR', 'GBP', 'CHF'];
  static const List<String> _allCurrencies = [
    'USD', 'EUR', 'GBP', 'CHF', 'CAD', 'JPY', 'SAR', 
    'RUB', 'AED', 'KWD', 'AUD', 'DKK', 'SEK', 'NOK'
  ];

  Future<CurrencyResponse> fetchCurrencies({bool showAll = false}) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final currencies = showAll ? _allCurrencies : _defaultCurrencies;
        
        // Extract update time
        String updateTime = 'N/A';
        if (data.containsKey('Update_Date')) {
          updateTime = _formatTime(data['Update_Date']);
        }
        
        final currencyList = currencies
            .where((code) => data.containsKey(code))
            .map((code) => CurrencyData.fromJson(code, data[code]))
            .toList();
        
        return CurrencyResponse(
          currencies: currencyList,
          updateTime: updateTime,
        );
      } else {
        throw Exception('Failed to load currency data');
      }
    } catch (e) {
      throw Exception('Error fetching currencies: $e');
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