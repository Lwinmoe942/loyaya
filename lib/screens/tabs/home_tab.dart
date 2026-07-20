import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loyaya/screens/ai_tools_screen.dart';
import 'package:loyaya/screens/games_screen.dart';
import 'package:loyaya/screens/math_quiz_list_screen.dart';
import 'package:loyaya/screens/redeem_gift_screen.dart';
import 'package:loyaya/screens/scratch_screen.dart';
import 'package:loyaya/screens/tutorials_screen.dart';
import 'package:loyaya/screens/watch_screen.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/screens/survey_list_screen.dart';
import 'package:loyaya/widgets/earn_grid_item.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.api,
    required this.balance,
    required this.tier,
    required this.rate,
    required this.loading,
    required this.onRefresh,
  });

  final ApiClient api;
  final int balance;
  final String tier;
  final int rate;
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
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
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
            const _PromoBannerCarousel(),
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
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                  onTap: _checkIn,
                ),
                EarnGridItem(
                  label: 'Redeem',
                  icon: Icons.card_giftcard,
                  color: const Color(0xFF81C784),
                  onTap: () => _open(RedeemGiftScreen(api: widget.api)),
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
                  onTap: () => _open(ScratchScreen(api: widget.api)),
                ),
                EarnGridItem(
                  label: 'Tutorials',
                  icon: Icons.play_circle_outline,
                  color: const Color(0xFF3949AB),
                  onTap: () => _open(TutorialsScreen(api: widget.api)),
                ),
                EarnGridItem(
                  label: 'AI Tools',
                  icon: Icons.smart_toy_outlined,
                  color: const Color(0xFF29B6F6),
                  onTap: () => _open(AiToolsScreen(api: widget.api)),
                ),
                EarnGridItem(
                  label: 'Watch',
                  icon: Icons.play_arrow_rounded,
                  color: const Color(0xFF3949AB),
                  onTap: () => _open(WatchScreen(api: widget.api)),
                ),
                EarnGridItem(
                  label: 'Games',
                  icon: Icons.sports_esports_outlined,
                  color: const Color(0xFF3949AB),
                  onTap: () => _open(GamesScreen(api: widget.api)),
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

class _PromoSlide {
  const _PromoSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}

class _PromoBannerCarousel extends StatefulWidget {
  const _PromoBannerCarousel();

  @override
  State<_PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<_PromoBannerCarousel> {
  static const List<_PromoSlide> _slides = [
    _PromoSlide(
      title: 'Points ယူမယ်ဆို နေ့တိုင်း\nDaily Check In ဝင်ဖို့ မမေ့ပါနဲ့နော်',
      subtitle: 'DO YOU KNOW?',
      icon: Icons.check_circle,
      colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
    ),
    _PromoSlide(
      title: 'ခဲခြစ်ရင်းနဲ့ Points\nကံထူးနိုင်တယ်နော်',
      subtitle: 'SCRATCH & WIN',
      icon: Icons.style,
      colors: [Color(0xFFF9A825), Color(0xFFF57F17)],
    ),
    _PromoSlide(
      title:
          'Tutorials ထဲမှာ Points ယူနည်းတွေ\nကြည့်လို့ရတယ်ဆိုတာ သိပြီးပြီလား',
      subtitle: 'TUTORIALS',
      icon: Icons.play_circle_fill,
      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    ),
    _PromoSlide(
      title: 'သင်္ချာတွက်ရင်း Points ရနိုင်တယ်\nMath Quiz ကို စမ်းကြည့်ပါ',
      subtitle: 'MATH QUIZ',
      icon: Icons.calculate,
      colors: [Color(0xFF283593), Color(0xFF1565C0)],
    ),
  ];

  final PageController _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: slide.colors,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              slide.subtitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            slide.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(slide.icon, color: Colors.white, size: 36),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (index) {
            final active = index == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
