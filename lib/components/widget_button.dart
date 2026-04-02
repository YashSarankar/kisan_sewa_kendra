import 'package:flutter/material.dart';

class WidgetButton extends StatelessWidget {
  final void Function()? onTap;
  final Widget child;
  const WidgetButton({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: child,
    );
  }
}
