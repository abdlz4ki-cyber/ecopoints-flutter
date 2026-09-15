class LevelInfo {
  final int level;
  final String title;
  final int minPoints;

  const LevelInfo({
    required this.level,
    required this.title,
    required this.minPoints,
  });
}

class AppLevels {
  static const List<LevelInfo> _tiers = [
    LevelInfo(level: 1, title: 'Pemula Hijau', minPoints: 0),
    LevelInfo(level: 2, title: 'Pejuang Hijau', minPoints: 300),
    LevelInfo(level: 3, title: 'Pencinta Bumi', minPoints: 800),
    LevelInfo(level: 4, title: 'Green Warrior', minPoints: 1500),
    LevelInfo(level: 5, title: 'Ahli Daur Ulang', minPoints: 3000),
    LevelInfo(level: 6, title: 'Pelindung Ekosistem', minPoints: 6000),
    LevelInfo(level: 7, title: 'Legenda Lingkungan', minPoints: 10000),
  ];

  static List<LevelInfo> get tiers => List.unmodifiable(_tiers);

  static LevelInfo fromPoints(int points) {
    LevelInfo current = _tiers.first;
    for (final tier in _tiers) {
      if (points >= tier.minPoints) current = tier;
    }
    return current;
  }

  static LevelInfo? nextLevel(int points) {
    for (final tier in _tiers) {
      if (points < tier.minPoints) return tier;
    }
    return null;
  }

  static double progress(int points) {
    final current = fromPoints(points);
    final next = nextLevel(points);
    if (next == null) return 1.0;
    final span = next.minPoints - current.minPoints;
    if (span <= 0) return 1.0;
    return ((points - current.minPoints) / span).clamp(0.0, 1.0).toDouble();
  }

  static String label(int points) {
    final info = fromPoints(points);
    return 'Lv. ${info.level} ${info.title}';
  }

  static String pointsToNext(int points) {
    final next = nextLevel(points);
    if (next == null) return 'Level maksimal tercapai';
    return '${next.minPoints - points} poin menuju Lv. ${next.level}';
  }
}
