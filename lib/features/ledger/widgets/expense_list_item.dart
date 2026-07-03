import 'package:flutter/material.dart';
import 'package:xarajatlar_test/features/ledger/widgets/tinted_container.dart';

import '../../../core/app_spacing.dart';
import '../../../core/app_strings.dart';
import '../../../core/money_formatter.dart';
import 'trailing_amount_text.dart';

class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.title,
    required this.payerName,
    required this.participantCount,
    required this.amount,
    required this.onTap,
    required this.onDelete,
  });

  final String title;
  final String payerName;
  final int participantCount;
  final int amount;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: TintedContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppStrings.expenseSubtitle(payerName, participantCount),
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TrailingAmountText(
              text: formatSom(amount),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Theme.of(context).colorScheme.outline,
              onPressed: onDelete,
              tooltip: AppStrings.deleteTooltip,
            ),
          ],
        ),
      ),
    );
  }
}
