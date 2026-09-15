class RedemptionModel {
  final int id;
  final int userId;
  final String? userName;
  final int rewardId;
  final String rewardName;
  final int pointsUsed;
  final String status;
  final String? notes;
  final String? voucherCode;
  final String? createdAt;

  const RedemptionModel({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.rewardName,
    required this.pointsUsed,
    required this.status,
    this.userName,
    this.notes,
    this.voucherCode,
    this.createdAt,
  });

  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    return RedemptionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      rewardId: (json['reward_id'] as num?)?.toInt() ?? 0,
      rewardName: json['reward_name'] as String? ?? '',
      pointsUsed: (json['points_used'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      userName: json['user_name'] as String?,
      notes: json['notes'] as String?,
      voucherCode: json['voucher_code'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
