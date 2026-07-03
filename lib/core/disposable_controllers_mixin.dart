import 'package:flutter/widgets.dart';

/// Tracks every [TextEditingController] created via [manageController] and
/// disposes them automatically, so a `State` can't forget to dispose one —
/// the single biggest source of controller leaks in ad hoc widget code.
mixin DisposableControllersMixin<T extends StatefulWidget> on State<T> {
  final List<TextEditingController> _managedControllers = [];

  TextEditingController manageController([String text = '']) {
    final controller = TextEditingController(text: text);
    _managedControllers.add(controller);
    return controller;
  }

  /// Disposes a single controller ahead of the widget's own disposal — for
  /// controllers whose lifetime is shorter than the widget's (e.g. one per
  /// dynamically added/removed list item).
  void disposeController(TextEditingController controller) {
    _managedControllers.remove(controller);
    controller.dispose();
  }

  @override
  void dispose() {
    for (final controller in _managedControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
