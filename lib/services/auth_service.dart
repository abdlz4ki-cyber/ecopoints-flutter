import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  // Global notifier for current logged in user
  static final ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier<UserModel?>(null);

  // Initialize and load saved session
  static Future<UserModel?> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(userJson));
        currentUserNotifier.value = user;
        return user;
      } catch (_) {}
    }
    return null;
  }

  // Get current token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Check login status
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Login
  static Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiService.post(
      ApiConfig.login,
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw ApiException('Format response server tidak sesuai.');
    }

    final result = LoginResult.fromJson(data);

    // Save token and user to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, result.token);
    await prefs.setString(_keyUser, jsonEncode(result.user.toJson()));

    currentUserNotifier.value = result.user;
    return result;
  }

  // Register
  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await ApiService.post(
      ApiConfig.register,
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw ApiException('Format response server tidak sesuai.');
    }

    return UserModel.fromJson(data);
  }

  // Get current user profile from API
  static Future<UserModel> getProfile() async {
    final token = await getToken();
    if (token == null) {
      throw ApiException('Sesi login telah berakhir. Silakan login kembali.');
    }

    final data = await ApiService.get(
      ApiConfig.me,
      token: token,
    );

    if (data is! Map<String, dynamic>) {
      throw ApiException('Format response server tidak sesuai.');
    }

    final user = UserModel.fromJson(data);

    // Update cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    currentUserNotifier.value = user;

    return user;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
    currentUserNotifier.value = null;
  }
}
