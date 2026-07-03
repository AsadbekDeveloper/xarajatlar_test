/// Spacing scale from the design tokens: 4 · 8 · 12 · 16 · 24.
class AppSpacing {
  const AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

/// Radius tokens: card 12px · button 10px.
class AppRadius {
  const AppRadius._();

  static const card = 12.0;
  static const button = 10.0;
}

/// Layout bounds — keeps content readable on viewports wider than a phone
/// (e.g. a resized browser window) instead of stretching edge-to-edge.
class AppLayout {
  const AppLayout._();

  static const maxContentWidth = 480.0;
  static const splitAmountFieldWidth = 120.0;

  /// Cap on a trailing amount/value in a Row next to an Expanded label —
  /// see TrailingAmountText, which shrinks the value to fit within this
  /// width (via FittedBox) rather than ellipsizing it, so the sibling label
  /// always gets the rest of the row without either widget overflowing.
  static const trailingValueMaxWidth = 120.0;
}
