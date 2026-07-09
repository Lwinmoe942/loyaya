import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class RedeemGiftScreen extends StatefulWidget {
  const RedeemGiftScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<RedeemGiftScreen> createState() => _RedeemGiftScreenState();
}

class _RedeemGiftScreenState extends State<RedeemGiftScreen> {
  final _codeController = TextEditingController();
  bool _submitting = false;
  String? _message;
  bool _success = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool get _canRedeem =>
      _codeController.text.trim().isNotEmpty && !_submitting;

  Future<void> _redeem() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _submitting = true;
      _message = null;
      _success = false;
    });

    try {
      final result = await widget.api.redeemGiftCode(code);
      setState(() {
        _success = true;
        _message = result['message'] as String? ??
            'Redeemed! +${result['points']} points.';
        _codeController.clear();
      });
    } on ApiException catch (e) {
      setState(() {
        _message = apiErrorMessage(e.error);
      });
    } catch (_) {
      setState(() {
        _message = 'Could not redeem code. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
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
              onBack: () => Navigator.pop(context, _success),
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
                        hintText: 'LSO-XXXXXX',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
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
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _canRedeem ? _redeem : null,
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(_submitting ? 'Redeeming...' : 'Redeem Code'),
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
