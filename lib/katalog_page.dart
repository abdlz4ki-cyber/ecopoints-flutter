import 'package:ecopoints/panduan_screen.dart';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

void main() {
  runApp(const EcoPointsApp());
}

class EcoPointsApp extends StatelessWidget {
  const EcoPointsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoPoints',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ================= Navigasi Utama =================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

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
    final Color cardBackgroundColor = const Color(0xFFECEAE0);
    final Color cardBorderColor = const Color(0xFFDCD8C9);
    final Color primaryDarkColor = const Color(0xFF2C4033);
    final Color textGray = const Color(0xFF6B6B6B);
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: _pages[_currentIndex],
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
        padding: EdgeInsets.fromLTRB(8, 10, 8, bottomPadding > 0 ? bottomPadding + 4 : 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 'Beranda', 0, primaryDarkColor, textGray),
            _buildNavItem(Icons.bar_chart_rounded, 'Peringkat', 1, primaryDarkColor, textGray),
            _buildNavItem(Icons.card_giftcard_rounded, 'Katalog', 2, primaryDarkColor, textGray),
            _buildNavItem(Icons.menu_book_rounded, 'Panduan', 3, primaryDarkColor, textGray),
            _buildNavItem(Icons.person_outline_rounded, 'Profil', 4, primaryDarkColor, textGray),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color activeColor, Color inactiveColor) {
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
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, Nabila Putri!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Text(
                            'Lv. 4 Green Warrior',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        MainNavigationScreen.changeTab(context, 4);
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cardBorderColor, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(21),
                          child: Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: Color(0xFF2C4033)),
                          ),
                        ),
                      ),
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
                          color: Color(0xFFA3B1A8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: const [
                          Text(
                            '2.450',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Poin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE5C158),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Setara Rp24.500',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFA3B1A8),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SetorSampahScreen()),
                                  );
                                },
                                icon: const Icon(Icons.recycling, size: 18, color: Color(0xFF1E1E1E)),
                                label: const Text(
                                  'Setor Sampah',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E1E1E)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5F3EC),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
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
                                  MainNavigationScreen.changeTab(context, 2);
                                },
                                icon: const Icon(Icons.card_giftcard, size: 18, color: Colors.white),
                                label: const Text(
                                  'Tukar Hadiah',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF4A6052), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Sampah Terpilah', style: TextStyle(fontSize: 11, color: textGray, fontWeight: FontWeight.w500)),
                                Icon(Icons.delete_outline, size: 16, color: textGray),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '34.8 kg',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textDark),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Reduksi Emisi', style: TextStyle(fontSize: 11, color: textGray, fontWeight: FontWeight.w500)),
                                Icon(Icons.eco_outlined, size: 16, color: textGray),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '52.2 kg CO₂',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Aktivitas',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textDark),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RiwayatScreen()),
                        );
                      },
                      child: Text(
                        'Lihat Semua>',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textGray),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildActivityCard(
                  icon: Icons.recycling,
                  title: 'Setor Plastik PET & Kardus',
                  subtitle: '3.5 kg • Bank Sampah Melati RW 05\nHari ini, 10:45 WIB',
                  points: '+250 Poin',
                  pointsColor: const Color(0xFFB8860B),
                  statusWidget: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: const Text('Rincian >', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                  ),
                  bgColor: cardBackgroundColor,
                  borderColor: cardBorderColor,
                ),
                const SizedBox(height: 10),
                _buildActivityCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Tukar Saldo GoPay\nRp10.000',
                  subtitle: 'Transfer ke 0812-****-8821 •\nBerhasil\nKemarin, 14:20 WIB',
                  points: '-1.000 Poin',
                  pointsColor: Colors.red.shade700,
                  statusWidget: Text('Penukaran', style: TextStyle(fontSize: 10, color: textGray, fontWeight: FontWeight.w500)),
                  bgColor: cardBackgroundColor,
                  borderColor: cardBorderColor,
                ),
                const SizedBox(height: 10),
                _buildActivityCard(
                  icon: Icons.description_outlined,
                  title: 'Setor Kertas & Arsip HVS',
                  subtitle: '5.0 kg • Unit Bank Sukamaju\n12 Des 2024',
                  points: '+250 Poin',
                  pointsColor: const Color(0xFFB8860B),
                  statusWidget: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: const Text('Selesai', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                  ),
                  bgColor: cardBackgroundColor,
                  borderColor: cardBorderColor,
                ),
                const SizedBox(height: 40),
              ],
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
              color: const Color(0xFFF5F3EC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF2C4033)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF6B6B6B), height: 1.3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(points, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: pointsColor)),
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
  const PeringkatScreen({Key? key}) : super(key: key);

  @override
  State<PeringkatScreen> createState() => _PeringkatScreenState();
}

class _PeringkatScreenState extends State<PeringkatScreen> {
  String _selectedTab = 'Bulan Ini';

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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            onPressed: () => MainNavigationScreen.changeTab(context, 0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Papan Peringkat',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Lv. 4 Green Warrior',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: textDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBorderColor, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/profile.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 16, color: Color(0xFF2C4033)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 'Bulan Ini'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedTab == 'Bulan Ini' ? primaryDarkColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Bulan Ini',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _selectedTab == 'Bulan Ini' ? Colors.white : textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 'Sepanjang Waktu'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedTab == 'Sepanjang Waktu' ? primaryDarkColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Sepanjang Waktu',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _selectedTab == 'Sepanjang Waktu' ? Colors.white : textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('3 Besar Daur Ulang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textDark)),
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, size: 14, color: Color(0xFFB8860B)),
                        const SizedBox(width: 4),
                        Text('Top Kontributor', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textGray)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(color: Color(0xFFD3D3D3), shape: BoxShape.circle),
                              child: const Center(child: Text('2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black))),
                            ),
                            const SizedBox(height: 8),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey,
                              child: ClipOval(
                                child: Image.asset('assets/images/user2.png', fit: BoxFit.cover, width: 60, height: 60,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Ahmad Fauzi', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textDark)),
                            const SizedBox(height: 2),
                            Text('3.210 Poin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB8860B))),
                            const SizedBox(height: 2),
                            Text('49.0 kg', style: TextStyle(fontSize: 9, color: textGray)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: primaryDarkColor, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(color: primaryDarkColor, shape: BoxShape.circle),
                              child: const Center(child: Text('1', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryDarkColor, width: 2)),
                              child: const CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.grey,
                                backgroundImage: AssetImage('assets/images/profile.png'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Siti Rahma', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                            const SizedBox(height: 2),
                            Text('3.820 Poin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFB8860B))),
                            const SizedBox(height: 2),
                            Text('58.0 kg', style: TextStyle(fontSize: 9, color: textGray)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(color: Color(0xFFE5C158), shape: BoxShape.circle),
                              child: const Center(child: Text('3', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))),
                            ),
                            const SizedBox(height: 8),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey,
                              child: ClipOval(
                                child: Image.asset('assets/images/user3.png', fit: BoxFit.cover, width: 60, height: 60,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Budi Santoso', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textDark)),
                            const SizedBox(height: 2),
                            Text('2.980 Poin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB8860B))),
                            const SizedBox(height: 2),
                            Text('44.0 kg', style: TextStyle(fontSize: 9, color: textGray)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Peringkat 4 – 8', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textDark)),
                    Text('Update Realtime', style: TextStyle(fontSize: 10, color: textGray)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRankItem('4', 'DL', 'Dewi Lestari', 'RT 01 • 41.2 kg', '2.850 Poin', cardBackgroundColor, cardBorderColor, textDark, textGray, false),
                const SizedBox(height: 8),
                _buildRankItem('5', 'HG', 'Hendra Gunawan', 'RT 04 • 36.5 kg', '2.570 Poin', cardBackgroundColor, cardBorderColor, textDark, textGray, false),
                const SizedBox(height: 8),
                _buildRankItem('6', 'MI', 'Maya Indah', 'RT 02 • 35.1 kg', '2.510 Poin', cardBackgroundColor, cardBorderColor, textDark, textGray, false),
                const SizedBox(height: 8),
                _buildRankItem('7', '', 'Nabila Putri', 'RT 03 • 34.8 kg', '2.450 Poin', const Color(0xFFD4E0D8), primaryDarkColor, textDark, textGray, true),
                const SizedBox(height: 8),
                _buildRankItem('8', 'RR', 'Rizky Ramadhan', 'RT 05 • 32.9 kg', '2.320 Poin', cardBackgroundColor, cardBorderColor, textDark, textGray, false),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankItem(String rank, String initials, String name, String subtitle, String points, Color bgColor, Color borderColor, Color textDark, Color textGray, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isMe ? 1.5 : 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(rank, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textDark)),
              ),
              const SizedBox(width: 12),
              isMe
                  ? const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage('assets/images/profile.png'),
              )
                  : Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E0D6),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C4033),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Anda', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 10, color: textGray)),
                ],
              ),
            ],
          ),
          Text(
            points,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFB8860B)),
          ),
        ],
      ),
    );
  }
}

// ================= Halaman Katalog Hadiah (KatalogScreen) =================
class KatalogScreen extends StatefulWidget {
  const KatalogScreen({Key? key}) : super(key: key);

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'E-Wallet', 'Listrik & Pulsa', 'Voucher'];

  // Fungsi Dialog Konfirmasi Penukaran Dinamis (E-Wallet vs Voucher/Token)
  void _showKonfirmasiDialog(BuildContext context, String title, String pointsCost, String rewardType) {
    final Color modalBgColor = const Color(0xFFF5F3EC);
    final Color cardBgColor = const Color(0xFFECEAE0);
    final Color borderColor = const Color(0xFFDCD8C9);
    final Color primaryColor = const Color(0xFF2C4033);
    final Color textDark = const Color(0xFF1E1E1E);
    final TextEditingController phoneController = TextEditingController(text: '0812-8921-9920');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Dialog(
              backgroundColor: modalBgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                            rewardType == 'ewallet' ? Icons.account_balance_wallet : Icons.card_giftcard,
                            size: 28,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Konfirmasi Penukaran',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textDark),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Apakah Anda yakin ingin menukarkan poin untuk hadiah ini?',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Color(0xFF6B6B6B), height: 1.3),
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
                                      rewardType == 'ewallet' ? Icons.account_balance_wallet : Icons.card_giftcard,
                                      size: 20,
                                      color: const Color(0xFF2C4033),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rewardType == 'ewallet' ? 'E-WALLET TRANSFER' : 'VOUCHER / TOKEN',
                                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF6B6B6B)),
                                        ),
                                        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                                        Text('$pointsCost Poin', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB8860B))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Divider(color: Color(0xFFDCD8C9), height: 1),
                              ),

                              // KONDISI DINAMIS: E-Wallet vs Voucher/Token
                              if (rewardType == 'ewallet') ...[
                                const Text('Nomor HP / Akun Tujuan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: const Icon(Icons.phone_android, size: 18),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDCD8C9))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDCD8C9))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2C4033), width: 1.5)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  ),
                                  onChanged: (value) {
                                    setStateModal(() {});
                                  },
                                ),
                                const SizedBox(height: 4),
                                const Text('Pastikan nomor aktif dan sesuai dengan akun e-wallet Anda.', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                const SizedBox(height: 12),
                              ] else ...[
                                const Text('Kode Voucher / Token:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFDCD8C9)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SelectableText(
                                        'PLN-8892-3310-9921',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C4033)),
                                      ),
                                      Icon(Icons.copy, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('Kode voucher akan otomatis aktif setelah konfirmasi.', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                const SizedBox(height: 12),
                              ],

                              _buildRowDetail('Saldo Saat Ini', '2.450 Poin', textDark),
                              const SizedBox(height: 6),
                              _buildRowDetail('Biaya Penukaran', '-$pointsCost', const Color(0xFFB8860B)),
                              const SizedBox(height: 6),
                              const Divider(color: Color(0xFFDCD8C9), height: 1),
                              const SizedBox(height: 6),
                              _buildRowDetail('Sisa Saldo Poin', '1.450 Poin', textDark),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (rewardType == 'ewallet' && phoneController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Masukkan nomor handphone terlebih dahulu!')),
                                );
                                return;
                              }
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    rewardType == 'ewallet'
                                        ? 'Penukaran ke nomor ${phoneController.text} berhasil diproses!'
                                        : 'Voucher berhasil diklaim!',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                            label: const Text('Ya, Tukar Sekarang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B6B6B))),
                          ),
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
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B6B6B))),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: valueColor)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF5F3EC);
    final Color primaryDarkColor = const Color(0xFF2C4033);
    final Color textDark = const Color(0xFF1E1E1E);
    final Color cardBackgroundColor = const Color(0xFFECEAE0);
    final Color cardBorderColor = const Color(0xFFDCD8C9);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            onPressed: () {
                              MainNavigationScreen.changeTab(context, 0);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Katalog Hadiah',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Lv. 4 Green Warrior',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: textDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBorderColor, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/profile.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 16, color: Color(0xFF2C4033)),
                            ),
                          ),
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
                          color: Color(0xFFA3B1A8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: const [
                          Text(
                            '2.450',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Poin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE5C158),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Setara Rp24.500',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFA3B1A8),
                        ),
                      ),
                    ],
                  ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryDarkColor : cardBackgroundColor,
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
                // Daftar item katalog dengan tipe reward ('ewallet' atau 'voucher')
                _buildKatalogCard('assets/images/gopay_card.png', 'GoPay Saldo Rp10.000', '1.000', 'Tukar', true, cardBackgroundColor, cardBorderColor, primaryDarkColor, textDark, 'ewallet'),
                const SizedBox(height: 12),
                _buildKatalogCard('assets/images/ovo_card.png', 'OVO Cash Rp20.000', '2.000', 'Tukar', true, cardBackgroundColor, cardBorderColor, primaryDarkColor, textDark, 'ewallet'),
                const SizedBox(height: 12),
                _buildKatalogCard('assets/images/pln_token.png', 'Token Listrik PLN Rp20.000', '2.100', 'Tukar', true, cardBackgroundColor, cardBorderColor, primaryDarkColor, textDark, 'voucher'),
                const SizedBox(height: 12),
                _buildKatalogCard('assets/images/shopeepay_card.png', 'ShopeePay Rp25.000', '2.500', 'Poin Kurang', false, cardBackgroundColor, cardBorderColor, primaryDarkColor, textDark, 'ewallet'),
                const SizedBox(height: 12),
                _buildKatalogCard('assets/images/totebag_eco.png', 'Tas Belanja Kanvas Eco', '1.500', 'Tukar', true, cardBackgroundColor, cardBorderColor, primaryDarkColor, textDark, 'voucher'),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKatalogCard(String imageUrl, String title, String pointsText, String buttonText, bool isButtonEnabled, Color cardBg, Color borderColor, Color primaryColor, Color textDarkColor, String rewardType) {
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
              color: const Color(0xFFE2E0D6),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.card_giftcard, size: 40, color: primaryColor.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textDarkColor)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, size: 14, color: Color(0xFFB8860B)),
                        const SizedBox(width: 4),
                        Text('$pointsText Poin', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFB8860B))),
                      ],
                    ),
                  ],
                ),
                isButtonEnabled
                    ? ElevatedButton(
                  onPressed: () {
                    _showKonfirmasiDialog(context, title, pointsText, rewardType);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    minimumSize: Size.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                )
                    : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E0D6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B6B6B))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= Halaman Profil Pengguna (ProfileScreen) =================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _currentPasswordController = TextEditingController(text: 'secretpassword');
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cardBorderColor),
                      ),
                      child: Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Akun\nAktif', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textDark, height: 1.1)),
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
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cardBorderColor, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Image.asset(
                                    'assets/images/profile.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person, size: 32, color: Color(0xFF2C4033)),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: primaryDarkColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: backgroundColor, width: 1.5),
                                  ),
                                  child: const Icon(Icons.edit, size: 10, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nabila Putri',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: cardBorderColor),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, size: 10, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Lv. 4 Green Warrior',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textDark),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'nabila.putri@email.com',
                                  style: TextStyle(fontSize: 11, color: textGray),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ID PENGGUNA:',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textGray),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cardBackgroundColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: cardBorderColor),
                              ),
                              child: Text(
                                'NAS-88204',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textDark),
                              ),
                            ),
                          ],
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Tabungan Poin',
                                    style: TextStyle(fontSize: 10, color: textGray, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.monetization_on, size: 14, color: Color(0xFFB8860B)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '2.450 Poin',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textDark),
                                      ),
                                    ],
                                  ),
                                ],
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
                                    style: TextStyle(fontSize: 10, color: textGray, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '34.8 kg',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textDark),
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
                        MaterialPageRoute(builder: (context) => const HadiahSayaScreen()),
                      );
                    },
                    icon: const Icon(Icons.card_giftcard_rounded, size: 16, color: Color(0xFF2C4033)),
                    label: const Text(
                      'Hadiah Saya & Riwayat Penukaran',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2C4033)),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                            child: const Icon(Icons.lock_outline, size: 16, color: Color(0xFF2C4033)),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Keamanan Akun',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textDark),
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
                      Text('Kata Sandi Saat Ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        style: TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrentPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: textGray),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword = !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Kata Sandi Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        style: TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          hintText: 'Minimal 8 karakter unik',
                          hintStyle: TextStyle(fontSize: 12, color: textGray.withOpacity(0.6)),
                          filled: true,
                          fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: textGray),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Kombinasi huruf besar, angka, dan simbol direkomendasikan.', style: TextStyle(fontSize: 9, color: textGray)),
                      const SizedBox(height: 12),
                      Text('Konfirmasi Kata Sandi Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          hintText: 'Ulangi kata sandi baru',
                          hintStyle: TextStyle(fontSize: 12, color: textGray.withOpacity(0.6)),
                          filled: true,
                          fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: textGray),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password berhasil disimpan!')),
                            );
                          },
                          icon: const Icon(Icons.save_outlined, size: 16, color: Colors.white),
                          label: const Text('Simpan Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDarkColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                            (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                    label: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.redAccent),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

// ================= Halaman Hadiah Saya (Voucher Aktif & Riwayat Selesai) =================
class HadiahSayaScreen extends StatefulWidget {
  const HadiahSayaScreen({Key? key}) : super(key: key);

  @override
  State<HadiahSayaScreen> createState() => _HadiahSayaScreenState();
}

class _HadiahSayaScreenState extends State<HadiahSayaScreen> {
  String _selectedTab = 'Voucher Aktif';

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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hadiah Saya',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                            ),
                            Text(
                              'Voucher & Riwayat Penukaran',
                              style: TextStyle(fontSize: 10, color: textGray),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cardBorderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('3 Hadiah\nAktif', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: textDark, height: 1.1)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 'Voucher Aktif'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedTab == 'Voucher Aktif' ? primaryDarkColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Voucher Aktif 3',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _selectedTab == 'Voucher Aktif' ? Colors.white : textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 'Riwayat Selesai'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedTab == 'Riwayat Selesai' ? primaryDarkColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Riwayat Selesai 1',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _selectedTab == 'Riwayat Selesai' ? Colors.white : textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedTab == 'Voucher Aktif') ...[
                  _buildVoucherCard(
                    category: 'Voucher Belanja',
                    title: 'Voucher TikTok Shop Rp25.000',
                    subtitle: '14 Des 2024 • 2.500 Poin',
                    badgeText: 'Siap Digunakan',
                    badgeColor: const Color(0xFFD4E0D8),
                    badgeTextColor: const Color(0xFF2C4033),
                    contentWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Kode Kupon:', style: TextStyle(fontSize: 10, color: textGray)),
                            Text('Berlaku s.d. 31 Des 2024', style: TextStyle(fontSize: 10, color: textGray)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TIKTOK-ECO025K-9482', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark)),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode berhasil disalin!')));
                                },
                                icon: const Icon(Icons.copy, size: 12, color: Color(0xFF2C4033)),
                                label: const Text('Salin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2C4033))),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: cardBorderColor),
                                  backgroundColor: cardBackgroundColor,
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    cardBg: cardBackgroundColor,
                    borderColor: cardBorderColor,
                    textDark: textDark,
                  ),
                  const SizedBox(height: 12),
                  _buildVoucherCard(
                    category: 'Saldo E-Wallet',
                    title: 'GoPay Saldo Rp10.000',
                    subtitle: 'Hari ini, 10:15 WIB • 1.000 Poin',
                    badgeText: 'Menunggu Pengiriman',
                    badgeColor: const Color(0xFFF9E8C7),
                    badgeTextColor: const Color(0xFF8C6500),
                    contentWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Nomor Tujuan:', style: TextStyle(fontSize: 10, color: textGray)),
                            Text('0812-****-8821 (Nabila Putri)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textDark)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('No. Referensi:', style: TextStyle(fontSize: 10, color: textGray)),
                            Text('GPY-ECO-884219', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textDark)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.hourglass_top_rounded, size: 12, color: Color(0xFFB8860B)),
                            const SizedBox(width: 4),
                            Text('Sedang diproses oleh sistem transfer (estimasi 1-7 hari)', style: TextStyle(fontSize: 9, color: textGray)),
                          ],
                        ),
                      ],
                    ),
                    cardBg: cardBackgroundColor,
                    borderColor: cardBorderColor,
                    textDark: textDark,
                  ),
                  const SizedBox(height: 12),
                  _buildVoucherCard(
                    category: 'Voucher Makan',
                    title: 'McD Voucher Rp50.000',
                    subtitle: '01 Des 2024 • 5.000 Poin',
                    badgeText: 'Siap Digunakan',
                    badgeColor: const Color(0xFFD4E0D8),
                    badgeTextColor: const Color(0xFF2C4033),
                    contentWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Kode Kupon:', style: TextStyle(fontSize: 10, color: textGray)),
                            Text('Berlaku s.d. 15 Jan 2025', style: TextStyle(fontSize: 10, color: textGray)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('MCD-ECO050-2024', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark)),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode berhasil disalin!')));
                                },
                                icon: const Icon(Icons.copy, size: 12, color: Color(0xFF2C4033)),
                                label: const Text('Salin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2C4033))),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: cardBorderColor),
                                  backgroundColor: cardBackgroundColor,
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    cardBg: cardBackgroundColor,
                    borderColor: cardBorderColor,
                    textDark: textDark,
                  ),
                ] else ...[
                  _buildVoucherCard(
                    category: 'Voucher Makan',
                    title: 'McD Voucher Rp50.000',
                    subtitle: '01 Des 2024 • 5.000 Poin',
                    badgeText: 'Sudah Digunakan',
                    badgeColor: const Color(0xFFE2E0D6),
                    badgeTextColor: textGray,
                    contentWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kode: MCD-ECO050-USED', style: TextStyle(fontSize: 10, decoration: TextDecoration.lineThrough, color: textGray)),
                        Text('Dipakai 05 Des 2024', style: TextStyle(fontSize: 10, color: textGray)),
                      ],
                    ),
                    cardBg: cardBackgroundColor,
                    borderColor: cardBorderColor,
                    textDark: textDark,
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

  Widget _buildVoucherCard({
    required String category,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required Widget contentWidget,
    required Color cardBg,
    required Color borderColor,
    required Color textDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3EC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: const Icon(Icons.card_giftcard, size: 18, color: Color(0xFF2C4033)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF6B6B6B))),
                      const SizedBox(height: 2),
                      Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textDark)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF6B6B6B))),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badgeText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeTextColor)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(color: Color(0xFFDCD8C9), height: 1),
          ),
          contentWidget,
        ],
      ),
    );
  }
}

// ================= Halaman Setor Sampah Screen =================
class SetorSampahScreen extends StatefulWidget {
  const SetorSampahScreen({Key? key}) : super(key: key);

  @override
  State<SetorSampahScreen> createState() => _SetorSampahScreenState();
}

class _SetorSampahScreenState extends State<SetorSampahScreen> {
  bool _isCategoryExpanded = false;
  bool _isMethodExpanded = false;
  String _selectedCategory = 'Plastik PET';
  double _weight = 3.5;

  final Map<String, int> _pointRates = {
    'Plastik PET': 150,
    'Kertas & Kardus': 100,
    'Kaleng Logam': 200,
    'Elektronik (E-waste)': 250,
  };

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF5F3EC);
    final Color primaryDarkColor = const Color(0xFF2C4033);
    final Color textDark = const Color(0xFF1E1E1E);
    final Color textGray = const Color(0xFF6B6B6B);
    final Color cardBackgroundColor = const Color(0xFFECEAE0);
    final Color cardBorderColor = const Color(0xFFDCD8C9);

    int currentRate = _pointRates[_selectedCategory] ?? 150;
    int estimatedPoints = (_weight * currentRate).round();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        Text(
                          'Setor Sampah',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Lv. 4 Green Warrior',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: textDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBorderColor, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/profile.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 16, color: Color(0xFF2C4033)),
                            ),
                          ),
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
                        'ESTIMASI PEROLEHAN POIN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA3B1A8),
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
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Poin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE5C158),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(color: Color(0xFF3B5244), height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.hourglass_bottom_rounded, size: 14, color: Color(0xFFE5C158)),
                              const SizedBox(width: 6),
                              const Text(
                                'Total Estimasi Berat',
                                style: TextStyle(fontSize: 11, color: Color(0xFFA3B1A8)),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B5244),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_weight.toStringAsFixed(1)} kg',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pilih Kategori Sampah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCategoryExpanded = !_isCategoryExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Text(
                          _isCategoryExpanded ? 'Tutup Kategori ^' : 'Ubah Kategori v',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: primaryDarkColor),
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
                        onTap: () {
                          setState(() {
                            _isCategoryExpanded = !_isCategoryExpanded;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: cardBorderColor),
                                  ),
                                  child: const Icon(Icons.recycling, size: 18, color: Color(0xFF2C4033)),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_selectedCategory, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _isCategoryExpanded ? 'Botol bening mineral, cup plastik' : 'Tap untuk ubah kategori atau berat',
                                      style: TextStyle(fontSize: 10, color: textGray),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(_isCategoryExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18, color: textGray),
                          ],
                        ),
                      ),
                      if (_isCategoryExpanded) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Color(0xFFDCD8C9)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimasi Berat:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textGray)),
                            Text('${_weight.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark)),
                          ],
                        ),
                        Slider(
                          value: _weight,
                          min: 0.5,
                          max: 20.0,
                          divisions: 39,
                          activeColor: primaryDarkColor,
                          inactiveColor: cardBorderColor,
                          onChanged: (val) {
                            setState(() {
                              _weight = val;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildCategoryOption('Plastik PET', 'Botol bening mineral, cup plastik', '88 Pts/kg'),
                        const SizedBox(height: 8),
                        _buildCategoryOption('Kertas & Kardus', 'Kardus cokelat, arsip HVS, koran', '50 Pts/kg'),
                        const SizedBox(height: 8),
                        _buildCategoryOption('Kaleng Logam', 'Aluminium softdrink, seng tipis', '120 Pts/kg'),
                        const SizedBox(height: 8),
                        _buildCategoryOption('Elektronik (E-waste)', 'Kabel, adaptor, baterai gadget', '250 Pts/kg'),
                      ] else ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.delete_outline, size: 12, color: Color(0xFF2C4033)),
                              const SizedBox(width: 6),
                              Text('$_selectedCategory  ${_weight.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textDark)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Foto Sampah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: const Icon(Icons.camera_alt_outlined, size: 20, color: Color(0xFF2C4033)),
                      ),
                      const SizedBox(height: 8),
                      Text('Ambil Foto atau Unggah Bukti Sampah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textDark)),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.image_outlined, size: 14, color: Color(0xFF2C4033)),
                        label: const Text('Pilih Foto', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2C4033))),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cardBorderColor),
                          backgroundColor: backgroundColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pilih Metode & Lokasi Penyerahan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isMethodExpanded = !_isMethodExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Text(
                          _isMethodExpanded ? 'Tutup Metode ^' : 'Ubah Metode v',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: primaryDarkColor),
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: cardBorderColor),
                                ),
                                child: const Icon(Icons.storefront_rounded, size: 18, color: Color(0xFF2C4033)),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Drop-off Mandiri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD4E0D8),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Bebas Biaya', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF2C4033))),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('Bank Sampah Unit Melati 05', style: TextStyle(fontSize: 11, color: textGray)),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.radio_button_checked, size: 18, color: Color(0xFF2C4033)),
                        ],
                      ),
                      if (_isMethodExpanded) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Operasional hari ini: Buka s.d 16.00 WIB', style: TextStyle(fontSize: 9, color: textGray)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 110,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E2D9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text('// Peta Wilayah Layanan //', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.navigation, size: 10, color: Colors.white),
                                  label: const Text('Rute', style: TextStyle(fontSize: 9, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryDarkColor,
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Divider(color: Color(0xFFDCD8C9), height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF2C4033)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Jl. Melati Indah No. 12 (450m dari lokasi Anda)',
                              style: TextStyle(fontSize: 10, color: textDark, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                    label: const Text(
                      'Kirim Formulir Setor',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDarkColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildCategoryOption(String title, String desc, String points) {
    bool isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE2E0D6) : const Color(0xFFF5F3EC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF2C4033) : const Color(0xFFDCD8C9), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.category_outlined, size: 16, color: Color(0xFF2C4033)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                    const SizedBox(height: 2),
                    Text(desc, style: const TextStyle(fontSize: 9, color: Color(0xFF6B6B6B))),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4E0D8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('+$points', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF2C4033))),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_off,
                  size: 16,
                  color: isSelected ? const Color(0xFF2C4033) : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Halaman Riwayat Lengkap =================
class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF5F3EC);
    final Color primaryDarkColor = const Color(0xFF2C4033);
    final Color textDark = const Color(0xFF1E1E1E);
    final Color cardBackgroundColor = const Color(0xFFECEAE0);
    final Color cardBorderColor = const Color(0xFFDCD8C9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Semua Riwayat Aktivitas',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        iconTheme: IconThemeData(color: primaryDarkColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildActivityCard(
            icon: Icons.recycling,
            title: 'Setor Plastik PET & Kardus',
            subtitle: '3.5 kg • Bank Sampah Melati RW 05\nHari ini, 10:45 WIB',
            points: '+250 Poin',
            pointsColor: const Color(0xFFB8860B),
            statusWidget: const Text('Selesai', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
            bgColor: cardBackgroundColor,
            borderColor: cardBorderColor,
          ),
          const SizedBox(height: 10),
          _buildActivityCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Tukar Saldo GoPay Rp10.000',
            subtitle: 'Transfer ke 0812-****-8821 • Berhasil\nKemarin, 14:20 WIB',
            points: '-1.000 Poin',
            pointsColor: const Color(0xFFB8860B),
            statusWidget: const Text('Penukaran', style: TextStyle(fontSize: 10)),
            bgColor: cardBackgroundColor,
            borderColor: cardBorderColor,
          ),
          const SizedBox(height: 10),
          _buildActivityCard(
            icon: Icons.description_outlined,
            title: 'Setor Kertas & Arsip HVS',
            subtitle: '5.0 kg • Unit Bank Sukamaju\n12 Des 2024',
            points: '+250 Poin',
            pointsColor: const Color(0xFFB8860B),
            statusWidget: const Text('Selesai', style: TextStyle(fontSize: 10)),
            bgColor: cardBackgroundColor,
            borderColor: cardBorderColor,
          ),
        ],
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
              color: const Color(0xFFF5F3EC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF2C4033)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF6B6B6B), height: 1.3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(points, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: pointsColor)),
              const SizedBox(height: 6),
              statusWidget,
            ],
          ),
        ],
      ),
    );
  }
}