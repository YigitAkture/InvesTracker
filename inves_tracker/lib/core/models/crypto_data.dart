class CryptoData {
  final String code;
  final String name;
  final double usdPrice;
  final double tryPrice;
  final double selling;
  final double sellingUsd; // Add this
  final double changeRate;
  final bool isIncreasing;

  CryptoData({
    required this.code,
    required this.name,
    required this.usdPrice,
    required this.tryPrice,
    required this.selling,
    required this.sellingUsd, // Add this
    required this.changeRate,
    required this.isIncreasing,
  });

  // Factory for backend API response
  factory CryptoData.fromBackend(Map<String, dynamic> json) {
    final change = (json['change'] ?? 0.0).toDouble();
    final selling = (json['selling'] ?? 0.0).toDouble();
    final usdPrice = (json['usdPrice'] ?? 0.0).toDouble();
    final tryPrice = (json['tryPrice'] ?? 0.0).toDouble();
    
    // Calculate USD selling price
    final sellingUsd = tryPrice > 0 ? (selling / tryPrice) * usdPrice : 0.0;
    
    return CryptoData(
      code: json['code'] ?? '',
      name: json['name'] ?? json['code'] ?? '',
      usdPrice: usdPrice,
      tryPrice: tryPrice,
      selling: selling,
      sellingUsd: sellingUsd,
      changeRate: change.abs(),
      isIncreasing: change >= 0,
    );
  }

  factory CryptoData.fromJson(String code, Map<String, dynamic> json) {
    final change = (json['Change'] ?? 0.0).toDouble();
    final selling = (json['Selling'] ?? 0.0).toDouble();
    final usdPrice = (json['USD_Price'] ?? 0.0).toDouble();
    final tryPrice = (json['TRY_Price'] ?? 0.0).toDouble();
    
    // Calculate USD selling price
    final sellingUsd = tryPrice > 0 ? (selling / tryPrice) * usdPrice : 0.0;
    
    return CryptoData(
      code: code,
      name: json['Name'] ?? code,
      usdPrice: usdPrice,
      tryPrice: tryPrice,
      selling: selling,
      sellingUsd: sellingUsd,
      changeRate: change.abs(),
      isIncreasing: change >= 0,
    );
  }
}