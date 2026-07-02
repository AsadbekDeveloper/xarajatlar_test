import 'package:flutter/material.dart';

import '../../../core/app_spacing.dart';
import '../../../core/app_strings.dart';
import '../../../core/app_theme.dart';
import '../../../core/money_formatter.dart';

class PersonBalanceTile extends StatelessWidget {
  const PersonBalanceTile({
    super.key,
    required this.name,
    required this.balance,
  });

  final String name;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ledgerColors = context.ledgerColors;

    final Color amountColor;
    final String statusLabel;
    if (balance > 0) {
      amountColor = ledgerColors.positive;
      statusLabel = AppStrings.balancePositiveLabel;
    } else if (balance < 0) {
      amountColor = ledgerColors.negative;
      statusLabel = AppStrings.balanceNegativeLabel;
    } else {
      amountColor = Theme.of(context).colorScheme.outline;
      statusLabel = AppStrings.balanceZeroLabel;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(statusLabel, style: textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            formatSignedSom(balance),
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: amountColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
