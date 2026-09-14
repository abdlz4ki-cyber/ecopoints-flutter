class LeaderboardEntry {
  final int rank;
  final int userId;
  final String name;
  final int pointsBalance;
  final double totalKg;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.pointsBalance,
    required this.totalKg,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      pointsBalance: (json['points_balance'] as num).toInt(),
      totalKg: (json['total_kg'] as num).toDouble(),
    );
  }
}
