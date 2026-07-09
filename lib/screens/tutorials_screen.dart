import 'package:flutter/material.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/coming_soon_dialog.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key});

  static const _items = [
    (
      title: 'How to Get Points With Check-in',
      subtitle: 'Daily check-in guide',
      duration: '01:45',
    ),
    (
      title: 'How to Redeem Gift Codes',
      subtitle: 'Enter your gift code and claim points',
      duration: '02:26',
    ),
    (
      title: 'Math Quiz Tips',
      subtitle: 'Solve quizzes and earn +2 points',
      duration: '01:12',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            DingaPageHeader(
              title: 'Tutorials',
              subtitle: 'Learn how to use the app and earn points.',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 120,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, Color(0xFFFF9800)],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 12,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.play_arrow, color: Colors.white, size: 16),
                                      Text('Watch', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentBlue.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Support',
                                      style: TextStyle(
                                        color: AppColors.accentBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    item.duration,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.subtitle,
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.school_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Step by step guide',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  FilledButton(
                                    onPressed: () =>
                                        showComingSoon(context, feature: 'Video tutorials'),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(80, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    child: const Text('Open'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
