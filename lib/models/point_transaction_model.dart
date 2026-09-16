class PointTransactionModel {
  final int id;
  final String type;
  final int amount;
  final String? description;
  final String? createdAt;

  const PointTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    this.createdAt,
  });

  factory PointTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointTransactionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
