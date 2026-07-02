import 'package:flutter/material.dart';

import '../../../core/app_spacing.dart';

/// Shared page shell for both ledger screens: a page-edge margin around a
/// white rounded card with its own inner padding, matching the reference
/// design's "Ekran 1" / "Ekran 2" layout.
class ScreenCard extends StatelessWidget {
  const ScreenCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Card(
        child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: child),
      ),
    );
  }
}
