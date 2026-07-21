/// AdMob configuration.
///
/// Defaults are production Lotaya Shwe Oh units. Override for testing:
/// `--dart-define=ADMOB_REWARDED_UNIT_ID=ca-app-pub-3940256099942544/5224354917`
class AdConfig {
  static const String androidAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
    defaultValue: 'ca-app-pub-4585563722385266~5736907361',
  );

  static const String rewardedUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_UNIT_ID',
    defaultValue: 'ca-app-pub-4585563722385266/2915871123',
  );

  static const String interstitialUnitId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_UNIT_ID',
    defaultValue: 'ca-app-pub-4585563722385266/4975178390',
  );

  static const String bannerUnitId = String.fromEnvironment(
    'ADMOB_BANNER_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );

  static bool get isTestMode =>
      androidAppId.contains('3940256099942544') ||
      rewardedUnitId.contains('3940256099942544') ||
      interstitialUnitId.contains('3940256099942544');
}
