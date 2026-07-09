import 'package:flutter/material.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/coming_soon_dialog.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class RedeemGiftScreen extends StatefulWidget {
  const RedeemGiftScreen({super.key});

  @override
  State<RedeemGiftScreen> createState() => _RedeemGiftScreenState();
}

class _RedeemGiftScreenState extends State<RedeemGiftScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool get _canRedeem => _codeController.text.trim().isNotEmpty;

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
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'LD-TE-XXXXXX',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _canRedeem
                          ? () => showComingSoon(
                                context,
                                feature: 'Gift code redeem',
                              )
                          : null,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Redeem Code'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
