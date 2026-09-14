import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPassObscure = true;
  bool _isConfirmObscure = true;

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

                const SizedBox(height: 40),
                const Text('Buat Akun Baru', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text('Mulai kelola sampah dan kumpulkan poinmu.', style: TextStyle(fontSize: 15, color: textGray)),
                const SizedBox(height: 32),

                _buildLabel('Nama Lengkap'),
                _buildTextField('masukkan nama lengkap'),
                const SizedBox(height: 20),

                _buildLabel('Email'),
                _buildTextField('masukkan email'),
                const SizedBox(height: 20),

                _buildLabel('Kata Sandi'),
                _buildPasswordField('masukkan kata sandi', _isPassObscure, () => setState(() => _isPassObscure = !_isPassObscure)),
                const SizedBox(height: 20),

                _buildLabel('Konfirmasi Kata Sandi'),
                _buildPasswordField('masukkan ulang kata sandi', _isConfirmObscure, () => setState(() => _isConfirmObscure = !_isConfirmObscure)),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: primaryDarkColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: const Text('Daftar Akun', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 40),

                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                    child: RichText(
                      text: TextSpan(
                        text: 'Sudah punya akun? ', style: TextStyle(color: textGray, fontSize: 14),
                        children: [TextSpan(text: 'Masuk', style: TextStyle(color: primaryDarkColor, fontWeight: FontWeight.w700))],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: borderColor, thickness: 1),
                const SizedBox(height: 12),
                const Center(child: Icon(Icons.shield_outlined, size: 20)),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)));
  Widget _buildTextField(String hint) => TextField(decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: textGray, fontSize: 14), filled: true, fillColor: inputFillColor, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryDarkColor, width: 1.5))));
  Widget _buildPasswordField(String hint, bool isObscure, VoidCallback onToggle) => TextField(obscureText: isObscure, decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: textGray, fontSize: 14), filled: true, fillColor: inputFillColor, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryDarkColor, width: 1.5)), suffixIcon: IconButton(icon: Icon(isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: textGray), onPressed: onToggle)));
}