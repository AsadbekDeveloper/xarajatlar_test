import 'package:flutter/material.dart';

import '../../../core/app_spacing.dart';
import '../../../core/app_strings.dart';
import '../../../core/money_formatter.dart';

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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppStrings.expenseSubtitle(payerName, participantCount),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              formatSom(amount),
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
