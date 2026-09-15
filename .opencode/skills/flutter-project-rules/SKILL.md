---
name: flutter-project-rules
description: Use whenever making changes to any Dart file under lib/ in the ecopoints-flutter project. Enforces conventions: Indonesian UI text and consistent terminology, AppColors palette instead of raw hex colors, business values from app_constants/app_levels instead of hardcodes, dart format on touched files only, respecting unrelated user changes, and flutter analyze + flutter test passing before declaring done.
---

# Flutter Project Rules (ecopoints-flutter)

EcoPoints is a waste-bank points app: UI text in Indonesian, nasabah UI + petugas portal, Go backend at `http://139.190.96.203:8092/api/v1`.

## Non-negotiables

1. **UI text in Indonesian, consistent terms.**
   - Deposit = "Setor"/"Setoran"; redeem = "Tukar"/"Penukaran".
   - Status: deposit → "Menunggu" / "Selesai" / "Ditolak"; redemption → "Sedang Diproses" / "Siap Digunakan" / "Ditolak" / "Kedaluwarsa".
   - Layar: Beranda, Katalog, Riwayat, Panduan, Leaderboard, Profil, Portal Petugas.

2. **No raw hex colors.** All colors come from `lib/config/app_colors.dart` (`AppColors.*`). Prefer semantic tokens (`surface`, `surfaceAlt`, `surfaceBorder`, `text`, `textMuted`, `primary`, `success`/`successBg`, `danger`/`dangerBg`, `warning`/`warningBg`, `pendingCard`, `gold`). Never introduce `Color(0xFF...)`. Avoid `Colors.red.shade...` except where trivially unavoidable.

3. **No hardcoded business values.** Use:
   - `lib/config/app_constants.dart` → `defaultRupiahPerPoint`, `co2ReductionPerKg`, formatting helpers.
   - `lib/config/app_levels.dart` → `AppLevels.tiers`, `fromPoints()`, `nextLevel()`, `progress()`, `label()`, `pointsToNext()`.
   - Never inline point rates, rupiah-per-point, level thresholds, or CO2 constants.

4. **`dart format` only the files you touched.** Revert formatting churn on untouched files. Check `git status` before finishing.

5. **Respect unrelated changes.** Do not modify files the user is working on independently (e.g. `android/`, `ios/`, `pubspec.*`, `welcome_screen.dart`, `register_screen.dart`) unless the task explicitly requires it.

6. **Verify before done.** `dart format` (touched files) → `flutter analyze` must report "No issues found!" → `flutter test` must pass → `git status` shows only intended files changed.

## Conventions

- Mimic surrounding code. Large screens live in `lib/main.dart` as StatefulWidget + `_build*` methods; use local aliases like `final textDark = AppColors.text;`.
- Thousands separator (dots): `x.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")`.
- Weight: `${x.toStringAsFixed(1)} kg`. Points suffix: "Poin".
- Level label: `AppLevels.label(points)` → "Lv. 3 Pencinta Bumi"; progress bar value: `AppLevels.progress(points)` (0.0–1.0).
- Rupiah-per-point: `WasteService.getRupiahPerPoint()` (cached; call `resetRupiahRateCache()` to force refresh). Fallback `AppConstants.defaultRupiahPerPoint`.
- Avatar: `UserAvatar` widget (initials), not emoji/text pictures.
- QR: `QrImageView` from `qr_flutter`.

## Backend contract & gotchas

- Base URL in `lib/config/api_config.dart`; HTTP calls in `lib/services/waste_service.dart` and `lib/services/auth_service.dart`. Models in `lib/models/` mirror snake_case JSON keys.
- `WasteDepositModel`: id, code, userId, userName, wasteTypeId, wasteTypeName, pointsPerKg, dropPointId?, dropPointName?, weightKg, estimatedPoints, earnedPoints?, status, notes?, createdAt?. There is **no `verified_at` and no queue info** — don't claim to show "antrean/estimasi waktu verifikasi" unless the API adds it.
- **Backend has NO reject endpoint.** `verifyWasteDeposit` accepts `weight_kg` + optional `notes` only. Do not build a formal "tolak + alasan" flow; express rejection via UI state and notes text.
- `lib/petugas_page.dart` is large and contains **two `_showVerificationSheet` definitions** (dashboard tab and riwayat tab). When editing one, update/check the other so they stay consistent, and be careful with brace balance around `StatefulBuilder`.