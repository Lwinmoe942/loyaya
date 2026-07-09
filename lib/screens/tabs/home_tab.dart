import 'package:flutter/material.dart';
import 'package:loyaya/screens/games_screen.dart';
import 'package:loyaya/screens/math_quiz_list_screen.dart';
import 'package:loyaya/screens/redeem_gift_screen.dart';
import 'package:loyaya/screens/scratch_screen.dart';
import 'package:loyaya/screens/tutorials_screen.dart';
import 'package:loyaya/screens/watch_screen.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/screens/survey_list_screen.dart';
import 'package:loyaya/widgets/coming_soon_dialog.dart';
import 'package:loyaya/widgets/earn_grid_item.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.api,
    required this.balance,
    required this.tier,
    required this.rate,
    required this.publicId,
    required this.loading,
    required this.onRefresh,
  });

  final ApiClient api;
  final int balance;
  final String tier;
  final int rate;
  final String publicId;
  final bool loading;
  final Future<void> Function() onRefresh;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? _message;

  Future<void> _checkIn() async {
    setState(() => _message = null);
    try {
      final result = await widget.api.dailyCheckIn();
      setState(() {
        _message = result['duplicate'] == true
            ? 'Already checked in today'
            : 'Check-in successful! +10 points';
      });
      await widget.onRefresh();
    } on ApiException catch (e) {
      setState(() {
        _message = e.error == 'ALREADY_CLAIMED_TODAY'
            ? 'Already checked in today'
            : e.error;
      });
    }
  }

  void _open(Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen))
        .then((_) => widget.onRefresh());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
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
                  child: const Icon(Icons.monetization_on, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lotaya Shwe Oh',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Stay updated & earn rewards!',
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7E57C2), Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Earn Points Daily',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.balance} pts · ${widget.tier} · 1 pt = ${widget.rate} MMK',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.stars, color: Colors.amber, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              children: [
                EarnGridItem(
                  label: 'Daily Checkin',
                  icon: Icons.calendar_today,
                  color: const Color(0xFF66BB6A),
                  badge: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 10),
                  ),
                  onTap: _checkIn,
                ),
                EarnGridItem(
                  label: 'Redeem',
                  icon: Icons.card_giftcard,
                  color: const Color(0xFF81C784),
                  onTap: () => _open(RedeemGiftScreen(publicId: widget.publicId)),
                ),
                EarnGridItem(
                  label: 'Survey',
                  icon: Icons.poll_outlined,
                  color: const Color(0xFF42A5F5),
                  onTap: () => _open(SurveyListScreen(api: widget.api)),
                ),
                EarnGridItem(
                  label: 'Scratch',
                  icon: Icons.style_outlined,
                  color: const Color(0xFF5C6BC0),
                  onTap: () => _open(const ScratchScreen()),
                ),
                EarnGridItem(
                  label: 'Tutorials',
                  icon: Icons.play_circle_outline,
                  color: const Color(0xFF3949AB),
                  onTap: () => _open(const TutorialsScreen()),
                ),
                EarnGridItem(
                  label: 'AI Tools',
                  icon: Icons.smart_toy_outlined,
                  color: const Color(0xFF29B6F6),
                  onTap: () => showComingSoon(context, feature: 'AI Tools'),
                ),
                EarnGridItem(
                  label: 'Watch',
                  icon: Icons.play_arrow_rounded,
                  color: const Color(0xFF3949AB),
                  onTap: () => _open(const WatchScreen()),
                ),
                EarnGridItem(
                  label: 'Games',
                  icon: Icons.sports_esports_outlined,
                  color: const Color(0xFF3949AB),
                  onTap: () => _open(const GamesScreen()),
                ),
                EarnGridItem(
                  label: 'Math Quiz',
                  icon: Icons.casino_outlined,
                  color: const Color(0xFF3949AB),
                  onTap: () => _open(MathQuizListScreen(api: widget.api)),
                ),
              ],
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _message!.contains('successful')
                      ? AppColors.accentGreen
                      : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
