import 'package:flutter/material.dart';
import 'package:loyaya/screens/survey_detail_screen.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/content_repository.dart';
import 'package:loyaya/services/progress_service.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class SurveyListScreen extends StatefulWidget {
  const SurveyListScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends State<SurveyListScreen> {
  final _progress = ProgressService();
  List<SurveyItem> _surveys = [];
  Set<String> _completed = {};
  Set<String> _locked = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await _progress.syncLocksFromApi(widget.api);
    } catch (_) {
      // Use cached locks if server is unavailable.
    }
    final surveys = await ContentRepository.instance.surveys();
    final completed = await _progress.completedSurveyIds();
    final locked = await _progress.lockedSurveyIds();
    if (mounted) {
      setState(() {
        _surveys = surveys;
        _completed = completed;
        _locked = locked;
        _loading = false;
      });
    }
  }

  Future<void> _openSurvey(SurveyItem survey) async {
    final done = _completed.contains(survey.id);
    final locked = _locked.contains(survey.id);

    final passed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SurveyDetailScreen(
          survey: survey,
          api: widget.api,
          initiallyLocked: locked && !done,
        ),
      ),
    );
    if (passed == true) {
      await _progress.markSurveyCompleted(survey.id);
    }
    await _load();
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
                  'Answer all 3 questions correctly. Wrong once = try again tomorrow. ${_surveys.length} surveys.',
              onBack: () => Navigator.pop(context),
              titleColor: const Color(0xFFE57373),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _surveys.length,
                      itemBuilder: (context, index) {
                        final survey = _surveys[index];
                        final done = _completed.contains(survey.id);
                        final locked = _locked.contains(survey.id);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _openSurvey(survey),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          survey.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          survey.description,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          done
                                              ? 'You already passed this survey'
                                              : locked
                                                  ? 'Wrong today. Try again tomorrow.'
                                                  : '3 questions · ${survey.points} points',
                                          style: TextStyle(
                                            color: done
                                                ? Colors.orange.shade800
                                                : locked
                                                    ? AppColors.primary
                                                    : AppColors.accentBlue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      done
                                          ? 'Passed'
                                          : locked
                                              ? 'Locked'
                                              : '${survey.points} Points',
                                      style: TextStyle(
                                        color: Colors.amber.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
