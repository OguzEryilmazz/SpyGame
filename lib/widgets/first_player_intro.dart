import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// İLK OYUNCU İÇİN KISA TANITIM ANİMASYONU
// ---------------------------------------------------------------------------

enum _StepVisual { icon, swipeDemo, doubleTapDemo, voteDemo, winDemo }

class _IntroStep {
  final IconData icon;
  final String title;
  final String description;
  final _StepVisual visual;
  final Duration duration;

  const _IntroStep({
    required this.icon,
    required this.title,
    required this.description,
    this.visual = _StepVisual.icon,
    this.duration = const Duration(milliseconds: 2200),
  });
}

// ── YENİ: Genişletilmiş ve daha öğretici adımlar ──
const List<_IntroStep> _kIntroSteps = [
  _IntroStep(
    icon: Icons.groups_rounded,
    title: 'Sıra Sende',
    description: 'Telefon herkese sırayla gelecek.',
    duration: Duration(milliseconds: 2500),
  ),
  _IntroStep(
    icon: Icons.swipe_up_alt_rounded,
    title: 'Kartını Gör',
    description: 'Paneli yukarı kaydır ve sırrını öğren.',
    visual: _StepVisual.swipeDemo, // Eski phoneDemo
    duration: Duration(milliseconds: 3600),
  ),
  _IntroStep(
    icon: Icons.touch_app_rounded,
    title: 'Çift Tıkla',
    description: 'Öğrendikten sonra çift tıklayarak telefonu devret.',
    visual: _StepVisual.doubleTapDemo, // YENİ EKLENDİ
    duration: Duration(milliseconds: 3600),
  ),
  _IntroStep(
    icon: Icons.theater_comedy_rounded,
    title: 'Biri Imposter',
    description: 'Kelimeyi bilmeyen tek kişiyi sorularla arayın.',
    duration: Duration(milliseconds: 3000),
  ),
  _IntroStep(
    icon: Icons.how_to_vote_rounded,
    title: 'Oylama Zamanı',
    description: 'Süre bitince en şüphelendiğiniz kişiyi oylayın.',
    visual: _StepVisual.voteDemo,
    duration: Duration(milliseconds: 3200),
  ),
  _IntroStep(
    icon: Icons.emoji_events_rounded,
    title: 'Bul ve Kazan!',
    description: 'Imposter\'ı bulursanız takım, bulamazsanız o kazanır.',
    visual: _StepVisual.winDemo, // YENİ EKLENDİ
    duration: Duration(milliseconds: 3200),
  ),
];

class FirstPlayerIntro extends StatefulWidget {
  final VoidCallback onFinished;
  final Color accentColor;

  const FirstPlayerIntro({
    super.key,
    required this.onFinished,
    required this.accentColor,
  });

  @override
  State<FirstPlayerIntro> createState() => _FirstPlayerIntroState();
}

class _FirstPlayerIntroState extends State<FirstPlayerIntro>
    with TickerProviderStateMixin {
  int _stepIndex = 0;
  Timer? _stepTimer;
  bool _closing = false;

  // ── 1. Yukarı Kaydırma Demosu (Swipe) ──
  late final AnimationController _swipeCtrl;
  late final Animation<double> _panelHeight;
  late final Animation<double> _swipeFingerFade;
  late final Animation<double> _textFade;

  // ── 2. Çift Tıklama Demosu (Double Tap) ──
  late final AnimationController _doubleTapCtrl;
  late final Animation<double> _dtFingerFade;
  late final Animation<double> _dtFingerScale;
  late final Animation<Offset> _dtCardSlide;

  // ── 3. Oylama Demosu (Vote) ──
  late final AnimationController _voteCtrl;
  late final Animation<double> _voteHighlight;
  late final Animation<double> _voteCheckScale;

  // ── 4. Kazanma Demosu (Win) ──
  late final AnimationController _winCtrl;
  late final Animation<double> _winScale;

  @override
  void initState() {
    super.initState();

    // -- Kaydırma Animasyonu Kurulumu --
    _swipeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _panelHeight = CurvedAnimation(
      parent: _swipeCtrl,
      curve: const Interval(0.10, 0.55, curve: Curves.easeOutCubic),
    );
    _textFade = CurvedAnimation(
      parent: _swipeCtrl,
      curve: const Interval(0.45, 0.62, curve: Curves.easeIn),
    );
    _swipeFingerFade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 8),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 72),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_swipeCtrl);

    // -- YENİ: Çift Tıklama Animasyonu Kurulumu --
    _doubleTapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _dtFingerFade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_doubleTapCtrl);

    // Parmağın iki kez hızlıca küçülüp büyümesi (Tıklama efekti)
    _dtFingerScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.75), weight: 5), // 1. Tık in
      TweenSequenceItem(tween: Tween(begin: 0.75, end: 1.0), weight: 5), // 1. Tık out
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.75), weight: 5), // 2. Tık in
      TweenSequenceItem(tween: Tween(begin: 0.75, end: 1.0), weight: 5), // 2. Tık out
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
    ]).animate(_doubleTapCtrl);

    // Kartın sola kayıp sağdan yenisinin gelmesi
    _dtCardSlide = TweenSequence<Offset>([
      TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 45),
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(-1.5, 0.0))
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 15),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(1.5, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 15),
      TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 25),
    ]).animate(_doubleTapCtrl);

    // -- Oylama Animasyonu Kurulumu --
    _voteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
    _voteHighlight = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
          weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
          weight: 15),
    ]).animate(_voteCtrl);
    _voteCheckScale = CurvedAnimation(
      parent: _voteCtrl,
      curve: const Interval(0.45, 0.62, curve: Curves.easeOutBack),
    );

    // -- YENİ: Kazanma (Kupa) Animasyonu Kurulumu --
    _winCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _winScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _winCtrl, curve: Curves.easeInOut),
    );

    _scheduleNextStep();
  }

  void _scheduleNextStep() {
    _stepTimer = Timer(_kIntroSteps[_stepIndex].duration, () {
      if (!mounted) return;
      if (_stepIndex < _kIntroSteps.length - 1) {
        setState(() => _stepIndex++);
        _scheduleNextStep();
      } else {
        _finish();
      }
    });
  }

  void _finish() async {
    if (_closing) return;
    _closing = true;
    _stepTimer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_seen', true);

    widget.onFinished();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _swipeCtrl.dispose();
    _doubleTapCtrl.dispose();
    _voteCtrl.dispose();
    _winCtrl.dispose();
    super.dispose();
  }

  Widget _phoneFrame({required Widget child}) {
    return Container(
      width: 108,
      height: 190,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              top: 6,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 28,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeDemo() {
    const maxPanelH = 96.0;
    return _phoneFrame(
      child: AnimatedBuilder(
        animation: _swipeCtrl,
        builder: (_, __) {
          final panelH = maxPanelH * _panelHeight.value;
          final fingerBottom = 14 + (maxPanelH - 6) * _panelHeight.value;
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(color: widget.accentColor),
              Container(
                width: double.infinity,
                height: panelH,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                alignment: Alignment.center,
                child: Opacity(
                  opacity: _textFade.value,
                  child: const Text(
                    'IMPOSTER',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: fingerBottom,
                child: Opacity(
                  opacity: _swipeFingerFade.value,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // YENİ: Çift Tıklama Animasyonu
  Widget _buildDoubleTapDemo() {
    return _phoneFrame(
      child: AnimatedBuilder(
        animation: _doubleTapCtrl,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Kaybolan/Gelen Oyuncu Kartı
              SlideTransition(
                position: _dtCardSlide,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: widget.accentColor,
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              // Dokunan Parmak
              Positioned(
                bottom: 40,
                child: Opacity(
                  opacity: _dtFingerFade.value,
                  child: Transform.scale(
                    scale: _dtFingerScale.value,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVoteDemo() {
    return _phoneFrame(
      child: AnimatedBuilder(
        animation: _voteCtrl,
        builder: (_, __) {
          return Container(
            color: const Color(0xFFF4F4F6),
            padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
            child: Column(
              children: List.generate(3, (i) {
                final isSelected = i == 1;
                final glow = isSelected ? _voteHighlight.value : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    decoration: BoxDecoration(
                      color: Color.lerp(Colors.white, widget.accentColor.withOpacity(0.18), glow),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.accentColor.withOpacity(glow),
                        width: 1.4,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 15,
                          height: 15,
                          child: isSelected
                              ? Opacity(
                            opacity: glow,
                            child: Transform.scale(
                              scale: _voteCheckScale.value,
                              child: Icon(Icons.check_circle_rounded, size: 15, color: widget.accentColor),
                            ),
                          )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  // YENİ: Kazanma Animasyonu
  Widget _buildWinDemo() {
    return AnimatedBuilder(
      animation: _winCtrl,
      builder: (_, __) {
        return Transform.scale(
          scale: _winScale.value,
          child: Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFD54F).withOpacity(0.4),
                  Colors.transparent
                ],
                stops: const [0.3, 1.0],
              ),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 64,
              color: Color(0xFFFFC107), // Altın rengi
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisual(_IntroStep step) {
    switch (step.visual) {
      case _StepVisual.swipeDemo:
        return _buildSwipeDemo();
      case _StepVisual.doubleTapDemo:
        return _buildDoubleTapDemo();
      case _StepVisual.voteDemo:
        return _buildVoteDemo();
      case _StepVisual.winDemo:
        return _buildWinDemo();
      case _StepVisual.icon:
        return Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: widget.accentColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(step.icon, size: 42, color: widget.accentColor),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _kIntroSteps[_stepIndex];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _finish,
      child: Container(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.82,
            heightFactor: 0.66, // Biraz daha alan açmak için hafifçe artırıldı
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              elevation: 16,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.92, end: 1.0).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Column(
                          key: ValueKey(_stepIndex),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildVisual(step),
                            const SizedBox(height: 18),
                            Text(
                              step.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF222222),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              step.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.black.withOpacity(0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Adım noktaları
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_kIntroSteps.length, (i) {
                        final active = i == _stepIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: active
                                ? widget.accentColor
                                : widget.accentColor.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Atla',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}