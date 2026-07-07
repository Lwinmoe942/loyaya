class ApiConfig {
  /// Local dev (Android emulator: use 10.0.2.2)
  /// Physical phone on same WiFi: use your PC IP e.g. 192.168.1.100
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
