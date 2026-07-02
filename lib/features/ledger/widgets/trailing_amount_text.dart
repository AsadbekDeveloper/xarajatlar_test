import 'package:flutter/material.dart';

/// The ellipsized, end-aligned amount column shared by every list row that
/// ends in a money value (expense list, balances, settlements).
class TrailingAmountText extends StatelessWidget {
  const TrailingAmountText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: style,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.end,
  );
}
