/// Formats a whole-so'm amount with a thousands space separator, e.g.
/// `formatSom(90000) == "90 000"`. No `intl` dependency — this is the only
/// place in the app that touches number formatting.
String formatSom(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    if (i > 0 && remaining % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return amount < 0 ? '-$buffer' : buffer.toString();
}

/// Same as [formatSom] with an explicit sign for positive amounts, used for
/// balances where "+50 000" vs "50 000" carries meaning.
String formatSignedSom(int amount) {
  if (amount > 0) return '+${formatSom(amount)}';
  return formatSom(amount);
}
