import 'package:flutter/foundation.dart';

class LevelInfo {
  final int level;
  final String title;
  final double minKg;
  final String icon;
  final String description;

  const LevelInfo({
    required this.level,
    required this.title,
    required this.minKg,
    this.icon = '🌱',
    this.description = '',
  });
}

class AppLevels {
  static const List<LevelInfo> _tiers = [
    LevelInfo(
      level: 1,
      title: 'Pemula Hijau',
      minKg: 0.0,
      icon: '🌱',
      description: 'Langkah awal memulai kebiasaan memilah sampah.',
    ),
    LevelInfo(
      level: 2,
      title: 'Pejuang Hijau',
      minKg: 5.0,
      icon: '🌿',
      description: 'Mulai konsisten mendaur ulang sampah rumah tangga.',
    ),
    LevelInfo(
      level: 3,
      title: 'Pencinta Bumi',
      minKg: 15.0,
      icon: '🍀',
      description: 'Penyelamat lingkungan aktif dengan kontribusi nyata.',
    ),
    LevelInfo(
      level: 4,
      title: 'Sahabat Alam',
      minKg: 35.0,
      icon: '🌲',
      description: 'Mengurangi timbulan sampah di TPA secara signifikan.',
    ),
    LevelInfo(
      level: 5,
      title: 'Green Warrior',
      minKg: 75.0,
      icon: '⚔️',
      description: 'Pejuang daur ulang tangguh dengan dampak lingkungan luas.',
    ),
    LevelInfo(
      level: 6,
      title: 'Ahli Daur Ulang',
      minKg: 150.0,
      icon: '🏆',
      description: 'Inspirator komunitas dalam pengelolaan sampah mandiri.',
    ),
    LevelInfo(
      level: 7,
      title: 'Pelindung Ekosistem',
      minKg: 300.0,
      icon: '🛡️',
      description: 'Pahlawan lingkungan dengan jejak karbon minimal.',
    ),
    LevelInfo(
      level: 8,
      title: 'Legenda Lingkungan',
      minKg: 500.0,
      icon: '👑',
      description: 'Tingkat tertinggi dedikasi untuk kelestarian bumi.',
    ),
  ];

  static List<LevelInfo> get tiers => List.unmodifiable(_tiers);

  static LevelInfo fromKg(num kg) {
    final val = kg.toDouble();
    LevelInfo current = _tiers.first;
    for (final tier in _tiers) {
      if (val >= tier.minKg) current = tier;
    }
    return current;
  }

  static LevelInfo? nextLevel(num kg) {
    final val = kg.toDouble();
    for (final tier in _tiers) {
      if (val < tier.minKg) return tier;
    }
    return null;
  }

  static double progress(num kg) {
    final val = kg.toDouble();
    final current = fromKg(val);
    final next = nextLevel(val);
    if (next == null) return 1.0;
    final span = next.minKg - current.minKg;
    if (span <= 0) return 1.0;
    return ((val - current.minKg) / span).clamp(0.0, 1.0).toDouble();
  }

  static String label(num kg) {
    final info = fromKg(kg);
    return 'Lv. ${info.level} ${info.title}';
  }

  static String kgToNext(num kg) {
    final val = kg.toDouble();
    final next = nextLevel(val);
    if (next == null) return 'Level Maksimal';
    final remaining = (next.minKg - val).clamp(0.0, 99999.0);
    return '${remaining.toStringAsFixed(1)} kg lagi ke Lv. ${next.level}';
  }

  // Global notifier for user's total recycled waste in Kilograms
  static final ValueNotifier<double> userTotalKgNotifier = ValueNotifier<double>(0.0);

  static void updateTotalKg(double totalKg) {
    if (userTotalKgNotifier.value != totalKg) {
      userTotalKgNotifier.value = totalKg;
    }
  }

  // Fallback helpers
  static LevelInfo fromPoints(num points) => fromKg(points);
  static String pointsToNext(num points) => kgToNext(points);
}
