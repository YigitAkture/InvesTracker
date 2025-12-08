class Debt {
  final String id;
  final String userId;
  final String debtType; // "Currency", "Gold", "Crypto"
  final String debtCode; // "USD", "GRA", "BTC", etc.
  final double amount;
  final String? note;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Debt({
    required this.id,
    required this.userId,
    required this.debtType,
    required this.debtCode,
    required this.amount,
    this.note,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      debtType: json['debtType'] ?? '',
      debtCode: json['debtCode'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      note: json['note'],
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : null,
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
      'debtType': debtType,
      'debtCode': debtCode,
      'amount': amount,
      'note': note,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Debt copyWith({
    String? id,
    String? userId,
    String? debtType,
    String? debtCode,
    double? amount,
    String? note,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      debtType: debtType ?? this.debtType,
      debtCode: debtCode ?? this.debtCode,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}