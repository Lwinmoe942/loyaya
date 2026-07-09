import 'package:flutter/material.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/coming_soon_dialog.dart';

class ClassroomTab extends StatelessWidget {
  const ClassroomTab({
    super.key,
    required this.balance,
    required this.loading,
  });

  final int balance;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Classroom',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Learn and unlock lessons with points.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CLASSROOM PASS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unlock All Classes',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Watch classroom lessons without collecting points while your pass is active. For learning access only.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              showComingSoon(context, feature: 'Monthly pass'),
                          child: const Text('Monthly\nAll Access'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              showComingSoon(context, feature: 'Yearly pass'),
                          child: const Text('Yearly\nAll Access'),
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
            child: ListTile(
              title: Text(
                'Balance: $balance points',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'unlocked', label: Text('Unlocked')),
                ],
                selected: const {'all'},
                onSelectionChanged: (_) {},
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Classes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.play_arrow, color: Colors.white),
                ),
                title: const Text('Getting Started Guide'),
                subtitle: const Text('15 lessons · Coming soon'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showComingSoon(context, feature: 'Classroom lessons'),
              ),
            ),
        ],
      ),
    );
  }
}
