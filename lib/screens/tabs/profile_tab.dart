import 'package:flutter/material.dart';
import 'package:loyaya/screens/referral_screen.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/coming_soon_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.api,
    required this.user,
    required this.balance,
    required this.publicId,
    required this.onLogout,
    required this.onRefresh,
  });

  final ApiClient api;

  final Map<String, dynamic>? user;
  final int balance;
  final String publicId;
  final VoidCallback onLogout;
  final Future<void> Function() onRefresh;

  int _accountAgeDays() {
    final created = user?['created_at']?.toString();
    if (created == null) return 0;
    final dt = DateTime.tryParse(created);
    if (dt == null) return 0;
    return DateTime.now().difference(dt).inDays.clamp(0, 9999);
  }

  @override
  Widget build(BuildContext context) {
    final name = user?['name']?.toString() ?? 'User';
    final email = user?['email']?.toString() ?? '';
    final days = _accountAgeDays();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
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
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your profile status',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            value: '$balance',
                            label: 'Points',
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: _StatTile(
                            value: '',
                            label: 'Edit Profile',
                            icon: Icons.edit_outlined,
                            onTap: () => showComingSoon(
                              context,
                              feature: 'Edit profile',
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: _StatTile(
                            value: '$days',
                            label: 'days\nAccount Age',
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.share_outlined,
              title: 'Referral Program',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ReferralScreen(api: api)),
              ),
            ),
            _MenuTile(
              icon: Icons.restart_alt,
              title: 'Reset All Posts',
              onTap: () => showComingSoon(context, feature: 'Reset posts'),
            ),
            _MenuTile(
              icon: Icons.info_outline,
              title: 'About Us',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const _AboutScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const _TermsScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.info_outline,
              title: 'Version',
              trailing: 'v 1.0.0',
              onTap: () {},
            ),
            _MenuTile(
              icon: Icons.logout,
              title: 'Logout',
              titleColor: AppColors.primary,
              onTap: onLogout,
            ),
            if (publicId.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'ID: $publicId',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TermsScreen extends StatelessWidget {
  const _TermsScreen();

  static final Uri _website = Uri.parse('https://u5aidigital.com');

  Future<void> _openWebsite(BuildContext context) async {
    final opened = await launchUrl(
      _website,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the website.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const _InfoCard(title: 'Effective Date', body: 'July 19, 2026'),
          const _InfoCard(
            title: '1. Agreement to These Terms',
            body:
                'By creating an account, accessing, or using Lotaya Shwe Oh, '
                'you agree to these Terms & Conditions. If you do not agree, '
                'please stop using the app.',
          ),
          const _InfoCard(
            title: '2. App and Operator',
            body:
                'Lotaya Shwe Oh is an independently operated learning and '
                'engagement app.\n\n'
                'Operator: Independent developer\n'
                'Address: Shibazono 1-Chome 1-26, Yume House, Room 103, '
                'Kawaguchi City, Saitama 333-0854, Japan.',
          ),
          const _InfoCard(
            title: '3. Accounts and Security',
            body:
                'You must provide accurate information and keep your password, '
                'OTP, verification codes, and account access confidential. You '
                'are responsible for activity performed through your account.\n\n'
                'Do not sell, transfer, share, or create accounts through '
                'automated or deceptive methods.',
          ),
          const _InfoCard(
            title: '4. Learning Points',
            body:
                'Points may be awarded for eligible activities such as quizzes, '
                'local surveys, tutorials, games, daily activities, or rewarded '
                'advertisements.\n\n'
                'Points are virtual in-app units for educational progress and '
                'eligible app features. They are not cash, electronic money, '
                'cryptocurrency, savings, an investment, or a promise of income. '
                'They cannot be sold, traded, transferred, or withdrawn as cash '
                'inside the app.\n\n'
                'Point amounts, eligibility, limits, and availability may change '
                'to prevent abuse or improve the service.',
          ),
          const _InfoCard(
            title: '5. Advertisements and Third-Party Services',
            body:
                'The app may display optional rewarded ads and other advertising '
                'provided by third-party networks. A reward is granted only when '
                'the required ad or activity is completed and confirmed.\n\n'
                'Third-party content, offers, websites, and services are governed '
                'by their own terms and privacy practices. Lotaya Shwe Oh does '
                'not control their availability, decisions, or content.',
          ),
          const _InfoCard(
            title: '6. Fair Use',
            body:
                'You must not hack, reverse engineer, modify, automate, exploit, '
                'or manipulate the app, advertisements, points, referrals, or '
                'reward systems. Multiple-account abuse, fake activity, bots, '
                'VPN-based reward manipulation, and fraudulent claims are '
                'prohibited.\n\n'
                'Invalid or abusive activity may result in points being removed '
                'and the account being restricted or suspended.',
          ),
          const _InfoCard(
            title: '7. Content and Intellectual Property',
            body:
                'Original app design, text, and materials created for Lotaya '
                'Shwe Oh may not be copied, resold, or redistributed without '
                'permission. Third-party names, trademarks, advertisements, '
                'videos, and materials remain the property of their respective '
                'owners.',
          ),
          const _InfoCard(
            title: '8. Availability and Changes',
            body:
                'Features, content, points, advertisements, and services may be '
                'updated, limited, paused, or discontinued. We do not guarantee '
                'that every feature or advertisement will always be available '
                'in every country, device, or network.',
          ),
          const _InfoCard(
            title: '9. Disclaimer',
            body:
                'The app is provided on an “as available” basis for learning and '
                'general engagement. Educational results may vary. We do not '
                'guarantee earnings, employment, business success, advertising '
                'approval, or uninterrupted service.',
          ),
          const _InfoCard(
            title: '10. Suspension and Termination',
            body:
                'We may restrict or terminate accounts that violate these terms, '
                'engage in fraud, misuse rewards, threaten other users, or create '
                'security or legal risks.',
          ),
          const _InfoCard(
            title: '11. Governing Rules',
            body:
                'These terms are governed by applicable laws and regulations in '
                'Japan. Mandatory consumer protections that apply in a user’s '
                'location remain unaffected.',
          ),
          _InfoCard(
            title: '12. Official Contact',
            body:
                'For official information, support, or questions about these '
                'terms, use the website below. Do not trust unofficial agents, '
                'social media accounts, private messages, or websites claiming '
                'to represent Lotaya Shwe Oh.',
            footer: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openWebsite(context),
                icon: const Icon(Icons.language),
                label: const Text('https://u5aidigital.com'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutScreen extends StatelessWidget {
  const _AboutScreen();

  static final Uri _website = Uri.parse('https://u5aidigital.com');

  Future<void> _openWebsite(BuildContext context) async {
    final opened = await launchUrl(
      _website,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the website.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const _InfoCard(
            title: 'Lotaya Shwe Oh',
            body:
                'Learn through quizzes, local surveys, tutorials, and useful '
                'digital tools. Complete eligible in-app activities to collect '
                'points and explore more learning features.',
          ),
          const _InfoCard(
            title: 'What We Do',
            body:
                'Lotaya Shwe Oh is an independent learning and engagement app. '
                'It combines educational quizzes, general-knowledge activities, '
                'AI-assisted tools, and simple games in one place.\n\n'
                'Our goal is to make learning and practising digital skills more '
                'accessible and enjoyable. Lotaya Shwe Oh is not affiliated with '
                'Google or any advertised third-party brand.',
          ),
          const _InfoCard(
            title: 'Points Are Not Money',
            body:
                'Lotaya Shwe Oh points are virtual in-app units. They are not '
                'cash, electronic money, cryptocurrency, a bank balance, or an '
                'investment, and they do not earn interest.\n\n'
                'Points are intended only for educational progress and eligible '
                'features inside Lotaya Shwe Oh. The app does not provide an '
                'in-app cash withdrawal, money transfer, point trading, or '
                'point-selling service.',
          ),
          const _InfoCard(
            title: 'Safe Use',
            body:
                'Never share your password, OTP, verification code, access '
                'token, payment details, or private account information with '
                'anyone.\n\n'
                'Be careful of unofficial pages, groups, messages, agents, or '
                'websites claiming to represent Lotaya Shwe Oh. Always verify '
                'information through the official website below.',
          ),
          _InfoCard(
            title: 'Developer Information',
            body:
                'OPERATOR\n'
                'Independent developer\n\n'
                'ADDRESS\n'
                'Shibazono 1-Chome 1-26, Yume House, Room 103\n'
                'Kawaguchi City, Saitama 333-0854\n'
                'Japan',
            footer: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openWebsite(context),
                icon: const Icon(Icons.language),
                label: const Text('https://u5aidigital.com'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body, this.footer});

  final String title;
  final String body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            if (footer != null) ...[const SizedBox(height: 10), footer!],
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    this.color,
    this.icon,
    this.onTap,
  });

  final String value;
  final String label;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            if (icon != null)
              Icon(icon, color: AppColors.primary)
            else
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailing;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: TextStyle(color: titleColor)),
        trailing: trailing != null
            ? Text(
                trailing!,
                style: const TextStyle(color: AppColors.textSecondary),
              )
            : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
