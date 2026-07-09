import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/content_repository.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class MathQuizScreen extends StatefulWidget {
  const MathQuizScreen({
    super.key,
    required this.api,
    required this.quiz,
  });

  final ApiClient api;
  final MathQuizItem quiz;

  @override
  State<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  final _answerController = TextEditingController();
  bool _loading = false;
  String? _message;
  bool? _correct;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final answer = int.tryParse(_answerController.text.trim());
    if (answer == null) {
      setState(() => _message = 'Enter a number');
      return;
    }

    if (answer != widget.quiz.answer) {
      setState(() {
        _correct = false;
        _message = 'Wrong answer — try again';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

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
      setState(() => _message = e.error);
    } catch (_) {
      setState(() => _message = 'NETWORK_ERROR');
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
                subtitle: 'Solve correctly and earn +${widget.quiz.points} points.',
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
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Submit (+${widget.quiz.points} pts)'),
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
