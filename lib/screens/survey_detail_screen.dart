import 'package:flutter/material.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/content_repository.dart';
import 'package:loyaya/services/progress_service.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class SurveyDetailScreen extends StatefulWidget {
  const SurveyDetailScreen({
    super.key,
    required this.survey,
    required this.api,
    this.initiallyLocked = false,
  });

  final SurveyItem survey;
  final ApiClient api;
  final bool initiallyLocked;

  @override
  State<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends State<SurveyDetailScreen> {
  final _progress = ProgressService();
  final Map<int, int?> _answers = {};
  bool _submitting = false;
  bool _watchingAd = false;
  bool _locked = false;
  String? _message;
  bool _passed = false;

  @override
  void initState() {
    super.initState();
    _locked = widget.initiallyLocked;
    if (_locked) {
      _message = apiErrorMessage('LOCKED_TRY_TOMORROW');
    }
  }

  bool get _allAnswered =>
      _answers.length == widget.survey.questions.length &&
      _answers.values.every((v) => v != null);

  Future<void> _lockSurvey() async {
    try {
      await widget.api.recordContentFail(
        contentType: 'survey',
        contentId: widget.survey.id,
      );
      await _progress.markSurveyLocked(widget.survey.id);
    } catch (_) {
      await _progress.markSurveyLocked(widget.survey.id);
    }
    if (mounted) {
      setState(() {
        _locked = true;
        _message = apiErrorMessage('LOCKED_TRY_TOMORROW');
      });
    }
  }

  Future<void> _submit() async {
    if (_locked || _passed) return;

    if (!_allAnswered) {
      setState(() => _message = 'Please answer all questions');
      return;
    }

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

    setState(() => _watchingAd = false);

    for (var i = 0; i < widget.survey.questions.length; i++) {
      if (_answers[i] != widget.survey.questions[i].correct) {
        await _lockSurvey();
        return;
      }
    }

    setState(() => _submitting = true);

    try {
      final result = await widget.api.earnSurvey(widget.survey.id);
      setState(() {
        _passed = true;
        _message = result['duplicate'] == true
            ? 'You already passed this survey'
            : 'All correct! +${widget.survey.points} points';
      });
      if (result['duplicate'] != true) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      setState(() {
        _message = apiErrorMessage(e.error);
        if (e.error == 'LOCKED_TRY_TOMORROW') _locked = true;
      });
    } catch (_) {
      setState(() => _message = apiErrorMessage('NETWORK_ERROR'));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            DingaPageHeader(
              title: 'Survey',
              subtitle:
                  'Watch a reward ad, answer all 3 correctly. One wrong = try again tomorrow.',
              onBack: () => Navigator.pop(context),
              titleColor: const Color(0xFFE57373),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.survey.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.survey.points} Points',
                                  style: TextStyle(
                                    color: Colors.amber.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.survey.description,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          if (_passed || _locked) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _passed
                                    ? const Color(0xFFFFF3E0)
                                    : const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _passed
                                    ? 'You already passed this survey'
                                    : 'Wrong today. Try again tomorrow.',
                                style: TextStyle(
                                  color: _passed
                                      ? const Color(0xFFE65100)
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < widget.survey.questions.length; i++)
                    _QuestionCard(
                      index: i,
                      question: widget.survey.questions[i],
                      selected: _answers[i],
                      enabled: !_locked && !_passed && !_submitting && !_watchingAd,
                      onSelect: (value) => setState(() => _answers[i] = value),
                    ),
                  if (_message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _passed
                            ? AppColors.accentGreen
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed:
                        _submitting || _passed || _locked || _watchingAd ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                    ),
                    child: _submitting || _watchingAd
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _locked
                                ? 'Try Again Tomorrow'
                                : _watchingAd
                                    ? 'Watching ad...'
                                    : 'Watch Ad & Submit Answers',
                          ),
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

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  final int index;
  final SurveyQuestion question;
  final int? selected;
  final bool enabled;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QUESTION ${index + 1}',
              style: const TextStyle(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < question.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: enabled ? () => onSelect(i) : null,
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    backgroundColor: selected == i
                        ? AppColors.accentBlue.withValues(alpha: 0.08)
                        : null,
                    side: BorderSide(
                      color: selected == i
                          ? AppColors.accentBlue
                          : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    '${String.fromCharCode(65 + i)}) ${question.options[i]}',
                    style: TextStyle(
                      color: selected == i
                          ? AppColors.accentBlue
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
