/// AdMob configuration (publisher pub-3204424161016506).
///
/// Production units are used for debug and release so local tests match Play.
/// Override only when needed:
/// `--dart-define=ADMOB_REWARDED_UNIT_ID=...`
class AdConfig {
  static const String androidAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
    defaultValue: 'ca-app-pub-3204424161016506~7357921237',
  );

  static const String rewardedUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_UNIT_ID',
    defaultValue: 'ca-app-pub-3204424161016506/7937339884',
  );

  static const String interstitialUnitId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_UNIT_ID',
    defaultValue: 'ca-app-pub-3204424161016506/4880765852',
  );

  static const String bannerUnitId = String.fromEnvironment(
    'ADMOB_BANNER_UNIT_ID',
    defaultValue: 'ca-app-pub-3204424161016506/6077463308',
  );

  static bool get isTestMode =>
      androidAppId.contains('3940256099942544') ||
      rewardedUnitId.contains('3940256099942544') ||
      interstitialUnitId.contains('3940256099942544') ||
      bannerUnitId.contains('3940256099942544');

  static bool get hasRewardedUnit => rewardedUnitId.isNotEmpty;
  static bool get hasInterstitialUnit => interstitialUnitId.isNotEmpty;
}
