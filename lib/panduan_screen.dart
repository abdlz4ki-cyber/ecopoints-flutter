import 'package:flutter/material.dart';
import 'config/app_colors.dart';
import 'config/app_levels.dart';

class PanduanScreen extends StatelessWidget {
  const PanduanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = AppColors.surface;
    const Color textDark = AppColors.text;
    const Color textGray = AppColors.textMuted;
    const Color cardBackgroundColor = AppColors.surfaceAlt;
    const Color cardBorderColor = AppColors.surfaceBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Judul
                const Text(
                  'Panduan Pengguna',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Petunjuk & Cara Penggunaan Aplikasi EcoPoints',
                  style: TextStyle(
                    fontSize: 12,
                    color: textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // CARD 1: Apa itu EcoPoints?
                _buildPanduanCard(
                  number: '01',
                  icon: Icons.eco_rounded,
                  title: 'Apa itu EcoPoints?',
                  description:
                      'EcoPoints adalah aplikasi buat kamu yang peduli sama kelestarian lingkungan! Di sini, sampah rumah tangga yang kamu pilah (seperti plastik, kardus, atau kaleng) disetorkan ke drop point terdekat untuk ditimbang dan ditukar menjadi Poin. Poin tersebut bisa ditukar dengan saldo e-wallet, voucher, atau pulsa.',
                  cardBackgroundColor: cardBackgroundColor,
                  cardBorderColor: cardBorderColor,
                  backgroundColor: backgroundColor,
                  textDark: textDark,
                  textGray: textGray,
                ),
                const SizedBox(height: 14),

                // CARD 2: Cara Daftar & Masuk Akun
                _buildPanduanCard(
                  number: '02',
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Cara Daftar & Masuk Akun',
                  description:
                      '• Belum punya akun? Klik tombol Register / Daftar di halaman login, lalu isi nama lengkap, email, dan buat kata sandi akun kamu.\n• Sudah punya akun? Cukup masukkan email dan kata sandi di halaman Login untuk langsung masuk ke Beranda EcoPoints.',
                  cardBackgroundColor: cardBackgroundColor,
                  cardBorderColor: cardBorderColor,
                  backgroundColor: backgroundColor,
                  textDark: textDark,
                  textGray: textGray,
                ),
                const SizedBox(height: 14),

                // CARD 3: Cara Menyetorkan Sampah & Dapat Poin
                _buildPanduanCard(
                  number: '03',
                  icon: Icons.recycling_rounded,
                  title: 'Cara Menyetorkan Sampah',
                  description:
                      '1. Buka Menu "Setor Sampah": Pilih jenis sampah yang ingin disetor dan masukkan perkiraan berat (kg).\n2. Pilih Lokasi Drop Point: Pilih titik drop point terdekat yang aktif di peta lokasi.\n3. Dapatkan Kode Transaksi / QR Code: Sistem membuat kode tiket unik untuk setoranmu.\n4. Serahkan ke Petugas: Kunjungi drop point, tunjukkan kode QR ke petugas untuk ditimbang fisiknya secara akurat.\n5. Poin & Kilogram Bertambah: Setelah diverifikasi petugas, poin dan total kilogram daur ulangmu langsung bertambah secara instan!',
                  cardBackgroundColor: cardBackgroundColor,
                  cardBorderColor: cardBorderColor,
                  backgroundColor: backgroundColor,
                  textDark: textDark,
                  textGray: textGray,
                ),
                const SizedBox(height: 14),

                // CARD 4: Cara Menukar Poin
                _buildPanduanCard(
                  number: '04',
                  icon: Icons.card_giftcard_rounded,
                  title: 'Cara Menukar Poin Hadiah',
                  description:
                      '• Masuk ke menu Katalog Hadiah.\n• Pilih hadiah impianmu (E-Wallet DANA, GoPay, OVO, ShopeePay, token listrik, atau voucher diskon belanja).\n• Pastikan saldo poinmu mencukupi, lalu klik "Tukar Sekarang".\n• Kupon digital atau permintaan transfer e-wallet akan langsung tercatat di Riwayat Penukaran.',
                  cardBackgroundColor: cardBackgroundColor,
                  cardBorderColor: cardBorderColor,
                  backgroundColor: backgroundColor,
                  textDark: textDark,
                  textGray: textGray,
                ),
                const SizedBox(height: 14),

                // CARD 5: Tingkat Level Berdasarkan Kilogram (Kg)
                _buildLevelGuideCard(
                  cardBackgroundColor: cardBackgroundColor,
                  cardBorderColor: cardBorderColor,
                  backgroundColor: backgroundColor,
                  textDark: textDark,
                  textGray: textGray,
                ),
                const SizedBox(height: 14),

                // CARD 6: Fitur Tambahan & Leaderboard
                _buildPanduanCard(
                  number: '06',
                  icon: Icons.leaderboard_rounded,
                  title: 'Peringkat & Dampak Ekologis',
                  description:
                      '• Papan Peringkat (Leaderboard): Pantau nasabah teraktif yang mengumpulkan kilogram sampah terbanyak.\n• Kalkulator Jejak Karbon: Setiap 1 kg sampah yang kamu setor dihitung setara mengurangi emisi karbon CO2 di bumi.\n• Peta Drop Point Interaktif: Temukan lokasi bank sampah dan pengepul resmi terdekat dengan navigasi arah yang mudah.',
                  cardBackgroundColor: cardBackgroundColor,
                  cardBorderColor: cardBorderColor,
                  backgroundColor: backgroundColor,
                  textDark: textDark,
                  textGray: textGray,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelGuideCard({
    required Color cardBackgroundColor,
    required Color cardBorderColor,
    required Color backgroundColor,
    required Color textDark,
    required Color textGray,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.military_tech_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level Berdasarkan Kilogram (Kg)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tingkatkan levelmu dengan menyetor sampah daur ulang',
                      style: TextStyle(fontSize: 11, color: textGray),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Level akunmu meningkat secara bertahap berdasarkan total berat fisik (kg) sampah yang berhasil disetorkan dan disetujui petugas:',
            style: TextStyle(fontSize: 11.5, color: textGray, height: 1.4),
          ),
          const SizedBox(height: 12),
          Column(
            children: AppLevels.tiers.map((tier) {
              final isTopTier = tier.level >= 7;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isTopTier
                        ? AppColors.gold.withValues(alpha: 0.5)
                        : cardBorderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isTopTier
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          tier.icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Lv. ${tier.level} ${tier.title}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isTopTier) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.star_rounded,
                                    size: 14, color: AppColors.gold),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tier.description,
                            style: TextStyle(
                              fontSize: 10,
                              color: textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isTopTier
                            ? AppColors.gold.withValues(alpha: 0.18)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tier.minKg == 0.0
                            ? 'Mulai 0 kg'
                            : '≥ ${tier.minKg.toStringAsFixed(tier.minKg % 1 == 0 ? 0 : 1)} kg',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isTopTier
                              ? AppColors.goldDark
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPanduanCard({
    required String number,
    required IconData icon,
    required String title,
    required String description,
    required Color cardBackgroundColor,
    required Color cardBorderColor,
    required Color backgroundColor,
    required Color textDark,
    required Color textGray,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: cardBorderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 13, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      number,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: textDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 11.5, color: textGray, height: 1.45),
          ),
        ],
      ),
    );
  }
}
