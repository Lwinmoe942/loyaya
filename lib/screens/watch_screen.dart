import 'package:flutter/material.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/coming_soon_dialog.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

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
                    'Watch videos, claim points, and get +1 bonus with reward ad.',
                onBack: () => Navigator.pop(context),
                titleColor: Colors.white,
                subtitleColor: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _WatchCard(
                  title: 'Getting Started Video',
                  points: 1,
                  watchSec: 20,
                  claimed: true,
                  onTap: () => showComingSoon(context, feature: 'Watch videos'),
                ),
                _WatchCard(
                  title: 'Earn Points Tutorial',
                  points: 2,
                  watchSec: 20,
                  claimed: false,
                  onTap: () => showComingSoon(context, feature: 'Watch videos'),
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
    required this.onTap,
  });

  final String title;
  final int points;
  final int watchSec;
  final bool claimed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
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
                    claimed ? '$watchSec / $watchSec sec' : '0 / $watchSec sec',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bonus', style: TextStyle(color: AppColors.textSecondary)),
                  Text('+1 Available', style: TextStyle(fontWeight: FontWeight.w600)),
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
