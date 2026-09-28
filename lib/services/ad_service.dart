import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loyaya/config/ad_config.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _loadingRewarded = false;
  bool _loadingInterstitial = false;
  String? lastRewardedError;
  String? lastInterstitialError;
  bool get isRewardedReady => _rewardedAd != null;
  bool get isInterstitialReady => _interstitialAd != null;

  Future<void> init() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    await Future.wait([
      _loadRewarded(),
      _loadInterstitial(),
    ]);
  }

  Future<void> _loadRewarded() async {
    if (!AdConfig.hasRewardedUnit) return;
    if (_loadingRewarded) return;
    _loadingRewarded = true;
    final completer = Completer<void>();

    await RewardedAd.load(
      adUnitId: AdConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('AdService: Rewarded loaded (${AdConfig.rewardedUnitId})');
          lastRewardedError = null;
          _rewardedAd = ad;
          _loadingRewarded = false;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          lastRewardedError =
              'code=${error.code} ${error.message}'.trim();
          print(
            'AdService: Rewarded FAILED code=${error.code} '
            'domain=${error.domain} message=${error.message}',
          );
          _rewardedAd = null;
          _loadingRewarded = false;
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        _loadingRewarded = false;
      },
    );
  }

  Future<void> _loadInterstitial() async {
    if (!AdConfig.hasInterstitialUnit) return;
    if (_loadingInterstitial) return;
    _loadingInterstitial = true;
    final completer = Completer<void>();

    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print(
            'AdService: Interstitial loaded (${AdConfig.interstitialUnitId})',
          );
          lastInterstitialError = null;
          _interstitialAd = ad;
          _loadingInterstitial = false;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          lastInterstitialError =
              'code=${error.code} ${error.message}'.trim();
          print(
            'AdService: Interstitial FAILED code=${error.code} '
            'domain=${error.domain} message=${error.message}',
          );
          _interstitialAd = null;
          _loadingInterstitial = false;
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        _loadingInterstitial = false;
      },
    );
  }

  /// Full-screen ad when opening Redeem / Scratch / Games.
  Future<void> showInterstitial() async {
    if (!_initialized) {
      await init();
    }

    if (_interstitialAd == null) {
      await _loadInterstitial();
    }

    final ad = _interstitialAd;
    if (ad == null) return;

    final completer = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (dismissed) {
        dismissed.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (failed, error) {
        failed.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        if (!completer.isCompleted) completer.complete();
      },
    );

    ad.show();
    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () {},
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

  Future<bool> showRewardedMultiple(
    int count, {
    void Function(int current, int total)? onProgress,
    void Function()? onAdNotReady,
  }) async {
    for (var i = 0; i < count; i++) {
      onProgress?.call(i + 1, count);
      final rewarded = await showRewarded(onAdNotReady: onAdNotReady);
      if (!rewarded) return false;
    }
    return true;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
