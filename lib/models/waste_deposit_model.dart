class WasteDepositItemModel {
  final int id;
  final int wasteTypeId;
  final String wasteTypeName;
  final int pointsPerKg;
  final double weightKg;
  final double originalWeightKg;
  final double? actualWeightKg;
  final int estimatedPoints;
  final int? earnedPoints;

  const WasteDepositItemModel({
    required this.id,
    required this.wasteTypeId,
    required this.wasteTypeName,
    required this.pointsPerKg,
    required this.weightKg,
    required this.originalWeightKg,
    this.actualWeightKg,
    required this.estimatedPoints,
    this.earnedPoints,
  });

  factory WasteDepositItemModel.fromJson(Map<String, dynamic> json) {
    return WasteDepositItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      wasteTypeId: (json['waste_type_id'] as num?)?.toInt() ?? 0,
      wasteTypeName: json['waste_type_name'] as String? ?? '',
      pointsPerKg: (json['points_per_kg'] as num?)?.toInt() ?? 0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      originalWeightKg: (json['original_weight_kg'] as num?)?.toDouble() ??
          (json['weight_kg'] as num?)?.toDouble() ??
          0.0,
      actualWeightKg: (json['actual_weight_kg'] as num?)?.toDouble(),
      estimatedPoints: (json['estimated_points'] as num?)?.toInt() ?? 0,
      earnedPoints: (json['earned_points'] as num?)?.toInt(),
    );
  }
}

class WasteDepositModel {
  final int id;
  final String code;
  final int userId;
  final String userName;
  final List<WasteDepositItemModel> items;
  final double totalWeightKg;
  final int estimatedPoints;
  final int? earnedPoints;
  final int? dropPointId;
  final String? dropPointName;
  final String status;
  final int? verifiedBy;
  final String? verifierName;
  final String? notes;
  final String? createdAt;

  const WasteDepositModel({
    required this.id,
    required this.code,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalWeightKg,
    required this.estimatedPoints,
    this.earnedPoints,
    this.dropPointId,
    this.dropPointName,
    required this.status,
    this.verifiedBy,
    this.verifierName,
    this.notes,
    this.createdAt,
  });

  // Convenience getters for backwards compatibility / UI display
  String get wasteTypeName {
    if (items.isEmpty) return 'Sampah';
    if (items.length == 1) return items.first.wasteTypeName;
    return '${items.first.wasteTypeName} +${items.length - 1} lainnya';
  }

  double get weightKg => totalWeightKg;
  double get originalWeightKg =>
      items.fold<double>(0.0, (sum, i) => sum + i.originalWeightKg);
  double? get actualWeightKg {
    if (items.isEmpty) return null;
    final hasActual = items.any((i) => i.actualWeightKg != null);
    if (!hasActual) return null;
    return items.fold<double>(
        0.0, (sum, i) => sum + (i.actualWeightKg ?? i.weightKg));
  }

  int get pointsPerKg => items.isNotEmpty ? items.first.pointsPerKg : 0;

  factory WasteDepositModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    List<WasteDepositItemModel> items = [];
    if (rawItems is List) {
      items = rawItems
          .map((i) => WasteDepositItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    final totalWeight = (json['total_weight_kg'] as num?)?.toDouble() ??
        (json['weight_kg'] as num?)?.toDouble() ??
        items.fold<double>(0.0, (sum, i) => sum + i.weightKg);

    return WasteDepositModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code'] as String? ?? '',
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      userName: json['user_name'] as String? ?? '',
      items: items,
      totalWeightKg: totalWeight,
      estimatedPoints: (json['estimated_points'] as num?)?.toInt() ?? 0,
      earnedPoints: (json['earned_points'] as num?)?.toInt(),
      dropPointId: (json['drop_point_id'] as num?)?.toInt(),
      dropPointName: json['drop_point_name'] as String?,
      status: json['status'] as String? ?? 'pending',
      verifiedBy: (json['verified_by'] as num?)?.toInt(),
      verifierName: json['verifier_name'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

}

