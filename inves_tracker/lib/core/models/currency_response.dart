import 'package:inves_tracker/core/models/currency_data.dart';

class CurrencyResponse {
  final List<CurrencyData> currencies;
  final String updateTime;

  CurrencyResponse({
    required this.currencies,
    required this.updateTime,
  });
}