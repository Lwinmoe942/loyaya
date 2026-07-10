/// AdMob configuration.
///
/// **Setup (production):**
/// 1. Create app at https://admob.google.com
/// 2. Add Android app `com.loyaya.loyaya`
/// 3. Create a **Rewarded** ad unit
/// 4. Create an **Interstitial** ad unit (entry ads on Redeem / Scratch / Games)
/// 5. Run / build with:
///    `--dart-define=ADMOB_ANDROID_APP_ID=ca-app-pub-XXXX~YYYY`
///    `--dart-define=ADMOB_REWARDED_UNIT_ID=ca-app-pub-XXXX/ZZZZ`
///    `--dart-define=ADMOB_INTERSTITIAL_UNIT_ID=ca-app-pub-XXXX/WWWW`
///
/// **Testing:** Google test IDs below work without an AdMob account.
class AdConfig {
  /// Google sample Android app ID (safe for testing).
  static const String androidAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713',
  );

  /// Google sample rewarded ad unit (Android).
  static const String rewardedUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );

  /// Google sample interstitial ad unit (Android).
  static const String interstitialUnitId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );

  static bool get isTestMode =>
      androidAppId.contains('3940256099942544') ||
      rewardedUnitId.contains('3940256099942544') ||
      interstitialUnitId.contains('3940256099942544');
}
