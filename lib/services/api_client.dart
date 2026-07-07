import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loyaya/config/api_config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/me'),
      headers: _headers,
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> balance() async {
    final res = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/points/balance'),
      headers: _headers,
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> dailyCheckIn() async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/points/earn'),
      headers: _headers,
      body: jsonEncode({'action': 'daily_checkin'}),
    );
    return _parse(res);
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
