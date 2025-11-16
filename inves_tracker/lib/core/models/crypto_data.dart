class CryptoData {
  final String code;
  final String name;
  final double usdPrice;
  final double tryPrice;
  final double changeRate;
  final bool isIncreasing;

  CryptoData({
    required this.code,
    required this.name,
    required this.usdPrice,
    required this.tryPrice,
    required this.changeRate,
    required this.isIncreasing,
  });

  factory CryptoData.fromJson(String code, Map<String, dynamic> json) {
    final change = (json['Change'] ?? 0.0).toDouble();
    
    return CryptoData(
      code: code,
      name: json['Name'] ?? code,
      usdPrice: (json['USD_Price'] ?? 0.0).toDouble(),
      tryPrice: (json['TRY_Price'] ?? 0.0).toDouble(),
      changeRate: change.abs(),
      isIncreasing: change >= 0,
    );
  }
}