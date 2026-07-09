import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';
import 'package:url_launcher/url_launcher.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  List<Map<String, dynamic>> _videos = [];
  bool _loading = true;
  final Set<String> _claimed = {};
  String? _watchingId;
  int _watchProgress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await widget.api.watchVideos();
      if (mounted) setState(() => _videos = items);
    } catch (_) {
      // empty
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startWatch(Map<String, dynamic> video) async {
    final id = video['id']?.toString() ?? '';
    final url = video['video_url']?.toString();
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    if (_claimed.contains(id)) return;

    _timer?.cancel();
    setState(() {
      _watchingId = id;
      _watchProgress = 0;
    });

    final target = video['watch_seconds'] as int? ?? 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      final next = _watchProgress + 1;
      setState(() => _watchProgress = next);
      if (next >= target) {
        t.cancel();
        await _claim(video);
      }
    });
  }

  Future<void> _claim(Map<String, dynamic> video) async {
    final id = video['id']?.toString() ?? '';
    if (_claimed.contains(id)) return;

    try {
      final result = await widget.api.earnWatchVideo(id);
      if (mounted) {
        setState(() {
          _claimed.add(id);
          _watchingId = null;
        });
        if (result['duplicate'] != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Earned +${video['points'] ?? 3} points for watching!',
              ),
            ),
          );
        }
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
          const SnackBar(content: Text('Could not claim points.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFE58B8B),
            child: SafeArea(
              bottom: false,
              child: DingaPageHeader(
                title: 'Watch & Get Points',
                subtitle:
                    'Watch videos and claim points when the timer completes.',
                onBack: () => Navigator.pop(context, _claimed.isNotEmpty),
                titleColor: Colors.white,
                subtitleColor: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final video in _videos)
                        _WatchCard(
                          title: video['title']?.toString() ?? '',
                          points: video['points'] as int? ?? 3,
                          watchSec: video['watch_seconds'] as int? ?? 20,
                          claimed: _claimed.contains(video['id']?.toString()),
                          progress: _watchingId == video['id']?.toString()
                              ? _watchProgress
                              : 0,
                          onTap: () => _startWatch(video),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _WatchCard extends StatelessWidget {
  const _WatchCard({
    required this.title,
    required this.points,
    required this.watchSec,
    required this.claimed,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final int points;
  final int watchSec;
  final bool claimed;
  final int progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: claimed ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$points Points',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Watch Time', style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    claimed
                        ? '$watchSec / $watchSec sec'
                        : '$progress / $watchSec sec',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (claimed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Claimed',
                    style: TextStyle(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                FilledButton(
                  onPressed: onTap,
                  child: const Text('Watch Now'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
