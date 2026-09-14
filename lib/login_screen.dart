import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'admin_login_screen.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;

  final Color backgroundColor = const Color(0xFFF5F3EC);
  final Color primaryDarkColor = const Color(0xFF2C4033);
  final Color inputFillColor = const Color(0xFFEBE6DC);
  final Color borderColor = const Color(0xFFD6D1C7);
  final Color textDark = const Color(0xFF1E1E1E);
  final Color textGray = const Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // HEADER KONSISTEN
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back, size: 28, color: textDark),
                        ),
                        Expanded(
                          child: Center(
                            child: Row(
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
                          ),
                        ),
                        const SizedBox(width: 28),
                      ],
                    ),

                    const SizedBox(height: 48),
                    Text('Selamat Datang Kembali', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textDark, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    Text('Masuk ke akun EcoPoints milikmu.', style: TextStyle(fontSize: 15, color: textGray)),
                    const SizedBox(height: 40),

                    Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
                    const SizedBox(height: 8),
                    TextField(decoration: _inputDeco('masukkan email')),
                    const SizedBox(height: 24),

                    Text('Kata Sandi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
                    const SizedBox(height: 8),
                    TextField(
                      obscureText: _isObscure,
                      decoration: _inputDeco('masukkan kata sandi').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: textGray),
                          onPressed: () => setState(() => _isObscure = !_isObscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // Mengarahkan ke MainNavigationScreen dan menghapus riwayat halaman login
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MainNavigationScreen(      )),
                                (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryDarkColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Masuk', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const Spacer(),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                        child: RichText(
                          text: TextSpan(
                            text: 'Belum punya akun? ', style: TextStyle(color: textGray, fontSize: 14),
                            children: [TextSpan(text: 'Daftar Sekarang', style: TextStyle(color: primaryDarkColor, fontWeight: FontWeight.w700))],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: borderColor, thickness: 1),
                    const SizedBox(height: 12),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginScreen())),
                        child: Icon(Icons.shield_outlined, color: textDark, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textGray, fontSize: 14),
      filled: true,
      fillColor: inputFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryDarkColor, width: 1.5)),
    );
  }
}