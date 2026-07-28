import 'package:flutter/material.dart';
import 'package:campusbite/utils/formatters.dart';

/// Reusable balance card widget
class BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final String? currency;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showProgress;
  final double? progressValue;

  const BalanceCard({
    super.key,
    required this.title,
    required this.amount,
    this.currency,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.showProgress = false,
    this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveCurrency = currency ?? 'Birr';

    return Card(
      color: backgroundColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              Formatters.formatCurrency(amount, currency: effectiveCurrency),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor ?? theme.colorScheme.primary,
              ),
            ),
            if (showProgress && progressValue != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  iconColor ?? theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
