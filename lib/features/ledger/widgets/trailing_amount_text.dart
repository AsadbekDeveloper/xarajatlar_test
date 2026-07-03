import 'package:flutter/material.dart';

import '../../../core/app_spacing.dart';

/// The end-aligned amount column shared by every list row that ends in a
/// money value (expense list, balances, settlements). Use directly as a Row
/// child.
///
/// Shrinks to fit via [FittedBox] rather than ellipsizing — a truncated
/// amount (e.g. "999 999…") can be misread as a different number, so digits
/// are never dropped, only shrunk. The `ConstrainedBox` caps how much of the
/// Row this can claim, so an extreme value shrinks instead of squeezing the
/// sibling `Expanded` label to nothing.
class TrailingAmountText extends StatelessWidget {
  const TrailingAmountText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(
      maxWidth: AppLayout.trailingValueMaxWidth,
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(text, style: style, maxLines: 1),
    ),
  );
}
