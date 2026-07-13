import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseApplyScreen extends StatefulWidget {
  const CourseApplyScreen({
    super.key,
    required this.api,
    required this.course,
    required this.balance,
    required this.onApplied,
  });

  final ApiClient api;
  final Map<String, dynamic> course;
  final int balance;
  final VoidCallback onApplied;

  @override
  State<CourseApplyScreen> createState() => _CourseApplyScreenState();
}

class _CourseApplyScreenState extends State<CourseApplyScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _submitting = false;
  String? _error;

  int get _required => widget.course['points_required'] as int? ?? 0;
  String get _title => widget.course['title']?.toString() ?? 'Course';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.length < 2) {
      setState(() => _error = 'အမည် ထည့်ပါ။');
      return;
    }
    if (phone.length < 6) {
      setState(() => _error = 'ဖုန်းနံပါတ် ထည့်ပါ။');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('လျှောက်လွှာ အတည်ပြု'),
        content: Text(
          'လျှောက်လိုက်ရင် လက်ရှိ point ${widget.balance} အကုန် လျှော့ပါမယ်။\n\n'
          'သင်တန်း: $_title\n'
          'အမည်: $name\n'
          'ဖုန်း: $phone\n\n'
          'ဆက်လုပ်မလား?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('မလုပ်တော့'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('လျှောက်မယ်'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await widget.api.applyForCourse(
        courseId: widget.course['id']?.toString() ?? '',
        name: name,
        phone: phone,
      );
      if (!mounted) return;

      widget.onApplied();

      final email = result['contact_email']?.toString() ?? 'moegyi707299@gmail.com';
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('လျှောက်လွှာ ပို့ပြီးပါပြီ'),
          content: Text(
            'သင့် point အကုန် လျှော့ပြီးပါပြီ။\n\n'
            'ကျွန်ုပ်တို့က ဖုန်းနဲ့ ဆက်သွယ်ပြီး သင်တန်းမိတ်ဆက်ပေးပါမယ်။\n\n'
            'Email: $email',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final uri = Uri(
                  scheme: 'mailto',
                  path: email,
                  queryParameters: {
                    'subject': 'Course application — $_title',
                    'body':
                        'Name: $name\nPhone: $phone\nCourse: $_title\nPoints deducted: ${widget.balance}',
                  },
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: const Text('Email ပို့'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e.error));
    } catch (_) {
      if (mounted) setState(() => _error = apiErrorMessage('NETWORK_ERROR'));
    } finally {
      if (mounted) setState(() => _submitting = false);
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
                title: 'သင်တန်းလျှောက်',
                subtitle:
                    '$_title — $required points ရောက်ပြီးမှ လျှောက်လို့ရပါမယ်။ '
                    'လျှောက်လိုက်ရင် point အကုန် လျှော့ပါမယ်။',
                onBack: () => Navigator.pop(context),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course['subtitle']?.toString() ?? '',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'လက်ရှိ balance: ${widget.balance} pts',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                enabled: !_submitting,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'အမည်',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                enabled: !_submitting,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'ဖုန်းနံပါတ်',
                  hintText: '09xxxxxxxxx',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('လျှောက်လွှာ ပို့မယ်'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primary,
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
