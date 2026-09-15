import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/waste_deposit_model.dart';
import '../services/waste_service.dart';

class VerificationSheet extends StatefulWidget {
  const VerificationSheet({
    super.key,
    required this.deposit,
    this.onUpdated,
  });

  final WasteDepositModel deposit;
  final Future<void> Function()? onUpdated;

  @override
  State<VerificationSheet> createState() => _VerificationSheetState();
}

class _VerificationSheetState extends State<VerificationSheet> {
  late final TextEditingController _beratCtrl;
  late final TextEditingController _notesCtrl;
  bool _isVerifying = false;
  bool _isRejecting = false;

  WasteDepositModel get deposit => widget.deposit;

  bool get _isPending => deposit.status == 'pending';
  bool get _isRejected => deposit.status.toLowerCase() == 'rejected';

  @override
  void initState() {
    super.initState();
    _beratCtrl =
        TextEditingController(text: deposit.weightKg.toStringAsFixed(1));
    _notesCtrl = TextEditingController(text: deposit.notes ?? '');
  }

  @override
  void dispose() {
    _beratCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final berat = double.tryParse(_beratCtrl.text.trim());
    if (berat == null || berat <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan berat aktual yang valid!')));
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isVerifying = true);
    try {
      await WasteService.verifyDeposit(
        deposit.id,
        weightKg: berat,
        notes: _notesCtrl.text.trim(),
      );
      if (mounted) navigator.pop();
      await widget.onUpdated?.call();
      messenger.showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Expanded(
                child:
                    Text('Setoran diverifikasi! Poin berhasil diterbitkan.')),
          ]),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  Future<void> _handleReject() async {
    final reason = _notesCtrl.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Isi alasan penolakan di kolom Catatan dulu.')));
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isRejecting = true);
    try {
      await WasteService.rejectDeposit(deposit.id, reason: reason);
      if (mounted) navigator.pop();
      await widget.onUpdated?.call();
      messenger.showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.cancel, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Expanded(child: Text('Setoran ditolak.')),
          ]),
          backgroundColor: AppColors.danger,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRejecting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.fact_check_outlined,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Verifikasi Setoran',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text)),
                        Text(
                          deposit.code,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _isPending
                          ? AppColors.pendingBg
                          : (_isRejected
                              ? AppColors.dangerBg
                              : AppColors.successSoft),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isPending
                          ? 'MENUNGGU'
                          : (_isRejected ? 'DITOLAK' : 'SELESAI'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _isPending
                            ? AppColors.warning
                            : (_isRejected
                                ? AppColors.danger
                                : Colors.green.shade700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    _infoRow('Nasabah', deposit.userName, Icons.person_outline),
                    const SizedBox(height: 8),
                    _infoRow(
                        'Jenis Sampah', deposit.wasteTypeName, Icons.recycling),
                    const SizedBox(height: 8),
                    _infoRow('Lokasi', deposit.dropPointName ?? '-',
                        Icons.location_on_outlined),
                    const SizedBox(height: 8),
                    _infoRow(
                        'Est. Berat',
                        '${deposit.weightKg.toStringAsFixed(1)} kg',
                        Icons.monitor_weight_outlined),
                    const SizedBox(height: 8),
                    _infoRow('Est. Poin', '${deposit.estimatedPoints} Pts',
                        Icons.stars_outlined),
                    const SizedBox(height: 8),
                    _infoRow('Poin / kg', '${deposit.pointsPerKg} Pts per kg',
                        Icons.speed_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Berat Aktual (kg)',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              const SizedBox(height: 6),
              TextField(
                controller: _beratCtrl,
                enabled: _isPending,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.monitor_weight_outlined,
                      size: 18, color: AppColors.textMuted),
                  suffixText: 'kg',
                  filled: true,
                  fillColor: AppColors.surfaceAlt,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.surfaceBorder)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.surfaceBorder)),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _beratCtrl,
                builder: (_, __) {
                  final beratLive =
                      double.tryParse(_beratCtrl.text.trim()) ?? 0.0;
                  final poinLive = (beratLive * deposit.pointsPerKg).round();
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '× ${deposit.pointsPerKg} Poin/kg → sekitar $poinLive Poin untuk ${beratLive.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              const Text('Catatan',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              const SizedBox(height: 6),
              TextField(
                controller: _notesCtrl,
                enabled: _isPending,
                maxLines: 2,
                style: const TextStyle(fontSize: 13, color: AppColors.text),
                decoration: InputDecoration(
                  hintText: _isPending
                      ? 'Contoh: Sampah dalam kondisi bersih'
                      : (deposit.notes ?? '-'),
                  hintStyle: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted.withValues(alpha: 0.7)),
                  filled: true,
                  fillColor: AppColors.surfaceAlt,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.surfaceBorder)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.surfaceBorder)),
                ),
              ),
              const SizedBox(height: 16),
              if (_isPending) ...[
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: (_isVerifying || _isRejecting)
                              ? null
                              : _handleReject,
                          icon: _isRejecting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.danger))
                              : const Icon(Icons.cancel_outlined,
                                  size: 18, color: AppColors.danger),
                          label: Text(
                            _isRejecting ? 'Menolak...' : 'Tolak',
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isVerifying || _isRejecting
                              ? null
                              : _handleVerify,
                          icon: _isVerifying
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_outline,
                                  size: 18, color: Colors.white),
                          label: Text(
                            _isVerifying ? 'Memproses...' : 'Terbitkan Poin',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ] else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: _isRejected
                          ? AppColors.dangerBg
                          : AppColors.successSoft,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(_isRejected ? Icons.cancel : Icons.check_circle,
                          color: _isRejected ? Colors.red : Colors.green,
                          size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isRejected
                              ? 'Setoran ditolak.${(deposit.notes ?? '').isEmpty ? '' : '  Alasan: ${deposit.notes}.'}'
                              : 'Sudah diverifikasi. Poin +${deposit.earnedPoints ?? "-"} Pts telah diterbitkan.',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isRejected
                                  ? AppColors.danger
                                  : AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
