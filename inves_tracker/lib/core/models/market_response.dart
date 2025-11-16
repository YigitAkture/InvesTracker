import 'package:inves_tracker/core/models/crypto_data.dart';
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/models/gold_data.dart';

class MarketResponse {
  final List<CryptoData> cryptos;
  final List<CurrencyData> currencies;
  final List<GoldData> golds;
  final String updateTime;

  MarketResponse({
    required this.cryptos,
    required this.currencies,
    required this.golds,
    required this.updateTime,
  });
}