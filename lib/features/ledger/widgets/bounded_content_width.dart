import 'package:flutter/material.dart';

import '../../../core/app_spacing.dart';

/// Centers [child] and caps it at [AppLayout.maxContentWidth] so this
/// mobile-first design doesn't stretch edge-to-edge on a wide/resized
/// browser window. Shared by [ScreenCard] and the add/edit expense sheet.
class BoundedContentWidth extends StatelessWidget {
  const BoundedContentWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
        child: child,
      ),
    );
  }
}
