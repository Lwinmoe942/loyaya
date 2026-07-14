import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class CpxSurveyScreen extends StatefulWidget {
  const CpxSurveyScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<CpxSurveyScreen> createState() => _CpxSurveyScreenState();
}

class _CpxSurveyScreenState extends State<CpxSurveyScreen> {
  WebViewController? _controller;
  bool _loading = true;
  String? _error;
  String? _wallUrl;
  int _pointsPerSurvey = 2;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _openInBrowser() async {
    final url = _wallUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final config = await widget.api.cpxConfig();
      final wallUrl = config['wall_url'] as String? ?? '';
      _pointsPerSurvey = config['points_per_survey'] as int? ?? 2;
      _wallUrl = wallUrl;

      if (wallUrl.isEmpty) {
        throw ApiException(statusCode: 503, error: 'CPX_NOT_CONFIGURED');
      }

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
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => _loading = true);
            },
            onPageFinished: (_) {
              if (mounted) setState(() => _loading = false);
            },
            onNavigationRequest: (request) {
              final uri = Uri.tryParse(request.url);
              if (uri == null) return NavigationDecision.prevent;
              if (uri.scheme == 'http' || uri.scheme == 'https') {
                return NavigationDecision.navigate;
              }
              launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            },
            onWebResourceError: (error) {
              if (error.isForMainFrame != true) return;
              if (!mounted) return;
              setState(() {
                _error =
                    'Survey page failed to load. Try Retry or Open in Browser.';
                _loading = false;
              });
            },
          ),
        );

      if (controller.platform is AndroidWebViewController) {
        await (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      await controller.loadRequest(Uri.parse(wallUrl));

      if (!mounted) return;
      setState(() {
        _controller = controller;
        _loading = true;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorMessage(e.error);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load surveys. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DingaPageHeader(
              title: 'Survey',
              subtitle:
                  'Complete CPX surveys to earn $_pointsPerSurvey points each. Points are added automatically.',
              onBack: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'If questions stay blank, tap Open in Browser. After screen-outs, wait a few hours.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _wallUrl == null ? null : _openInBrowser,
                    child: const Text('Open in Browser'),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _load,
                              child: const Text('Retry'),
                            ),
                            TextButton(
                              onPressed:
                                  _wallUrl == null ? null : _openInBrowser,
                              child: const Text('Open in Browser'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: _controller == null
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        WebViewWidget(controller: _controller!),
                        if (_loading)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
