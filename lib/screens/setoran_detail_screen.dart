import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/app_colors.dart';
import '../models/waste_deposit_model.dart';

class SetoranDetailScreen extends StatelessWidget {
  final WasteDepositModel deposit;

  const SetoranDetailScreen({super.key, required this.deposit});

  @override
  Widget build(BuildContext context) {
    final isVerified = deposit.status.toLowerCase() == 'verified';
    final isRejected = deposit.status.toLowerCase() == 'rejected';
    final statusText = isVerified
        ? 'Selesai'
        : (isRejected ? 'Ditolak' : 'Menunggu Verifikasi');
    final statusIcon = isVerified
        ? Icons.check_circle
        : (isRejected ? Icons.cancel : Icons.hourglass_top);
    final statusBg = isVerified
        ? AppColors.successBg
        : (isRejected ? AppColors.dangerBg : AppColors.warningBg);
    final statusFg = isVerified
        ? AppColors.success
        : (isRejected ? AppColors.danger : AppColors.warning);

    final String statusInfo;
    if (isVerified) {
      statusInfo =
          'Petugas sudah memverifikasi setoran ini. Poin sebesar ${deposit.earnedPoints ?? deposit.estimatedPoints} sudah diterbitkan ke saldo Anda.';
    } else if (isRejected) {
      final note =
          (deposit.notes ?? '').isEmpty ? '' : '  Alasan: ${deposit.notes}.';
      statusInfo = 'Setoran ini tidak disetujui petugas.$note';
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
                          : (isRejected
                              ? '${deposit.earnedPoints?.toString() ?? '0'} Poin'
                              : '${deposit.estimatedPoints} Poin (estimasi)'),
                      valueColor: isVerified
                          ? AppColors.success
                          : (isRejected
                              ? AppColors.danger
                              : AppColors.warning)),
                  if (deposit.notes != null && deposit.notes!.isNotEmpty)
                    _detailRow(
                        Icons.notes_outlined, 'Keterangan', deposit.notes!),
                ],
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
