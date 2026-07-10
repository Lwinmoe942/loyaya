import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/ad_banner.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  static const _minWatchSeconds = 20;

  late final WebViewController _webView;
  Timer? _timer;
  int _progress = 0;
  bool _claiming = false;
  bool _claimed = false;
  String? _error;

  String get _videoId {
    final url = widget.video['video_url']?.toString() ?? '';
    return youtubeIdFromUrl(url) ?? 'dQw4w9WgXcQ';
  }

  @override
  void initState() {
    super.initState();
    _webView = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(
        Uri.parse(
          'https://www.youtube.com/embed/$_videoId?autoplay=1&playsinline=1&rel=0',
        ),
      );
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
      final points = widget.video['points'] as int? ?? 3;
      if (result['duplicate'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already claimed this video.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Earned +$points points!')),
        );
      }
      Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    final title = widget.video['title']?.toString() ?? 'Watch Video';
    final remaining = (_minWatchSeconds - _progress).clamp(0, _minWatchSeconds);

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
                          : 'Keep watching — $remaining seconds left for +${widget.video['points'] ?? 3} pts',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _claimed ? AppColors.accentGreen : AppColors.textSecondary,
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
  final id = youtubeIdFromUrl(videoUrl ?? '') ?? 'dQw4w9WgXcQ';
  return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
}
