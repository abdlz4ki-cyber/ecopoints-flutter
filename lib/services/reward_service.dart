import '../config/api_config.dart';
import '../models/reward_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class RewardService {
  // Fetch active rewards catalog
  static Future<List<RewardModel>> getRewards() async {
    final token = await AuthService.getToken();
    final data = await ApiService.get(
      ApiConfig.rewards,
      token: token,
    );

    if (data is List) {
      return data
          .map((item) => RewardModel.fromJson(item as Map<String, dynamic>))
          .where((item) => item.isActive)
          .toList();
    }
    return [];
  }
}
