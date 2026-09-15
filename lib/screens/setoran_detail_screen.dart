import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/app_colors.dart';
import '../models/waste_deposit_model.dart';
import '../services/waste_service.dart';

class SetoranDetailScreen extends StatefulWidget {
  final WasteDepositModel deposit;

  const SetoranDetailScreen({super.key, required this.deposit});

  @override
  State<SetoranDetailScreen> createState() => _SetoranDetailScreenState();
}

class _SetoranDetailScreenState extends State<SetoranDetailScreen> {
  bool _isCancelling = false;

  WasteDepositModel get deposit => widget.deposit;

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Setoran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
            'Setoran "${deposit.code}" akan dibatalkan. Yakin ingin membatalkan?',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx, false),
            child: const Text('Tidak',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dlgCtx, true),
            child: const Text('Ya, Batalkan',
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

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isCancelling = true);
    try {
      await WasteService.cancelDeposit(deposit.id);
      messenger.showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.cancel, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text('Setoran dibatalkan.')),
        ]),
        backgroundColor: AppColors.danger,
      ));
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      messenger.showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = deposit.status.toLowerCase() == 'verified';
    final isRejected = deposit.status.toLowerCase() == 'rejected';
    final isCancelled = deposit.status.toLowerCase() == 'cancelled' ||
        deposit.status.toLowerCase() == 'canceled';
    final statusText = isVerified
        ? 'Selesai'
        : (isRejected
            ? 'Ditolak'
            : (isCancelled ? 'Dibatalkan' : 'Menunggu Verifikasi'));
    final statusIcon = isVerified
        ? Icons.check_circle
        : (isRejected
            ? Icons.cancel
            : (isCancelled
                ? Icons.cancel_presentation_outlined
                : Icons.hourglass_top));
    final statusBg = isVerified
        ? AppColors.successBg
        : (isRejected || isCancelled
            ? AppColors.dangerBg
            : AppColors.warningBg);
    final statusFg = isVerified
        ? AppColors.success
        : (isRejected || isCancelled ? AppColors.danger : AppColors.warning);

    final String statusInfo;
    if (isVerified) {
      statusInfo =
          'Petugas sudah memverifikasi setoran ini. Poin sebesar ${deposit.earnedPoints ?? deposit.estimatedPoints} sudah diterbitkan ke saldo Anda.';
    } else if (isRejected) {
      final note =
          (deposit.notes ?? '').isEmpty ? '' : '  Alasan: ${deposit.notes}.';
      statusInfo = 'Setoran ini tidak disetujui petugas.$note';
    } else if (isCancelled) {
      final note =
          (deposit.notes ?? '').isEmpty ? '' : '  Catatan: ${deposit.notes}.';
      statusInfo = 'Setoran ini dibatalkan.$note';
    } else {
      statusInfo =
          'Petugas setempat sedang mengecek ulang berat & kondisi sampah Anda. Estimasi poin ${deposit.estimatedPoints} masuk saldo setelah diverifikasi.';
    }

    String dateDisplay = 'Baru saja';
    if (deposit.createdAt != null && deposit.createdAt!.length >= 10) {
      dateDisplay = deposit.createdAt!.substring(0, 10);
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Detail Setoran',
            style:
                TextStyle(fontWeight: FontWeight.w700, color: AppColors.text)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: statusFg.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusFg, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(statusText,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: statusFg)),
                        const SizedBox(height: 3),
                        Text(statusInfo,
                            style: TextStyle(
                                fontSize: 11.5,
                                height: 1.35,
                                color: statusFg.withValues(alpha: 0.9))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kode QR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  const Text('Kode Setoran',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  QrImageView(
                    data: deposit.code,
                    version: QrVersions.auto,
                    size: 130,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(deposit.code,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppColors.text)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: deposit.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kode disalin')),
                          );
                        },
                        child: const Icon(Icons.copy,
                            size: 15, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tunjukkan kode ini ke petugas untuk verifikasi.',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detail
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informasi Setoran',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text)),
                  const SizedBox(height: 12),
                  _detailRow(
                      Icons.recycling, 'Jenis Sampah', deposit.wasteTypeName),
                  _detailRow(Icons.location_on_outlined, 'Drop Point',
                      deposit.dropPointName ?? 'Tidak diketahui'),
                  _detailRow(Icons.event, 'Tanggal Setor', dateDisplay),
                  _detailRow(Icons.monitor_weight_outlined, 'Berat',
                      '${deposit.weightKg.toStringAsFixed(1)} kg'),
                  _detailRow(Icons.layers_outlined, 'Poin per kg',
                      '${deposit.pointsPerKg} Poin / kg'),
                  _detailRow(
                      Icons.stars_outlined,
                      'Poin Diterbitkan',
                      isVerified
                          ? '+${deposit.earnedPoints ?? deposit.estimatedPoints} Poin'
                          : (isRejected || isCancelled
                              ? '${deposit.earnedPoints?.toString() ?? '0'} Poin'
                              : '${deposit.estimatedPoints} Poin (estimasi)'),
                      valueColor: isVerified
                          ? AppColors.success
                          : (isRejected || isCancelled
                              ? AppColors.danger
                              : AppColors.warning)),
                  if (deposit.notes != null && deposit.notes!.isNotEmpty)
                    _detailRow(
                        Icons.notes_outlined, 'Keterangan', deposit.notes!),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (deposit.status.toLowerCase() == 'pending')
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isCancelling ? null : _handleCancel,
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.danger))
                      : const Icon(Icons.cancel_outlined,
                          size: 18, color: AppColors.danger),
                  label: Text(
                    _isCancelling ? 'Membatalkan...' : 'Batalkan Setoran',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger),
                    backgroundColor: AppColors.dangerBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
          const SizedBox(width: 10),
          Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.text)),
        ],
      ),
    );
  }
}
