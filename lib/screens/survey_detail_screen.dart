import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/content_repository.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class SurveyDetailScreen extends StatefulWidget {
  const SurveyDetailScreen({
    super.key,
    required this.survey,
    this.api,
  });

  final SurveyItem survey;
  final ApiClient? api;

  @override
  State<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends State<SurveyDetailScreen> {
  final Map<int, int?> _answers = {};
  bool _submitting = false;
  String? _message;
  bool _passed = false;

  bool get _allAnswered =>
      _answers.length == widget.survey.questions.length &&
      _answers.values.every((v) => v != null);

  Future<void> _submit() async {
    if (!_allAnswered) {
      setState(() => _message = 'Please answer all questions');
      return;
    }

    for (var i = 0; i < widget.survey.questions.length; i++) {
      if (_answers[i] != widget.survey.questions[i].correct) {
        setState(() {
          _message = 'Some answers are wrong. Please review and try again.';
          _passed = false;
        });
        return;
      }
    }

    if (widget.api == null) {
      setState(() => _message = 'Sign in required to earn points');
      return;
    }

    setState(() {
      _submitting = true;
      _message = null;
    });

    try {
      final result = await widget.api!.earnSurvey(widget.survey.id);
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
      setState(() => _message = e.error);
    } catch (_) {
      setState(() => _message = 'NETWORK_ERROR');
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
              subtitle: 'Answer all 3 questions correctly to earn points.',
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
                          if (_passed) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'You already passed this survey',
                                style: TextStyle(
                                  color: Color(0xFFE65100),
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
                    onPressed: _submitting || _passed ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Submit Answers'),
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
    required this.onSelect,
  });

  final int index;
  final SurveyQuestion question;
  final int? selected;
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
                  onPressed: () => onSelect(i),
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
