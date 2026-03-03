import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Mirrors Kotlin SetUpScreenComponents.kt → SettingItem composable.
///
/// Shows an icon box on the left, title + subtitle in the middle,
/// and an optional [child] widget below the whole row (used for CounterRow).
class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.onIconTap,
    this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  /// When set, the icon box becomes tappable (used for the hints toggle).
  final VoidCallback? onIconTap;

  /// Content rendered below the header row (e.g. CounterRow).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // ── Icon box ──────────────────────────────────────────────────
            GestureDetector(
              onTap: onIconTap,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            ),

            const SizedBox(width: 16),

            // ── Labels ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (child != null) ...[
          const SizedBox(height: 16),
          child!,
        ],
      ],
    );
  }
}
