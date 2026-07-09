import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:loyaya/config/api_config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

  static const Duration _timeout = Duration(seconds: 90);

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// Pings the API so Render free tier can wake before sign-up/login.
  Future<bool> wakeServer() async {
    try {
      final res = await _get(
        Uri.parse('${ApiConfig.baseUrl}/health'),
        headers: const {'Accept': 'application/json'},
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    return _withRetry(() async {
      final res = await _post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      );
      return _parse(res);
    });
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _withRetry(() async {
      final res = await _post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      return _parse(res);
    });
  }

  Future<Map<String, dynamic>> me() async {
    return _withRetry(() async {
      final res = await _get(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/me'),
        headers: _headers,
      );
      return _parse(res);
    });
  }

  Future<Map<String, dynamic>> balance() async {
    final res = await _get(
      Uri.parse('${ApiConfig.baseUrl}/api/points/balance'),
      headers: _headers,
    );
    return _parse(res);
  }

  Future<List<Map<String, dynamic>>> history() async {
    final res = await _get(
      Uri.parse('${ApiConfig.baseUrl}/api/points/history'),
      headers: _headers,
    );
    final data = _parse(res);
    final list = data['history'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> dailyCheckIn() async {
    return earn(action: 'daily_checkin');
  }

  Future<Map<String, dynamic>> earnMathQuiz() async {
    return earn(action: 'math_quiz');
  }

  Future<Map<String, dynamic>> earn({
    required String action,
    String? idempotentKey,
  }) async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/points/earn'),
      headers: _headers,
      body: jsonEncode({
        'action': action,
        if (idempotentKey != null) 'idempotent_key': idempotentKey,
      }),
    );
    return _parse(res);
  }

  Future<T> _withRetry<T>(Future<T> Function() action) async {
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await action();
      } on ApiException catch (e) {
        lastError = e;
        if (!_shouldRetry(e) || attempt == 1) rethrow;
        await Future<void>.delayed(const Duration(seconds: 3));
      } on SocketException catch (e) {
        lastError = e;
        if (attempt == 1) {
          throw ApiException(statusCode: 0, error: 'NETWORK_ERROR');
        }
        await Future<void>.delayed(const Duration(seconds: 3));
      } on TimeoutException catch (e) {
        lastError = e;
        if (attempt == 1) {
          throw ApiException(statusCode: 0, error: 'REQUEST_TIMEOUT');
        }
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }
    throw lastError ?? ApiException(statusCode: 0, error: 'REQUEST_FAILED');
  }

  bool _shouldRetry(ApiException e) {
    return e.statusCode == 0 ||
        e.error == 'REQUEST_TIMEOUT' ||
        e.error == 'NETWORK_ERROR';
  }

  Future<http.Response> _get(Uri uri, {Map<String, String>? headers}) {
    return _client
        .get(uri, headers: headers)
        .timeout(_timeout, onTimeout: _onTimeout);
  }

  Future<http.Response> _post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client
        .post(uri, headers: headers, body: body)
        .timeout(_timeout, onTimeout: _onTimeout);
  }

  Future<http.Response> _onTimeout() {
    throw TimeoutException('Request timed out');
  }

  Map<String, dynamic> _parse(http.Response res) {
    final body = res.body.isEmpty ? '{}' : res.body;
    final data = jsonDecode(body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw ApiException(
        statusCode: res.statusCode,
        error: data['error']?.toString() ?? 'REQUEST_FAILED',
      );
    }
    return data;
  }
}

class ApiException implements Exception {
  ApiException({required this.statusCode, required this.error});

  final int statusCode;
  final String error;

  @override
  String toString() => 'ApiException($statusCode): $error';
}

String apiErrorMessage(String error) {
  final isRenderHost = ApiConfig.baseUrl.contains('onrender.com');

  return switch (error) {
    'REQUEST_TIMEOUT' => isRenderHost
        ? 'Server is slow to respond. Free hosting may take up to 60 seconds on first request. Please try again.'
        : 'Cannot reach the API server. Ensure php artisan serve is running, phone and PC are on the same Wi-Fi, and use your PC IP (not 10.0.2.2) on a physical device.',
    'NETWORK_ERROR' => isRenderHost
        ? 'Cannot reach the server. Check your internet connection and try again.'
        : 'Network error. Use your PC Wi-Fi IP in API_URL (e.g. http://192.168.x.x:8000), not 10.0.2.2 on a real phone.',
    'EMAIL_EXISTS' => 'This email is already registered.',
    'INVALID_CREDENTIALS' => 'Invalid email or password.',
    'VALIDATION_ERROR' => 'Please check your input and try again.',
    _ => error,
  };
}
