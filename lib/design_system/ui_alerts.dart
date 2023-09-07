import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'alert_ignore_back_button.dart';

void showSnackbar({
  required BuildContext context,
  required String content,
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      duration: duration ?? const Duration(seconds: 3),
    ),
  );
}

void showUnderDevelopmentSnackbar(BuildContext context) {
  return showSnackbar(context: context, content: 'Under development');
}

Future<bool?> showAppDialog({
  required BuildContext context,
  Widget? content,
  bool barrierDismissible = true,
  bool overrideOnConfirm = false,
  String? title,
  String? confirmText,
  String? cancelText,
  RouteSettings? routeSettings,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) async {
  if (Platform.isIOS) {
    return showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      routeSettings: routeSettings,
      builder: (context) {
        final dialog = CupertinoAlertDialog(
          title: title == null ? null : Text(title),
          content: content,
          actions: <Widget>[
            if (confirmText != null)
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: overrideOnConfirm
                    ? onConfirm
                    : () {
                        Navigator.pop(context, true);
                        onConfirm?.call();
                      },
                child: Text(confirmText),
              ),
            if (cancelText != null)
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context, false);
                  onCancel?.call();
                },
                child: Text(cancelText),
              ),
          ],
        );

        return AlertIgnoreBackButton(dismissable: barrierDismissible, child: dialog);
      },
    );
  }

  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    routeSettings: routeSettings,
    builder: (context) {
      final dialog = AlertDialog(
        title: title == null ? null : Text(title),
        content: content,
        actions: <Widget>[
          if (cancelText != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
                onCancel?.call();
              },
              child: Text(cancelText.toUpperCase()),
            ),
          if (confirmText != null)
            TextButton(
              onPressed: overrideOnConfirm
                  ? onConfirm
                  : () {
                      Navigator.pop(context, true);
                      onConfirm?.call();
                    },
              child: Text(confirmText.toUpperCase()),
            ),
        ],
      );

      return AlertIgnoreBackButton(dismissable: barrierDismissible, child: dialog);
    },
  );
}
