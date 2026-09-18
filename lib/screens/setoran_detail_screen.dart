import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
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
      messenger.showSnackBar(const SnackBar(
        content: Row(children: [
          Icon(Icons.cancel, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text('Setoran berhasil dibatalkan.')),
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

  void _shareReceiptSummary() {
    final isRejected = deposit.status.toLowerCase() == 'rejected';
    final isCancelled = deposit.status.toLowerCase() == 'cancelled' ||
        deposit.status.toLowerCase() == 'canceled';

    final itemsText = deposit.items.map((i) {
      final w = i.actualWeightKg ?? i.weightKg;
      final p = (isRejected || isCancelled)
          ? 0
          : (i.earnedPoints ?? i.estimatedPoints);
      return '  • ${i.wasteTypeName}: ${w.toStringAsFixed(2)} kg (${i.pointsPerKg} Pts/kg) -> ${isRejected || isCancelled ? "0 Pts" : "+$p Pts"}';
    }).join('\n');

    final pointsText = (isRejected || isCancelled)
        ? '0 Poin (${isRejected ? "Ditolak" : "Dibatalkan"})'
        : '+${deposit.earnedPoints ?? deposit.estimatedPoints} Poin';

    final summary = '''
════════════════════════════════
    BUKTI RESI SETORAN ECOPOINTS
════════════════════════════════
No. Transaksi : ${deposit.code}
Status        : ${deposit.status.toUpperCase()}
Daftar Sampah :
$itemsText
Total Berat   : ${deposit.totalWeightKg.toStringAsFixed(2)} kg
Poin Didapat  : $pointsText
Drop Point    : ${deposit.dropPointName ?? '-'}
Waktu         : ${deposit.createdAt ?? '-'}
════════════════════════════════
Disetor via Aplikasi EcoPoints Mobile
''';
    Clipboard.setData(ClipboardData(text: summary));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Ringkasan E-Receipt disalin ke clipboard!'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = deposit.status.toLowerCase() == 'verified';
    final isRejected = deposit.status.toLowerCase() == 'rejected';
    final isCancelled = deposit.status.toLowerCase() == 'cancelled' ||
        deposit.status.toLowerCase() == 'canceled';

    final statusText = isVerified
        ? 'DIVERIFIKASI'
        : (isRejected
            ? 'DITOLAK'
            : (isCancelled ? 'DIBATALKAN' : 'MENUNGGU VERIFIKASI'));
    final statusIcon = isVerified
        ? Icons.check_circle_rounded
        : (isRejected
            ? Icons.cancel_rounded
            : (isCancelled
                ? Icons.highlight_off_rounded
                : Icons.hourglass_bottom_rounded));
    final statusBg = isVerified
        ? AppColors.successBg
        : (isRejected || isCancelled
            ? AppColors.dangerBg
            : AppColors.warningBg);
    final statusFg = isVerified
        ? AppColors.success
        : (isRejected || isCancelled ? AppColors.danger : AppColors.warning);

    final finalPoints = deposit.earnedPoints ?? deposit.estimatedPoints;
    final co2Saved = deposit.totalWeightKg * AppConstants.co2ReductionPerKg;

    String dateDisplay = 'Baru saja';
    if (deposit.createdAt != null && deposit.createdAt!.length >= 10) {
      dateDisplay = deposit.createdAt!.substring(0, 10);
      if (deposit.createdAt!.length >= 16) {
        dateDisplay =
            '${deposit.createdAt!.substring(0, 10)} ${deposit.createdAt!.substring(11, 16)} WIB';
      }
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Bukti Resi Setoran',
          style: TextStyle(
              fontWeight: FontWeight.w800, color: AppColors.text, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.text),
            tooltip: 'Bagikan Bukti',
            onPressed: _shareReceiptSummary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // E-Receipt Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Receipt Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.receipt_long_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ECOPOINTS DIGITAL RECEIPT',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Bukti Resmi Transaksi Bank Sampah',
                                  style: TextStyle(
                                      fontSize: 10, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: statusFg.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, color: statusFg, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: statusFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // QR Code & Transaction Code Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.surfaceBorder, width: 1.5),
                          ),
                          child: QrImageView(
                            data: deposit.code,
                            version: QrVersions.auto,
                            size: 130,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              deposit.code,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: deposit.code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Nomor resi disalin!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.copy,
                                    size: 15, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tunjukkan kode QR ini kepada petugas di Drop Point',
                          style: TextStyle(
                              fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),

                  // Dashed divider line
                  _buildDashedLine(),

                  // Receipt Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RINCIAN TRANSAKSI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _receiptRow('Waktu Transaksi', dateDisplay),
                        _receiptRow('Drop Point',
                            deposit.dropPointName ?? 'Titik Setor Mitra'),
                        if (deposit.notes != null &&
                            deposit.notes!.trim().isNotEmpty)
                          _receiptRow('Catatan', deposit.notes!),

                        const SizedBox(height: 12),
                        const Text(
                          'ITEM SAMPAH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Item list
                        if (deposit.items.isNotEmpty)
                          ...deposit.items.map((item) {
                            final w = item.actualWeightKg ?? item.weightKg;
                            final pts = item.earnedPoints ?? item.estimatedPoints;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.wasteTypeName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${w.toStringAsFixed(2)} kg  •  ${item.pointsPerKg} Pts/kg',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    (isRejected || isCancelled)
                                        ? '0 Pts'
                                        : '+$pts Pts',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: (isRejected || isCancelled)
                                          ? AppColors.textMuted
                                          : AppColors.gold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                        else
                          _receiptRow('Jenis Sampah', deposit.wasteTypeName),

                        const SizedBox(height: 10),
                        _receiptRow(
                            'Total Berat',
                            '${deposit.totalWeightKg.toStringAsFixed(2)} kg'),

                        const SizedBox(height: 12),
                        _buildDashedLine(),
                        const SizedBox(height: 12),

                        // Total Points Box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: (isRejected || isCancelled)
                                ? AppColors.dangerBg
                                : (isVerified
                                    ? AppColors.successBg
                                    : AppColors.primary.withValues(alpha: 0.08)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: (isRejected || isCancelled)
                                  ? AppColors.danger.withValues(alpha: 0.4)
                                  : (isVerified
                                      ? AppColors.success.withValues(alpha: 0.4)
                                      : AppColors.primary.withValues(alpha: 0.3)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isRejected
                                        ? 'STATUS POIN (DITOLAK)'
                                        : (isCancelled
                                            ? 'STATUS POIN (DIBATALKAN)'
                                            : (isVerified
                                                ? 'TOTAL POIN DIDAPAT'
                                                : 'PERKIRAAN POIN')),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      color: (isRejected || isCancelled)
                                          ? AppColors.danger
                                          : (isVerified
                                              ? AppColors.success
                                              : AppColors.primary),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    (isRejected || isCancelled)
                                        ? '0 POIN'
                                        : '+$finalPoints POIN',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: (isRejected || isCancelled)
                                          ? AppColors.danger
                                          : (isVerified
                                              ? AppColors.success
                                              : AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                (isRejected || isCancelled)
                                    ? Icons.cancel_outlined
                                    : Icons.stars_rounded,
                                color: (isRejected || isCancelled)
                                    ? AppColors.danger
                                    : AppColors.primary,
                                size: 36,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Eco Impact Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.eco_rounded,
                                  color: AppColors.success, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Setoran ini mencegah emisi setara ~${co2Saved.toStringAsFixed(2)} kg CO₂e bagi bumi!',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom receipt tear effect
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareReceiptSummary,
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Salin Resi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: const BorderSide(color: AppColors.surfaceBorder),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (deposit.status.toLowerCase() == 'pending') ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isCancelling ? null : _handleCancel,
                      icon: _isCancelling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cancel_outlined,
                              size: 16, color: Colors.white),
                      label: Text(
                        _isCancelling ? 'Membatalkan...' : 'Batalkan',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final dashCount =
            (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1.2,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.surfaceBorder),
              ),
            );
          }),
        );
      },
    );
  }
}
