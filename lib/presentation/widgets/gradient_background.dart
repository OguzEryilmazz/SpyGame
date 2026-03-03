import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Wraps its [child] in the standard pink→purple→red gradient background
/// used on every screen. Mirrors the Box+Brush.verticalGradient from Kotlin.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(context).style.copyWith(
              decoration: TextDecoration.none,
            ),
        child: child,
      ),
    );
  }
}
