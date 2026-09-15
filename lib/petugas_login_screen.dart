import 'package:flutter/material.dart';
import 'petugas_page.dart';
import 'login_screen.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'config/app_colors.dart';

class PetugasLoginScreen extends StatefulWidget {
  const PetugasLoginScreen({super.key});
  @override
  State<PetugasLoginScreen> createState() => _PetugasLoginScreenState();
}

class _PetugasLoginScreenState extends State<PetugasLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  final Color primaryDarkColor = AppColors.primary;
  final Color textDark = AppColors.text;
  final Color textGray = AppColors.textMuted;
  final Color inputFillColor = AppColors.surfaceBorderWarm;
  final Color borderColor = AppColors.surfaceBorderSoft;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handlePetugasLogin() async {
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

      // Check role
      if (result.user.role != 'petugas' && result.user.role != 'admin') {
        await AuthService.logout();
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Akses Ditolak: Portal ini khusus untuk Petugas/Admin. Akun Anda terdaftar sebagai (${result.user.role}).';
        });
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Selamat datang di Portal Petugas, ${result.user.name}!'),
          backgroundColor: primaryDarkColor,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PetugasMainScreen()),
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
        _errorMessage = 'Gagal terhubung ke server Go API.';
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: primaryDarkColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user_outlined, size: 14),
                          SizedBox(width: 4),
                          Text('Petugas',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Text(
                  'Login Portal Petugas',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Khusus petugas verifikasi setoran dan bank sampah.',
                  style: TextStyle(fontSize: 15, color: textGray, height: 1.4),
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

                const Text('Email Petugas',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'masukkan ID petugas atau email',
                    hintStyle: TextStyle(color: textGray, fontSize: 14),
                    filled: true,
                    fillColor: inputFillColor,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: primaryDarkColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text('Kata Sandi',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    hintText: 'masukkan kata sandi',
                    hintStyle: TextStyle(color: textGray, fontSize: 14),
                    filled: true,
                    fillColor: inputFillColor,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: primaryDarkColor, width: 1.5),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: textGray,
                      ),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // TOMBOL MASUK PORTAL PETUGAS
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePetugasLogin,
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
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Masuk Portal Petugas',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 80),

                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Bukan petugas operasional? ',
                              style: TextStyle(color: textGray, fontSize: 13),
                            ),
                            TextSpan(
                              text: 'Masuk sebagai Pengguna',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: textDark),
                            ),
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.arrow_forward_ios_rounded,
                                    size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
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
