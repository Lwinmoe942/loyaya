import 'package:flutter/material.dart';
import 'package:loyaya/screens/spin_wheel_screen.dart';
import 'package:loyaya/screens/tic_tac_toe_screen.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';
import 'package:loyaya/widgets/entry_ad_mixin.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> with EntryAdMixin {
  @override
  void initState() {
    super.initState();
    initEntryAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            DingaPageHeader(
              title: 'Games',
              subtitle: 'Play mini games and get points.',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  _GameCard(
                    title: 'Spin Wheel',
                    description: 'Spin the wheel and claim your reward points.',
                    icon: Icons.album_outlined,
                    iconColor: const Color(0xFFE91E63),
                    tags: const ['Reward Points', 'Ad Required'],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SpinWheelScreen(api: widget.api),
                      ),
                    ),
                  ),
                  _GameCard(
                    title: 'Tic Tac Toe',
                    description:
                        'Improve your brain and get points. Get extra points after watch ad.',
                    icon: Icons.grid_3x3,
                    iconColor: AppColors.accentBlue,
                    tags: const ['Easy +1', 'Hard +2', 'Super Hard +3'],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TicTacToeScreen(api: widget.api),
                      ),
                    ),
                  ),
                  _GameCard(
                    title: 'More Games Coming Soon',
                    description:
                        'Memory, Tap Game, Number Puzzle and more will be added later.',
                    icon: Icons.sports_esports_outlined,
                    iconColor: Colors.grey,
                    tags: const [],
                    enabled: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.tags,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final List<String> tags;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: enabled ? AppColors.textPrimary : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tags
                            .map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: t.contains('Bonus') || t.contains('Ad')
                                      ? const Color(0xFFFFF3E0)
                                      : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  t,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: t.contains('Bonus') || t.contains('Ad')
                                        ? Colors.orange.shade800
                                        : AppColors.accentGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              if (enabled)
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
