import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/ai_hero_card.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class AiTextToVoiceScreen extends StatefulWidget {
  const AiTextToVoiceScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<AiTextToVoiceScreen> createState() => _AiTextToVoiceScreenState();
}

class _AiTextToVoiceScreenState extends State<AiTextToVoiceScreen> {
  static const _actionAdCount = 3;

  final _controller = TextEditingController();
  final _tts = FlutterTts();
  final _random = Random();

  String _voice = 'default';
  bool _generating = false;
  bool _speaking = false;
  String? _status;
  String? _requestId;

  static const _voices = ['default', 'kore', 'puck', 'charon'];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1);
    await _tts.setPitch(1);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tts.stop();
    super.dispose();
  }

  int get _estimatedCost {
    final len = _controller.text.trim().length;
    if (len == 0) return 1;
    return max(1, (len / 50).ceil());
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _controller.text = data!.text!;
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _controller.text));
  }

  Future<void> _generate() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _status = 'Enter some text first.');
      return;
    }

    setState(() {
      _generating = true;
      _status = 'Watch ad 1 of $_actionAdCount...';
    });

    final rewarded = await AdService.instance.showRewardedMultiple(
      _actionAdCount,
      onProgress: (current, total) {
        if (mounted) {
          setState(() => _status = 'Watch ad $current of $total...');
        }
      },
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
      setState(() => _generating = false);
      return;
    }

    final requestId =
        _requestId ?? '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(99999)}';
    _requestId = requestId;

    try {
      final result = await widget.api.aiTextToVoice(
        text: text,
        voice: _voice,
        requestId: requestId,
      );
      if (!mounted) return;

      await _speak(text);
      setState(() {
        _generating = false;
        _status = result['message'] as String? ??
            'Voice generated. -${result['points_charged']} points.';
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _generating = false;
          _status = apiErrorMessage(e.error);
        });
      }
    }
  }

  Future<void> _speak(String text) async {
    setState(() => _speaking = true);
    await _tts.setLanguage('en-US');
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            DingaPageHeader(
              title: 'Text to Voice',
              onBack: () => Navigator.pop(context),
            ),
            const AiHeroCard(
              badge: 'Voice Generation',
              badgeIcon: Icons.volume_up,
              title: 'Turn Text into Voice',
              subtitle:
                  'Type or paste your content, then generate spoken voice output using AI.',
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Text',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Burmese or English text can be used here. If Burmese keyboard is difficult, use Paste.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Type your text here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Characters: ${_controller.text.length}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _paste,
                            icon: const Icon(Icons.content_paste, size: 18),
                            label: const Text('Paste'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _controller.text.isEmpty ? null : _copy,
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Copy'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _controller.text.isEmpty
                                ? null
                                : () => setState(() => _controller.clear()),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Clear'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Voice',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: _voices.map((v) {
                        final label = v[0].toUpperCase() + v.substring(1);
                        final selected = _voice == v;
                        return ChoiceChip(
                          label: Text(label),
                          selected: selected,
                          onSelected: (_) => setState(() => _voice = v),
                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const AiInfoCard(
              title: 'Before Generating',
              bullets: [
                'Watch 3 reward ads before voice generation starts.',
                'Points are charged based on text length (1 pt / 50 chars).',
                'Generated voice result will appear in AI History.',
                'After generation, you can play the audio again from this screen.',
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _generating ? null : _generate,
              icon: _generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _generating
                    ? 'Generating...'
                    : 'Generate Voice (~$_estimatedCost pts)',
              ),
            ),
            if (_speaking) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await _tts.stop();
                  setState(() => _speaking = false);
                },
                icon: const Icon(Icons.stop),
                label: const Text('Stop Playback'),
              ),
            ],
            if (_status != null) ...[
              const SizedBox(height: 12),
              Text(
                _status!,
                style: TextStyle(
                  color: _status!.contains('-')
                      ? AppColors.accentGreen
                      : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            const AiSponsoredCard(),
          ],
        ),
      ),
    );
  }
}
