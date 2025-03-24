import 'package:flutter/material.dart';

mixin NotificationUtils {
  static void showErrorOnContext(BuildContext context, String message, {Duration? duration}) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration ?? const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: scaffoldMessenger.hideCurrentSnackBar,
        ),
      ),
    );
  }

  static void showError(BuildContext? context, String message, {Duration? duration}) {
    if (context == null) {
      return;
    }

    showErrorOnContext(context, message, duration: duration);
  }

  static void showSuccessOnContext(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccess(BuildContext? context, String message, {Duration? duration}) {
    if (context == null) {
      return;
    }

    showSuccessOnContext(context, message, duration: duration);
  }

  static void showInfoOnContext(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext? context, String message, {Duration? duration}) {
    if (context == null) {
      return;
    }

    showInfoOnContext(context, message, duration: duration);
  }

  static void showWarningOnContext(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: duration ?? const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showWarning(BuildContext? context, String message, {Duration? duration}) {
    if (context == null) {
      return;
    }

    showWarningOnContext(context, message, duration: duration);
  }
}
