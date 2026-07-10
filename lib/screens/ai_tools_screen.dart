import 'package:flutter/material.dart';
import 'package:loyaya/screens/ai_history_screen.dart';
import 'package:loyaya/screens/ai_record_to_text_screen.dart';
import 'package:loyaya/screens/ai_text_to_voice_screen.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/ai_hero_card.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';
import 'package:loyaya/widgets/entry_ad_mixin.dart';

class AiToolsScreen extends StatefulWidget {
  const AiToolsScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<AiToolsScreen> createState() => _AiToolsScreenState();
}

class _AiToolsScreenState extends State<AiToolsScreen> with EntryAdMixin {
  @override
  void initState() {
    super.initState();
    initEntryAd();
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            DingaPageHeader(
              title: 'AI Tools',
              onBack: () => Navigator.pop(context),
            ),
            const AiHeroCard(
              badge: 'AI Powered',
              badgeIcon: Icons.auto_awesome,
              title: 'Create with AI',
              subtitle:
                  'Convert speech into text, turn text into voice, and manage your AI history easily in one place.',
              stats: [
                '2 Main Tools',
                'Points Usage Based',
                'Ad Reward Gate',
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Tools',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose one tool to get started',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _ToolTile(
              title: 'Record to Text',
              subtitle: 'Upload or record audio and convert it into text.',
              icon: Icons.mic,
              color: AppColors.primary,
              onTap: () => _open(AiRecordToTextScreen(api: widget.api)),
            ),
            _ToolTile(
              title: 'Text to Voice',
              subtitle: 'Enter text and generate voice output.',
              icon: Icons.volume_up_rounded,
              color: AppColors.accentBlue,
              onTap: () => _open(AiTextToVoiceScreen(api: widget.api)),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.history, color: AppColors.accentGreen),
                ),
                title: const Text(
                  'AI History',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'See your previous transcripts and generated audio files.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(AiHistoryScreen(api: widget.api)),
              ),
            ),
            const SizedBox(height: 12),
            const AiInfoCard(
              title: 'How AI Usage Works',
              bullets: [
                'Record to Text uses points based on audio duration.',
                'Text to Voice uses points based on text length.',
                'Some AI actions require watching 3 reward ads before running.',
                'Your finished results will appear in AI History.',
              ],
            ),
            const SizedBox(height: 12),
            const AiSponsoredCard(),
          ],
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
