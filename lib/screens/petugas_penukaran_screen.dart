import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/redemption_model.dart';
import '../services/waste_service.dart';
import '../utils/redemption_status_ui.dart';

// ================= Kelola Penukaran (Petugas) =================
class PetugasPenukaranScreen extends StatefulWidget {
  const PetugasPenukaranScreen({super.key});

  @override
  State<PetugasPenukaranScreen> createState() => _PetugasPenukaranScreenState();
}

class _PetugasPenukaranScreenState extends State<PetugasPenukaranScreen> {
  static const Color backgroundColor = AppColors.surface;
  static const Color primaryDarkColor = AppColors.primary;
  static const Color textDark = AppColors.text;
  static const Color textGray = AppColors.textMuted;
  static const Color cardBackgroundColor = AppColors.surfaceAlt;
  static const Color cardBorderColor = AppColors.surfaceBorder;

  List<RedemptionModel> _redemptions = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'Semua';

  bool _isActionable(RedemptionModel r) {
    final s = r.status.toLowerCase();
    return s == 'pending' || s == 'processing' || s == 'processed';
  }

  bool _isDone(RedemptionModel r) {
    final s = r.status.toLowerCase();
    return s == 'completed' || s == 'approved' || s == 'success';
  }

  bool _isRejected(RedemptionModel r) {
    final s = r.status.toLowerCase();
    return s == 'rejected' ||
        s == 'cancelled' ||
        s == 'canceled' ||
        s == 'failed' ||
        s == 'expired';
  }

  int get _actionCount => _redemptions.where(_isActionable).length;
  int get _doneCount => _redemptions.where(_isDone).length;

  List<RedemptionModel> get _filtered {
    switch (_selectedFilter) {
      case 'Perlu Aksi':
        return _redemptions.where(_isActionable).toList();
      case 'Selesai':
        return _redemptions.where(_isDone).toList();
      case 'Ditolak':
        return _redemptions.where(_isRejected).toList();
      default:
        return _redemptions;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRedemptions();
  }

  Future<void> _loadRedemptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await WasteService.getAllRedemptions();
      if (!mounted) return;
      setState(() {
        _redemptions = list;
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

  String _formatPoints(int points) => points.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );

  Future<void> _handleComplete(RedemptionModel r) async {
    // Capture the messenger BEFORE any async gap
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: cardBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Selesaikan Penukaran',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
        content: Text(
          'Tandai penukaran "${r.rewardName}" sudah selesai diproses?',
          style: const TextStyle(fontSize: 13, color: textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx, false),
            child: const Text('Batal', style: TextStyle(color: textGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryDarkColor),
            onPressed: () => Navigator.pop(dlgCtx, true),
            child: const Text('Selesaikan',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    try {
      await WasteService.completeRedemption(r.id, notes: r.notes);
      await _loadRedemptions();
      messenger.showSnackBar(const SnackBar(
        content: Row(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text('Penukaran berhasil diselesaikan!')),
        ]),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}'),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  Future<void> _handleReject(RedemptionModel r) async {
    // Capture the messenger BEFORE any async gap to avoid context issues
    final messenger = ScaffoldMessenger.of(context);
    final reasonCtrl = TextEditingController();
    String? validationError;

    try {
      final reason = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dlgCtx) {
          return StatefulBuilder(
            // Use '_' for the StatefulBuilder context to prevent
            // accidentally shadowing the outer widget's context
            builder: (_, setDlgState) => AlertDialog(
              backgroundColor: cardBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Tolak Penukaran',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tolak penukaran "${r.rewardName}"?',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonCtrl,
                    autofocus: true,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13, color: textDark),
                    decoration: InputDecoration(
                      hintText: 'Alasan penolakan (wajib diisi)',
                      hintStyle:
                          const TextStyle(fontSize: 12, color: textGray),
                      errorText: validationError,
                      filled: true,
                      fillColor: backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: cardBorderColor)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: cardBorderColor)),
                    ),
                    onChanged: (_) {
                      if (validationError != null) {
                        setDlgState(() => validationError = null);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgCtx),
                  child:
                      const Text('Batal', style: TextStyle(color: textGray)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger),
                  onPressed: () {
                    final text = reasonCtrl.text.trim();
                    if (text.isEmpty) {
                      setDlgState(() =>
                          validationError = 'Isi alasan penolakan dulu.');
                      return;
                    }
                    Navigator.pop(dlgCtx, text);
                  },
                  child: const Text('Tolak',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ],
            ),
          );
        },
      );

      if (reason == null || reason.isEmpty) return;
      if (!mounted) return;

      await WasteService.rejectRedemption(r.id, reason: reason);
      await _loadRedemptions();

      // Use the captured messenger – safe even if widget is no longer mounted
      messenger.showSnackBar(const SnackBar(
        content: Row(children: [
          Icon(Icons.cancel, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text('Penukaran berhasil ditolak.')),
        ]),
        backgroundColor: AppColors.danger,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}'),
        backgroundColor: AppColors.danger,
      ));
    } finally {
      reasonCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryDarkColor,
          onRefresh: _loadRedemptions,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: primaryDarkColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.card_giftcard_outlined,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text('ECOPOINTS PETUGAS',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                              letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Kelola Penukaran',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text('Proses & verifikasi penukaran hadiah nasabah',
                      style: TextStyle(fontSize: 12, color: textGray)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildFilterButton('Semua', '${_redemptions.length}'),
                      const SizedBox(width: 8),
                      _buildFilterButton('Perlu Aksi', '$_actionCount'),
                      const SizedBox(width: 8),
                      _buildFilterButton('Selesai', '$_doneCount'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('PENUKARAN HADIAH',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: textGray,
                              letterSpacing: 0.5)),
                      Text('Total: ${filtered.length} Penukaran',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: textGray)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator()))
                  else if (_error != null)
                    _buildErrorState()
                  else if (filtered.isEmpty)
                    _buildEmptyState()
                  else
                    ...filtered.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildRedemptionCard(r),
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
            border: Border.all(
                color: isSelected ? primaryDarkColor : cardBorderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : textDark)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.avatarBgSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(count,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : textDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRedemptionCard(RedemptionModel r) {
    final statusUi = redemptionStatusUi(r);
    final isEwallet = r.rewardName.toLowerCase().contains('gopay') ||
        r.rewardName.toLowerCase().contains('ovo') ||
        r.rewardName.toLowerCase().contains('dana') ||
        r.rewardName.toLowerCase().contains('shopee');
    final dateDisplay = (r.createdAt != null && r.createdAt!.length >= 10)
        ? r.createdAt!.substring(0, 10)
        : 'Baru saja';
    final pointsLabel = isEwallet || r.voucherCode != null
        ? 'Kode: ${r.voucherCode ?? '-'}'
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      child: const Icon(Icons.card_giftcard,
                          size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.rewardName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: textDark)),
                          const SizedBox(height: 2),
                          Text(
                            '${r.userName ?? 'Nasabah'} • ${_formatPoints(r.pointsUsed)} Poin',
                            style:
                                const TextStyle(fontSize: 11, color: textGray),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusUi.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(statusUi.label,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusUi.fg)),
              ),
            ],
          ),
          if (r.notes != null && r.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                    isEwallet
                        ? Icons.account_balance_wallet_outlined
                        : Icons.sticky_note_2_outlined,
                    size: 13,
                    color: textGray),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${isEwallet ? 'Tujuan E-Wallet' : 'Catatan'}: ${r.notes}',
                    style: const TextStyle(fontSize: 11, color: textDark),
                  ),
                ),
              ],
            ),
          ],
          if (pointsLabel != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cardBorderColor)),
              child: Row(
                children: [
                  Icon(Icons.confirmation_number_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(pointsLabel,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textDark)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(dateDisplay,
              style: const TextStyle(fontSize: 10, color: textGray)),
          if (_isActionable(r)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleReject(r),
                    icon: const Icon(Icons.cancel_outlined,
                        size: 15, color: AppColors.danger),
                    label: const Text('Tolak',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.danger)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger),
                      backgroundColor: AppColors.dangerBg,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleComplete(r),
                    icon: const Icon(Icons.check_circle_outline,
                        size: 15, color: Colors.white),
                    label: const Text('Selesaikan',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorderColor)),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 40, color: textGray),
          const SizedBox(height: 12),
          const Text('Gagal memuat data penukaran',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(_error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: textGray)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadRedemptions,
            style: ElevatedButton.styleFrom(backgroundColor: primaryDarkColor),
            child: const Text('Coba Lagi',
                style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorderColor)),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard, size: 40, color: textGray),
          const SizedBox(height: 12),
          const Text('Tidak ada penukaran',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Belum ada penukaran hadiah pada kategori ini.',
              style: TextStyle(fontSize: 11, color: textGray)),
        ],
      ),
    );
  }
}
