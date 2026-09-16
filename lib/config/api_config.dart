class ApiConfig {
  // Allow overriding baseUrl during development or in settings
  static String? _customBaseUrl;

  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url;
  }

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    // VPS API server
    return 'http://139.190.96.203:8092/api/v1';
    // return 'http://10.0.2.2:8092/api/v1';

  }

  // Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get me => '$baseUrl/auth/me';
  static String get changePassword => '$baseUrl/auth/change-password';
  static String get wasteTypes => '$baseUrl/waste-types';
  static String get dropPoints => '$baseUrl/drop-points';
  static String get rewards => '$baseUrl/rewards';
  static String get wasteDeposits => '$baseUrl/waste-deposits';
  static String get myRedemptions => '$baseUrl/rewards/my-redemptions';
  static String get allRedemptions => '$baseUrl/rewards/redemptions';
  static String get pushTokens => '$baseUrl/push-tokens';
  static String redeemReward(int id) => '$baseUrl/rewards/$id/redeem';
  static String verifyWasteDeposit(int id) =>
      '$baseUrl/waste-deposits/$id/verify';
  static String rejectWasteDeposit(int id) =>
      '$baseUrl/waste-deposits/$id/reject';
  static String cancelWasteDeposit(int id) =>
      '$baseUrl/waste-deposits/$id/cancel';
  static String completeRedemption(int id) =>
      '$baseUrl/rewards/redemptions/$id/verify';
  static String rejectRedemption(int id) =>
      '$baseUrl/rewards/redemptions/$id/reject';
  static String leaderboard({String period = 'all', int limit = 10}) =>
      '$baseUrl/leaderboard?period=$period&limit=$limit';

  // Helper for standard headers
  static Map<String, String> headers({String? token}) {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      map['Authorization'] = 'Bearer $token';
    }
    return map;
  }
}
