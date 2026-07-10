import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final _codeController = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  String? _message;
  bool _success = false;

  String _referralCode = '';
  String _referralLink = '';
  bool _inviteApplied = false;
  String? _appliedCode;
  int _referralCount = 0;
  int _bonusEarned = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await widget.api.referralStatus();
      if (!mounted) return;
      setState(() {
        _referralCode = data['referral_code'] as String? ?? '';
        _referralLink = data['referral_link'] as String? ?? '';
        _inviteApplied = data['invite_applied'] == true;
        _appliedCode = data['applied_code'] as String?;
        _referralCount = data['referral_count'] as int? ?? 0;
        _bonusEarned = data['referral_bonus_earned'] as int? ?? 0;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _message = apiErrorMessage(e.error);
        });
      }
    }
  }

  Future<void> _applyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _submitting = true;
      _message = null;
      _success = false;
    });

    try {
      final result = await widget.api.applyReferralCode(code);
      if (!mounted) return;
      setState(() {
        _success = true;
        _message = result['message'] as String? ?? 'Invite code applied!';
        _codeController.clear();
      });
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _message = apiErrorMessage(e.error));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  DingaPageHeader(
                    title: 'Referral Program',
                    subtitle: 'Lotaya Dinga — invite friends, earn together.',
                    onBack: () => Navigator.pop(context),
                  ),
                  if (_inviteApplied)
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Invite Code Applied',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _appliedCode != null
                                ? 'You joined Lotaya Dinga with code $_appliedCode.'
                                : 'You have already applied a referral code successfully.',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Have an Invite Code?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter a friend\'s Lotaya Dinga referral code to link your account.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _codeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'Enter referral code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _submitting ? null : _applyCode,
                            child: _submitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Apply Code'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  _CopyCard(
                    title: 'Your Referral Link',
                    value: _referralLink,
                    hint: 'Tap to copy your full Lotaya Dinga referral link.',
                    onCopy: () => _copy(_referralLink, 'Referral link'),
                  ),
                  const SizedBox(height: 12),
                  _CopyCard(
                    title: 'Your Referral Code',
                    value: _referralCode,
                    hint: 'Share this code directly with your friends.',
                    large: true,
                    onCopy: () => _copy(_referralCode, 'Referral code'),
                  ),
                  const SizedBox(height: 12),
                  _Card(
                    child: Column(
                      children: [
                        _BenefitRow(
                          icon: Icons.card_giftcard,
                          text: 'Earn ',
                          highlight: '10%',
                          suffix: ' of your referred friend\'s points in Lotaya Dinga',
                        ),
                        const Divider(height: 24),
                        const _BenefitRow(
                          icon: Icons.emoji_events,
                          text:
                              'Refer more friends and claim monthly leaderboard rewards',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _InfoCard(
                    title: 'How Referral Works',
                    body:
                        'Invite your friends to join Lotaya Dinga using your referral link or referral code. '
                        'When a friend registers with your referral and starts earning points in the app, '
                        'you begin receiving referral rewards automatically.',
                  ),
                  const SizedBox(height: 12),
                  const _InfoCard(
                    title: 'Referral Benefits',
                    bullets: [
                      'You earn 10% of the points your referred friend earns in Lotaya Dinga',
                      'The more active your referred friends are, the more bonus points you receive',
                      'Invite more friends to climb higher on the referral leaderboard',
                      'Top referrers can claim monthly leaderboard rewards',
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _InfoCard(
                    title: 'Monthly Leaderboard Rewards',
                    body:
                        'Users who refer more active friends can rank higher on the Lotaya Dinga leaderboard. '
                        'If you stay among the top referrers, you may claim special monthly rewards.',
                  ),
                  const SizedBox(height: 12),
                  const _InfoCard(
                    title: 'Rules',
                    bullets: [
                      'Referral link or code must be used during registration or applied once in this screen',
                      'Self-referral or duplicate accounts are not allowed',
                      'Only valid and active referrals will count toward rewards',
                      'Fraudulent or abusive activity may result in referral disqualification',
                    ],
                  ),
                  if (_referralCount > 0 || _bonusEarned > 0) ...[
                    const SizedBox(height: 12),
                    _Card(
                      child: Row(
                        children: [
                          Expanded(
                            child: _MiniStat(
                              label: 'Friends Referred',
                              value: '$_referralCount',
                            ),
                          ),
                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                          Expanded(
                            child: _MiniStat(
                              label: 'Bonus Earned',
                              value: '$_bonusEarned pts',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _message!,
                      style: TextStyle(
                        color: _success ? AppColors.accentGreen : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: child));
  }
}

class _CopyCard extends StatelessWidget {
  const _CopyCard({
    required this.title,
    required this.value,
    required this.hint,
    required this.onCopy,
    this.large = false,
  });

  final String title;
  final String value;
  final String hint;
  final VoidCallback onCopy;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: large ? 22 : 14,
                        fontWeight: large ? FontWeight.bold : FontWeight.normal,
                        color: large ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(Icons.copy, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(hint, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.text,
    this.highlight,
    this.suffix,
  });

  final IconData icon;
  final String text;
  final String? highlight;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: highlight == null
              ? Text(text, style: const TextStyle(height: 1.35))
              : Text.rich(
                  TextSpan(
                    style: const TextStyle(color: AppColors.textPrimary, height: 1.35),
                    children: [
                      TextSpan(text: text),
                      TextSpan(
                        text: highlight,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (suffix != null) TextSpan(text: suffix),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    this.body,
    this.bullets = const [],
  });

  final String title;
  final String? body;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(body!, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
          ],
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: AppColors.primary)),
                  Expanded(
                    child: Text(b, style: const TextStyle(color: AppColors.textSecondary, height: 1.35)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
