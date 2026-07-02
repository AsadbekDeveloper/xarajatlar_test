import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// "Oladi" (positive) / "beradi" (negative) balance colors. These aren't
/// part of Material's semantic ColorScheme, so they're exposed via a
/// ThemeExtension — keeping `Theme.of(context)` the single source of color
/// for every widget, with no hardcoded `Colors.*` at call sites.
@immutable
class LedgerColors extends ThemeExtension<LedgerColors> {
  const LedgerColors({required this.positive, required this.negative});

  final Color positive;
  final Color negative;

  static const light = LedgerColors(
    positive: Color(0xFF16A34A),
    negative: Color(0xFFDC2626),
  );

  @override
  LedgerColors copyWith({Color? positive, Color? negative}) => LedgerColors(
    positive: positive ?? this.positive,
    negative: negative ?? this.negative,
  );

  @override
  LedgerColors lerp(ThemeExtension<LedgerColors>? other, double t) {
    if (other is! LedgerColors) return this;
    return LedgerColors(
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
    );
  }
}

extension LedgerThemeContext on BuildContext {
  LedgerColors get ledgerColors => Theme.of(this).extension<LedgerColors>()!;
}

extension LedgerColorsSign on LedgerColors {
  /// Picks [positive]/[negative] by the sign of [value], falling back to
  /// [zero] — the "oladi/beradi" color rule for a signed balance.
  Color forSign(int value, {required Color zero}) {
    if (value > 0) return positive;
    if (value < 0) return negative;
    return zero;
  }
}

class AppTheme {
  const AppTheme._();

  static const _primary = Color(0xFF2563EB);
  static const _scaffoldBackground = Color(0xFFF7F8FA);
  static const _surface = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF111827);
  static const _textSecondary = Color(0xFF6B7280);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      primary: _primary,
      surface: _surface,
      onSurface: _textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _scaffoldBackground,
      extensions: const [LedgerColors.light],
      textTheme: const TextTheme(
        // sarlavha (title)
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _textPrimary,
        ),
        // ism (name)
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        // asosiy (body)
        bodyMedium: TextStyle(fontSize: 14, color: _textPrimary),
        // izoh (caption)
        bodySmall: TextStyle(fontSize: 12, color: _textSecondary),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _scaffoldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: _textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
