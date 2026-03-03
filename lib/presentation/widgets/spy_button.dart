import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Primary action button used on every screen's bottom bar.
///
/// Mirrors the white Button with pink icon/text from Kotlin SetupScreen.
class SpyButton extends StatelessWidget {
  const SpyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.backgroundColor = Colors.white,
    this.foregroundColor = AppColors.pink,
    this.borderColor,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: Colors.white54,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 2)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: foregroundColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
