import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Ana logo animasyonu ──
  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // ── Işık halkası (sonar efekti) ──
  late AnimationController _sonarCtrl;
  late Animation<double> _sonarRadius;
  late Animation<double> _sonarOpacity;

  // ── Başlık metni ──
  late AnimationController _titleCtrl;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;

  // ── Alt tagline ──
  late AnimationController _tagCtrl;
  late Animation<double> _tagOpacity;

  // ── Parçacıklar ──
  late AnimationController _particleCtrl;

  // ── Geçiş fade ──
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeOut;

  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _buildParticles();

    // Logo: 0 → 1.15 → 1.0 scale, fade in
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.18)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 70),
      TweenSequenceItem(
          tween: Tween(begin: 1.18, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30),
    ]).animate(_logoCtrl);
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    // Sonar: sürekli tekrar
    _sonarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _sonarRadius = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sonarCtrl, curve: Curves.easeOut),
    );
    _sonarOpacity = Tween(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _sonarCtrl, curve: Curves.easeIn),
    );

    // Başlık: aşağıdan yukarı + fade
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleCtrl, curve: Curves.easeIn),
    );
    _titleSlide = Tween(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutCubic));

    // Tagline
    _tagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _tagOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tagCtrl, curve: Curves.easeIn),
    );

    // Parçacıklar
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Fade out (ekranı terk ederken)
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeOut = Tween(begin: 0.0, end: 1.0).animate(_fadeCtrl);

    _runSequence();
  }

  void _buildParticles() {
    for (int i = 0; i < 22; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 3 + 1,
        speed: _rng.nextDouble() * 0.3 + 0.1,
        phase: _rng.nextDouble(),
      ));
    }
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _titleCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _tagCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 2000));

    // Nereye gidileceğini belirle
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('tutorial_seen') ?? false;

    await _fadeCtrl.forward();

    if (!mounted) return;
    if (seen) {
      context.go('/');
    } else {
      await prefs.setBool('tutorial_seen', true);
      context.go('/tutorial');
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _sonarCtrl.dispose();
    _titleCtrl.dispose();
    _tagCtrl.dispose();
    _particleCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _fadeOut,
        builder: (_, child) => Opacity(
          opacity: 1.0 - _fadeOut.value,
          child: child,
        ),
        child: Stack(
          children: [
            // ── Arka plan gradyanı ──
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.2),
                    radius: 1.1,
                    colors: [
                      Color(0xFF1a0a2e),
                      Color(0xFF0d0d1a),
                      Colors.black,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // ── Grid çizgileri (gözetleme odası hissi) ──
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),

            // ── Yüzen parçacıklar ──
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _particleCtrl.value,
                  ),
                ),
              ),
            ),

            // ── Sonar halkaları ──
            Center(
              child: AnimatedBuilder(
                animation: _sonarCtrl,
                builder: (_, __) {
                  return CustomPaint(
                    size: Size(size.width * 0.9, size.width * 0.9),
                    painter: _SonarPainter(
                      radius: _sonarRadius.value,
                      opacity: _sonarOpacity.value,
                    ),
                  );
                },
              ),
            ),

            // ── Ana içerik ──
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo dairesi
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: _LogoBadge(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // SPY başlığı
                  AnimatedBuilder(
                    animation: _titleCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: const _TitleText(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  AnimatedBuilder(
                    animation: _tagCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _tagOpacity,
                      child: const _TaglineText(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Alt köşe ──
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _tagCtrl,
                builder: (_, __) => FadeTransition(
                  opacity: _tagOpacity,
                  child: const _BottomLabel(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOGO BADGE
// ---------------------------------------------------------------------------

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            Color(0xFF6C00FF),
            Color(0xFFFF3CAC),
            Color(0xFF784BA0),
            Color(0xFF6C00FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C00FF).withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFFFF3CAC).withOpacity(0.3),
            blurRadius: 60,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0d0d1a),
        ),
        child: Center(
          child: Image.asset(
            'assets/my_imposter.png',
            width: 70,
            height: 70,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.person_off_rounded,
              size: 56,
              color: Color(0xFFFF3CAC),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TITLE TEXT
// ---------------------------------------------------------------------------

class _TitleText extends StatelessWidget {
  const _TitleText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFF3CAC),
              Color(0xFFFFFFFF),
              Color(0xFF784BA0),
            ],
          ).createShader(bounds),
          child: const Text(
            'SPY',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 20,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 1.5,
              color: const Color(0xFFFF3CAC).withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            const Text(
              'HAİNİ BUL',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF3CAC),
                letterSpacing: 6,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 1.5,
              color: const Color(0xFFFF3CAC).withOpacity(0.6),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TAGLINE
// ---------------------------------------------------------------------------

class _TaglineText extends StatelessWidget {
  const _TaglineText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Kim güvenilir ki?',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.45),
        letterSpacing: 1.5,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BOTTOM LABEL
// ---------------------------------------------------------------------------

class _BottomLabel extends StatelessWidget {
  const _BottomLabel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: i == 1 ? 20 : 6,
              height: 4,
              decoration: BoxDecoration(
                color: i == 1
                    ? const Color(0xFFFF3CAC)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 12),
        Text(
          'YÜKLENIYOR',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 4,
            color: Colors.white.withOpacity(0.25),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SONAR PAINTER
// ---------------------------------------------------------------------------

class _SonarPainter extends CustomPainter {
  final double radius;
  final double opacity;

  _SonarPainter({required this.radius, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final phase = (radius - i * 0.25).clamp(0.0, 1.0);
      if (phase <= 0) continue;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFF6C00FF)
            .withOpacity(opacity * (1 - i * 0.3) * phase);

      canvas.drawCircle(center, maxR * phase, paint);
    }
  }

  @override
  bool shouldRepaint(_SonarPainter old) =>
      old.radius != radius || old.opacity != opacity;
}

// ---------------------------------------------------------------------------
// GRID PAINTER
// ---------------------------------------------------------------------------

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}

// ---------------------------------------------------------------------------
// PARTICLE SYSTEM
// ---------------------------------------------------------------------------

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final y = (p.y - t * 0.4) % 1.0;
      final opacity = (sin(t * pi) * 0.5).clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.size,
        Paint()
          ..color = const Color(0xFFFF3CAC).withOpacity(opacity * 0.4),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}