class WasteDepositModel {
  final int id;
  final String code;
  final int userId;
  final String userName;
  final int wasteTypeId;
  final String wasteTypeName;
  final int pointsPerKg;
  final int? dropPointId;
  final String? dropPointName;
  final double weightKg;
  final double originalWeightKg;
  final double? actualWeightKg;
  final int estimatedPoints;
  final int? earnedPoints;
  final String status;
  final String? notes;
  final String? createdAt;

  const WasteDepositModel({
    required this.id,
    required this.code,
    required this.userId,
    required this.userName,
    required this.wasteTypeId,
    required this.wasteTypeName,
    required this.pointsPerKg,
    this.dropPointId,
    this.dropPointName,
    required this.weightKg,
    required this.originalWeightKg,
    this.actualWeightKg,
    required this.estimatedPoints,
    this.earnedPoints,
    required this.status,
    this.notes,
    this.createdAt,
  });

  factory WasteDepositModel.fromJson(Map<String, dynamic> json) {
    return WasteDepositModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code'] as String? ?? '',
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      userName: json['user_name'] as String? ?? '',
      wasteTypeId: (json['waste_type_id'] as num?)?.toInt() ?? 0,
      wasteTypeName: json['waste_type_name'] as String? ?? '',
      pointsPerKg: (json['points_per_kg'] as num?)?.toInt() ?? 0,
      dropPointId: (json['drop_point_id'] as num?)?.toInt(),
      dropPointName: json['drop_point_name'] as String?,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      originalWeightKg: (json['original_weight_kg'] as num?)?.toDouble() ??
          (json['weight_kg'] as num?)?.toDouble() ??
          0.0,
      actualWeightKg: (json['actual_weight_kg'] as num?)?.toDouble(),
      estimatedPoints: (json['estimated_points'] as num?)?.toInt() ?? 0,
      earnedPoints: (json['earned_points'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
