import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'config/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPassObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  final Color primaryDarkColor = AppColors.primary;
  final Color textDark = AppColors.text;
  final Color textGray = AppColors.textMuted;
  final Color inputFillColor = AppColors.surfaceBorderWarm;
  final Color borderColor = AppColors.surfaceBorderSoft;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Semua field wajib diisi.';
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _errorMessage = 'Kata sandi minimal 8 karakter.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Konfirmasi kata sandi tidak cocok.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Pendaftaran berhasil! Silakan masuk dengan akun Anda.'),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal mendaftar. Periksa koneksi ke Go API.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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
                                border:
                                    Border.all(color: borderColor, width: 1),
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

                const SizedBox(height: 40),
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mulai kelola sampah dan kumpulkan poinmu.',
                  style: TextStyle(fontSize: 15, color: textGray),
                ),
                const SizedBox(height: 24),

                // Error Message Banner
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.dangerSoft),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildLabel('Nama Lengkap'),
                _buildTextField(_nameController, 'masukkan nama lengkap'),
                const SizedBox(height: 18),

                _buildLabel('Email'),
                _buildTextField(_emailController, 'masukkan email',
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 18),

                _buildLabel('Kata Sandi (Min. 8 Karakter)'),
                _buildPasswordField(
                  _passwordController,
                  'masukkan kata sandi',
                  _isPassObscure,
                  () => setState(() => _isPassObscure = !_isPassObscure),
                ),
                const SizedBox(height: 18),

                _buildLabel('Konfirmasi Kata Sandi'),
                _buildPasswordField(
                  _confirmPasswordController,
                  'masukkan ulang kata sandi',
                  _isConfirmObscure,
                  () => setState(() => _isConfirmObscure = !_isConfirmObscure),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDarkColor,
                      disabledBackgroundColor:
                          primaryDarkColor.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Daftar Akun',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'Sudah punya akun? ',
                        style: TextStyle(color: textGray, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Masuk',
                            style: TextStyle(
                                color: primaryDarkColor,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: borderColor, thickness: 1),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
      );

  Widget _buildTextField(TextEditingController controller, String hint,
          {TextInputType? keyboardType}) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textGray, fontSize: 14),
          filled: true,
          fillColor: inputFillColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryDarkColor, width: 1.5),
          ),
        ),
      );

  Widget _buildPasswordField(TextEditingController controller, String hint,
          bool isObscure, VoidCallback onToggle) =>
      TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textGray, fontSize: 14),
          filled: true,
          fillColor: inputFillColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryDarkColor, width: 1.5),
          ),
          suffixIcon: IconButton(
            icon: Icon(
                isObscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: textGray),
            onPressed: onToggle,
          ),
        ),
      );
}
