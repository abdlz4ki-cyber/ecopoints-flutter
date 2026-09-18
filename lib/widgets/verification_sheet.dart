import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Map<int, TextEditingController> _weightControllers = {};
  late final TextEditingController _singleWeightCtrl;
  late final TextEditingController _notesCtrl;
  bool _isVerifying = false;
  bool _isRejecting = false;

  WasteDepositModel get deposit => widget.deposit;

  bool get _isPending => deposit.status == 'pending';
  bool get _isRejected => deposit.status.toLowerCase() == 'rejected';

  @override
  void initState() {
    super.initState();
    _singleWeightCtrl =
        TextEditingController(text: deposit.weightKg.toStringAsFixed(1));
    _notesCtrl = TextEditingController(text: deposit.notes ?? '');

    for (final item in deposit.items) {
      final defaultWeight = item.actualWeightKg ??
          (item.originalWeightKg > 0 ? item.originalWeightKg : item.weightKg);
      _weightControllers[item.id] =
          TextEditingController(text: defaultWeight.toStringAsFixed(1));
    }
  }

  @override
  void dispose() {
    _singleWeightCtrl.dispose();
    _notesCtrl.dispose();
    for (final c in _weightControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerify() async {
    List<Map<String, dynamic>> itemsPayload = [];
    if (deposit.items.isNotEmpty) {
      for (final item in deposit.items) {
        final ctrl = _weightControllers[item.id];
        final w = double.tryParse(ctrl?.text.trim() ?? '');
        if (w == null || w <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Masukkan berat valid (> 0 kg) untuk "${item.wasteTypeName}"!')),
          );
          return;
        }
        if (w > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Berat maksimal untuk "${item.wasteTypeName}" adalah 100 kg!')),
          );
          return;
        }
        itemsPayload.add({
          'item_id': item.id,
          'weight_kg': w,
        });
      }
    } else {
      final w = double.tryParse(_singleWeightCtrl.text.trim());
      if (w == null || w <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan berat valid (> 0 kg)!')),
        );
        return;
      }
      if (w > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berat maksimal adalah 100 kg!')),
        );
        return;
      }
    }

    setState(() => _isVerifying = true);
    try {
      await WasteService.verifyDeposit(
        deposit.id,
        items: itemsPayload.isNotEmpty ? itemsPayload : null,
        notes: _notesCtrl.text.trim(),
      );
      HapticFeedback.heavyImpact();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      widget.onUpdated?.call();
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
    setState(() => _isRejecting = true);
    try {
      await WasteService.rejectDeposit(deposit.id, reason: reason);
      HapticFeedback.mediumImpact();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      widget.onUpdated?.call();
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
    double totalLiveWeight = 0;
    int totalLivePoints = 0;

    if (deposit.items.isNotEmpty) {
      for (final item in deposit.items) {
        final ctrl = _weightControllers[item.id];
        final w = double.tryParse(ctrl?.text.trim() ?? '') ??
            item.actualWeightKg ??
            item.weightKg;
        totalLiveWeight += w;
        totalLivePoints += (w * item.pointsPerKg).round();
      }
    } else {
      totalLiveWeight = deposit.weightKg;
      totalLivePoints = deposit.estimatedPoints;
    }

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
                    _infoRow('Lokasi', deposit.dropPointName ?? '-',
                        Icons.location_on_outlined),
                    const SizedBox(height: 8),
                    _infoRow('Total Jenis', '${deposit.items.length} jenis sampah',
                        Icons.recycling_outlined),
                    const SizedBox(height: 8),
                    _infoRow(
                        'Est. Total Berat',
                        '${deposit.totalWeightKg.toStringAsFixed(1)} kg',
                        Icons.monitor_weight_outlined),
                    const SizedBox(height: 8),
                    _infoRow('Est. Total Poin', '${deposit.estimatedPoints} Pts',
                        Icons.stars_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Detail & Berat Aktual per Jenis Sampah',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text)),
              const SizedBox(height: 8),

              // Multi-item weight edit list
              if (deposit.items.isNotEmpty)
                ...deposit.items.map((item) {
                  final ctrl = _weightControllers[item.id];
                  final liveW = double.tryParse(ctrl?.text.trim() ?? '') ??
                      item.actualWeightKg ??
                      item.weightKg;
                  final livePts = (liveW * item.pointsPerKg).round();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.wasteTypeName,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.greenTint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${item.pointsPerKg} Pts/kg',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Berat diajukan: ${item.originalWeightKg.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: TextField(
                                controller: ctrl,
                                enabled: _isPending,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*')),
                                ],
                                onChanged: (_) {
                                  if (mounted) setState(() {});
                                },
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text),
                                decoration: InputDecoration(
                                  labelText: 'Berat Aktual (kg)',
                                  labelStyle: const TextStyle(
                                      fontSize: 11, color: AppColors.textMuted),
                                  helperText: 'Maks. 100 kg',
                                  helperStyle: const TextStyle(
                                      fontSize: 9, color: AppColors.textMuted),
                                  suffixText: 'kg',
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: AppColors.surfaceBorder)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: AppColors.surfaceBorder)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.successSoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+$livePts Pts',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.success),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                })
              else ...[
                TextField(
                  controller: _singleWeightCtrl,
                  enabled: _isPending,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (_) {
                    if (mounted) setState(() {});
                  },
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
                    helperText: 'Maks. 100 kg',
                    helperStyle: const TextStyle(
                        fontSize: 9, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
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
              ],

              const SizedBox(height: 6),
              // Live Total summary card
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL BERAT & POIN',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5),
                        ),
                        Text(
                          '${totalLiveWeight.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text),
                        ),
                      ],
                    ),
                    Text(
                      '+$totalLivePoints POIN',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              const Text('Catatan Petugas',
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
                      ? 'Contoh: Sampah bersih & sudah dipilah'
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

