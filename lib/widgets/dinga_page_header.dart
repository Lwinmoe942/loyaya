import 'package:flutter/material.dart';
import 'package:loyaya/theme/app_theme.dart';

class DingaPageHeader extends StatelessWidget {
  const DingaPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.titleColor = AppColors.primary,
    this.subtitleColor = AppColors.textSecondary,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back_ios_new, color: titleColor, size: 20),
            )
          else
            const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
