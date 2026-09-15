import 'package:flutter/material.dart';
import 'config/app_colors.dart';
import 'config/app_levels.dart';

class PanduanScreen extends StatelessWidget {
  const PanduanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = AppColors.surface;
    final Color textDark = AppColors.text;
    final Color textGray = AppColors.textMuted;
    final Color cardBackgroundColor = AppColors.surfaceAlt;
    final Color cardBorderColor = AppColors.surfaceBorder;

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
                Text(
                  'Panduan Pengguna',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
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
                  title: 'Apa itu EcoPoints?',
                  description:
                      'EcoPoints adalah aplikasi buat kamu yang peduli sama lingkungan! Di sini, sampah rumah tangga yang kamu miliki (seperti botol plastik, kardus, atau kaleng) bisa disetorkan untuk diubah jadi Poin. Poin tersebut nantinya bisa kamu tukar dengan berbagai hadiah menarik seperti saldo e-wallet, pulsa, atau voucher diskon.',
                  cardBackgroundColor: cardBackgroundColor,
                  cardBorderColor: cardBorderColor,
                  backgroundColor: backgroundColor,
                  textDark: textDark,
                  textGray: textGray,
                ),
                const SizedBox(height: 16),

                // CARD 2: Cara Daftar & Masuk Akun
                _buildPanduanCard(
                  number: '02',
                  title: 'Cara Daftar & Masuk Akun',
                  description:
                      '• Belum punya akun? Klik tombol Register / Daftar di halaman utama, lalu isi nama lengkap, email, dan buat password kamu. Setelah itu, kamu bisa langsung login.\n• Sudah punya akun? Cukup masukkan email dan password kamu di halaman Login, lalu klik Masuk untuk masuk ke Beranda.',
                  cardBackgroundColor: cardBackgroundColor,
                  cardBorderColor: cardBorderColor,
                  backgroundColor: backgroundColor,
                  textDark: textDark,
                  textGray: textGray,
                ),
                const SizedBox(height: 16),

                // CARD 3: Cara Menyetorkan Sampah & Dapat Poin
                _buildPanduanCard(
                  number: '03',
                  title: 'Cara Menyetorkan Sampah & Dapat Poin',
                  description:
                      'Mau tahu gimana caranya dapetin poin dari sampahmu? Ikuti langkah-langkah gampang ini:\n• Buka Menu "Setor Sampah": Pilih jenis sampah yang mau kamu setor (misal: Plastik PET, Kardus, Kaleng) dan masukkan perkiraan berat atau jumlahnya.\n• Pilih Lokasi Penyerahan: Pilih lokasi (pengepul) terdekat.\n• Dapatkan QR Code: Setelah submit, sistem akan otomatis bikin QR Code / Kode Transaksi Unik buat kamu.\n• Datangi Pengepul: Pergi ke titik pengepul terdekat, tunjukkan QR Code kamu ke petugas. Petugas akan menimbang sampah fisikmu.\n• Poin Masuk Otomatis: Kalau data sudah cocok, petugas akan menyetujui setoranmu, dan Poin akan langsung bertambah ke akunmu secara real-time! Status setoranmu di aplikasi akan berubah jadi "Selesai".',
                  cardBackgroundColor: cardBackgroundColor,
                  cardBorderColor: cardBorderColor,
                  backgroundColor: backgroundColor,
                  textDark: textDark,
                  textGray: textGray,
                ),
                const SizedBox(height: 16),

                // CARD 4: Cara Menukar Poin
                _buildPanduanCard(
                  number: '04',
                  title: 'Cara Menukar Poin',
                  description:
                      'Poinmu sudah banyak? Saatnya ditukar dengan hadiah impian:\n• Masuk ke menu Katalog Hadiah\n• Pilih hadiah atau voucher yang kamu inginkan (pastikan saldo poinmu mencukupi syaratnya, ya!).\n• Klik Tukar Poin.\n• Poinmu akan terpotong otomatis, dan kamu bakal dapat kode voucher atau status klaim hadiah yang bisa dicek di menu Riwayat Penukaran.',
                  cardBackgroundColor: cardBackgroundColor,
                  cardBorderColor: cardBorderColor,
                  backgroundColor: backgroundColor,
                  textDark: textDark,
                  textGray: textGray,
                ),
                const SizedBox(height: 16),

                // CARD 5: Fitur Seru Lainnya
                _buildPanduanCard(
                  number: '05',
                  title: 'Fitur Seru Lainnya',
                  description:
                      '• Leaderboard (Papan Peringkat): Mau lihat siapa yang paling jago kumpulin sampah dan peduli lingkungan? Cek menu Leaderboard buat lihat peringkat poin tertinggi minggu ini atau bulan ini!\n• Riwayat (History): Mau ngecek catatan masa lalu? Kamu bisa lihat daftar lengkap riwayat setoran sampah yang pernah kamu lakukan beserta riwayat hadiah apa saja yang sudah pernah kamu tukar.',
                  cardBackgroundColor: cardBackgroundColor,
                  cardBorderColor: cardBorderColor,
                  backgroundColor: backgroundColor,
                  textDark: textDark,
                  textGray: textGray,
                ),
                const SizedBox(height: 16),

                // CARD 6: Level & Ambang Poin
                _buildPanduanCard(
                  number: '06',
                  title: 'Level & Ambang Poin',
                  description:
                      'Semakin banyak poin yang kamu kumpulkan, semakin tinggi levelmu:\n${AppLevels.tiers.map((t) => '• Lv. ${t.level} ${t.title} — mulai ${t.minPoints} poin').join('\n')}',
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

  Widget _buildPanduanCard({
    required String number,
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
                child: Text(
                  number,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: textDark),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 11, color: textGray, height: 1.4),
          ),
        ],
      ),
    );
  }
}
