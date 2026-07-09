import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/coming_soon_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassroomTab extends StatefulWidget {
  const ClassroomTab({
    super.key,
    required this.api,
    required this.balance,
    required this.loading,
  });

  final ApiClient api;
  final int balance;
  final bool loading;

  @override
  State<ClassroomTab> createState() => _ClassroomTabState();
}

class _ClassroomTabState extends State<ClassroomTab> {
  List<Map<String, dynamic>> _lessons = [];
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _fetching = true);
    try {
      final items = await widget.api.classroomLessons();
      if (mounted) setState(() => _lessons = items);
    } catch (_) {
      // Keep empty list on error.
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  Future<void> _openLesson(Map<String, dynamic> lesson) async {
    final required = lesson['points_required'] as int? ?? 0;
    if (widget.balance < required) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Need $required points to unlock this class.'),
        ),
      );
      return;
    }

    final url = lesson['video_url']?.toString();
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.loading || _fetching;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
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
                      'Watch classroom lessons for learning. Some classes require minimum points to unlock.',
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
                  'Balance: ${widget.balance} points',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Classes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (busy)
              const Center(child: CircularProgressIndicator())
            else if (_lessons.isEmpty)
              const Card(
                child: ListTile(
                  title: Text('No classes available yet.'),
                ),
              )
            else
              for (final lesson in _lessons)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (lesson['points_required'] as int? ?? 0) <= widget.balance
                          ? AppColors.primary
                          : Colors.grey,
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                    title: Text(lesson['title']?.toString() ?? ''),
                    subtitle: Text(
                      '${lesson['lessons'] ?? 0} lessons · '
                      '${lesson['points_required'] ?? 0} pts to unlock',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openLesson(lesson),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
