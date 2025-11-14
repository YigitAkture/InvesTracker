class CurrencyData {
  final String code;
  final String name;
  final double buying;
  final double selling;
  final double changeRate;
  final bool isIncreasing;

  CurrencyData({
    required this.code,
    required this.name,
    required this.buying,
    required this.selling,
    required this.changeRate,
    required this.isIncreasing,
  });

  factory CurrencyData.fromJson(String code, Map<String, dynamic> json) {
    final buying = (json['Buying'] ?? 0.0).toDouble();
    final change = (json['Change'] ?? 0.0).toDouble();
    
    return CurrencyData(
      code: code,
      name: _getCurrencyName(code),
      buying: buying,
      selling: (json['Selling'] ?? 0.0).toDouble(),
      changeRate: change.abs(),
      isIncreasing: change >= 0,
    );
  }

  static String _getCurrencyName(String code) {
    const Map<String, String> names = {
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'CHF': 'Swiss Franc',
      'CAD': 'Canadian Dollar',
      'JPY': 'Japanese Yen',
      'SAR': 'Saudi Riyal',
      'RUB': 'Russian Ruble',
      'AED': 'UAE Dirham',
      'KWD': 'Kuwaiti Dinar',
      'AUD': 'Australian Dollar',
      'DKK': 'Danish Krone',
      'SEK': 'Swedish Krona',
      'NOK': 'Norwegian Krone',
    };
    return names[code] ?? code;
  }
}