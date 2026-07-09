import 'package:flutter/material.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/coming_soon_dialog.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.user,
    required this.balance,
    required this.publicId,
    required this.onLogout,
    required this.onRefresh,
  });

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
                    Text(email, style: const TextStyle(color: AppColors.textSecondary)),
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
                        Container(width: 1, height: 40, color: Colors.grey.shade300),
                        Expanded(
                          child: _StatTile(
                            value: '',
                            label: 'Edit Profile',
                            icon: Icons.edit_outlined,
                            onTap: () =>
                                showComingSoon(context, feature: 'Edit profile'),
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade300),
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
              title: 'Referral',
              onTap: () => showComingSoon(context, feature: 'Referral'),
            ),
            _MenuTile(
              icon: Icons.restart_alt,
              title: 'Reset All Posts',
              onTap: () => showComingSoon(context, feature: 'Reset posts'),
            ),
            _MenuTile(
              icon: Icons.info_outline,
              title: 'About Us',
              onTap: () => _showInfo(context, 'About Us', 'Lotaya Shwe Oh — earn points with daily check-in, surveys, and quizzes.'),
            ),
            _MenuTile(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () => _showInfo(context, 'Terms & Conditions', 'Use the app responsibly. Points have no cash value inside the app.'),
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
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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
            ? Text(trailing!, style: const TextStyle(color: AppColors.textSecondary))
            : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
