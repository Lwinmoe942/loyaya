import 'package:flutter/material.dart';
import 'package:loyaya/data/watch_videos.dart';
import 'package:loyaya/screens/watch_video_player_screen.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/ad_banner.dart';
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
    AdService.instance.preloadRewarded();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final items = watchFallbackVideos();
    final claimed = <String>{};
    try {
      final history = await widget.api.history();
      for (final row in history) {
        final ref = row['reference_id']?.toString() ?? '';
        if (ref.isEmpty) continue;
        final type = row['type']?.toString();
        if (type != 'earn_watch_video' && type != 'earn_watch_video_bonus') {
          continue;
        }
        // Fully done only after picture (+clip) was credited.
        if (ref.endsWith('_clip')) {
          claimed.add(ref.substring(0, ref.length - '_clip'.length));
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _videos = items;
        _claimed
          ..clear()
          ..addAll(claimed);
        _loading = false;
      });
    }
  }

  Future<void> _startWatch(int index) async {
    if (_starting) return;
    final id = _videos[index]['id']?.toString() ?? '';
    if (_claimed.contains(id)) return;

    setState(() => _starting = true);
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WatchVideoPlayerScreen(
          api: widget.api,
          videos: _videos,
          startIndex: index,
          claimedIds: _claimed,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _starting = false);
    await _load();
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
                    'Watch a picture 3 seconds, then 2 ads. +1 picture +2 ads. Next picture opens right away.',
                onBack: () => Navigator.pop(context, _claimed.isNotEmpty),
                titleColor: Colors.white,
                subtitleColor: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _videos.length,
                    itemBuilder: (context, index) {
                      final video = _videos[index];
                      final id = video['id']?.toString() ?? '';
                      final done = _claimed.contains(id);
                      return _WatchCard(
                        title: video['title']?.toString() ?? '',
                        imageAsset: video['image_asset']?.toString() ?? '',
                        done: done,
                        loading: _starting,
                        onWatch: () => _startWatch(index),
                      );
                    },
                  ),
          ),
          const SafeArea(
            top: false,
            child: ColoredBox(
              color: Colors.white,
              child: Center(child: AdBanner()),
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
    required this.imageAsset,
    required this.done,
    required this.loading,
    required this.onWatch,
  });

  final String title;
  final String imageAsset;
  final bool done;
  final bool loading;
  final VoidCallback onWatch;

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
              child: Image.asset(
                imageAsset,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: const Color(0xFF3D5A80),
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: done
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    done ? 'Passed' : '+3 pts',
                    style: TextStyle(
                      color: done
                          ? AppColors.accentGreen
                          : Colors.amber.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '3 seconds + 2 ads. +1 picture, +1 per ad.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: done || loading ? null : onWatch,
                child: Text(done ? 'Passed' : 'Watch 3s, then 2 ads'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
