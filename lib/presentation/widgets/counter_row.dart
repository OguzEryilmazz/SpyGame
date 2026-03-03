import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Mirrors Kotlin SetUpScreenComponents.kt → CounterRow composable.
///
/// Renders a pill-shaped row with [−] value [+] controls.
/// [suffix] appends a string after the number (e.g. " dk").
class CounterRow extends StatelessWidget {
  const CounterRow({
    super.key,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
    this.suffix = '',
    this.canDecrease = true,
    this.canIncrease = true,
  });

  final int value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final String suffix;
  final bool canDecrease;
  final bool canIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.counterBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Decrease button ───────────────────────────────────────────
          _CircleButton(
            icon: Icons.remove,
            onTap: canDecrease ? onDecrease : null,
          ),

          // ── Value display ─────────────────────────────────────────────
          Text(
            '$value$suffix',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          // ── Increase button ───────────────────────────────────────────
          _CircleButton(
            icon: Icons.add,
            onTap: canIncrease ? onIncrease : null,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? AppColors.iconBtnBg : AppColors.counterBg,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
          size: 22,
        ),
      ),
    );
  }
}
