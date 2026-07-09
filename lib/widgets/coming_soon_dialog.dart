import 'package:flutter/material.dart';
import 'package:loyaya/theme/app_theme.dart';

void showComingSoon(BuildContext context, {String? feature}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Coming Soon'),
      content: Text(
        feature != null
            ? '$feature will be added in a future update.'
            : 'This feature will be added in a future update.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    ),
  );
}
