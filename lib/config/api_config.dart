class ApiConfig {
  /// Override for local / Z.com:
  /// --dart-define=API_URL=https://api.yourdomain.com
  /// --dart-define=EXCHANGE_URL=https://api.yourdomain.com/exchange
  ///
  /// Android emulator → host PC: http://10.0.2.2:8000
  /// Physical phone (same Wi-Fi) → PC IP: http://192.168.x.x:8000
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://lotaya-shwe-oh-production-d73b.up.railway.app',
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

  /// Official company site (Play Store listing + in-app legal links).
  static const String officialWebsiteUrl = 'https://u5aidigital.com';

  static const String privacyPolicyUrl =
      'https://u5aidigital.com/privacy-policy.html';

  static const String termsOfUseUrl =
      'https://u5aidigital.com/terms-of-use.html';

  static const String contentPolicyUrl =
      'https://u5aidigital.com/content-policy.html';

  static String get accountDeletionUrl =>
      '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/account-deletion';
}
