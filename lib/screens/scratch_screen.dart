import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';
import 'package:loyaya/widgets/entry_ad_mixin.dart';
import 'package:loyaya/widgets/scratch_card.dart';

class ScratchScreen extends StatefulWidget {
  const ScratchScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<ScratchScreen> createState() => _ScratchScreenState();
}

class _ScratchScreenState extends State<ScratchScreen> with EntryAdMixin {
  static const _cooldownMinutes = 5;

  bool _loading = true;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool _watchingAd = false;
  bool _scratching = false;
  int? _wonPoints;
  String? _message;

  bool get _onCooldown => _cooldownSeconds > 0;

  @override
  void initState() {
    super.initState();
    initEntryAd();
    _loadStatus();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final status = await widget.api.gamesStatus();
      if (mounted) {
        _applyCooldown(status['scratch_cooldown_seconds'] as int? ?? 0);
        setState(() => _loading = false);
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

  void _applyCooldown(int seconds) {
    _cooldownTimer?.cancel();
    _cooldownSeconds = seconds.clamp(0, _cooldownMinutes * 60);
    if (_cooldownSeconds <= 0) return;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _cooldownSeconds = (_cooldownSeconds - 1).clamp(0, _cooldownMinutes * 60);
      });
      if (_cooldownSeconds <= 0) {
        _cooldownTimer?.cancel();
      }
    });
  }

  String _formatCooldown(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  Future<void> _watchAdAndScratch() async {
    if (_onCooldown || _watchingAd || _scratching) return;

    setState(() {
      _watchingAd = true;
      _message = null;
      _wonPoints = null;
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

    setState(() => _watchingAd = false);

    try {
      final result = await widget.api.playScratch();
      if (!mounted) return;
      setState(() {
        _wonPoints = result['points'] as int? ?? 0;
        _scratching = true;
      });
      _applyCooldown(_cooldownMinutes * 60);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _message = apiErrorMessage(e.error));
        if (e.error == 'SCRATCH_COOLDOWN') {
          _loadStatus();
        }
      }
    }
  }

  void _onRevealed() {
    if (_wonPoints == null) return;
    setState(() {
      _scratching = false;
      _message = 'Congratulations! You won $_wonPoints points!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DingaPageHeader(
                title: 'Scratch & Win',
                subtitle:
                    'Watch a reward ad, then scratch to reveal 2–5 points. Wait $_cooldownMinutes minutes between scratches.',
                onBack: () => Navigator.pop(context),
                titleColor: AppColors.primary,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scratch Status',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_loading)
                        const LinearProgressIndicator()
                      else if (_onCooldown)
                        Text(
                          'Next scratch in ${_formatCooldown(_cooldownSeconds)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        const Text(
                          'Scratch is available now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_scratching && _wonPoints != null)
                ScratchCard(
                  prizeText: '$_wonPoints pts',
                  onRevealed: _onRevealed,
                )
              else
                FilledButton(
                  onPressed: _onCooldown || _loading || _watchingAd
                      ? null
                      : _watchAdAndScratch,
                  child: _watchingAd
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Watch Ad To Scratch'),
                ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _message!.contains('Congratulations')
                        ? AppColors.accentGreen
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Spacer(),
              Card(
                color: const Color(0xFFFFF8E1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SPONSORED',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reward ads help keep Lotaya Shwe Oh free. You can scratch again after $_cooldownMinutes minutes.',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
