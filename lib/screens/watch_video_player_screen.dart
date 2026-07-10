import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/ad_banner.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WatchVideoPlayerScreen extends StatefulWidget {
  const WatchVideoPlayerScreen({
    super.key,
    required this.api,
    required this.video,
  });

  final ApiClient api;
  final Map<String, dynamic> video;

  @override
  State<WatchVideoPlayerScreen> createState() => _WatchVideoPlayerScreenState();
}

class _WatchVideoPlayerScreenState extends State<WatchVideoPlayerScreen> {
  late final int _minWatchSeconds;
  late final WebViewController _webView;
  Timer? _timer;
  int _progress = 0;
  bool _claiming = false;
  bool _claimed = false;
  String? _error;

  int get _basePoints => widget.video['points'] as int? ?? 1;
  int get _bonusPoints => widget.video['bonus_points'] as int? ?? 1;

  String get _videoId {
    final url = widget.video['video_url']?.toString() ?? '';
    return youtubeIdFromUrl(url) ?? 'M7lc1UVf-VE';
  }

  @override
  void initState() {
    super.initState();
    _minWatchSeconds = widget.video['watch_seconds'] as int? ?? 20;

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadHtmlString(
        _youtubeEmbedHtml(_videoId),
        baseUrl: 'https://www.youtube.com',
      );

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _webView = controller;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted || _claimed || _claiming) return;
      final next = _progress + 1;
      setState(() => _progress = next);
      if (next >= _minWatchSeconds) {
        t.cancel();
        await _claim();
      }
    });
  }

  Future<void> _claim() async {
    if (_claimed || _claiming) return;
    setState(() => _claiming = true);

    final id = widget.video['id']?.toString() ?? '';
    try {
      final result = await widget.api.earnWatchVideo(id);
      if (!mounted) return;
      setState(() => _claimed = true);
      if (result['duplicate'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already claimed this video.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Earned +$_basePoints point!')),
        );
      }
      await _askBonusDialog();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _claiming = false;
          _error = apiErrorMessage(e.error);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _claiming = false;
          _error = 'Could not claim points.';
        });
      }
    }
  }

  Future<void> _askBonusDialog() async {
    if (!mounted) return;

    final takeBonus = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Bonus +$_bonusPoints'),
        content: Text(
          'Watch 1 reward ad to claim bonus +$_bonusPoints point?\n\n'
          'You can also claim the bonus later from the video list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Watch ad'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (takeBonus == true) {
      await _claimBonusWithAd();
    } else if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _claimBonusWithAd() async {
    final rewarded = await AdService.instance.showRewarded(
      onAdNotReady: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad is loading. Please try again.')),
          );
        }
      },
    );

    if (!mounted) return;
    if (!rewarded) {
      Navigator.pop(context, true);
      return;
    }

    final id = widget.video['id']?.toString() ?? '';
    try {
      final result = await widget.api.earnWatchVideoBonus(id);
      if (!mounted) return;
      if (result['duplicate'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bonus already claimed.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bonus +$_bonusPoints point earned!')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e.error))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not claim bonus points.')),
        );
      }
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.video['title']?.toString() ?? 'Watch Video';
    final remaining =
        (_minWatchSeconds - _progress).clamp(0, _minWatchSeconds);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontSize: 16)),
      ),
      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(controller: _webView),
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
                        value: _progress / _minWatchSeconds,
                        backgroundColor: Colors.grey.shade200,
                        color: AppColors.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_progress / $_minWatchSeconds s',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _claimed
                      ? 'Points claimed!'
                      : _claiming
                          ? 'Claiming points...'
                          : 'Keep watching — $remaining seconds left for +$_basePoints pt',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        _claimed ? AppColors.accentGreen : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.primary),
                    textAlign: TextAlign.center,
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

String _youtubeEmbedHtml(String videoId) {
  return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
  <style>
    html, body { margin: 0; padding: 0; background: #000; height: 100%; }
    iframe { width: 100%; height: 100%; border: 0; }
  </style>
</head>
<body>
  <iframe
    src="https://www.youtube.com/embed/$videoId?autoplay=1&playsinline=1&rel=0&modestbranding=1&enablejsapi=1&origin=https://www.youtube.com"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen>
  </iframe>
</body>
</html>
''';
}

String? youtubeIdFromUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;

  if (uri.host.contains('youtu.be')) {
    final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    return id != null && id.isNotEmpty ? id : null;
  }

  final v = uri.queryParameters['v'];
  if (v != null && v.isNotEmpty) return v;

  final segments = uri.pathSegments;
  if (segments.contains('embed') && segments.length >= 2) {
    return segments[segments.indexOf('embed') + 1];
  }

  return null;
}

String youtubeThumbUrl(String? videoUrl) {
  final id = youtubeIdFromUrl(videoUrl ?? '') ?? 'M7lc1UVf-VE';
  return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
}
