import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'petugas_login_screen.dart';
import 'petugas_page.dart';
import 'main.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'config/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  final Color backgroundColor = AppColors.surface;
  final Color primaryDarkColor = AppColors.primary;
  final Color inputFillColor = AppColors.surfaceBorderWarm;
  final Color borderColor = AppColors.surfaceBorderSoft;
  final Color textDark = AppColors.text;
  final Color textGray = AppColors.textMuted;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan kata sandi wajib diisi.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang kembali, ${result.user.name}!'),
          backgroundColor: primaryDarkColor,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => result.user.isPetugasOrAdmin
              ? const PetugasMainScreen()
              : const MainNavigationScreen(),
        ),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Terjadi kesalahan koneksi. Pastikan backend Go API aktif.';
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
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
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
                          child:
                              Icon(Icons.arrow_back, size: 28, color: textDark),
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
                                    border: Border.all(
                                        color: borderColor, width: 1),
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

                    const SizedBox(height: 48),
                    Text(
                      'Selamat Datang Kembali',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masuk ke akun EcoPoints milikmu.',
                      style: TextStyle(fontSize: 15, color: textGray),
                    ),
                    const SizedBox(height: 32),

                    // Error Message Banner
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
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

                    Text('Email',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDeco('masukkan email'),
                    ),
                    const SizedBox(height: 24),

                    Text('Kata Sandi',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      decoration: _inputDeco('masukkan kata sandi').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: textGray,
                          ),
                          onPressed: () =>
                              setState(() => _isObscure = !_isObscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
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
                                'Masuk',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const Spacer(),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        ),
                        child: RichText(
                          text: TextSpan(
                            text: 'Belum punya akun? ',
                            style: TextStyle(color: textGray, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Daftar Sekarang',
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
                    const SizedBox(height: 12),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PetugasLoginScreen()),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined,
                                color: textDark, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              'Masuk sebagai Petugas',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: textDark,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryDarkColor, width: 1.5),
      ),
    );
  }
}
