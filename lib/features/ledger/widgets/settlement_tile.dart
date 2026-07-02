import 'package:flutter/material.dart';

import '../../../core/app_spacing.dart';
import '../../../core/money_formatter.dart';
import 'trailing_amount_text.dart';

class SettlementTile extends StatelessWidget {
  const SettlementTile({
    super.key,
    required this.fromName,
    required this.toName,
    required this.amount,
  });

  final String fromName;
  final String toName;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: textTheme.titleMedium?.copyWith(color: primary),
                children: [
                  TextSpan(text: fromName),
                  const TextSpan(text: ' → '),
                  TextSpan(text: toName),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TrailingAmountText(
            text: formatSom(amount),
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
