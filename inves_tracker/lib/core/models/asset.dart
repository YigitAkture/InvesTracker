class Asset {
  final String id;
  final String userId;
  final String assetType; // "Currency", "Gold", "Crypto"
  final String assetCode; // "USD", "GRA", "BTC", etc.
  final double amount;
  final double purchasePrice;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Asset({
    required this.id,
    required this.userId,
    required this.assetType,
    required this.assetCode,
    required this.amount,
    required this.purchasePrice,
    required this.createdAt,
    this.updatedAt,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      assetType: json['assetType'] ?? '',
      assetCode: json['assetCode'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      purchasePrice: (json['purchasePrice'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'assetType': assetType,
      'assetCode': assetCode,
      'amount': amount,
      'purchasePrice': purchasePrice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Asset copyWith({
    String? id,
    String? userId,
    String? assetType,
    String? assetCode,
    double? amount,
    double? purchasePrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assetType: assetType ?? this.assetType,
      assetCode: assetCode ?? this.assetCode,
      amount: amount ?? this.amount,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}