import '../config/api_config.dart';
import '../config/app_constants.dart';
import '../models/drop_point_model.dart';
import '../models/waste_type_model.dart';
import '../models/redemption_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

import '../models/waste_deposit_model.dart';

class WasteService {
  // Fetch list of active waste types
  static Future<List<WasteTypeModel>> getWasteTypes() async {
    final token = await AuthService.getToken();
    final data = await ApiService.get(
      ApiConfig.wasteTypes,
      token: token,
    );

    if (data is List) {
      return data
          .map((item) => WasteTypeModel.fromJson(item as Map<String, dynamic>))
          .where((item) => item.isActive)
          .toList();
    }
    return [];
  }

  // Fetch list of active drop points
  static Future<List<DropPointModel>> getDropPoints() async {
    final token = await AuthService.getToken();
    final data = await ApiService.get(
      ApiConfig.dropPoints,
      token: token,
    );

    if (data is List) {
      return data
          .map((item) => DropPointModel.fromJson(item as Map<String, dynamic>))
          .where((item) => item.isActive)
          .toList();
    }
    return [];
  }

  // Submit a new waste deposit
  static Future<WasteDepositModel> createDeposit({
    required int wasteTypeId,
    int? dropPointId,
    required double weightKg,
    String? notes,
  }) async {
    final token = await AuthService.getToken();
    final body = {
      'waste_type_id': wasteTypeId,
      if (dropPointId != null) 'drop_point_id': dropPointId,
      'weight_kg': weightKg,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final data = await ApiService.post(
      ApiConfig.wasteDeposits,
      body: body,
      token: token,
    );

    return WasteDepositModel.fromJson(data as Map<String, dynamic>);
  }

  // Fetch user's deposit history or all deposits if staff/admin
  static Future<List<WasteDepositModel>> getDeposits({String? status}) async {
    final token = await AuthService.getToken();
    String url = ApiConfig.wasteDeposits;
    if (status != null && status.isNotEmpty) {
      url += '?status=$status';
    }

    final data = await ApiService.get(
      url,
      token: token,
    );

    if (data is List) {
      return data
          .map((item) =>
              WasteDepositModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Verify a waste deposit (petugas/admin)
  static Future<WasteDepositModel> verifyDeposit(
    int id, {
    double? weightKg,
    String? notes,
  }) async {
    final token = await AuthService.getToken();
    final body = <String, dynamic>{};
    if (weightKg != null && weightKg > 0) body['weight_kg'] = weightKg;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    final data = await ApiService.put(
      ApiConfig.verifyWasteDeposit(id),
      body: body,
      token: token,
    );

    return WasteDepositModel.fromJson(data as Map<String, dynamic>);
  }

  // Tolak sebuah setoran (petugas/admin)
  static Future<WasteDepositModel> rejectDeposit(
    int id, {
    String? reason,
  }) async {
    final token = await AuthService.getToken();
    final body = <String, dynamic>{};
    if (reason != null && reason.isNotEmpty) body['notes'] = reason;

    final data = await ApiService.put(
      ApiConfig.rejectWasteDeposit(id),
      body: body,
      token: token,
    );

    return WasteDepositModel.fromJson(data as Map<String, dynamic>);
  }

  // Batalkan setoran oleh nasabah (status pending)
  static Future<WasteDepositModel> cancelDeposit(
    int id, {
    String? notes,
  }) async {
    final token = await AuthService.getToken();
    final body = <String, dynamic>{};
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    final data = await ApiService.put(
      ApiConfig.cancelWasteDeposit(id),
      body: body,
      token: token,
    );

    return WasteDepositModel.fromJson(data as Map<String, dynamic>);
  }

  // Semua penukaran hadiah (petugas/admin)
  static Future<List<RedemptionModel>> getAllRedemptions() async {
    final token = await AuthService.getToken();
    final data = await ApiService.get(
      ApiConfig.allRedemptions,
      token: token,
    );

    if (data is List) {
      return data
          .map((item) => RedemptionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Selesaikan penukaran hadiah (petugas/admin)
  static Future<RedemptionModel> completeRedemption(
    int id, {
    String? notes,
  }) async {
    final token = await AuthService.getToken();
    final body = <String, dynamic>{};
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    final data = await ApiService.put(
      ApiConfig.completeRedemption(id),
      body: body,
      token: token,
    );

    return RedemptionModel.fromJson(data as Map<String, dynamic>);
  }

  // Tolak penukaran hadiah (petugas/admin)
  static Future<RedemptionModel> rejectRedemption(
    int id, {
    String? reason,
  }) async {
    final token = await AuthService.getToken();
    final body = <String, dynamic>{};
    if (reason != null && reason.isNotEmpty) body['notes'] = reason;

    final data = await ApiService.put(
      ApiConfig.rejectRedemption(id),
      body: body,
      token: token,
    );

    return RedemptionModel.fromJson(data as Map<String, dynamic>);
  }

  // Redeem a reward
  static Future<RedemptionModel> redeemReward(int rewardId,
      {String? notes}) async {
    final token = await AuthService.getToken();
    final body = <String, dynamic>{};
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    final data = await ApiService.post(
      ApiConfig.redeemReward(rewardId),
      body: body,
      token: token,
    );

    return RedemptionModel.fromJson(data as Map<String, dynamic>);
  }

  // Get current user's redemption history
  static Future<List<RedemptionModel>> getMyRedemptions() async {
    final token = await AuthService.getToken();
    final data = await ApiService.get(
      ApiConfig.myRedemptions,
      token: token,
    );

    if (data is List) {
      return data
          .map((item) => RedemptionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static double _rupiahPerPoint = AppConstants.defaultRupiahPerPoint;
  static bool _rupiahRateLoaded = false;

  // Nilai rupiah per poin, dihitung dari harga sampah per kg di API.
  static Future<double> getRupiahPerPoint() async {
    if (_rupiahRateLoaded) return _rupiahPerPoint;
    try {
      final types = await getWasteTypes();
      final ratios = types
          .where((t) => t.pointsPerKg > 0)
          .map((t) => t.unitPricePerKg / t.pointsPerKg)
          .toList();
      if (ratios.isNotEmpty) {
        _rupiahPerPoint = ratios.reduce((a, b) => a + b) / ratios.length;
      }
    } catch (_) {
      // Pakai nilai default (AppConstants) bila API tidak tersedia.
    }
    _rupiahRateLoaded = true;
    return _rupiahPerPoint;
  }

  static void resetRupiahRateCache() {
    _rupiahRateLoaded = false;
    _rupiahPerPoint = AppConstants.defaultRupiahPerPoint;
  }
}
