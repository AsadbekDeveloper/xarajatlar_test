import 'package:flutter/material.dart';

import '../../../core/app_spacing.dart';

/// A rounded, pure-white panel — the brightest tier of the app's 3-step
/// surface hierarchy (scaffold darkest → card middle → this, brightest).
class TintedContainer extends StatelessWidget {
  const TintedContainer({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
    ),
    child: child,
  );
}
