import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Brand colours (mirrors Kotlin Color.kt) ───────────────────────────────────

class AppColors {
  AppColors._();

  // Gradient stops used on every screen background
  static const Color gradientStart = Color(0xFFE91E63); // Pink
  static const Color gradientMid = Color(0xFF9C27B0);   // Purple
  static const Color gradientEnd = Color(0xFFF44336);   // Red

  // Accent / semantic colours
  static const Color orange = Color(0xFFFF9800);
  static const Color blue = Color(0xFF2196F3);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);
  static const Color pink = Color(0xFFE91E63);
  static const Color purple = Color(0xFF9C27B0);

  // Card / surface overlays (white with opacity)
  static const Color cardSurface = Color(0x1AFFFFFF);    // 10 % white
  static const Color counterBg = Color(0x33FFFFFF);      // 20 % white
  static const Color iconBtnBg = Color(0x4DFFFFFF);      // 30 % white
  static const Color hintCardBg = Color(0x264CAF50);     // 15 % green

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xCCFFFFFF);  // 80 % white
  static const Color textMuted = Color(0xB3FFFFFF);      // 70 % white
}

// ── Gradient helper ───────────────────────────────────────────────────────────

class AppGradients {
  AppGradients._();

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.gradientStart,
      AppColors.gradientMid,
      AppColors.gradientEnd,
    ],
  );

  static const LinearGradient bottomScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x4D000000)],
  );
}

// ── Theme ─────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.pink,
        brightness: Brightness.dark,
      ),
      // Keep system UI transparent so gradient shows through
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
    );
  }
}
