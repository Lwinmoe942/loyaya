import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  static const _segments = ['1 pt', '2 pts', '2 pts', '3 pts', '3 pts', '5 pts'];

  bool _loading = true;
  bool _playedToday = false;
  bool _spinning = false;
  bool _watchingAd = false;
  String? _message;
  late final AnimationController _controller;
  final _random = Random();
  double _spinTurns = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _loadStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() => _loading = true);
    try {
      final status = await widget.api.gamesStatus();
      if (mounted) {
        setState(() {
          _playedToday = status['spin_played_today'] == true;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _message = apiErrorMessage(e.error);
        });
      }
    }
  }

  Future<void> _watchAdAndSpin() async {
    if (_playedToday || _spinning || _watchingAd) return;

    setState(() {
      _watchingAd = true;
      _message = null;
    });

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
      setState(() => _watchingAd = false);
      return;
    }

    setState(() {
      _watchingAd = false;
      _spinning = true;
      _spinTurns = 5 + _random.nextDouble();
    });

    _controller.forward(from: 0);

    try {
      final result = await widget.api.playSpin();
      if (!mounted) return;

      final segment = result['segment'] as String? ?? '';
      final points = result['points'] as int? ?? 0;

      await _controller.forward();
      if (!mounted) return;

      setState(() {
        _spinning = false;
        _playedToday = true;
        _message = 'You won $points points! ($segment)';
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _spinning = false;
          _message = apiErrorMessage(e.error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DingaPageHeader(
                title: 'Spin Wheel',
                subtitle: 'Watch an ad, spin once per day, win 1–5 points.',
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _controller.value * _spinTurns * 2 * pi,
                          child: child,
                        );
                      },
                      child: CustomPaint(
                        painter: _WheelPainter(labels: _segments),
                        child: const Center(
                          child: Icon(
                            Icons.album,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_loading)
                const LinearProgressIndicator()
              else if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _message!.contains('won')
                          ? AppColors.accentGreen
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: _playedToday || _loading || _spinning || _watchingAd
                    ? null
                    : _watchAdAndSpin,
                child: _watchingAd || _spinning
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_playedToday ? 'Come back tomorrow' : 'Watch Ad & Spin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.labels});

  final List<String> labels;
  static const _colors = [
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFF009688),
    Color(0xFFFF9800),
    Color(0xFF795548),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final sweep = 2 * pi / labels.length;

    for (var i = 0; i < labels.length; i++) {
      final paint = Paint()..color = _colors[i % _colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep,
        true,
        paint,
      );
    }

    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
