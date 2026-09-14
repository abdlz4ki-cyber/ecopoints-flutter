import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'services/auth_service.dart';
import 'services/waste_service.dart';
import 'models/user_model.dart';
import 'models/waste_deposit_model.dart';

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
    const Color cardBackgroundColor = Color(0xFFECEAE0);
    const Color cardBorderColor = Color(0xFFDCD8C9);
    const Color primaryDarkColor = Color(0xFF2C4033);
    const Color textGray = Color(0xFF6B6B6B);
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: cardBackgroundColor,
          border: Border(top: BorderSide(color: cardBorderColor, width: 1.0)),
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
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isSelected ? activeColor : inactiveColor),
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

// ================= Beranda Petugas =================
class PetugasHomeScreen extends StatefulWidget {
  const PetugasHomeScreen({Key? key}) : super(key: key);

  @override
  State<PetugasHomeScreen> createState() => _PetugasHomeScreenState();
}

class _PetugasHomeScreenState extends State<PetugasHomeScreen> {
  static const Color backgroundColor = Color(0xFFF5F3EC);
  static const Color primaryDarkColor = Color(0xFF2C4033);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGray = Color(0xFF6B6B6B);
  static const Color cardBackgroundColor = Color(0xFFECEAE0);
  static const Color cardBorderColor = Color(0xFFDCD8C9);

  final TextEditingController _kodeTransaksiController = TextEditingController();
  List<WasteDepositModel> _pendingDeposits = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingDeposits();
  }

  @override
  void dispose() {
    _kodeTransaksiController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingDeposits() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final deposits = await WasteService.getDeposits(status: 'pending');
      if (mounted) setState(() { _pendingDeposits = deposits; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _lookupByCode() async {
    final code = _kodeTransaksiController.text.trim();
    if (code.isEmpty) return;
    try {
      final all = await WasteService.getDeposits();
      final found = all.where((d) => d.code.toLowerCase() == code.toLowerCase()).toList();
      if (!mounted) return;
      if (found.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode transaksi tidak ditemukan.')));
        return;
      }
      _showVerificationSheet(found.first);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mencari: $e')));
    }
  }

  void _showVerificationSheet(WasteDepositModel deposit) {
    final beratCtrl = TextEditingController(text: deposit.weightKg.toStringAsFixed(1));
    final notesCtrl = TextEditingController(text: deposit.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        bool isVerifying = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(color: cardBorderColor, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: primaryDarkColor, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.fact_check_outlined, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Verifikasi Setoran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textDark)),
                              Text(deposit.code, style: const TextStyle(fontSize: 11, color: textGray)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: deposit.status == 'pending' ? const Color(0xFFF9EED9) : const Color(0xFFDCF5DC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            deposit.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w900,
                              color: deposit.status == 'pending' ? const Color(0xFFB8860B) : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardBorderColor),
                      ),
                      child: Column(
                        children: [
                          _sheetInfoRow('Nasabah', deposit.userName, Icons.person_outline),
                          const SizedBox(height: 8),
                          _sheetInfoRow('Jenis Sampah', deposit.wasteTypeName, Icons.recycling),
                          const SizedBox(height: 8),
                          _sheetInfoRow('Lokasi', deposit.dropPointName ?? '-', Icons.location_on_outlined),
                          const SizedBox(height: 8),
                          _sheetInfoRow('Est. Berat', '${deposit.weightKg.toStringAsFixed(1)} kg', Icons.monitor_weight_outlined),
                          const SizedBox(height: 8),
                          _sheetInfoRow('Est. Poin', '${deposit.estimatedPoints} Pts', Icons.stars_outlined),
                        ],
                      ),
                    ),
                    if (deposit.status == 'pending') ...[
                      const SizedBox(height: 16),
                      const Text('Berat Aktual (kg)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: beratCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.monitor_weight_outlined, size: 18, color: textGray),
                          suffixText: 'kg',
                          filled: true,
                          fillColor: cardBackgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Catatan (opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: notesCtrl,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13, color: textDark),
                        decoration: InputDecoration(
                          hintText: 'Contoh: Sampah dalam kondisi bersih',
                          hintStyle: TextStyle(fontSize: 11, color: textGray.withOpacity(0.7)),
                          filled: true,
                          fillColor: cardBackgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: isVerifying
                              ? null
                              : () async {
                                  final berat = double.tryParse(beratCtrl.text.trim());
                                  if (berat == null || berat <= 0) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Masukkan berat aktual yang valid!')));
                                    return;
                                  }
                                  setSheetState(() => isVerifying = true);
                                  try {
                                    await WasteService.verifyDeposit(deposit.id, weightKg: berat, notes: notesCtrl.text.trim());
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (mounted) {
                                      _loadPendingDeposits();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Row(children: [
                                            Icon(Icons.check_circle, color: Colors.white, size: 16),
                                            SizedBox(width: 8),
                                            Expanded(child: Text('Setoran diverifikasi! Poin berhasil diterbitkan.')),
                                          ]),
                                          backgroundColor: Colors.green.shade700,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setSheetState(() => isVerifying = false);
                                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                                  }
                                },
                          icon: isVerifying
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                          label: Text(
                            isVerifying ? 'Memproses...' : 'Konfirmasi & Terbitkan Poin',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDarkColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFDCF5DC), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Setoran sudah diverifikasi. Poin +${deposit.earnedPoints ?? "-"} Pts telah diterbitkan.',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _sheetInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: textGray),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 11, color: textGray)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryDarkColor,
          onRefresh: _loadPendingDeposits,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: primaryDarkColor, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'ECOPOINTS PETUGAS',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: textDark, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Profile Card
                  ValueListenableBuilder<UserModel?>(
                    valueListenable: AuthService.currentUserNotifier,
                    builder: (context, user, _) {
                      final name = user?.name ?? 'Petugas';
                      final id = user != null ? 'PET-${user.id.toString().padLeft(4, '0')}' : 'PET-0000';
                      return Container(
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
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: cardBorderColor, width: 1.5)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.asset(
                                      'assets/images/profile.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(Icons.person, color: primaryDarkColor),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: cardBackgroundColor, width: 1.5)),
                                    child: const Icon(Icons.check, size: 10, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textDark)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: const [
                                          Icon(Icons.location_on_outlined, size: 13, color: textGray),
                                          SizedBox(width: 4),
                                          Text('Bank Sampah Unit Melati 05', style: TextStyle(fontSize: 11, color: textGray)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: backgroundColor, borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: cardBorderColor),
                                    ),
                                    child: Text(id, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textDark)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // QR Scan Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pindai QR Tiket User', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textDark)),
                        const SizedBox(height: 2),
                        const Text('Arahkan kamera ke QR code tiket petugas', style: TextStyle(fontSize: 11, color: textGray)),
                        const SizedBox(height: 16),
                        Container(
                          height: 160, width: double.infinity,
                          decoration: BoxDecoration(
                            color: backgroundColor, borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 20, left: 30,
                                child: Icon(Icons.crop_free, size: 100, color: textGray.withOpacity(0.4)),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: cardBackgroundColor, shape: BoxShape.circle,
                                      border: Border.all(color: cardBorderColor),
                                    ),
                                    child: const Icon(Icons.camera_alt_outlined, size: 24, color: primaryDarkColor),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 80, height: 3,
                                    decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(2)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Center(child: Text('Ketuk untuk mulai pemindaian cepat', style: TextStyle(fontSize: 10, color: textGray))),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity, height: 46,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.qr_code_scanner, size: 18, color: Colors.white),
                            label: const Text('Buka Kamera Scan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryDarkColor, elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: cardBorderColor, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('ATAU VERIFIKASI MANUAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textGray, letterSpacing: 0.5)),
                      ),
                      const Expanded(child: Divider(color: cardBorderColor, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Manual Code Lookup
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kode Transaksi Setoran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                            Text('Contoh: ECP-2026-001', style: TextStyle(fontSize: 10, color: textGray)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _kodeTransaksiController,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.receipt_long_outlined, size: 18, color: textGray),
                                  hintText: 'ECP-2026-001',
                                  hintStyle: TextStyle(fontSize: 12, color: textGray.withOpacity(0.5), fontWeight: FontWeight.normal),
                                  filled: true,
                                  fillColor: backgroundColor,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _lookupByCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryDarkColor, elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Cek >', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Queue Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Antrean Hari Ini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textDark)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9EED9), borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: cardBorderColor),
                            ),
                            child: Text(
                              _isLoading ? '...' : '${_pendingDeposits.length}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB8860B)),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => PetugasMainScreen.changeTab(context, 1),
                        child: const Text('Semua Antrean >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textGray)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                  else if (_error != null)
                    _buildErrorCard()
                  else if (_pendingDeposits.isEmpty)
                    _buildEmptyCard()
                  else
                    ..._pendingDeposits.take(3).map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildPendingCard(d),
                        )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingCard(WasteDepositModel deposit) {
    return GestureDetector(
      onTap: () => _showVerificationSheet(deposit),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBackgroundColor, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: backgroundColor, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cardBorderColor),
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 20, color: primaryDarkColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${deposit.userName} • ${deposit.code}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Est. ${deposit.weightKg.toStringAsFixed(1)} kg (${deposit.wasteTypeName})',
                    style: const TextStyle(fontSize: 10, color: textGray),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF9EED9), borderRadius: BorderRadius.circular(6)),
              child: const Text('PENDING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFB8860B))),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: backgroundColor, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cardBorderColor),
              ),
              child: const Icon(Icons.arrow_forward_ios, size: 12, color: textGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBackgroundColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: textGray.withOpacity(0.5)),
          const SizedBox(height: 8),
          const Text('Tidak ada antrean pending', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textGray)),
          const SizedBox(height: 4),
          Text('Tarik ke bawah untuk refresh', style: TextStyle(fontSize: 11, color: textGray.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCCCC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Gagal memuat data. Tarik ke bawah untuk coba lagi.', style: TextStyle(fontSize: 12, color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }
}

// ================= Riwayat Verifikasi Petugas =================
class PetugasRiwayatScreen extends StatefulWidget {
  const PetugasRiwayatScreen({Key? key}) : super(key: key);

  @override
  State<PetugasRiwayatScreen> createState() => _PetugasRiwayatScreenState();
}

class _PetugasRiwayatScreenState extends State<PetugasRiwayatScreen> {
  static const Color backgroundColor = Color(0xFFF5F3EC);
  static const Color primaryDarkColor = Color(0xFF2C4033);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGray = Color(0xFF6B6B6B);
  static const Color cardBackgroundColor = Color(0xFFECEAE0);
  static const Color cardBorderColor = Color(0xFFDCD8C9);

  String _selectedFilter = 'Semua';
  List<WasteDepositModel> _allDeposits = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDeposits();
  }

  Future<void> _loadDeposits() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final deposits = await WasteService.getDeposits();
      if (mounted) setState(() { _allDeposits = deposits; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<WasteDepositModel> get _filtered {
    if (_selectedFilter == 'Pending') return _allDeposits.where((d) => d.status == 'pending').toList();
    if (_selectedFilter == 'Selesai') return _allDeposits.where((d) => d.status == 'verified').toList();
    return _allDeposits;
  }

  int get _pendingCount => _allDeposits.where((d) => d.status == 'pending').length;
  int get _selesaiCount => _allDeposits.where((d) => d.status == 'verified').length;

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) return 'Hari ini, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
      if (diff.inDays == 1) return 'Kemarin, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
      return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[m - 1];
  }

  void _showVerificationSheet(WasteDepositModel deposit) {
    final beratCtrl = TextEditingController(text: deposit.weightKg.toStringAsFixed(1));
    final notesCtrl = TextEditingController(text: deposit.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        bool isVerifying = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(color: cardBorderColor, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: primaryDarkColor, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.fact_check_outlined, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Verifikasi Setoran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textDark)),
                              Text(deposit.code, style: const TextStyle(fontSize: 11, color: textGray)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: deposit.status == 'pending' ? const Color(0xFFF9EED9) : const Color(0xFFDCF5DC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            deposit.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w900,
                              color: deposit.status == 'pending' ? const Color(0xFFB8860B) : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardBorderColor),
                      ),
                      child: Column(
                        children: [
                          _sheetInfoRow('Nasabah', deposit.userName, Icons.person_outline),
                          const SizedBox(height: 8),
                          _sheetInfoRow('Jenis Sampah', deposit.wasteTypeName, Icons.recycling),
                          const SizedBox(height: 8),
                          _sheetInfoRow('Lokasi', deposit.dropPointName ?? '-', Icons.location_on_outlined),
                          const SizedBox(height: 8),
                          _sheetInfoRow('Est. Berat', '${deposit.weightKg.toStringAsFixed(1)} kg', Icons.monitor_weight_outlined),
                          const SizedBox(height: 8),
                          _sheetInfoRow('Est. Poin', '${deposit.estimatedPoints} Pts', Icons.stars_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Berat Aktual (kg)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textDark)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: beratCtrl,
                      enabled: deposit.status == 'pending',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.monitor_weight_outlined, size: 18, color: textGray),
                        suffixText: 'kg',
                        filled: true,
                        fillColor: cardBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Catatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textDark)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesCtrl,
                      enabled: deposit.status == 'pending',
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13, color: textDark),
                      decoration: InputDecoration(
                        hintText: deposit.status == 'pending' ? 'Contoh: Sampah dalam kondisi bersih' : (deposit.notes ?? '-'),
                        hintStyle: TextStyle(fontSize: 11, color: textGray.withOpacity(0.7)),
                        filled: true,
                        fillColor: cardBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (deposit.status == 'pending')
                      SizedBox(
                        width: double.infinity, height: 48,
                        child: ElevatedButton.icon(
                          onPressed: isVerifying
                              ? null
                              : () async {
                                  final berat = double.tryParse(beratCtrl.text.trim());
                                  if (berat == null || berat <= 0) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Masukkan berat aktual yang valid!')));
                                    return;
                                  }
                                  setSheetState(() => isVerifying = true);
                                  try {
                                    await WasteService.verifyDeposit(deposit.id, weightKg: berat, notes: notesCtrl.text.trim());
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (mounted) {
                                      _loadDeposits();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Row(children: [
                                            Icon(Icons.check_circle, color: Colors.white, size: 16),
                                            SizedBox(width: 8),
                                            Expanded(child: Text('Setoran diverifikasi! Poin berhasil diterbitkan.')),
                                          ]),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setSheetState(() => isVerifying = false);
                                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                                  }
                                },
                          icon: isVerifying
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                          label: Text(
                            isVerifying ? 'Memproses...' : 'Konfirmasi & Terbitkan Poin',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDarkColor, elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFDCF5DC), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Sudah diverifikasi. Poin +${deposit.earnedPoints ?? "-"} Pts telah diterbitkan.',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _sheetInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: textGray),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 11, color: textGray)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryDarkColor,
          onRefresh: _loadDeposits,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                            decoration: BoxDecoration(color: primaryDarkColor, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Text('ECOPOINTS PETUGAS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textDark, letterSpacing: 0.5)),
                        ],
                      ),
                      ValueListenableBuilder<UserModel?>(
                        valueListenable: AuthService.currentUserNotifier,
                        builder: (context, user, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: cardBackgroundColor, borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: cardBorderColor),
                            ),
                            child: Row(
                              children: [
                                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(user?.name ?? 'Petugas', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark)),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Riwayat Verifikasi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text('Daftar seluruh setoran masuk di Petugas', style: TextStyle(fontSize: 12, color: textGray)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildFilterButton('Semua', '${_allDeposits.length}'),
                      const SizedBox(width: 8),
                      _buildFilterButton('Pending', '$_pendingCount'),
                      const SizedBox(width: 8),
                      _buildFilterButton('Selesai', '$_selesaiCount'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SETORAN MASUK TERBARU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: textGray, letterSpacing: 0.5)),
                      Text('Total: ${filtered.length} Tiket', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textGray)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                  else if (_error != null)
                    _buildErrorState()
                  else if (filtered.isEmpty)
                    _buildEmptyState()
                  else
                    ...filtered.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: d.status == 'pending' ? _buildCardPending(d) : _buildCardSelesai(d),
                        )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String title, String count) {
    bool isSelected = _selectedFilter == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? primaryDarkColor : cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? primaryDarkColor : cardBorderColor),
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

  Widget _buildCardPending(WasteDepositModel deposit) {
    return GestureDetector(
      onTap: () => _showVerificationSheet(deposit),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(deposit.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textDark)),
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
                  decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(4), border: Border.all(color: cardBorderColor)),
                  child: Text(deposit.code, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textDark)),
                ),
                const SizedBox(width: 6),
                Text('•  ${_formatDate(deposit.createdAt)}', style: const TextStyle(fontSize: 11, color: textGray)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorderColor)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: cardBorderColor)),
                        child: const Icon(Icons.recycling, size: 18, color: primaryDarkColor),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(deposit.wasteTypeName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                          const SizedBox(height: 2),
                          Text('Est: ${deposit.weightKg.toStringAsFixed(1)} kg (~${deposit.estimatedPoints} Poin)', style: const TextStyle(fontSize: 10, color: textGray)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: primaryDarkColor, borderRadius: BorderRadius.circular(8)),
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
                  children: const [
                    Icon(Icons.bolt, size: 14, color: Color(0xFFB8860B)),
                    SizedBox(width: 4),
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
      ),
    );
  }

  Widget _buildCardSelesai(WasteDepositModel deposit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(deposit.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textDark)),
                  const SizedBox(width: 8),
                  Text('USR-${deposit.userId.toString().padLeft(5, '0')}', style: const TextStyle(fontSize: 10, color: textGray)),
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
                decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(4), border: Border.all(color: cardBorderColor)),
                child: Text(deposit.code, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textDark)),
              ),
              const SizedBox(width: 6),
              Text('•  ${_formatDate(deposit.createdAt)}', style: const TextStyle(fontSize: 11, color: textGray)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorderColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: cardBorderColor)),
                      child: const Icon(Icons.description_outlined, size: 18, color: primaryDarkColor),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deposit.wasteTypeName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textDark)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text('Aktual: ${deposit.weightKg.toStringAsFixed(1)} kg • Poin: ', style: const TextStyle(fontSize: 10, color: textGray)),
                            Text('+${deposit.earnedPoints ?? 0} Pts', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB8860B))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: cardBorderColor)),
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
              const Text('Poin diterbitkan ke nasabah', style: TextStyle(fontSize: 10, color: textGray)),
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

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCCCC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Gagal memuat riwayat. Tarik ke bawah untuk coba lagi.', style: TextStyle(fontSize: 12, color: Colors.red.shade700))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorderColor)),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: textGray.withOpacity(0.5)),
          const SizedBox(height: 10),
          const Text('Belum ada riwayat setoran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textGray)),
          const SizedBox(height: 4),
          Text('Tarik ke bawah untuk refresh', style: TextStyle(fontSize: 11, color: textGray.withOpacity(0.7))),
        ],
      ),
    );
  }
}

// ================= Profil Petugas =================
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
    const Color backgroundColor = Color(0xFFF5F3EC);
    const Color primaryDarkColor = Color(0xFF2C4033);
    const Color textDark = Color(0xFF1E1E1E);
    const Color textGray = Color(0xFF6B6B6B);
    const Color cardBackgroundColor = Color(0xFFECEAE0);
    const Color cardBorderColor = Color(0xFFDCD8C9);

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
                      decoration: BoxDecoration(color: primaryDarkColor, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'ECOPOINTS\nMODE PETUGAS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textDark, letterSpacing: 0.5, height: 1.2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Profil Petugas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5)),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor, borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: cardBorderColor, width: 1.5)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/images/profile.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 30, color: primaryDarkColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ValueListenableBuilder<UserModel?>(
                              valueListenable: AuthService.currentUserNotifier,
                              builder: (context, user, _) {
                                final name = user?.name ?? 'Budi Santoso';
                                final role = (user?.role ?? 'petugas').toUpperCase();
                                final id = user != null ? 'PET-${user.id.toString().padLeft(4, '0')}' : 'PET-0042';

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textDark)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: primaryDarkColor, borderRadius: BorderRadius.circular(6)),
                                          child: Text(id, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                        const SizedBox(width: 6),
                                        Text('Petugas Lapangan ($role)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textDark)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(user?.email ?? 'petugas@ecopoints.test', style: const TextStyle(fontSize: 11, color: textGray)),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Divider(color: cardBorderColor, height: 1),
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
                    color: cardBackgroundColor, borderRadius: BorderRadius.circular(16),
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
                              color: backgroundColor, borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: cardBorderColor),
                            ),
                            child: const Icon(Icons.lock_outline, size: 16, color: primaryDarkColor),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Keamanan Akun Petugas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textDark)),
                              Text('Ganti kata sandi secara berkala', style: TextStyle(fontSize: 10, color: textGray)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Kata Sandi Saat Ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _currentPassController,
                        obscureText: _obscureCurrent,
                        style: const TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          filled: true, fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: textGray),
                            onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Kata Sandi Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _newPassController,
                        obscureText: _obscureNew,
                        style: const TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          hintText: 'Minimal 8 karakter (huruf & angka)',
                          hintStyle: TextStyle(fontSize: 11, color: textGray.withOpacity(0.7)),
                          filled: true, fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: textGray),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Konfirmasi Kata Sandi Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textDark)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmPassController,
                        obscureText: _obscureConfirm,
                        style: const TextStyle(fontSize: 12, color: textDark),
                        decoration: InputDecoration(
                          hintText: 'Ulangi kata sandi baru',
                          hintStyle: TextStyle(fontSize: 11, color: textGray.withOpacity(0.7)),
                          filled: true, fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorderColor)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: textGray),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity, height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password baru berhasil disimpan!')),
                            );
                          },
                          icon: const Icon(Icons.check, size: 16, color: Colors.white),
                          label: const Text('Simpan Password Baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDarkColor, elevation: 0,
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
                    color: cardBackgroundColor, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorderColor),
                  ),
                  child: TextButton.icon(
                    onPressed: () async {
                      await AuthService.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                    label: const Text('Keluar dari Akun Petugas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.redAccent)),
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