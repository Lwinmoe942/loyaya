import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/ai_hero_card.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';
import 'package:loyaya/widgets/entry_ad_mixin.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AiRecordToTextScreen extends StatefulWidget {
  const AiRecordToTextScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<AiRecordToTextScreen> createState() => _AiRecordToTextScreenState();
}

class _AiRecordToTextScreenState extends State<AiRecordToTextScreen>
    with EntryAdMixin {
  final _speech = SpeechToText();
  final _random = Random();

  String _language = 'auto';
  String _transcript = '';
  String? _status;
  bool _ready = false;
  bool _recording = false;
  bool _converting = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  String? _requestId;

  @override
  void initState() {
    super.initState();
    initEntryAd();
    _initSpeech();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onError: (e) => setState(() => _status = e.errorMsg),
      onStatus: (_) {},
    );
    if (mounted) setState(() => _ready = ok);
  }

  String? get _localeId => switch (_language) {
        'english' => 'en_US',
        'burmese' => 'my_MM',
        'thai' => 'th_TH',
        _ => null,
      };

  int get _estimatedCost => max(1, (_elapsedSeconds / 10).ceil());

  Future<void> _startRecording() async {
    if (!_ready || _recording) return;

    setState(() {
      _transcript = '';
      _elapsedSeconds = 0;
      _status = null;
      _requestId = null;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });

    final started = await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() => _transcript = result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        listenMode: ListenMode.dictation,
      ),
    );

    if (!started && mounted) {
      _timer?.cancel();
      setState(() => _status = 'Microphone permission is required.');
      return;
    }

    setState(() => _recording = true);
  }

  Future<void> _stopRecording() async {
    await _speech.stop();
    _timer?.cancel();
    if (mounted) setState(() => _recording = false);
  }

  Future<void> _convert() async {
    final text = _transcript.trim();
    if (text.isEmpty) {
      setState(() => _status = 'Record something first, then convert.');
      return;
    }

    setState(() {
      _converting = true;
      _status = null;
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
      setState(() => _converting = false);
      return;
    }

    final requestId =
        _requestId ?? '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(99999)}';
    _requestId = requestId;

    try {
      final result = await widget.api.aiRecordToText(
        text: text,
        durationSeconds: max(1, _elapsedSeconds),
        language: _language,
        requestId: requestId,
      );
      if (!mounted) return;
      setState(() {
        _converting = false;
        _status = result['message'] as String? ??
            'Saved to AI History. -${result['points_charged']} points.';
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _converting = false;
          _status = apiErrorMessage(e.error);
        });
      }
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
              title: 'Record to Text',
              onBack: () => Navigator.pop(context),
            ),
            const AiHeroCard(
              badge: 'Voice Recording',
              badgeIcon: Icons.mic,
              title: 'Record Voice to Text',
              subtitle:
                  'Record your voice, choose language, preview the audio, and convert it into text.',
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recording Studio',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap start, speak clearly, stop the recording, then preview it before converting.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mic, color: AppColors.primary),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatTime(_elapsedSeconds),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _recording
                                ? 'Recording...'
                                : _transcript.isEmpty
                                    ? 'No recording yet'
                                    : 'Recording ready',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          if (_transcript.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              _transcript,
                              textAlign: TextAlign.center,
                              style: const TextStyle(height: 1.4),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: !_ready || _converting
                          ? null
                          : (_recording ? _stopRecording : _startRecording),
                      icon: Icon(_recording ? Icons.stop : Icons.mic),
                      label: Text(_recording ? 'Stop Recording' : 'Start Recording'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _transcript.isEmpty || _recording
                          ? null
                          : () => setState(() {}),
                      icon: const Icon(Icons.play_arrow, color: AppColors.primary),
                      label: const Text('Preview Text'),
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
                      'Choose Language',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _LangChip(
                          label: 'Auto',
                          selected: _language == 'auto',
                          onTap: () => setState(() => _language = 'auto'),
                        ),
                        _LangChip(
                          label: 'English',
                          selected: _language == 'english',
                          onTap: () => setState(() => _language = 'english'),
                        ),
                        _LangChip(
                          label: 'Burmese',
                          selected: _language == 'burmese',
                          onTap: () => setState(() => _language = 'burmese'),
                        ),
                        _LangChip(
                          label: 'Thai',
                          selected: _language == 'thai',
                          onTap: () => setState(() => _language = 'thai'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const AiInfoCard(
              title: 'Before Converting',
              bullets: [
                'Speak clearly and avoid background noise.',
                'Choose the correct language for better accuracy.',
                'Reward ad must be completed before transcription starts.',
                'Estimated cost: 1 point per 10 seconds of audio.',
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _converting || _recording ? null : _convert,
              icon: _converting
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
                _converting
                    ? 'Converting...'
                    : 'Convert to Text (~$_estimatedCost pts)',
              ),
            ),
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

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
