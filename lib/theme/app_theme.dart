import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uygulama genelinde kullanılan ortak tema öğeleri.
///
/// Amaç: farklı ekranlarda birbirinden bağımsız gelişmiş gölge/font/buton
/// stillerini tek bir yerden yönetip tutarlı, "premium" bir görünüm
/// sağlamak. Yeni ekran eklerken bu dosyadaki yardımcıları kullan.
class AppTheme {
  /// main.dart -> MaterialApp.router(theme: AppTheme.themeData) şeklinde
  /// uygulanır. Sadece font ailesini global olarak değiştirir; ekranlardaki
  /// açık (explicit) fontSize/fontWeight/color değerlerine ya da mevcut
  /// renk/parlaklık ayarlarına dokunmaz — bu yüzden mevcut layout'ları
  /// bozma riski yoktur. (Tüm uygulamayı koyu temaya taşımak istersen bu
  /// ayrı, kapsamlı bir adım — o zaman burada brightness/colorScheme de
  /// güncellenir.)
  static ThemeData get themeData {
    return ThemeData(
      fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
    );
  }

  /// Başlıklar / logo tipi metinler için (SPY, ekran başlıkları vb.)
  static TextStyle heading({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w800,
    Color color = Colors.white,
    double? letterSpacing,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
}

/// Tüm kartlarda kullanılacak tutarlı gölge/elevation sistemi.
///
/// Şu ana kadar bazı kartlarda BoxShadow vardı, bazılarında hiç yoktu.
/// Bundan sonra her kart için bu iki fonksiyondan birini kullan:
/// - AppShadows.soft(...)  → düşük vurgu, arka plan kartları için
/// - AppShadows.glow(...)  → öne çıkan / seçili öğeler, CTA'lar için
class AppShadows {
  static List<BoxShadow> soft([Color color = Colors.black]) => [
    BoxShadow(
      color: color.withOpacity(0.18),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glow(Color accentColor) => [
    BoxShadow(
      color: accentColor.withOpacity(0.35),
      blurRadius: 24,
      spreadRadius: 1,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

/// Tüm ana CTA (Devam Et, Başlat, Onayla vb.) butonları için tek, tutarlı
/// bileşen. Gradient arkaplan + glow gölge + standart border-radius.
///
/// Kullanım:
/// PremiumButton(
///   label: 'Devam Et',
///   icon: Icons.play_arrow_rounded,
///   colors: const [Color(0xFFE91E63), Color(0xFF9C27B0)],
///   onPressed: () {...},
/// )
class PremiumButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final List<Color> colors;
  final VoidCallback? onPressed;
  final double height;

  const PremiumButton({
    super.key,
    required this.label,
    required this.colors,
    required this.onPressed,
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDisabled
              ? [Colors.grey.shade600, Colors.grey.shade700]
              : colors,
        ),
        boxShadow: isDisabled ? [] : AppShadows.glow(colors.first),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: AppTheme.heading(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}