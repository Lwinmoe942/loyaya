import 'package:flutter/material.dart';
import 'package:loyaya/screens/math_quiz_screen.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/content_repository.dart';
import 'package:loyaya/services/progress_service.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class MathQuizListScreen extends StatefulWidget {
  const MathQuizListScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<MathQuizListScreen> createState() => _MathQuizListScreenState();
}

class _MathQuizListScreenState extends State<MathQuizListScreen> {
  final _progress = ProgressService();
  List<MathQuizItem> _quizzes = [];
  Set<String> _completed = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final quizzes = await ContentRepository.instance.mathQuizzes();
    final completed = await _progress.completedMathIds();
    if (mounted) {
      setState(() {
        _quizzes = quizzes;
        _completed = completed;
        _loading = false;
      });
    }
  }

  Future<void> _openQuiz(MathQuizItem quiz) async {
    final passed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MathQuizScreen(api: widget.api, quiz: quiz),
      ),
    );
    if (passed == true) {
      await _progress.markMathCompleted(quiz.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DingaPageHeader(
              title: 'Math Quiz',
              subtitle: 'Solve correctly and earn points. ${_quizzes.length} quizzes available.',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = _quizzes[index];
                        final done = _completed.contains(quiz.id);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentBlue
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${quiz.points} pts',
                                        style: const TextStyle(
                                          color: AppColors.accentBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: done
                                            ? const Color(0xFFE8F5E9)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        done ? 'Passed' : 'New',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: done
                                              ? AppColors.accentGreen
                                              : AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  quiz.expression,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: done
                                        ? null
                                        : () => _openQuiz(quiz),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.accentBlue,
                                      disabledBackgroundColor:
                                          Colors.grey.shade300,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(done ? 'Completed' : 'Solve Now'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
