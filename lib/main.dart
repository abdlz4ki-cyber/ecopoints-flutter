import 'dart:async';

import 'package:ecopoints/panduan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'welcome_screen.dart';
import 'petugas_page.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/waste_service.dart';
import 'services/reward_service.dart';
import 'services/firebase_push_service.dart';
import 'config/api_config.dart';
import 'config/app_constants.dart';
import 'config/app_levels.dart';
import 'models/user_model.dart';
import 'models/reward_model.dart';
import 'models/waste_type_model.dart';
import 'models/drop_point_model.dart';
import 'models/waste_deposit_model.dart';
import 'widgets/user_avatar.dart';
import 'widgets/splash_screen.dart';
import 'config/app_colors.dart';
import 'screens/hadiah_saya_screen.dart';
import 'screens/riwayat_screen.dart';
import 'screens/setoran_detail_screen.dart';
import 'screens/drop_point_map_screen.dart';
import 'screens/notification_center_screen.dart';
import 'services/notification_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  await FirebasePushService.init();
  runApp(const EcoPointsApp());
}

class EcoPointsApp extends StatelessWidget {
  const EcoPointsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoPoints',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          onPrimary: Colors.white,
        ),
      ),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashScreen();
    return ValueListenableBuilder<UserModel?>(
      valueListenable: AuthService.currentUserNotifier,
      builder: (context, user, _) {
        if (user == null) return const WelcomeScreen();
        if (user.isPetugasOrAdmin) return const PetugasMainScreen();
        return const MainNavigationScreen();
      },
    );
  }
}

// ================= Navigasi Utama =================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();

  static void changeTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<MainNavigationScreenState>();
    state?.setTab(index);
  }
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _pages = [
    const HomeScreen(),
    const PeringkatScreen(),
    const KatalogScreen(),
    const PanduanScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final Color cardBackgroundColor = AppColors.surfaceAlt;
    final Color cardBorderColor = AppColors.surfaceBorder;
    final Color primaryDarkColor = AppColors.primary;
    final Color textGray = AppColors.textMuted;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          border: Border(
            top: BorderSide(
              color: cardBorderColor,
              width: 1.0,
            ),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
            8, 10, 8, bottomPadding > 0 ? bottomPadding + 4 : 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
                Icons.home_rounded, 'Beranda', 0, primaryDarkColor, textGray),
            _buildNavItem(Icons.bar_chart_rounded, 'Peringkat', 1,
                primaryDarkColor, textGray),
            _buildNavItem(Icons.card_giftcard_rounded, 'Katalog', 2,
                primaryDarkColor, textGray),
            _buildNavItem(Icons.menu_book_rounded, 'Panduan', 3,
                primaryDarkColor, textGray),
            _buildNavItem(Icons.person_outline_rounded, 'Profil', 4,
                primaryDarkColor, textGray),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      Color activeColor, Color inactiveColor) {
    bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Halaman Beranda (HomeScreen) =================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _syncTimer;
  bool _appForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshProfile();
    _loadMyDeposits();
    _startPeriodicSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Sinkron ulang saat aplikasi kembali ke foreground.
    if (state == AppLifecycleState.resumed) {
      _appForeground = true;
      _silentRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _appForeground = false;
    }
  }

  // Polling ringan: perbarui poin & setoran secara near-realtime.
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_appForeground) _silentRefresh();
    });
  }

  Future<void> _silentRefresh() async {
    try {
      await Future.wait([_refreshProfile(), _loadMyDeposits()]);
    } catch (_) {}
  }

  List<WasteDepositModel> _myDeposits = [];
  bool _loadingDeposits = true;

  Future<void> _refreshProfile() async {
    try {
      await AuthService.getProfile();
    } catch (_) {}
  }

  Future<void> _loadMyDeposits() async {
    try {
      final results = await Future.wait([
        WasteService.getDeposits(),
      ]);
      if (mounted) {
        setState(() {
          _myDeposits = results[0];
          _loadingDeposits = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingDeposits = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = AppColors.surface;
    final Color primaryDarkColor = AppColors.primary;
    final Color textDark = AppColors.text;
    final Color textGray = AppColors.textMuted;
    final Color cardBackgroundColor = AppColors.surfaceAlt;
    final Color cardBorderColor = AppColors.surfaceBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryDarkColor,
          onRefresh: () async {
            await Future.wait([
              _refreshProfile(),
              _loadMyDeposits(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: ValueListenableBuilder<UserModel?>(
                valueListenable: AuthService.currentUserNotifier,
                builder: (context, user, _) {
                  final displayName = user?.name.isNotEmpty == true
                      ? user!.name
                      : 'Pengguna EcoPoints';
                  final points = user?.pointsBalance ?? 0;

                  final totalKg = _myDeposits.fold<double>(
                      0.0, (sum, d) => sum + d.weightKg);
                  final totalCo2 = totalKg * AppConstants.co2ReductionPerKg;

                  final levelInfo = AppLevels.fromPoints(points);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, $displayName!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: cardBorderColor),
                                ),
                                child: Text(
                                  AppLevels.label(points),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NotificationCenterScreen(),
                                    ),
                                  );
                                },
                                child: ValueListenableBuilder<int>(
                                  valueListenable:
                                      NotificationStorageService.unreadCountNotifier,
                                  builder: (context, unreadCount, _) {
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: cardBackgroundColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: cardBorderColor),
                                          ),
                                          child: Icon(
                                            unreadCount > 0
                                                ? Icons.notifications_active_rounded
                                                : Icons.notifications_none_rounded,
                                            color: unreadCount > 0
                                                ? AppColors.primary
                                                : textDark,
                                            size: 22,
                                          ),
                                        ),
                                        if (unreadCount > 0)
                                          Positioned(
                                            top: -2,
                                            right: -2,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: AppColors.danger,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 18,
                                                minHeight: 18,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  unreadCount > 99
                                                      ? '99+'
                                                      : unreadCount.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  MainNavigationScreen.changeTab(context, 4);
                                },
                                child: UserAvatar(name: displayName, size: 42),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryDarkColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SALDO POIN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.mutedOnDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  points.toString().replaceAllMapped(
                                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                        (Match m) => '${m[1]}.',
                                      ),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Poin',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.goldBright,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Lv. ${levelInfo.level} ${levelInfo.title}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.goldBright,
                                  ),
                                ),
                                Text(
                                  AppLevels.pointsToNext(points),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.mutedOnDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: AppLevels.progress(points),
                                minHeight: 4,
                                backgroundColor: AppColors.primaryOutline,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.goldBright),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SetorSampahScreen()),
                                        );
                                        _loadMyDeposits();
                                        _refreshProfile();
                                      },
                                      icon: const Icon(Icons.recycling,
                                          size: 18, color: AppColors.text),
                                      label: const Text(
                                        'Setor Sampah',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.surface,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        MainNavigationScreen.changeTab(
                                            context, 2);
                                      },
                                      icon: const Icon(Icons.card_giftcard,
                                          size: 18, color: Colors.white),
                                      label: const Text(
                                        'Tukar Hadiah',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: AppColors.primaryOutline,
                                            width: 1.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBackgroundColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: cardBorderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Sampah Terpilah',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: textGray,
                                              fontWeight: FontWeight.w500)),
                                      Icon(Icons.delete_outline,
                                          size: 16, color: textGray),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${totalKg.toStringAsFixed(1)} kg',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: textDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBackgroundColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: cardBorderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Reduksi Emisi',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: textGray,
                                              fontWeight: FontWeight.w500)),
                                      Icon(Icons.eco_outlined,
                                          size: 16, color: textGray),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${totalCo2.toStringAsFixed(1)} kg CO₂',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: textDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const DropPointMapScreen()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: cardBorderColor),
                                ),
                                child: const Icon(Icons.map_rounded,
                                    size: 18, color: AppColors.primary),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Peta Drop Point',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.text)),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Lihat lokasi bank sampah terdekat',
                                      style: TextStyle(
                                          fontSize: 10, color: textGray),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  size: 18, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Riwayat Aktivitas',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: textDark),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RiwayatScreen()),
                              );
                              _loadMyDeposits();
                              _refreshProfile();
                            },
                            child: Text(
                              'Lihat Semua >',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textGray),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_loadingDeposits)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          ),
                        )
                      else if (_myDeposits.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.recycling, size: 36, color: textGray),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada riwayat setoran',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textDark),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mulai pilah sampahmu dan setor untuk kumpulkan poin!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, color: textGray),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._myDeposits.take(3).map((deposit) {
                          final isVerified =
                              deposit.status.toLowerCase() == 'verified';
                          final isRejected =
                              deposit.status.toLowerCase() == 'rejected';
                          final statusText = isVerified
                              ? 'Selesai'
                              : (isRejected ? 'Ditolak' : 'Menunggu');
                          final statusBgColor = isVerified
                              ? AppColors.successBg
                              : (isRejected
                                  ? AppColors.dangerBg
                                  : AppColors.warningBg);
                          final statusTextColor = isVerified
                              ? AppColors.success
                              : (isRejected
                                  ? AppColors.danger
                                  : AppColors.warning);

                          String dateDisplay = 'Baru saja';
                          if (deposit.createdAt != null &&
                              deposit.createdAt!.length >= 10) {
                            dateDisplay = deposit.createdAt!.substring(0, 10);
                          }

                          final pointsValue =
                              deposit.earnedPoints ?? deposit.estimatedPoints;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SetoranDetailScreen(
                                          deposit: deposit)),
                                );
                              },
                              child: _buildActivityCard(
                                icon: Icons.recycling,
                                title: 'Setor ${deposit.wasteTypeName}',
                                subtitle:
                                    '${deposit.weightKg.toStringAsFixed(1)} kg • ${deposit.dropPointName ?? 'Drop Point'}\n$dateDisplay',
                                points: '+$pointsValue Poin',
                                pointsColor: AppColors.gold,
                                statusWidget: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBgColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: statusTextColor.withValues(
                                            alpha: 0.3)),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: statusTextColor),
                                  ),
                                ),
                                bgColor: cardBackgroundColor,
                                borderColor: cardBorderColor,
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String points,
    required Color pointsColor,
    required Widget statusWidget,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted, height: 1.3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(points,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: pointsColor)),
              const SizedBox(height: 6),
              statusWidget,
            ],
          ),
        ],
      ),
    );
  }
}

// ================= Halaman Papan Peringkat (PeringkatScreen) =================
class PeringkatScreen extends StatefulWidget {
  const PeringkatScreen({super.key});

  @override
  State<PeringkatScreen> createState() => _PeringkatScreenState();
}

class _PeringkatScreenState extends State<PeringkatScreen> {
  String _selectedTab = 'Bulan Ini';
  List<dynamic> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final period = _selectedTab == 'Bulan Ini' ? 'monthly' : 'all';
      final data = await ApiService.get(
          ApiConfig.leaderboard(period: period, limit: 10));
      if (!mounted) return;
      final List list = data is List ? data : [];
      setState(() {
        _entries = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = AppColors.surface;
    const Color primaryDarkColor = AppColors.primary;
    const Color textDark = AppColors.text;
    const Color textGray = AppColors.textMuted;
    const Color cardBackgroundColor = AppColors.surfaceAlt;
    const Color cardBorderColor = AppColors.surfaceBorder;

    final currentUser = AuthService.currentUserNotifier.value;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryDarkColor,
          onRefresh: _loadLeaderboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: cardBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardBorderColor),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, size: 18),
                              color: textDark,
                              onPressed: () =>
                                  MainNavigationScreen.changeTab(context, 0),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Papan Peringkat',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textDark),
                          ),
                        ],
                      ),
                      if (currentUser != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                currentUser.name.split(' ').first,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: textDark),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tab Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: Row(
                      children: ['Bulan Ini', 'Sepanjang Waktu'].map((tab) {
                        final isActive = _selectedTab == tab;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_selectedTab != tab) {
                                setState(() => _selectedTab = tab);
                                _loadLeaderboard();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? primaryDarkColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tab,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isActive ? Colors.white : textDark,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Content
                  if (_isLoading)
                    const SizedBox(
                      height: 300,
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary)),
                    )
                  else if (_error != null)
                    SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off_rounded,
                                size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text('Gagal memuat data',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: textDark)),
                            const SizedBox(height: 4),
                            Text(_error!,
                                style: const TextStyle(
                                    fontSize: 11, color: textGray),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _loadLeaderboard,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: primaryDarkColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Coba Lagi',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_entries.isEmpty)
                    const SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.leaderboard_outlined,
                                size: 48, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text('Belum ada data peringkat',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: textDark)),
                            SizedBox(height: 4),
                            Text('Mulai setor sampah untuk masuk leaderboard!',
                                style:
                                    TextStyle(fontSize: 11, color: textGray)),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Top 3 Podium
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('3 Besar Daur Ulang',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: textDark)),
                        Row(
                          children: const [
                            Icon(Icons.emoji_events,
                                size: 14, color: AppColors.gold),
                            SizedBox(width: 4),
                            Text('Top Kontributor',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: textGray)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildPodium(_entries, currentUser, cardBackgroundColor,
                        cardBorderColor, primaryDarkColor, textDark, textGray),
                    const SizedBox(height: 24),

                    // Rank 4+
                    if (_entries.length > 3) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Peringkat 4 – ${_entries.length}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: textDark),
                          ),
                          const Text('Geser ke bawah untuk memperbarui',
                              style: TextStyle(fontSize: 10, color: textGray)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_entries.length - 3, (i) {
                        final entry = _entries[i + 3];
                        final rank = entry['rank'] as int;
                        final name = entry['name'] as String? ?? '';
                        final points = entry['points_balance'] as int? ?? 0;
                        final kg =
                            (entry['total_kg'] as num?)?.toDouble() ?? 0.0;
                        final isMe = currentUser != null &&
                            (entry['user_id'] as int?) == currentUser.id;
                        final initials = name.trim().isEmpty
                            ? '?'
                            : name
                                .trim()
                                .split(' ')
                                .map((w) => w.isNotEmpty ? w[0] : '')
                                .take(2)
                                .join()
                                .toUpperCase();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildRankItem(
                            '$rank',
                            initials,
                            name,
                            '${kg.toStringAsFixed(1)} kg',
                            '${_formatPoints(points)} Poin',
                            isMe ? AppColors.greenTint : cardBackgroundColor,
                            isMe ? primaryDarkColor : cardBorderColor,
                            textDark,
                            textGray,
                            isMe,
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List entries, dynamic currentUser, Color cardBg,
      Color cardBorder, Color primaryDark, Color textDark, Color textGray) {
    // Re-arrange: left=2nd, center=1st, right=3rd
    final List<Map<String, dynamic>> podium = [];
    if (entries.length >= 2) {
      podium.add({'entry': entries[1], 'pos': 'left'});
    }
    if (entries.isNotEmpty) {
      podium.add({'entry': entries[0], 'pos': 'center'});
    }
    if (entries.length >= 3) {
      podium.add({'entry': entries[2], 'pos': 'right'});
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: podium.map((item) {
        final e = item['entry'] as Map<String, dynamic>;
        final pos = item['pos'] as String;
        final isCenter = pos == 'center';
        final rank = e['rank'] as int;
        final name = e['name'] as String? ?? '';
        final points = e['points_balance'] as int? ?? 0;
        final kg = (e['total_kg'] as num?)?.toDouble() ?? 0.0;
        final isMe =
            currentUser != null && (e['user_id'] as int?) == currentUser.id;
        final initials = name.trim().isEmpty
            ? '?'
            : name
                .trim()
                .split(' ')
                .map((w) => w.isNotEmpty ? w[0] : '')
                .take(2)
                .join()
                .toUpperCase();

        Color badgeColor;
        if (rank == 1) {
          badgeColor = AppColors.primary;
        } else if (rank == 2) {
          badgeColor = AppColors.silver;
        } else {
          badgeColor = AppColors.goldBright;
        }

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCenter ? primaryDark : cardBorder,
                width: isCenter ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: isCenter ? 22 : 20,
                  height: isCenter ? 22 : 20,
                  decoration:
                      BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: rank == 2 ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: isCenter ? const EdgeInsets.all(2) : EdgeInsets.zero,
                  decoration: isCenter
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryDark, width: 2))
                      : null,
                  child: CircleAvatar(
                    radius: isCenter ? 32 : 30,
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: isCenter ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        isMe
                            ? '${name.split(' ').first} (Anda)'
                            : name.split(' ').first,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCenter ? 12 : 11,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatPoints(points)} Poin',
                  style: TextStyle(
                    fontSize: isCenter ? 11 : 10,
                    fontWeight: isCenter ? FontWeight.w800 : FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${kg.toStringAsFixed(1)} kg',
                  style: TextStyle(fontSize: 9, color: textGray),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatPoints(int points) {
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(points % 1000 == 0 ? 0 : 1)}k';
    }
    return '$points';
  }

  Widget _buildRankItem(
      String rank,
      String initials,
      String name,
      String subtitle,
      String points,
      Color bgColor,
      Color borderColor,
      Color textDark,
      Color textGray,
      bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isMe ? 1.5 : 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(rank,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textDark)),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.avatarBgSoft,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Text(initials,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textDark)),
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
                        name,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Anda',
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 10, color: textGray)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(points,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold)),
        ],
      ),
    );
  }
}

// ================= Halaman Katalog Hadiah (KatalogScreen) =================
class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = [
    'Semua',
    'E-Wallet',
    'Listrik & Pulsa',
    'Voucher'
  ];
  List<RewardModel> _apiRewards = [];
  bool _isLoadingRewards = true;

  @override
  void initState() {
    super.initState();
    _loadApiRewards();
  }

  Future<void> _loadApiRewards() async {
    try {
      final results = await Future.wait([
        RewardService.getRewards(),
      ]);
      if (mounted) {
        setState(() {
          _apiRewards = results[0];
          _isLoadingRewards = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRewards = false;
        });
      }
    }
  }

  // Fungsi Konfirmasi Dialog Dinamis (E-Wallet vs Voucher/Token)
  void _showKonfirmasiDialog(BuildContext context, int rewardId, String title,
      int pointCost, String rewardType, int currentPoints) {
    final Color modalBgColor = AppColors.surface;
    final Color cardBgColor = AppColors.surfaceAlt;
    final Color borderColor = AppColors.surfaceBorder;
    final Color primaryColor = AppColors.primary;
    final Color textDark = AppColors.text;
    final TextEditingController phoneController = TextEditingController();
    final bool isEnoughPoints = currentPoints >= pointCost;
    final int remainingPoints = currentPoints - pointCost;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Dialog(
              backgroundColor: modalBgColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(
                            rewardType == 'ewallet'
                                ? Icons.account_balance_wallet
                                : Icons.card_giftcard,
                            size: 28,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Konfirmasi Penukaran',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textDark),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Apakah Anda yakin ingin menukarkan poin untuk hadiah ini?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              height: 1.3),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: modalBgColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Icon(
                                      rewardType == 'ewallet'
                                          ? Icons.account_balance_wallet
                                          : Icons.card_giftcard,
                                      size: 20,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rewardType == 'ewallet'
                                              ? 'E-WALLET TRANSFER'
                                              : 'VOUCHER / TOKEN',
                                          style: const TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textMuted),
                                        ),
                                        Text(title,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: textDark)),
                                        Text(
                                          '${pointCost.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")} Poin',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.gold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Divider(
                                    color: AppColors.surfaceBorder, height: 1),
                              ),

                              // TAMPILAN DINAMIS: E-Wallet (Input Nomor) vs Voucher (Kode Kupon)
                              if (isEnoughPoints) ...[
                                if (rewardType == 'ewallet') ...[
                                  const Text('Nomor HP / Akun Tujuan',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    enabled: !isSubmitting,
                                    decoration: InputDecoration(
                                      hintText: 'Contoh: 0812xxxxxxx',
                                      hintStyle: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textHint),
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: const Icon(
                                          Icons.phone_android,
                                          size: 18),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: AppColors.surfaceBorder)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: AppColors.surfaceBorder)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: AppColors.primary,
                                              width: 1.5)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 12),
                                    ),
                                    onChanged: (value) {
                                      setStateModal(() {});
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                      'Pastikan nomor aktif dan sesuai dengan akun e-wallet Anda.',
                                      style: TextStyle(
                                          fontSize: 9, color: Colors.grey)),
                                  const SizedBox(height: 12),
                                ] else ...[
                                  const Text('Informasi Penukaran:',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppColors.surfaceBorder),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SelectableText(
                                          'Kupon Digital EcoPoints',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: AppColors.primary),
                                        ),
                                        Icon(Icons.check_circle_outline,
                                            size: 16, color: Colors.green),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                      'Kupon voucher akan langsung tercatat di riwayat penukaran Anda.',
                                      style: TextStyle(
                                          fontSize: 9, color: Colors.grey)),
                                  const SizedBox(height: 12),
                                ],
                              ],

                              _buildRowDetail(
                                  'Saldo Saat Ini',
                                  '${currentPoints.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")} Poin',
                                  textDark),
                              const SizedBox(height: 6),
                              _buildRowDetail(
                                  'Biaya Penukaran',
                                  '-${pointCost.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")} Poin',
                                  AppColors.gold),
                              const SizedBox(height: 6),
                              const Divider(
                                  color: AppColors.surfaceBorder, height: 1),
                              const SizedBox(height: 6),
                              _buildRowDetail(
                                'Sisa Saldo Poin',
                                isEnoughPoints
                                    ? '${remainingPoints.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")} Poin'
                                    : '-${(pointCost - currentPoints).toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")} Poin (Kurang)',
                                isEnoughPoints ? textDark : Colors.red,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        isEnoughPoints
                            ? Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: ElevatedButton.icon(
                                      onPressed: isSubmitting
                                          ? null
                                          : () async {
                                              if (rewardType == 'ewallet' &&
                                                  phoneController.text
                                                      .trim()
                                                      .isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Masukkan nomor handphone terlebih dahulu!')),
                                                );
                                                return;
                                              }

                                              setStateModal(() {
                                                isSubmitting = true;
                                              });

                                              try {
                                                final notes = rewardType ==
                                                        'ewallet'
                                                    ? 'Nomor E-Wallet: ${phoneController.text.trim()}'
                                                    : null;
                                                await WasteService.redeemReward(
                                                    rewardId,
                                                    notes: notes);
                                                await AuthService.getProfile();

                                                if (dialogContext.mounted) {
                                                  Navigator.pop(dialogContext);
                                                }

                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          AppColors.primary,
                                                      content: Text(
                                                          'Selamat! Penukaran "$title" berhasil diproses.'),
                                                    ),
                                                  );
                                                }

                                                _loadApiRewards();
                                              } catch (e) {
                                                if (dialogContext.mounted) {
                                                  setStateModal(() {
                                                    isSubmitting = false;
                                                  });
                                                }
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.red.shade800,
                                                      content: Text(e
                                                          .toString()
                                                          .replaceAll(
                                                              'Exception: ',
                                                              '')),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                      icon: isSubmitting
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2))
                                          : const Icon(
                                              Icons.check_circle_outline,
                                              size: 16,
                                              color: Colors.white),
                                      label: Text(
                                        isSubmitting
                                            ? 'Memproses...'
                                            : 'Ya, Tukar Sekarang',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 40,
                                    child: TextButton(
                                      onPressed: isSubmitting
                                          ? null
                                          : () => Navigator.pop(dialogContext),
                                      child: const Text('Batal',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textMuted)),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.avatarBgSoft,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: const Text('Poin Tidak Cukup',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textMuted)),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 40,
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: const Text('Kembali ke Katalog',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textMuted)),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRowDetail(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        Text(value,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: valueColor)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = AppColors.surface;
    final Color primaryDarkColor = AppColors.primary;
    final Color textDark = AppColors.text;
    final Color textGray = AppColors.textMuted;
    final Color cardBackgroundColor = AppColors.surfaceAlt;
    final Color cardBorderColor = AppColors.surfaceBorder;
    final currentUser = AuthService.currentUserNotifier.value;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: cardBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardBorderColor),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, size: 18),
                              color: textDark,
                              onPressed: () {
                                MainNavigationScreen.changeTab(context, 0);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Katalog Hadiah',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  AppLevels.label(
                                      currentUser?.pointsBalance ?? 0),
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: textDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        UserAvatar(name: currentUser?.name ?? '', size: 32),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<UserModel?>(
                  valueListenable: AuthService.currentUserNotifier,
                  builder: (context, user, _) {
                    final points = user?.pointsBalance ?? 0;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryDarkColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SALDO POIN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mutedOnDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                points.toString().replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (Match m) => '${m[1]}.',
                                    ),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Poin',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldBright,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      String filter = _filters[index];
                      bool isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryDarkColor
                                  : cardBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: cardBorderColor),
                            ),
                            child: Center(
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoadingRewards)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (_apiRewards.isNotEmpty) ...[
                  ..._apiRewards.map((reward) {
                    final currentPoints =
                        AuthService.currentUserNotifier.value?.pointsBalance ??
                            0;
                    final isEnough = currentPoints >= reward.pointCost;
                    final btnText = isEnough ? 'Tukar' : 'Poin Kurang';
                    final rType = reward.name.toLowerCase().contains('gopay') ||
                            reward.name.toLowerCase().contains('ovo') ||
                            reward.name.toLowerCase().contains('dana') ||
                            reward.name.toLowerCase().contains('shopee')
                        ? 'ewallet'
                        : 'voucher';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildKatalogCard(
                        rewardId: reward.id,
                        imageUrl: reward.image ?? '',
                        title: reward.name,
                        pointCost: reward.pointCost,
                        currentPoints: currentPoints,
                        buttonText: btnText,
                        isButtonEnabled: isEnough,
                        cardBg: cardBackgroundColor,
                        borderColor: cardBorderColor,
                        primaryColor: primaryDarkColor,
                        textDarkColor: textDark,
                        rewardType: rType,
                      ),
                    );
                  }),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.card_giftcard, size: 36, color: textGray),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada hadiah tersedia saat ini',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textDark),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKatalogCard({
    required int rewardId,
    required String imageUrl,
    required String title,
    required int pointCost,
    required int currentPoints,
    required String buttonText,
    required bool isButtonEnabled,
    required Color cardBg,
    required Color borderColor,
    required Color primaryColor,
    required Color textDarkColor,
    required String rewardType,
  }) {
    final pointsFormatted = pointCost.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Container(
              height: 130,
              width: double.infinity,
              color: AppColors.avatarBgSoft,
              child: _buildRewardImage(imageUrl, primaryColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: textDarkColor)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on,
                              size: 14, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Text('$pointsFormatted Poin',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold)),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showKonfirmasiDialog(context, rewardId, title, pointCost,
                        rewardType, currentPoints);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isButtonEnabled ? primaryColor : AppColors.avatarBgSoft,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    minimumSize: Size.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color:
                          isButtonEnabled ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardImage(String imageUrl, Color primaryColor) {
    final placeholder = Center(
      child: Icon(Icons.card_giftcard,
          size: 40, color: primaryColor.withValues(alpha: 0.5)),
    );
    if (imageUrl.isEmpty) return placeholder;

    final isNetwork =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }
    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}

// ================= Halaman Profil Pengguna (ProfileScreen) =================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isChangingPassword = false;

  double _totalRecycledKg = 0;

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTotalRecycled();
  }

  Future<void> _loadTotalRecycled() async {
    try {
      final deposits = await WasteService.getDeposits();
      var total = 0.0;
      for (final d in deposits) {
        if (d.status.toLowerCase() != 'rejected') total += d.weightKg;
      }
      if (mounted) setState(() => _totalRecycledKg = total);
    } catch (_) {}
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Masukkan kata sandi saat ini!'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (newPass.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kata sandi baru minimal 8 karakter!'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Konfirmasi kata sandi baru tidak cocok!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isChangingPassword = true);
    try {
      await AuthService.changePassword(
        currentPassword: current,
        newPassword: newPass,
      );
      if (!mounted) return;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Expanded(child: Text('Kata sandi berhasil diubah!')),
            ],
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString()), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = AppColors.surface;
    final Color primaryDarkColor = AppColors.primary;
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profil Saya',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cardBorderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Akun\nAktif',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: textDark,
                                  height: 1.1)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
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
                          Stack(
                            children: [
                              UserAvatar(
                                name: AuthService
                                        .currentUserNotifier.value?.name ??
                                    '',
                                size: 64,
                                backgroundColor: AppColors.avatarBg,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: primaryDarkColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: backgroundColor, width: 1.5),
                                  ),
                                  child: const Icon(Icons.edit,
                                      size: 10, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ValueListenableBuilder<UserModel?>(
                              valueListenable: AuthService.currentUserNotifier,
                              builder: (context, user, _) {
                                final name = user?.name.isNotEmpty == true
                                    ? user!.name
                                    : 'Pengguna';
                                final email = user?.email.isNotEmpty == true
                                    ? user!.email
                                    : '-';
                                final role =
                                    (user?.role ?? 'nasabah').toUpperCase();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border:
                                            Border.all(color: cardBorderColor),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.verified,
                                              size: 10, color: Colors.green),
                                          const SizedBox(width: 4),
                                          Text(
                                            role,
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: textDark),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email,
                                      style: TextStyle(
                                          fontSize: 11, color: textGray),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: ValueListenableBuilder<UserModel?>(
                          valueListenable: AuthService.currentUserNotifier,
                          builder: (context, user, _) {
                            final id = user != null
                                ? 'NAS-${user.id.toString().padLeft(4, '0')}'
                                : 'NAS-0000';
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ID PENGGUNA:',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: textGray),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cardBackgroundColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: cardBorderColor),
                                  ),
                                  child: Text(
                                    id,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: textDark),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cardBorderColor),
                              ),
                              child: ValueListenableBuilder<UserModel?>(
                                valueListenable:
                                    AuthService.currentUserNotifier,
                                builder: (context, user, _) {
                                  final pts = user?.pointsBalance ?? 0;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Tabungan Poin',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: textGray,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.monetization_on,
                                              size: 14, color: AppColors.gold),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$pts Poin',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: textDark),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cardBorderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sampah Terdaur',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: textGray,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_totalRecycledKg.toStringAsFixed(1)} kg',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: textDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HadiahSayaScreen()),
                      );
                    },
                    icon: const Icon(Icons.card_giftcard_rounded,
                        size: 16, color: AppColors.primary),
                    label: const Text(
                      'Hadiah Saya & Riwayat Penukaran',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
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
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: cardBorderColor),
                            ),
                            child: const Icon(Icons.lock_outline,
                                size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Keamanan Akun',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: textDark),
                              ),
                              Text(
                                'Ubah kata sandi Anda secara berkala',
                                style: TextStyle(fontSize: 10, color: textGray),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Kata Sandi Saat Ini',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        style: TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: textGray),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Kata Sandi Baru',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        style: TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          hintText: 'Minimal 8 karakter unik',
                          hintStyle: TextStyle(
                              fontSize: 12,
                              color: textGray.withValues(alpha: 0.6)),
                          filled: true,
                          fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: textGray),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          'Kombinasi huruf besar, angka, dan simbol direkomendasikan.',
                          style: TextStyle(fontSize: 9, color: textGray)),
                      const SizedBox(height: 12),
                      Text('Konfirmasi Kata Sandi Baru',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          hintText: 'Ulangi kata sandi baru',
                          hintStyle: TextStyle(
                              fontSize: 12,
                              color: textGray.withValues(alpha: 0.6)),
                          filled: true,
                          fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: textGray),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _isChangingPassword
                              ? null
                              : _handleChangePassword,
                          icon: _isChangingPassword
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save_outlined,
                                  size: 16, color: Colors.white),
                          label: Text(
                              _isChangingPassword
                                  ? 'Menyimpan...'
                                  : 'Simpan Password',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDarkColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: TextButton.icon(
                    onPressed: () async {
                      await AuthService.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WelcomeScreen()),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded,
                        size: 16, color: Colors.redAccent),
                    label: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= Halaman Setor Sampah Screen =================
class SetorSampahScreen extends StatefulWidget {
  const SetorSampahScreen({super.key});

  @override
  State<SetorSampahScreen> createState() => _SetorSampahScreenState();
}

class _SetorSampahScreenState extends State<SetorSampahScreen> {
  bool _isCategoryExpanded = true;
  bool _isMethodExpanded = false;
  bool _isLoadingData = true;
  bool _isSubmitting = false;
  double _weight = 3.5;

  List<WasteTypeModel> _wasteTypes = [];
  WasteTypeModel? _selectedWasteType;

  List<DropPointModel> _dropPoints = [];
  DropPointModel? _selectedDropPoint;

  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final types = await WasteService.getWasteTypes();
      final drops = await WasteService.getDropPoints();
      if (!mounted) return;
      setState(() {
        _wasteTypes = types;
        if (types.isNotEmpty) {
          _selectedWasteType = types.first;
        }
        _dropPoints = drops;
        if (drops.isNotEmpty) {
          _selectedDropPoint = drops.first;
        }
        _isLoadingData = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _submitDeposit() async {
    if (_selectedWasteType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Silakan pilih jenis sampah terlebih dahulu')),
      );
      return;
    }

    final currentUser = AuthService.currentUserNotifier.value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Silakan login terlebih dahulu untuk menyetor sampah')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final deposit = await WasteService.createDeposit(
        wasteTypeId: _selectedWasteType!.id,
        dropPointId: _selectedDropPoint?.id,
        weightKg: _weight,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      // Refresh user profile points
      AuthService.getProfile();

      _showTicketDialog(deposit);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim setoran: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _showTicketDialog(WasteDepositModel deposit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        const primaryDark = AppColors.primary;
        const cardBg = AppColors.surfaceAlt;
        const cardBorder = AppColors.surfaceBorder;
        const textDark = AppColors.text;
        const textGray = AppColors.textMuted;

        return Dialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.greenTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: primaryDark, size: 34),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Formulir Terkirim!',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textDark),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tunjukkan kode ini kepada petugas di Bank Sampah untuk diverifikasi & ditimbang.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: textGray, height: 1.4),
                ),
                const SizedBox(height: 18),
                // QR Code visual
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SCAN QR CODE INI',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: textGray,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      QrImageView(
                        data: deposit.code,
                        version: QrVersions.auto,
                        size: 160,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.primary,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tunjukkan kepada petugas untuk di-scan',
                        style: TextStyle(fontSize: 9, color: textGray),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'KODE TRANSAKSI',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: textGray,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            deposit.code,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: primaryDark,
                                letterSpacing: 1),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded,
                                size: 16, color: primaryDark),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: deposit.code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Kode transaksi disalin ke clipboard!')),
                              );
                            },
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.warningBgSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warningBorder),
                        ),
                        child: const Text(
                          'Menunggu Verifikasi Petugas',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warningStrong),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(color: cardBorder, height: 1),
                      ),
                      _buildTicketRow('Jenis Sampah', deposit.wasteTypeName,
                          textDark, textGray),
                      const SizedBox(height: 6),
                      _buildTicketRow(
                          'Estimasi Berat',
                          '${deposit.weightKg.toStringAsFixed(1)} kg',
                          textDark,
                          textGray),
                      const SizedBox(height: 6),
                      _buildTicketRow(
                          'Estimasi Poin',
                          '+${deposit.estimatedPoints} Poin',
                          textDark,
                          textGray,
                          isPoints: true),
                      if (deposit.dropPointName != null) ...[
                        const SizedBox(height: 6),
                        _buildTicketRow('Lokasi', deposit.dropPointName!,
                            textDark, textGray),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // close dialog
                      Navigator.pop(context); // back to home
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Selesai & Kembali ke Beranda',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketRow(
      String label, String value, Color textDark, Color textGray,
      {bool isPoints = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: textGray)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPoints ? AppColors.gold : textDark,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = AppColors.surface;
    const Color primaryDarkColor = AppColors.primary;
    const Color textDark = AppColors.text;
    const Color textGray = AppColors.textMuted;
    const Color cardBackgroundColor = AppColors.surfaceAlt;
    const Color cardBorderColor = AppColors.surfaceBorder;

    final int currentRate = _selectedWasteType?.pointsPerKg ?? 150;
    final int estimatedPoints = (_weight * currentRate).round();

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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, size: 18),
                            color: textDark,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Setor Sampah',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: textDark),
                        ),
                      ],
                    ),
                    ValueListenableBuilder<UserModel?>(
                      valueListenable: AuthService.currentUserNotifier,
                      builder: (context, user, _) {
                        final levelName =
                            user?.role == 'petugas' ? 'Petugas' : 'Nasabah';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(
                                user?.name.split(' ').first ?? levelName,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: textDark),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Estimasi Poin Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryDarkColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ESTIMASI PEROLEHAN POIN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedOnDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '+$estimatedPoints',
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Poin',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldBright),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(color: AppColors.primaryDeep, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.scale_rounded,
                                  size: 14, color: AppColors.goldBright),
                              const SizedBox(width: 6),
                              Text(
                                'Rate: $currentRate Poin / kg',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.mutedOnDark),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDeep,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_weight.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Kategori Sampah
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pilih Kategori Sampah',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: textDark)),
                    GestureDetector(
                      onTap: () => setState(
                          () => _isCategoryExpanded = !_isCategoryExpanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Text(
                          _isCategoryExpanded
                              ? 'Tutup Kategori ^'
                              : 'Ubah Kategori v',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: primaryDarkColor),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => setState(
                            () => _isCategoryExpanded = !_isCategoryExpanded),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: cardBorderColor),
                                    ),
                                    child: const Icon(Icons.recycling,
                                        size: 18, color: primaryDarkColor),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedWasteType?.name ??
                                              'Pilih Jenis Sampah',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: textDark),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_selectedWasteType?.pointsPerKg ?? 0} Poin / kg',
                                          style: const TextStyle(
                                              fontSize: 10, color: textGray),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                                _isCategoryExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 18,
                                color: textGray),
                          ],
                        ),
                      ),
                      if (_isCategoryExpanded) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: cardBorderColor),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estimasi Berat:',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: textGray)),
                            Text('${_weight.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: textDark)),
                          ],
                        ),
                        Slider(
                          value: _weight,
                          min: 0.5,
                          max: 30.0,
                          divisions: 59,
                          activeColor: primaryDarkColor,
                          inactiveColor: cardBorderColor,
                          onChanged: (val) => setState(() => _weight = val),
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingData)
                          const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                      color: primaryDarkColor)))
                        else if (_wasteTypes.isEmpty)
                          const Text(
                              'Belum ada jenis sampah aktif dari server.',
                              style: TextStyle(fontSize: 11, color: textGray))
                        else
                          ..._wasteTypes.map((wt) {
                            final isSelected = _selectedWasteType?.id == wt.id;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedWasteType = wt),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.avatarBgSoft
                                      : backgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryDarkColor
                                        : cardBorderColor,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.category_outlined,
                                              size: 16,
                                              color: primaryDarkColor),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  wt.name,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textDark),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  wt.description ??
                                                      'Sampah daur ulang',
                                                  style: const TextStyle(
                                                      fontSize: 9,
                                                      color: textGray),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.greenTint,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                              '+${wt.pointsPerKg} Pts/kg',
                                              style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryDarkColor)),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.radio_button_off,
                                          size: 16,
                                          color: isSelected
                                              ? primaryDarkColor
                                              : Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Drop Point Selection
                Row(
                  children: [
                    const Expanded(
                      child: Text('Pilih Lokasi Bank Sampah',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: textDark)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DropPointMapScreen()),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.map_outlined,
                            size: 20, color: primaryDarkColor),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(
                          () => _isMethodExpanded = !_isMethodExpanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Text(
                          _isMethodExpanded
                              ? 'Tutup Lokasi ^'
                              : 'Ganti Lokasi v',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: primaryDarkColor),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: cardBorderColor),
                                  ),
                                  child: const Icon(Icons.storefront_rounded,
                                      size: 18, color: primaryDarkColor),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedDropPoint?.name ??
                                            'Drop-off Mandiri',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: textDark),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedDropPoint?.address ??
                                            'Pilih drop point terdekat',
                                        style: const TextStyle(
                                            fontSize: 10, color: textGray),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle,
                              size: 18, color: primaryDarkColor),
                        ],
                      ),
                      if (_isMethodExpanded) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Divider(color: cardBorderColor),
                        ),
                        if (_dropPoints.isEmpty)
                          const Text('Tidak ada drop point tersedia.',
                              style: TextStyle(fontSize: 10, color: textGray))
                        else
                          ..._dropPoints.map((dp) {
                            final isSel = _selectedDropPoint?.id == dp.id;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDropPoint = dp;
                                  _isMethodExpanded = false;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.avatarBgSoft
                                      : backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: isSel
                                          ? primaryDarkColor
                                          : cardBorderColor),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16, color: primaryDarkColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(dp.name,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: textDark)),
                                          Text(dp.address,
                                              style: const TextStyle(
                                                  fontSize: 9,
                                                  color: textGray)),
                                        ],
                                      ),
                                    ),
                                    if (isSel)
                                      const Icon(Icons.check,
                                          size: 16, color: primaryDarkColor),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Catatan Tambahan (Notes)
                const Text('Catatan Tambahan (Opsional)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: textDark)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: TextField(
                    controller: _notesController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12, color: textDark),
                    decoration: const InputDecoration(
                      hintText:
                          'Contoh: Sampah plastik sudah bersih & dipilah rapi...',
                      hintStyle: TextStyle(fontSize: 11, color: textGray),
                      contentPadding: EdgeInsets.all(12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitDeposit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 16),
                    label: Text(
                      _isSubmitting
                          ? 'Mengirim Formulir...'
                          : 'Kirim Formulir Setor',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDarkColor,
                      disabledBackgroundColor:
                          primaryDarkColor.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
