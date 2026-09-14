import 'package:flutter/material.dart';
import 'welcome_screen.dart'; // Pastikan file welcome_screen.dart Anda tersedia di proyek

class PetugasMainScreen extends StatefulWidget {
  const PetugasMainScreen({Key? key}) : super(key: key);

  @override
  State<PetugasMainScreen> createState() => PetugasMainScreenState();

  static void changeTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<PetugasMainScreenState>();
    state?.setTab(index);
  }
}

class PetugasMainScreenState extends State<PetugasMainScreen> {
  int _currentIndex = 0;

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _pages = [
    const PetugasHomeScreen(),
    const PetugasRiwayatScreen(),
    const PetugasProfilScreen(),
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
            _buildNavItem(Icons.description_outlined, 'Riwayat', 1, primaryDarkColor, textGray),
            _buildNavItem(Icons.person_outline_rounded, 'Profil', 2, primaryDarkColor, textGray),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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

// ================= Halaman Utama Petugas (Beranda) =================
class PetugasHomeScreen extends StatelessWidget {
  const PetugasHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF5F3EC);
    final Color primaryDarkColor = const Color(0xFF2C4033);
    final Color textDark = const Color(0xFF1E1E1E);
    final Color textGray = const Color(0xFF6B6B6B);
    final Color cardBackgroundColor = const Color(0xFFECEAE0);
    final Color cardBorderColor = const Color(0xFFDCD8C9);

    final TextEditingController _kodeTransaksiController = TextEditingController(text: 'ECP-94821');

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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryDarkColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ECOPOINTS PETUGAS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: cardBorderColor, width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                'assets/images/profile.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, color: Color(0xFF2C4033)),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: cardBackgroundColor, width: 1.5),
                              ),
                              child: const Icon(Icons.check, size: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Budi Santoso',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: cardBorderColor),
                                  ),
                                  child: Text(
                                    'PET-\n0042',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: textDark, height: 1.1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 13, color: textGray),
                                const SizedBox(width: 4),
                                Text(
                                  'Bank Sampah Unit Melati 05',
                                  style: TextStyle(fontSize: 11, color: textGray),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
                      Text(
                        'Pindai QR Tiket User',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Arahkan kamera ke QR code tiket petugas',
                        style: TextStyle(fontSize: 11, color: textGray),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 20,
                              left: 30,
                              child: Icon(Icons.crop_free, size: 100, color: textGray.withOpacity(0.4)),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: cardBackgroundColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cardBorderColor),
                                  ),
                                  child: Icon(Icons.camera_alt_outlined, size: 24, color: primaryDarkColor),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 80,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Ketuk untuk mulai pemindaian cepat',
                          style: TextStyle(fontSize: 10, color: textGray),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.qr_code_scanner, size: 18, color: Colors.white),
                          label: const Text(
                            'Buka Kamera Scan',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDarkColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Divider(color: cardBorderColor, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'ATAU VERIFIKASI MANUAL',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textGray, letterSpacing: 0.5),
                      ),
                    ),
                    Expanded(child: Divider(color: cardBorderColor, thickness: 1)),
                  ],
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kode Transaksi Setoran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                          Text('Contoh: ECP-94821', style: TextStyle(fontSize: 10, color: textGray)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _kodeTransaksiController,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.receipt_long_outlined, size: 18, color: textGray),
                                filled: true,
                                fillColor: backgroundColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryDarkColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Cek Transaksi >',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
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
                    Row(
                      children: [
                        Text('Antrean Hari Ini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textDark)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9EED9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: const Text('1', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB8860B))),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => PetugasMainScreen.changeTab(context, 1),
                      child: Text('Semua Antrean >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textGray)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Icon(Icons.inventory_2_outlined, size: 20, color: primaryDarkColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nabila Putri • ECP-94821',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Estimasi: 3.5 kg (Plastik PET)',
                              style: TextStyle(fontSize: 10, color: textGray),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9EED9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PENDING',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFB8860B)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Icon(Icons.arrow_forward_ios, size: 12, color: textGray),
                      ),
                    ],
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

// ================= Halaman Riwayat Verifikasi Petugas =================
class PetugasRiwayatScreen extends StatefulWidget {
  const PetugasRiwayatScreen({Key? key}) : super(key: key);

  @override
  State<PetugasRiwayatScreen> createState() => _PetugasRiwayatScreenState();
}

class _PetugasRiwayatScreenState extends State<PetugasRiwayatScreen> {
  String _selectedFilter = 'Semua';

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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryDarkColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ECOPOINTS PETUGAS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: textDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cardBorderColor),
                      ),
                      child: Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Budi Santoso', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Riwayat Verifikasi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                Text('Daftar seluruh setoran masuk di Petugas', style: TextStyle(fontSize: 12, color: textGray)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFilterButton('Semua', '3', cardBackgroundColor, cardBorderColor, primaryDarkColor, textDark),
                    const SizedBox(width: 8),
                    _buildFilterButton('Pending', '1', cardBackgroundColor, cardBorderColor, primaryDarkColor, textDark),
                    const SizedBox(width: 8),
                    _buildFilterButton('Selesai', '2', cardBackgroundColor, cardBorderColor, primaryDarkColor, textDark),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SETORAN MASUK TERBARU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: textGray, letterSpacing: 0.5)),
                    Text('Total: 3 Tiket', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textGray)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCardPending(cardBackgroundColor, cardBorderColor, backgroundColor, textDark, textGray),
                const SizedBox(height: 12),
                _buildCardSelesai('Ahmad Fauzi', 'ID: USR-77102', 'ECP-94819', 'Kemarin, 14:20 WIB', 'Kertas & Kardus Tebal', '5.2 kg', '+260 Pts', cardBackgroundColor, cardBorderColor, backgroundColor, textDark, textGray),
                const SizedBox(height: 12),
                _buildCardSelesai('Siti Rahma', 'ID: USR-55410', 'ECP-94802', '10 Sep 2026', 'Minyak Jelantah', '2.1 kg', '+315 Pts', cardBackgroundColor, cardBorderColor, backgroundColor, textDark, textGray),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String title, String count, Color cardBg, Color borderColor, Color activeColor, Color textDark) {
    bool isSelected = _selectedFilter == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeColor : cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? activeColor : borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : textDark)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFE2E0D6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(count, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : textDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPending(Color cardBg, Color borderColor, Color backgroundColor, Color textDark, Color textGray) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Nabila Putri', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textDark)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF9EED9), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE5C158))),
                    child: const Text('Penyetor', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB8860B))),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 8, color: Colors.white),
                    SizedBox(width: 4),
                    Text('PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(4), border: Border.all(color: borderColor)),
                child: Text('ECP-94821', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textDark)),
              ),
              const SizedBox(width: 6),
              Text('•  Hari ini, 10:45 WIB', style: TextStyle(fontSize: 11, color: textGray)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor)),
                      child: const Icon(Icons.recycling, size: 18, color: Color(0xFF2C4033)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Plastik PET (Botol Bening)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                        const SizedBox(height: 2),
                        Text('Estimasi Berat: 3.5 kg (~525 Poin)', style: TextStyle(fontSize: 10, color: textGray)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFF2C4033), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, size: 14, color: Color(0xFFB8860B)),
                  const SizedBox(width: 4),
                  Text('Ketuk untuk proses verifikasi timbangan', style: TextStyle(fontSize: 10, color: textGray)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF9EED9), borderRadius: BorderRadius.circular(6)),
                child: const Text('Siap\nTimbang', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFB8860B), height: 1.1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardSelesai(String nama, String idUser, String kodeTrans, String waktu, String kategori, String aktual, String poinTerbit, Color cardBg, Color borderColor, Color backgroundColor, Color textDark, Color textGray) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(nama, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textDark)),
                  const SizedBox(width: 8),
                  Text(idUser, style: TextStyle(fontSize: 10, color: textGray)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF556B2F), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: const [
                    Icon(Icons.check, size: 10, color: Colors.white),
                    SizedBox(width: 4),
                    Text('SELESAI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(4), border: Border.all(color: borderColor)),
                child: Text(kodeTrans, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textDark)),
              ),
              const SizedBox(width: 6),
              Text('•  $waktu', style: TextStyle(fontSize: 11, color: textGray)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor)),
                      child: const Icon(Icons.description_outlined, size: 18, color: Color(0xFF2C4033)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kategori, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text('Aktual: $aktual • Poin Terbit: ', style: TextStyle(fontSize: 10, color: textGray)),
                            Text(poinTerbit, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB8860B))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: borderColor)),
                  child: Row(
                    children: const [
                      Icon(Icons.lock_outline, size: 10, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Terkunci', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diverifikasi oleh: Budi Santoso (PET-0042)', style: TextStyle(fontSize: 10, color: textGray)),
              Row(
                children: const [
                  Icon(Icons.check_circle, size: 12, color: Colors.green),
                  SizedBox(width: 4),
                  Text('Poin Masuk Pengguna', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================= Halaman Profil Petugas (PetugasProfilScreen) =================
class PetugasProfilScreen extends StatefulWidget {
  const PetugasProfilScreen({Key? key}) : super(key: key);

  @override
  State<PetugasProfilScreen> createState() => _PetugasProfilScreenState();
}

class _PetugasProfilScreenState extends State<PetugasProfilScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final TextEditingController _currentPassController = TextEditingController(text: 'secretpassword');
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryDarkColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ECOPOINTS\nMODE PETUGAS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Profil Petugas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                    letterSpacing: -0.5,
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
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: cardBorderColor, width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/images/profile.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 30, color: Color(0xFF2C4033)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Budi Santoso',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: textDark,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primaryDarkColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'PET-0042',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text('Petugas Lapangan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textDark)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Penugasan Bank Sampah Unit',
                                  style: TextStyle(fontSize: 11, color: textGray),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Divider(color: Color(0xFFDCD8C9), height: 1),
                      ),
                      _buildInfoRow(Icons.storefront_rounded, 'Wilayah Penugasan', 'Bank Sampah Unit Melati 05', textGray, textDark),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.location_on_outlined, 'Alamat Petugas', 'Jl. Melati Indah No. 12, Kebayoran Baru', textGray, textDark),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.phone_outlined, 'Nomor WhatsApp Petugas', '0812-3456-7890', textGray, textDark),
                    ],
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
                            child: Icon(Icons.lock_outline, size: 16, color: primaryDarkColor),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Keamanan Akun Petugas',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textDark),
                              ),
                              Text(
                                'Ganti kata sandi secara berkala untuk menjaga akun',
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
                        controller: _currentPassController,
                        obscureText: _obscureCurrent,
                        style: TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: textGray),
                            onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Kata Sandi Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _newPassController,
                        obscureText: _obscureNew,
                        style: TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          hintText: 'Minimal 8 karakter (huruf & angka)',
                          hintStyle: TextStyle(fontSize: 11, color: textGray.withOpacity(0.7)),
                          filled: true,
                          fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: textGray),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Konfirmasi Kata Sandi Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmPassController,
                        obscureText: _obscureConfirm,
                        style: TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          hintText: 'Ulangi kata sandi baru',
                          hintStyle: TextStyle(fontSize: 11, color: textGray.withOpacity(0.7)),
                          filled: true,
                          fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: textGray),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
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
                              const SnackBar(content: Text('Password baru berhasil disimpan!')),
                            );
                          },
                          icon: const Icon(Icons.check, size: 16, color: Colors.white),
                          label: const Text('Simpan Password Baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
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
                      'Keluar dari Akun Petugas',
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

  Widget _buildInfoRow(IconData icon, String label, String value, Color textGray, Color textDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: textGray),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: textGray, fontWeight: FontWeight.w500)),
              const SizedBox(height: 1),
              Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textDark)),
            ],
          ),
        ),
      ],
    );
  }
}