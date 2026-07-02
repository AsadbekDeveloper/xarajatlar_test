import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Single place feature code routes user feedback through — never call
/// `ScaffoldMessenger` directly elsewhere.
extension ContextFeedback on BuildContext {
  void showError(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: ledgerColors.negative),
      );
  }

  void showSuccessToast(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }
}
