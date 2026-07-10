import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loyaya/config/ad_config.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  RewardedAd? _rewardedAd;
  bool _loading = false;

  Future<void> init() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    await _loadRewarded();
  }

  Future<void> _loadRewarded() async {
    if (_loading) return;
    _loading = true;
    final completer = Completer<void>();

    await RewardedAd.load(
      adUnitId: AdConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loading = false;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _loading = false;
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        _loading = false;
      },
    );
  }

  /// Shows a rewarded ad. Returns true if user earned the reward.
  Future<bool> showRewarded({void Function()? onAdNotReady}) async {
    if (!_initialized) {
      await init();
    }

    if (_rewardedAd == null) {
      await _loadRewarded();
    }

    final ad = _rewardedAd;
    if (ad == null) {
      onAdNotReady?.call();
      return false;
    }

    final completer = Completer<bool>();
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (dismissed) {
        dismissed.dispose();
        _rewardedAd = null;
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (failed, error) {
        failed.dispose();
        _rewardedAd = null;
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
      },
    );

    return completer.future;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
