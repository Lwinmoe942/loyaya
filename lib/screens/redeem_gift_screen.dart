import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loyaya/config/api_config.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/coming_soon_dialog.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';
import 'package:url_launcher/url_launcher.dart';

class RedeemGiftScreen extends StatefulWidget {
  const RedeemGiftScreen({super.key, required this.publicId});

  final String publicId;

  @override
  State<RedeemGiftScreen> createState() => _RedeemGiftScreenState();
}

class _RedeemGiftScreenState extends State<RedeemGiftScreen> {
  final _codeController = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _copyId() async {
    await Clipboard.setData(ClipboardData(text: widget.publicId));
    setState(() => _message = 'ID copied to clipboard');
  }

  Future<void> _openExchange() async {
    final uri = Uri.parse(ApiConfig.exchangeUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      setState(() => _message = 'Could not open exchange page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DingaPageHeader(
              title: 'Redeem Gift Code',
              onBack: () => Navigator.pop(context),
              titleColor: AppColors.primary,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Redeem Code',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Claim reward points from your gift code.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Gift Code',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${_codeController.text.length} chars',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _codeController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'LSO-TE-XXXXXX',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () =>
                          showComingSoon(context, feature: 'Gift code redeem'),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Redeem Code'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exchange Website',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your ID: ${widget.publicId}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copyId,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy ID'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _openExchange,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Exchange'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.accentGreen,
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
