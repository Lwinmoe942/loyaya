import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loyaya/config/ad_config.dart';

/// Banner ad placement. Skips Google sample unit IDs in production builds.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _banner;
  bool _loaded = false;
  bool _skipped = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Do not ship Google sample banner IDs with a production App ID.
    if (AdConfig.bannerUnitId.contains('3940256099942544') &&
        !AdConfig.androidAppId.contains('3940256099942544')) {
      if (mounted) setState(() => _skipped = true);
      return;
    }

    final banner = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    await banner.load();
    if (mounted) setState(() => _banner = banner);
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_skipped) return const SizedBox.shrink();

    final banner = _banner;
    if (!_loaded || banner == null) {
      return const SizedBox(height: 0);
    }

    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }
}
