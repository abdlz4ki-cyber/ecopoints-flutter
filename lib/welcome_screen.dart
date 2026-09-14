import 'package:ecopoints/login_screen.dart';
import 'package:ecopoints/register_screen.dart';
import 'package:ecopoints/petugas_login_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF5F3EC);
    final Color primaryDarkColor = const Color(0xFF2C4033);
    final Color textDark = const Color(0xFF1E1E1E);
    final Color textGray = const Color(0xFF6B6B6B);
    final Color cardBackgroundColor = const Color(0xFFECEAE0);
    final Color cardBorderColor = const Color(0xFFDCD8C9);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // HEADER KONSISTEN
                Row(
                  children: [
                    const SizedBox(width: 28), // Penyeimbang kiri
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: cardBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: cardBorderColor, width: 1),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'EcoPoints',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: primaryDarkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                  ],
                ),

                const SizedBox(height: 24),

                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    color: cardBorderColor,
                    child: Image.asset(
                      'assets/images/55.jpeg', // Path sesuai folder asset Anda
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Ini akan muncul jika nama file salah atau belum kedip di pubspec.yaml
                        return const Center(child: Icon(Icons.image, size: 50, color: Colors.grey));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Pilah sampahnya, kumpulkan poinnya, nikmati reward-nya',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                    height: 1.3,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Setor sampah anorganikmu, kumpulkan poinnya,\ndan tukarkan dengan voucher pilihanmu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: textGray, height: 1.5),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeatureCard('Pilah Sampah', 'Organik &\nAnorganik', Icons.recycling_rounded, cardBackgroundColor, cardBorderColor, primaryDarkColor),
                    _buildFeatureCard('Dapatkan\nPoin', 'Tiap Kilogram', Icons.monetization_on_outlined, cardBackgroundColor, cardBorderColor, primaryDarkColor),
                    _buildFeatureCard('Tukar Hadiah', 'Voucher &\nPulsa', Icons.card_giftcard_rounded, cardBackgroundColor, cardBorderColor, primaryDarkColor),
                  ],
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    icon: const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                    label: const Text('Masuk / Login', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDarkColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    icon: Icon(Icons.person_add_alt_1_rounded, color: primaryDarkColor, size: 22),
                    label: Text('Daftar Akun Baru', style: TextStyle(color: primaryDarkColor, fontSize: 16, fontWeight: FontWeight.w700)),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PetugasLoginScreen()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Masuk sebagai Petugas ', style: TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w500)),
                      Icon(Icons.arrow_forward, color: textDark, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color bgColor, Color borderColor, Color primaryColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: primaryColor, height: 1.2)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF6B6B6B), height: 1.2)),
          ],
        ),
      ),
    );
  }
}