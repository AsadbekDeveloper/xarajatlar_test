import 'package:flutter/material.dart';

import '../../../core/app_spacing.dart';

/// The end-aligned amount column shared by every list row that ends in a
/// money value (expense list, balances, settlements).
///
/// Shrinks to fit via [FittedBox] instead of ellipsizing. Unlike a truncated
/// name, a truncated monetary figure (e.g. "999 999…") can be misread as a
/// different amount, so this never drops digits — it makes them smaller
/// instead. The `ConstrainedBox` still bounds how much of the Row this can
/// claim (so an extreme value shrinks rather than pushing the sibling
/// `Expanded` label to zero width or overflowing the Row); `FittedBox`
/// guarantees the full string always renders within that bound, so the cap
/// doesn't have to be sized exactly to the widest possible value. Use this
/// directly as a Row child.
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
