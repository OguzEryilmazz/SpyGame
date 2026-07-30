import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _Slide {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _Slide(this.icon, this.color, this.title, this.desc);
}

// Renkleri daha soft ve "premium" pastel/neon tonlarına çektik
const _slides = [
  _Slide(Icons.theater_comedy_rounded, Color(0xFFF9D371), 'Biri Imposter',
      'Herkes kelimeyi görür, sadece Imposter göremez.'),
  _Slide(Icons.smartphone_rounded, Color(0xFF5DD9C1), 'Sırayla Bak',
      'Kartını gör, kimseye gösterme, sıradakine ver.'),
  _Slide(Icons.forum_rounded, Color(0xFF8CEE93), 'Sor, Oyla',
      'Sorular sorup Imposter\'ı bulmaya çalışın, süre bitince oylayın.'),
  _Slide(Icons.emoji_events_rounded, Color(0xFFFF8A65), 'Kazanma',
      'Imposter bulunursa diğerleri, bulunmazsa Imposter kazanır.'),
];

class _TutorialScreenState extends State<TutorialScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  bool _dontShowAgain = false;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_seen', _dontShowAgain);
    await prefs.setBool('show_every_10', !_dontShowAgain);

    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;
    final activeColor = _slides[_page].color;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0E), // Derin, premium siyah
      body: Stack(
        children: [
          // 1. Arka Plan: Yumuşak Ortam Işığı (Ambient Glow)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            top: MediaQuery.of(context).size.height * 0.15,
            left: _page % 2 == 0 ? -100 : 100, // Sayfaya göre sağa/sola kayar
            right: _page % 2 == 0 ? 100 : -100,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              height: MediaQuery.of(context).size.width * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    activeColor.withOpacity(0.15), // Çok hafif bir renk yansıması
                    Colors.transparent,
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),

          // 2. Ana İçerik
          SafeArea(
            child: Column(
              children: [
                // Üst Bar: Atla Butonu
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white54,
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      child: const Text('Atla'),
                    ),
                  ),
                ),

                // Orta Alan: Sayfalar
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _slides.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) {
                      final s = _slides[i];
                      return TweenAnimationBuilder<double>(
                        key: ValueKey(i),
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, child) => Transform.scale(
                          scale: 0.9 + 0.1 * v, // Daha yumuşak büyüme
                          child: Opacity(opacity: v.clamp(0, 1), child: child),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // İkon: Buzlu Cam (Glassmorphism) Efektli Kutu
                              ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: s.color.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(
                                        color: s.color.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(s.icon, size: 54, color: s.color),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),

                              // Başlık
                              Text(
                                s.title,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5, // Harf arası boşluk (Premium hissi artırır)
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Açıklama
                              Text(
                                s.desc,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Alt Kısım: Noktalar, Özel Checkbox ve Buton
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                  child: Column(
                    children: [
                      // Sayfa Noktaları (Pagination)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (i) {
                          final active = i == _page;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: active ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? activeColor
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Özel Tasarım Checkbox (Klasik Android görünümü yerine)
                      GestureDetector(
                        onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(scale: animation, child: child),
                                child: Icon(
                                  _dontShowAgain
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  key: ValueKey(_dontShowAgain),
                                  color: _dontShowAgain
                                      ? activeColor
                                      : Colors.white.withOpacity(0.4),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Bir daha gösterme',
                                style: TextStyle(
                                  color: _dontShowAgain
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Modern, Kenarları Tam Yuvarlak (Pill) Buton
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLast
                              ? _finish
                              : () => _pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Zıtlık için beyaz buton
                            foregroundColor: Colors.black, // Üzerindeki yazı siyah
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            isLast ? 'Oyuna Başla' : 'İleri',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}