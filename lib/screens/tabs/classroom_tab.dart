import 'package:flutter/material.dart';
import 'package:loyaya/screens/course_apply_screen.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassroomTab extends StatefulWidget {
  const ClassroomTab({
    super.key,
    required this.api,
    required this.balance,
    required this.loading,
    required this.onRefresh,
  });

  final ApiClient api;
  final int balance;
  final bool loading;
  final Future<void> Function() onRefresh;

  @override
  State<ClassroomTab> createState() => _ClassroomTabState();
}

class _ClassroomTabState extends State<ClassroomTab> {
  List<Map<String, dynamic>> _courses = [];
  Map<String, Map<String, dynamic>> _applications = {};
  String _contactEmail = 'moegyi707299@gmail.com';
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _fetching = true);
    try {
      final courses = await widget.api.courses();
      final appsData = await widget.api.courseApplications();
      final apps = (appsData['applications'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final byCourse = <String, Map<String, dynamic>>{};
      for (final row in apps) {
        final id = row['course_id']?.toString();
        if (id == null || id.isEmpty) continue;
        final existing = byCourse[id];
        if (existing == null || _isNewer(row, existing)) {
          byCourse[id] = row;
        }
      }
      if (mounted) {
        setState(() {
          _courses = courses;
          _applications = byCourse;
          _contactEmail =
              appsData['contact_email']?.toString() ?? _contactEmail;
        });
      }
    } catch (_) {
      // Keep last data on error.
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  bool _isNewer(Map<String, dynamic> a, Map<String, dynamic> b) {
    final ai = a['id'] as int? ?? 0;
    final bi = b['id'] as int? ?? 0;
    return ai > bi;
  }

  Map<String, dynamic>? _applicationFor(String courseId) =>
      _applications[courseId];

  String _statusFor(Map<String, dynamic> course) {
    final app = _applicationFor(course['id']?.toString() ?? '');
    if (app != null) return app['status']?.toString() ?? 'pending';
    final required = course['points_required'] as int? ?? 0;
    if (widget.balance < required) return 'locked';
    return 'available';
  }

  Future<void> _openCourse(Map<String, dynamic> course) async {
    final status = _statusFor(course);
    final required = course['points_required'] as int? ?? 0;

    if (status == 'locked') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ဒီသင်တန်းအတွက် $required points လိုပါသေးတယ်။ '
            'လက်ရှိ ${widget.balance} pts',
          ),
        ),
      );
      return;
    }

    if (status == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'လျှောက်လွှာ စောင့်ဆိုင်းနေပါတယ်။ $_contactEmail က ဆက်သွယ်ပေးပါမယ်။',
          ),
        ),
      );
      return;
    }

    if (status == 'approved') {
      final app = _applicationFor(course['id']?.toString() ?? '');
      final url = app?['video_url']?.toString() ??
          course['video_url']?.toString();
      if (url == null || url.isEmpty) return;
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    if (status == 'rejected') {
      if (widget.balance < required) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$required points ပြန်ရောက်မှ ထပ်လျှောက်လို့ရပါမယ်။'),
          ),
        );
        return;
      }
    }

    final applied = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CourseApplyScreen(
          api: widget.api,
          course: course,
          balance: widget.balance,
          onApplied: () async {
            await widget.onRefresh();
            await _load();
          },
        ),
      ),
    );

    if (applied == true) {
      await widget.onRefresh();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.loading || _fetching;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await widget.onRefresh();
          await _load();
        },
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
                        'Premium သင်တန်း',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '500 / 1000 / 2000 points ရောက်ရင် လျှောက်လို့ရပါမယ်။',
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
                      'လျှောက်လွှာ လမ်းညွှန်',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Point ရောက်ပြီး လျှောက်လွှာ ပို့ပါ\n'
                      '2. Point အကုန် လျှော့ပါမယ်\n'
                      '3. အမည် + ဖုန်းနံပါတ် ထည့်ပါ\n'
                      '4. ကျွန်ုပ်တို့က ဖုန်းဆက်ပြီး သင်တန်းမိတ်ဆက်ပေးပါမယ်',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: $_contactEmail',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
              'သင်တန်းများ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (busy)
              const Center(child: CircularProgressIndicator())
            else if (_courses.isEmpty)
              const Card(
                child: ListTile(title: Text('သင်တန်း မရှိသေးပါ။')),
              )
            else
              for (final course in _courses)
                _CourseCard(
                  course: course,
                  status: _statusFor(course),
                  onTap: () => _openCourse(course),
                ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.status,
    required this.onTap,
  });

  final Map<String, dynamic> course;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final required = course['points_required'] as int? ?? 0;
    final title = course['title']?.toString() ?? '';
    final subtitle = course['subtitle']?.toString() ?? '';

    final (Color badgeColor, String badgeText, IconData icon) = switch (status) {
      'approved' => (
          AppColors.accentGreen,
          'Enrolled',
          Icons.play_circle_fill,
        ),
      'pending' => (
          Colors.orange,
          'Pending',
          Icons.hourglass_top,
        ),
      'available' => (
          AppColors.primary,
          'Apply',
          Icons.how_to_reg,
        ),
      'rejected' => (
          AppColors.primary,
          'Re-apply',
          Icons.refresh,
        ),
      _ => (
          Colors.grey,
          'Locked',
          Icons.lock,
        ),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: badgeColor,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$subtitle\n$required points လိုအပ်'),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
