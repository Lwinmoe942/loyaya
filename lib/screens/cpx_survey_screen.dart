import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  int _pointsPerSurvey = 2;

  @override
  void initState() {
    super.initState();
    _load();
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

      if (wallUrl.isEmpty) {
        throw ApiException(statusCode: 503, error: 'CPX_NOT_CONFIGURED');
      }

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _loading = false);
            },
            onWebResourceError: (error) {
              if (!mounted) return;
              setState(() {
                _error = error.description;
                _loading = false;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(wallUrl));

      if (!mounted) return;
      setState(() {
        _controller = controller;
        _loading = true;
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
                        TextButton(onPressed: _load, child: const Text('Retry')),
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
