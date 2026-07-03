/// Spacing scale from the design tokens: 4 · 8 · 12 · 16 · 24.
class AppSpacing {
  const AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

/// Radius tokens: card 12px · button 10px · sheet 24px.
class AppRadius {
  const AppRadius._();

  static const card = 12.0;
  static const button = 10.0;
  static const sheet = 24.0;
}

/// Layout bounds — keeps content readable on viewports wider than a phone
/// (e.g. a resized browser window) instead of stretching edge-to-edge.
class AppLayout {
  const AppLayout._();

  static const maxContentWidth = 480.0;
  static const splitAmountFieldWidth = 120.0;

  /// Max width for a trailing amount value in a Row — see [TrailingAmountText].
  static const trailingValueMaxWidth = 120.0;
}
