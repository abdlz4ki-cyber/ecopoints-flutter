import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/waste_deposit_model.dart';
import '../models/redemption_model.dart';
import '../services/waste_service.dart';
import '../utils/redemption_status_ui.dart';
import 'setoran_detail_screen.dart';

// ================= Halaman Riwayat Lengkap =================
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _selectedTab = 'Semua';
  final List<String> _tabs = ['Semua', 'Setor Sampah', 'Tukar Hadiah'];

  List<WasteDepositModel> _deposits = [];
  List<RedemptionModel> _redemptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllHistory();
  }

  Future<void> _loadAllHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        WasteService.getDeposits(),
        WasteService.getMyRedemptions(),
      ]);

      if (mounted) {
        setState(() {
          _deposits = results[0] as List<WasteDepositModel>;
          _redemptions = results[1] as List<RedemptionModel>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Semua Riwayat Aktivitas',
          style: TextStyle(
              color: textDark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        iconTheme: IconThemeData(color: primaryDarkColor),
      ),
      body: Column(
        children: [
          // Tab bar filter
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = tab;
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
                            tab,
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
          ),
          const SizedBox(height: 8),

          // Content list
          Expanded(
            child: RefreshIndicator(
              color: primaryDarkColor,
              onRefresh: _loadAllHistory,
              child: _buildBody(cardBackgroundColor, cardBorderColor, textDark,
                  textGray, primaryDarkColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Color cardBg, Color cardBorder, Color textDark,
      Color textGray, Color primaryColor) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final List<Widget> items = [];

    // Tampilkan deposits jika tab 'Semua' atau 'Setor Sampah'
    if (_selectedTab == 'Semua' || _selectedTab == 'Setor Sampah') {
      for (final d in _deposits) {
        final isVerified = d.status.toLowerCase() == 'verified';
        final isRejected = d.status.toLowerCase() == 'rejected';
        final statusText =
            isVerified ? 'Selesai' : (isRejected ? 'Ditolak' : 'Menunggu');
        final statusBgColor = isVerified
            ? AppColors.successBg
            : (isRejected ? AppColors.dangerBg : AppColors.warningBg);
        final statusTextColor = isVerified
            ? AppColors.success
            : (isRejected ? AppColors.danger : AppColors.warning);

        String dateDisplay = 'Baru saja';
        if (d.createdAt != null && d.createdAt!.length >= 10) {
          dateDisplay = d.createdAt!.substring(0, 10);
        }

        final points = d.earnedPoints ?? d.estimatedPoints;

        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: GestureDetector(
              onTap: () async {
                final cancelled = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SetoranDetailScreen(deposit: d)),
                );
                if (cancelled == true && mounted) {
                  await _loadAllHistory();
                }
              },
              child: _buildActivityCard(
                icon: Icons.recycling,
                title: 'Setor ${d.wasteTypeName}',
                subtitle:
                    'Kode: ${d.code} • ${d.weightKg.toStringAsFixed(1)} kg\n${d.dropPointName ?? 'Drop Point'} • $dateDisplay',
                points: '+$points Poin',
                pointsColor: AppColors.gold,
                statusWidget: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: statusTextColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusTextColor),
                  ),
                ),
                bgColor: cardBg,
                borderColor: cardBorder,
              ),
            ),
          ),
        );
      }
    }

    // Tampilkan redemptions jika tab 'Semua' atau 'Tukar Hadiah'
    if (_selectedTab == 'Semua' || _selectedTab == 'Tukar Hadiah') {
      for (final r in _redemptions) {
        String dateDisplay = 'Baru saja';
        if (r.createdAt != null && r.createdAt!.length >= 10) {
          dateDisplay = r.createdAt!.substring(0, 10);
        }

        final statusUi = redemptionStatusUi(r);

        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildActivityCard(
              icon: Icons.card_giftcard,
              title: 'Tukar ${r.rewardName}',
              subtitle: '${r.notes ?? 'Kupon Hadiah'} • $dateDisplay',
              points: '-${r.pointsUsed} Poin',
              pointsColor: Colors.red.shade700,
              statusWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusUi.bg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusUi.fg.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusUi.label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusUi.fg),
                ),
              ),
              bgColor: cardBg,
              borderColor: cardBorder,
            ),
          ),
        );
      }
    }

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: textGray),
                const SizedBox(height: 12),
                Text(
                  'Belum ada riwayat pada kategori ini',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aktivitas setor dan tukar hadiah akan muncul di sini',
                  style: TextStyle(fontSize: 12, color: textGray),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      children: items,
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
