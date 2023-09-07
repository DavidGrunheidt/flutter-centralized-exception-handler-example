import 'package:flutter/material.dart';

class AlertIgnoreBackButton extends StatelessWidget {
  final bool dismissable;
  final Widget child;

  const AlertIgnoreBackButton({
    super.key,
    required this.dismissable,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return dismissable ? child : WillPopScope(onWillPop: () async => false, child: child);
  }
}
