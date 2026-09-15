import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiService {
  static const Duration timeoutDuration = Duration(seconds: 15);

  // Dipanggil saat request ber-auth menerima 401 (sesi kedaluwarsa).
  static void Function()? onUnauthorized;

  // Helper to parse response
  static dynamic _processResponse(http.Response response,
      {bool authenticated = false}) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    }

    if (authenticated && response.statusCode == 401) {
      onUnauthorized?.call();
    }

    // Error handling
    String errorMessage =
        'Terjadi kesalahan pada server (${response.statusCode})';
    dynamic errors;

    if (body is Map<String, dynamic>) {
      if (body.containsKey('message') && body['message'] != null) {
        errorMessage = body['message'].toString();
      }
      if (body.containsKey('errors')) {
        errors = body['errors'];
      }
    }

    throw ApiException(
      errorMessage,
      statusCode: response.statusCode,
      errors: errors,
    );
  }

  // GET
  static Future<dynamic> get(String url, {String? token}) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(timeoutDuration);

      return _processResponse(response, authenticated: token != null);
    } on SocketException {
      throw ApiException(
          'Tidak dapat terhubung ke server. Pastikan server Go API aktif.');
    } on http.ClientException {
      throw ApiException('Koneksi ke server gagal. Periksa koneksi jaringan.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error: ${e.toString()}');
    }
  }

  // POST
  static Future<dynamic> post(String url,
      {Map<String, dynamic>? body, String? token}) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: ApiConfig.headers(token: token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      return _processResponse(response, authenticated: token != null);
    } on SocketException {
      throw ApiException(
          'Tidak dapat terhubung ke server. Pastikan server Go API aktif.');
    } on http.ClientException {
      throw ApiException('Koneksi ke server gagal. Periksa koneksi jaringan.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error: ${e.toString()}');
    }
  }

  // PUT
  static Future<dynamic> put(String url,
      {Map<String, dynamic>? body, String? token}) async {
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: ApiConfig.headers(token: token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      return _processResponse(response, authenticated: token != null);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error: ${e.toString()}');
    }
  }

  // DELETE
  static Future<dynamic> delete(String url, {String? token}) async {
    try {
      final response = await http
          .delete(
            Uri.parse(url),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(timeoutDuration);

      return _processResponse(response, authenticated: token != null);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error: ${e.toString()}');
    }
  }
}
