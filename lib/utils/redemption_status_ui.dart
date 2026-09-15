import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/redemption_model.dart';

class RedemptionStatusUi {
  final String label;
  final Color bg;
  final Color fg;

  const RedemptionStatusUi(this.label, this.bg, this.fg);
}

RedemptionStatusUi redemptionStatusUi(RedemptionModel r) {
  final s = r.status.toLowerCase();
  if (s == 'completed' || s == 'approved' || s == 'success') {
    return const RedemptionStatusUi(
        'Siap Digunakan', AppColors.successBg, AppColors.success);
  }
  if (s == 'pending' || s == 'processing' || s == 'processed') {
    return const RedemptionStatusUi(
        'Sedang Diproses', AppColors.pendingCard, AppColors.pendingCardText);
  }
  if (s == 'rejected' || s == 'cancelled' || s == 'canceled' || s == 'failed') {
    return const RedemptionStatusUi(
        'Ditolak', AppColors.dangerBg, AppColors.danger);
  }
  if (s == 'expired') {
    return const RedemptionStatusUi(
        'Kedaluwarsa', AppColors.surfaceBorderSoft, AppColors.textMuted);
  }
  return RedemptionStatusUi(
      r.status, AppColors.pendingCard, AppColors.pendingCardText);
}
