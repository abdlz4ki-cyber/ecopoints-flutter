import 'package:ecopoints/Petugas_page.dart';
import 'package:ecopoints/login_screen.dart';
import 'package:flutter/material.dart';

// Ganti dengan path file tempat PetugasMainScreen Anda berada, atau biarkan jika berada di file yang sama
// import 'petugas_page.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _isObscure = true;

  final Color primaryDarkColor = const Color(0xFF2C4033);
  final Color textDark = const Color(0xFF1E1E1E);
  final Color textGray = const Color(0xFF6B6B6B);
  final Color inputFillColor = const Color(0xFFEBE6DC);
  final Color borderColor = const Color(0xFFD6D1C7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // HEADER KONSISTEN
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back, size: 28, color: textDark),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: inputFillColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor, width: 1),
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primaryDarkColor),
                        ),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user_outlined, size: 14),
                          SizedBox(width: 4),
                          Text('Petugas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Text('Login Portal Admin', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text('Khusus petugas verifikasi dan pengelola bank\nsampah.', style: TextStyle(fontSize: 15, color: textGray, height: 1.4)),
                const SizedBox(height: 40),

                const Text('ID Petugas / Email Admin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'masukkan ID petugas atau email',
                    hintStyle: TextStyle(color: textGray, fontSize: 14),
                    filled: true,
                    fillColor: inputFillColor,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryDarkColor, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 20),

                const Text('Kata Sandi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    hintText: 'masukkan kata sandi',
                    hintStyle: TextStyle(color: textGray, fontSize: 14),
                    filled: true,
                    fillColor: inputFillColor,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryDarkColor, width: 1.5)),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: textGray),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // TOMBOL MASUK PORTAL ADMIN
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      // Mengarahkan ke halaman PetugasMainScreen dan menghapus riwayat halaman login admin
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const PetugasMainScreen()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDarkColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Masuk Portal Admin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 120),

                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Bukan petugas operasional? ', style: TextStyle(color: textGray, fontSize: 13)),
                        Text('Masuk sebagai Pengguna', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textDark)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: borderColor, thickness: 1),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}