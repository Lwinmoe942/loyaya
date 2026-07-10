import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loyaya/screens/watch_video_player_screen.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  List<Map<String, dynamic>> _videos = [];
  bool _loading = true;
  bool _starting = false;
  final Set<String> _claimed = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await widget.api.watchVideos();
      final history = await widget.api.history();
      final claimed = <String>{};
      for (final row in history) {
        if (row['type']?.toString() == 'earn_watch_video') {
          final ref = row['reference_id']?.toString();
          if (ref != null && ref.isNotEmpty) claimed.add(ref);
        }
      }
      if (mounted) {
        setState(() {
          _videos = items;
          _claimed
            ..clear()
            ..addAll(claimed);
        });
      }
    } catch (_) {
      // empty
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startWatch(Map<String, dynamic> video) async {
    final id = video['id']?.toString() ?? '';
    if (_claimed.contains(id) || _starting) return;

    setState(() => _starting = true);

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
      setState(() => _starting = false);
      return;
    }

    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WatchVideoPlayerScreen(
          api: widget.api,
          video: video,
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _starting = false);

    if (completed == true) {
      setState(() => _claimed.add(id));
      await _load();
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
                    'Watch the reward ad, then watch the video for at least 20 seconds.',
                onBack: () => Navigator.pop(context, _claimed.isNotEmpty),
                titleColor: Colors.white,
                subtitleColor: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _videos.isEmpty
                    ? const Center(
                        child: Text(
                          'No videos available right now.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final video in _videos)
                            _WatchCard(
                              title: video['title']?.toString() ?? '',
                              points: video['points'] as int? ?? 3,
                              watchSec: video['watch_seconds'] as int? ?? 20,
                              thumbUrl: youtubeThumbUrl(
                                video['video_url']?.toString(),
                              ),
                              claimed: _claimed.contains(video['id']?.toString()),
                              loading: _starting,
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
    required this.thumbUrl,
    required this.claimed,
    required this.loading,
    required this.onTap,
  });

  final String title;
  final int points;
  final int watchSec;
  final String thumbUrl;
  final bool claimed;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    thumbUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.play_circle_fill, size: 48),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ],
              ),
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
                const Text(
                  'Minimum watch',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  '$watchSec seconds',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (claimed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
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
                onPressed: loading ? null : onTap,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Watch Ad & Play'),
              ),
          ],
        ),
      ),
    );
  }
}
