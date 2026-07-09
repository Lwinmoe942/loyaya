import 'package:flutter/material.dart';
import 'package:loyaya/theme/app_theme.dart';

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key, required this.loading});

  final bool loading;

  static const _sampleRows = [
    ('1', 'Win Ko', 'za**@g**', '1,850'),
    ('2', 'Ei Ei', 'ei**@g**', '1,829'),
    ('3', 'Zay Phoe', 'zp**@g**', '1,412'),
    ('4', 'YanNaing', 'yn**@g**', '1,205'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.leaderboard, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leaderboard',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'See top users by recruit bonus activity.',
                      style: TextStyle(color: AppColors.primary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF263238), Color(0xFF455A64)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WHO IS FIRST?',
                        style: TextStyle(
                          color: Color(0xFFFFEB3B),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Share our class to your friends\nGet gifts for inviting friends!',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    'LSO',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text('No.', style: _headerStyle),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Name', style: _headerStyle),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('Email', style: _headerStyle),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Ref Count', style: _headerStyle),
                        ),
                      ],
                    ),
                  ),
                  for (final row in _sampleRows)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Text(row.$1)),
                          Expanded(flex: 2, child: Text(row.$2)),
                          Expanded(flex: 3, child: Text(row.$3)),
                          Expanded(
                            flex: 2,
                            child: Text(
                              row.$4,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Live referral rankings coming soon.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );
}
