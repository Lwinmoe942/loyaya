import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/ad_banner.dart';

class WatchVideoPlayerScreen extends StatefulWidget {
  const WatchVideoPlayerScreen({
    super.key,
    required this.api,
    required this.videos,
    required this.startIndex,
    required this.claimedIds,
  });

  final ApiClient api;
  final List<Map<String, dynamic>> videos;
  final int startIndex;
  final Set<String> claimedIds;

  @override
  State<WatchVideoPlayerScreen> createState() => _WatchVideoPlayerScreenState();
}

class _WatchVideoPlayerScreenState extends State<WatchVideoPlayerScreen> {
  static const _watchSeconds = 3;
  static const _adCount = 1;

  late int _index;
  Timer? _timer;
  int _progress = 0;
  bool _watchingAd = false;
  bool _clipDone = false;
  bool _passed = false;
  int _adsClaimed = 0;
  String? _message;

  Map<String, dynamic> get _video => widget.videos[_index];
  String get _id => _video['id']?.toString() ?? '';
  String get _title => _video['title']?.toString() ?? 'Watch';
  String get _imageAsset => _video['image_asset']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex.clamp(0, widget.videos.length - 1);
    AdService.instance.preloadRewarded();
    _startClip();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(milliseconds: 1200)),
    );
  }

  void _startClip() {
    _timer?.cancel();
    setState(() {
      _progress = 0;
      _watchingAd = false;
      _clipDone = false;
      _passed = false;
      _adsClaimed = 0;
      _message = 'Watch this picture for 3 seconds';
    });
    AdService.instance.preloadRewarded();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted || _watchingAd || _passed) return;
      final next = _progress + 1;
      setState(() => _progress = next);
      if (next >= _watchSeconds) {
        t.cancel();
        setState(() => _clipDone = true);
        await _watchAdsAndClaim();
      }
    });
  }

  /// Returns (ok, newlyEarned). Duplicate = already claimed for this account.
  Future<(bool ok, bool newlyEarned)> _claimNow(
    Future<Map<String, dynamic>> Function() earn,
    String okText,
  ) async {
    try {
      final result = await earn();
      final duplicate = result['duplicate'] == true;
      if (!duplicate) {
        _toast(okText);
        return (true, true);
      }
      return (true, false);
    } on ApiException catch (e) {
      _toast(apiErrorMessage(e.error));
      return (false, false);
    } catch (_) {
      _toast(apiErrorMessage('NETWORK_ERROR'));
      return (false, false);
    }
  }

  Future<void> _watchAdsAndClaim() async {
    if (_passed || _watchingAd) return;
    setState(() {
      _watchingAd = true;
      _message = 'Preparing ads...';
    });

    // Wait for a ready ad before the first show — avoids instant fail on slow VPN.
    AdService.instance.preloadRewarded();
    for (var w = 0; w < 40 && !AdService.instance.isRewardedReady; w++) {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (w % 8 == 7) AdService.instance.preloadRewarded();
    }

    for (var i = _adsClaimed; i < _adCount; i++) {
      if (!mounted) return;
      setState(() => _message = 'Watch ad...');
      AdService.instance.preloadRewarded();
      final rewarded = await AdService.instance.showRewarded(
        onAdNotReady: () =>
            _toast(AdService.instance.rewardedNotReadyMessage()),
      );
      if (!mounted) return;
      if (!rewarded) {
        setState(() {
          _watchingAd = false;
          _message = 'Watch the ad until the end. Skip = 0 points.';
        });
        return;
      }
      final (ok, _) = await _claimNow(
        () => widget.api.earnWatchAd(_id, i + 1),
        'Ad: +1 point',
      );
      if (!ok) {
        if (!mounted) return;
        setState(() {
          _watchingAd = false;
          _message = 'Could not claim ad points. Check VPN and try again.';
        });
        return;
      }
      _adsClaimed = i + 1;
      AdService.instance.preloadRewarded();
    }

    final (clipOk, clipNew) = await _claimNow(
      () => widget.api.earnWatchClip(_id),
      'Picture: +1 point',
    );
    if (!clipOk) {
      if (!mounted) return;
      setState(() {
        _watchingAd = false;
        _message = 'Ads done, but picture points failed. Tap to retry claim.';
      });
      return;
    }

    widget.claimedIds.add(_id);
    if (!mounted) return;
    setState(() {
      _watchingAd = false;
      _passed = true;
      _message = clipNew
          ? 'Passed! +1 picture, +1 ad'
          : 'Already claimed for this account.';
    });
    AdService.instance.preloadRewarded();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _openNext();
  }

  void _openNext() {
    for (var i = _index + 1; i < widget.videos.length; i++) {
      final id = widget.videos[i]['id']?.toString() ?? '';
      if (!widget.claimedIds.contains(id)) {
        setState(() => _index = i);
        _startClip();
        return;
      }
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (_watchSeconds - _progress).clamp(0, _watchSeconds);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(_title, style: const TextStyle(fontSize: 16)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.asset(
              _imageAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF3D5A80),
                alignment: Alignment.center,
                child: Text(
                  _title,
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _progress / _watchSeconds,
                        backgroundColor: Colors.grey.shade200,
                        color: AppColors.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_progress / $_watchSeconds s',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _passed
                      ? (_message ?? 'Passed')
                      : _watchingAd
                          ? (_message ?? 'Watching ads...')
                          : (_message ??
                              'Keep watching — $remaining seconds left, then 1 ad'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _passed
                        ? AppColors.accentGreen
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_clipDone && !_passed && !_watchingAd) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _watchAdsAndClaim,
                      child: Text(
                        _adsClaimed == 0
                            ? 'Watch 1 ad (+1)'
                            : 'Claim picture +1',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const AdBanner(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
