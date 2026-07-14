class ApiConfig {
  /// Production (Z.com):
  /// --dart-define=API_URL=https://api.yourdomain.com
  /// --dart-define=EXCHANGE_URL=https://api.yourdomain.com/exchange
  ///
  /// Android emulator → host PC: http://10.0.2.2:8000
  /// Physical phone (same Wi-Fi) → PC IP: http://192.168.x.x:8000
  /// Run backend: php artisan serve --host=0.0.0.0 --port=8000
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String exchangeUrl = String.fromEnvironment(
    'EXCHANGE_URL',
    defaultValue: '',
  );

  /// Prefer explicit EXCHANGE_URL; otherwise `{API_URL}/exchange`.
  static String get exchangePageUrl {
    if (exchangeUrl.isNotEmpty) return exchangeUrl;
    return '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/exchange';
  }
}
