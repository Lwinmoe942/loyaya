import 'package:flutter/material.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/content_repository.dart';
import 'package:loyaya/services/progress_service.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class MathQuizScreen extends StatefulWidget {
  const MathQuizScreen({
    super.key,
    required this.api,
    required this.quiz,
    this.initiallyLocked = false,
  });

  final ApiClient api;
  final MathQuizItem quiz;
  final bool initiallyLocked;

  @override
  State<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  final _answerController = TextEditingController();
  final _progress = ProgressService();
  bool _loading = false;
  bool _watchingAd = false;
  bool _locked = false;
  String? _message;
  bool? _correct;

  @override
  void initState() {
    super.initState();
    _locked = widget.initiallyLocked;
    if (_locked) {
      _message = apiErrorMessage('LOCKED_TRY_TOMORROW');
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _lockQuiz() async {
    try {
      await widget.api.recordContentFail(
        contentType: 'math_quiz',
        contentId: widget.quiz.id,
      );
      await _progress.markMathLocked(widget.quiz.id);
    } catch (_) {
      await _progress.markMathLocked(widget.quiz.id);
    }
    if (mounted) {
      setState(() {
        _locked = true;
        _correct = false;
        _message = apiErrorMessage('LOCKED_TRY_TOMORROW');
      });
    }
  }

  Future<void> _submit() async {
    if (_locked) return;

    final answer = int.tryParse(_answerController.text.trim());
    if (answer == null) {
      setState(() => _message = 'Enter a number');
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

    if (answer != widget.quiz.answer) {
      await _lockQuiz();
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await widget.api.earnMathQuiz(widget.quiz.id);
      setState(() {
        _correct = true;
        _message = result['duplicate'] == true
            ? 'You already earned points for this quiz'
            : 'Correct! +${widget.quiz.points} points';
      });
      if (result['duplicate'] != true) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      setState(() => _message = apiErrorMessage(e.error));
      if (e.error == 'LOCKED_TRY_TOMORROW') {
        setState(() => _locked = true);
      }
    } catch (_) {
      setState(() => _message = apiErrorMessage('NETWORK_ERROR'));
    } finally {
      if (mounted) setState(() => _loading = false);
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DingaPageHeader(
                title: 'Math Quiz',
                subtitle: 'Watch a reward ad, solve correctly, and earn +${widget.quiz.points} points.',
                onBack: () => Navigator.pop(context),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '${widget.quiz.expression} = ?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _answerController,
                        enabled: !_locked && !_loading && !_watchingAd,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Your answer',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading || _locked || _watchingAd ? null : _submit,
                child: _loading || _watchingAd
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_locked
                        ? 'Try Again Tomorrow'
                        : _watchingAd
                            ? 'Watching ad...'
                            : 'Watch Ad & Submit (+${widget.quiz.points} pts)'),
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _correct == true
                        ? AppColors.accentGreen
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
