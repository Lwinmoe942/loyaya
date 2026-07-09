import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorialsScreen extends StatefulWidget {
  const TutorialsScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await widget.api.tutorials();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      // empty
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(Map<String, dynamic> item) async {
    final url = item['video_url']?.toString();
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            DingaPageHeader(
              title: 'Tutorials',
              subtitle: 'Learn how to use the app and earn points.',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 120,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary, Color(0xFFFF9800)],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    size: 48,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentBlue
                                                .withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item['category']?.toString() ?? 'Guide',
                                            style: const TextStyle(
                                              color: AppColors.accentBlue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          item['duration']?.toString() ?? '',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['title']?.toString() ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['subtitle']?.toString() ?? '',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FilledButton(
                                        onPressed: () => _open(item),
                                        child: const Text('Open'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
