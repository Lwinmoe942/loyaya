import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loyaya/data/watch_videos.dart';
import 'package:loyaya/screens/watch_video_player_screen.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/ad_banner.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';
import 'package:loyaya/config/ad_config.dart';

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
  final Set<String> _claimedBase = {};
  final Set<String> _claimedBonus = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);

    // Keep the local 5-second clips. Server catalog still has old
    // YouTube embeds that fail with error 152-4 in Myanmar.
    var items = watchFallbackVideos();

    final claimedBase = <String>{};
    final claimedBonus = <String>{};
    try {
      final history = await widget.api.history();
      for (final row in history) {
        final ref = row['reference_id']?.toString();
        if (ref == null || ref.isEmpty) continue;
        final type = row['type']?.toString();
        if (type == 'earn_watch_video') {
          claimedBase.add(ref);
        } else if (type == 'earn_watch_video_bonus') {
          claimedBonus.add(ref);
        }
      }
    } catch (_) {
      // History is optional for showing the video list.
    }

    if (mounted) {
      setState(() {
        _videos = items;
        _claimedBase
          ..clear()
          ..addAll(claimedBase);
        _claimedBonus
          ..clear()
          ..addAll(claimedBonus);
        _loading = false;
      });
    }
  }

  Future<void> _startWatch(Map<String, dynamic> video) async {
    final id = video['id']?.toString() ?? '';
    if (_claimedBase.contains(id) || _starting) return;

    setState(() => _starting = true);

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
      await _load();
    }
  }

  Future<void> _claimBonus(Map<String, dynamic> video) async {
    final id = video['id']?.toString() ?? '';
    if (!_claimedBase.contains(id) ||
        _claimedBonus.contains(id) ||
        _starting) {
      return;
    }

    setState(() => _starting = true);

    final bonusAds = video['bonus_ads'] as int? ?? 3;
    final rewarded = await AdService.instance.showRewardedMultiple(
      bonusAds,
      onAdNotReady: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AdConfig.hasRewardedUnit
                    ? 'Ad is loading. Please try again.'
                    : 'Rewarded ad unit is not set yet. Create it in AdMob first.',
              ),
            ),
          );
        }
      },
    );

    if (!mounted) return;
    if (!rewarded) {
      setState(() => _starting = false);
      if (AdService.instance.lastShowHadAd) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Watch the reward ad until the end to earn bonus points.',
            ),
          ),
        );
      }
      return;
    }

    try {
      final result = await widget.api.earnWatchVideoBonus(id);
      if (!mounted) return;
      final bonus = video['bonus_points'] as int? ?? 2;
      if (result['duplicate'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bonus already claimed for this video.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bonus +$bonus points earned!')),
        );
      }
      await _load();
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
    } finally {
      if (mounted) setState(() => _starting = false);
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
                    'Watch the 5-second clip to earn 1 point. '
                    'Watch 3 reward ads for bonus +2.',
                onBack: () => Navigator.pop(
                  context,
                  _claimedBase.isNotEmpty || _claimedBonus.isNotEmpty,
                ),
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
                              points: video['points'] as int? ?? 1,
                              bonusPoints: video['bonus_points'] as int? ?? 2,
                              watchSec: video['watch_seconds'] as int? ?? 5,
                              thumbUrl: youtubeThumbUrl(
                                video['video_url']?.toString(),
                              ),
                              baseClaimed: _claimedBase.contains(
                                video['id']?.toString(),
                              ),
                              bonusClaimed: _claimedBonus.contains(
                                video['id']?.toString(),
                              ),
                              loading: _starting,
                              onWatch: () => _startWatch(video),
                              onBonus: () => _claimBonus(video),
                            ),
                        ],
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
    required this.points,
    required this.bonusPoints,
    required this.watchSec,
    required this.thumbUrl,
    required this.baseClaimed,
    required this.bonusClaimed,
    required this.loading,
    required this.onWatch,
    required this.onBonus,
  });

  final String title;
  final int points;
  final int bonusPoints;
  final int watchSec;
  final String thumbUrl;
  final bool baseClaimed;
  final bool bonusClaimed;
  final bool loading;
  final VoidCallback onWatch;
  final VoidCallback onBonus;

  @override
  Widget build(BuildContext context) {
    final fullyClaimed = baseClaimed && bonusClaimed;

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
                  thumbUrl.isEmpty
                      ? Container(
                          height: 160,
                          width: double.infinity,
                          color: const Color(0xFF2B2B2B),
                          child: const Icon(
                            Icons.play_circle_fill,
                            size: 48,
                            color: Colors.white70,
                          ),
                        )
                      : Image.network(
                          thumbUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
                    '$points Point${points == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Bonus +$bonusPoints with 3 reward ads',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
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
            if (fullyClaimed)
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
            else if (baseClaimed && !bonusClaimed)
              FilledButton(
                onPressed: loading ? null : onBonus,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Watch 3 ads for +$bonusPoints bonus'),
              )
            else
              FilledButton(
                onPressed: loading ? null : onWatch,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Watch & Play'),
              ),
          ],
        ),
      ),
    );
  }
}
