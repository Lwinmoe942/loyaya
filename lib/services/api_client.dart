import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:loyaya/config/api_config.dart';
import 'package:loyaya/models/ai_history_item.dart';

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
    String? referralCode,
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
          if (referralCode != null && referralCode.trim().isNotEmpty)
            'referral_code': referralCode.trim().toUpperCase(),
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

  Future<Map<String, dynamic>> earn({
    required String action,
    String? idempotentKey,
    String? contentId,
  }) async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/points/earn'),
      headers: _headers,
      body: jsonEncode({
        'action': action,
        if (idempotentKey != null) 'idempotent_key': idempotentKey,
        if (contentId != null) 'content_id': contentId,
      }),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> earnMathQuiz(String quizId) async {
    return earn(
      action: 'math_quiz',
      idempotentKey: 'math_quiz_$quizId',
      contentId: quizId,
    );
  }

  Future<Map<String, dynamic>> earnSurvey(String surveyId) async {
    return earn(
      action: 'survey',
      idempotentKey: 'survey_$surveyId',
      contentId: surveyId,
    );
  }

  Future<Map<String, dynamic>> earnWatchVideo(String videoId) async {
    return earn(
      action: 'watch_video',
      idempotentKey: 'watch_video_$videoId',
      contentId: videoId,
    );
  }

  Future<Map<String, dynamic>> earnWatchVideoBonus(String videoId) async {
    return earn(
      action: 'watch_video_bonus',
      idempotentKey: 'watch_video_bonus_$videoId',
      contentId: videoId,
    );
  }

  Future<Map<String, dynamic>> redeemGiftCode(String code) async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/gift/redeem'),
      headers: _headers,
      body: jsonEncode({'code': code.trim()}),
    );
    return _parse(res);
  }

  Future<List<Map<String, dynamic>>> leaderboard() async {
    final res = await _get(
      Uri.parse('${ApiConfig.baseUrl}/api/leaderboard'),
      headers: const {'Accept': 'application/json'},
    );
    final data = _parse(res);
    final list = data['rows'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> tutorials() async {
    return _catalogItems('/api/content/tutorials');
  }

  Future<List<Map<String, dynamic>>> classroomLessons() async {
    return _catalogItems('/api/content/classroom');
  }

  Future<List<Map<String, dynamic>>> courses() async {
    return _catalogItems('/api/content/courses');
  }

  Future<Map<String, dynamic>> courseApplications() async {
    final res = await _get(
      Uri.parse('${ApiConfig.baseUrl}/api/courses/applications'),
      headers: _headers,
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> applyForCourse({
    required String courseId,
    required String name,
    required String phone,
  }) async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/courses/apply'),
      headers: _headers,
      body: jsonEncode({
        'course_id': courseId,
        'name': name,
        'phone': phone,
      }),
    );
    return _parse(res);
  }

  Future<List<Map<String, dynamic>>> watchVideos() async {
    return _catalogItems('/api/content/watch');
  }

  Future<List<Map<String, dynamic>>> _catalogItems(String path) async {
    final res = await _get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: const {'Accept': 'application/json'},
    );
    final data = _parse(res);
    final list = data['items'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> contentLocks() async {
    final res = await _get(
      Uri.parse('${ApiConfig.baseUrl}/api/content/locks'),
      headers: _headers,
    );
    final data = _parse(res);
    final list = data['locks'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> recordContentFail({
    required String contentType,
    required String contentId,
  }) async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/content/fail'),
      headers: _headers,
      body: jsonEncode({
        'content_type': contentType,
        'content_id': contentId,
      }),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> gamesStatus() async {
    final res = await _get(
      Uri.parse('${ApiConfig.baseUrl}/api/games/status'),
      headers: _headers,
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> playScratch() async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/games/scratch'),
      headers: _headers,
      body: '{}',
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> playSpin() async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/games/spin'),
      headers: _headers,
      body: '{}',
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> ticTacToeWin(
    String matchId, {
    required String difficulty,
  }) async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/games/tic-tac-toe'),
      headers: _headers,
      body: jsonEncode({
        'match_id': matchId,
        'difficulty': difficulty,
      }),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> ticTacToeLoss(String matchId) async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/games/tic-tac-toe/loss'),
      headers: _headers,
      body: jsonEncode({'match_id': matchId}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> ticTacToeBonus(String matchId) async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/games/tic-tac-toe/bonus'),
      headers: _headers,
      body: jsonEncode({'match_id': matchId}),
    );
    return _parse(res);
  }

  Future<List<AiHistoryItem>> aiHistory() async {
    final res = await _get(
      Uri.parse('${ApiConfig.baseUrl}/api/ai/history'),
      headers: _headers,
    );
    final data = _parse(res);
    final list = data['items'] as List<dynamic>? ?? [];
    return list
        .cast<Map<String, dynamic>>()
        .map(AiHistoryItem.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> aiRecordToText({
    required String text,
    required int durationSeconds,
    required String language,
    required String requestId,
  }) async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/ai/record-to-text'),
      headers: _headers,
      body: jsonEncode({
        'text': text,
        'duration_seconds': durationSeconds,
        'language': language,
        'request_id': requestId,
      }),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> aiTextToVoice({
    required String text,
    required String voice,
    required String requestId,
  }) async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/ai/text-to-voice'),
      headers: _headers,
      body: jsonEncode({
        'text': text,
        'voice': voice,
        'request_id': requestId,
      }),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> referralStatus() async {
    final res = await _get(
      Uri.parse('${ApiConfig.baseUrl}/api/referral/status'),
      headers: _headers,
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> applyReferralCode(String code) async {
    final res = await _post(
      Uri.parse('${ApiConfig.baseUrl}/api/referral/apply'),
      headers: _headers,
      body: jsonEncode({'code': code.trim().toUpperCase()}),
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
    Map<String, dynamic> data;
    try {
      data = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        statusCode: res.statusCode,
        error: res.statusCode == 404
            ? 'API_NOT_FOUND_CHECK_URL'
            : 'REQUEST_FAILED',
      );
    }
    if (res.statusCode >= 400) {
      final message = data['error'] ??
          data['message'] ??
          (res.statusCode == 404 ? 'API_NOT_FOUND_CHECK_URL' : 'REQUEST_FAILED');
      throw ApiException(
        statusCode: res.statusCode,
        error: message.toString(),
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
    'EMAIL_EXISTS' => 'This email already has an account. Please sign in.',
    'LOCKED_TRY_TOMORROW' =>
      'You answered wrong today. Please try again tomorrow.',
    'INVALID_CODE' => 'Invalid gift code. Please check and try again.',
    'ALREADY_REDEEMED' => 'You already redeemed this gift code.',
    'EXPIRED' => 'This gift code has expired.',
    'MAX_USES' => 'This gift code has reached its use limit.',
    'ALREADY_PLAYED_TODAY' => 'You already played this game today. Come back tomorrow!',
    'SCRATCH_COOLDOWN' => 'Please wait 5 minutes before scratching again.',
    'TIC_TAC_TOE_LOSS_COOLDOWN' => 'Please wait before playing again.',
    'INSUFFICIENT_POINTS' => 'Not enough points for this AI action.',
    'EMPTY_TEXT' => 'Please enter some text first.',
    'INVALID_REQUEST' => 'Invalid request. Please try again.',
    'ALREADY_APPLIED' => 'You already applied a referral code.',
    'COURSE_ALREADY_APPLIED' =>
      'You already applied for this course or are enrolled.',
    'INSUFFICIENT_POINTS_FOR_COURSE' =>
      'Not enough points to apply for this course yet.',
    'SELF_REFERRAL' => 'You cannot use your own referral code.',
    'DAILY_LIMIT' => 'Daily win limit reached. Try again tomorrow.',
    'ALREADY_CLAIMED' => 'Points for this match were already claimed.',
    'INVALID_MATCH' => 'Invalid game session. Please start a new match.',
    'INVALID_ACTION' => 'This reward is not available on the server yet.',
    'Server Error' => 'Server error while claiming points. Please try again.',
    'INVALID_CREDENTIALS' => 'Invalid email or password.',
    'VALIDATION_ERROR' => 'Please check your input and try again.',
    'API_NOT_FOUND_CHECK_URL' =>
      'API URL is wrong. Copy the exact domain from Railway → lotaya-shwe-oh → Settings → Networking.',
    _ => error,
  };
}
