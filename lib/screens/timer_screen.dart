import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../ads/ad_providers.dart';
import 'category_screen.dart'; // gameStateProvider

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with TickerProviderStateMixin {
  late int _timeLeft;
  late int _totalSeconds;
  bool _isRunning = true;
  bool _isFinished = false;
  Timer? _timer;

  // Pulse animasyonu (son 10 saniye)
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Glow animasyonu
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    final gs = ref.read(gameStateProvider);
    _totalSeconds = (gs?.durationMinutes ?? 5) * 60;
    _timeLeft = _totalSeconds;

    // Ekranı açık tut
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    WakelockPlus.enable(); // pubspec'e wakelock_plus ekle — yoksa sil

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.6)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    _disableWakelock();
    super.dispose();
  }

  void _disableWakelock() {
    try {
      WakelockPlus.disable();
    } catch (_) {}
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        t.cancel();
        setState(() {
          _isRunning = false;
          _isFinished = true;
        });
        _vibrate();
      }
    });
  }

  void _togglePause() {
    if (_isFinished) return;
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _startTimer();
      setState(() => _isRunning = true);
    }
  }

  void _restart() {
    _timer?.cancel();
    setState(() {
      _timeLeft = _totalSeconds;
      _isRunning = true;
      _isFinished = false;
    });
    _startTimer();
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isFinished = true;
      _timeLeft = 0;
    });
    _vibrate();
  }

  Future<void> _vibrate() async {
    try {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  String get _timeString {
    final m = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_timeLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Renkler
  Color get _primaryColor {
    if (_isFinished) return const Color(0xFF6B7280);
    if (_timeLeft <= 10) return const Color(0xFFEF4444);
    if (_timeLeft <= 30) return const Color(0xFFFBBF24);
    return const Color(0xFF3B82F6);
  }

  Color get _secondaryColor {
    if (_isFinished) return const Color(0xFF9CA3AF);
    if (_timeLeft <= 10) return const Color(0xFFFCA5A5);
    if (_timeLeft <= 30) return const Color(0xFFFDE68A);
    return const Color(0xFF60A5FA);
  }

  Color get _bgColor {
    if (_isFinished) return const Color(0xFF1a1625);
    if (_timeLeft <= 30) return const Color(0xFF1f1416);
    return const Color(0xFF0a0e27);
  }

  @override
  Widget build(BuildContext context) {
    final gs = ref.watch(gameStateProvider);
    final playerCount = gs?.players.length ?? 0;
    final progress = _totalSeconds > 0 ? _timeLeft / _totalSeconds : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.4),
            radius: 1.2,
            colors: [
              _bgColor.withOpacity(0.8),
              _bgColor,
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Glow arka plan ──
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: _GlowPainter(
                  color: _primaryColor,
                  alpha: _glowAnim.value,
                ),
              ),
            ),

            // ── Ana içerik ──
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 48, bottom: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Durum kartı
                    _StatusCard(
                      isFinished: _isFinished,
                      isRunning: _isRunning,
                      primaryColor: _primaryColor,
                    ),

                    const SizedBox(height: 32),

                    // Zamanlayıcı
                    _TimerDial(
                      timeString: _timeString,
                      progress: progress,
                      primaryColor: _primaryColor,
                      secondaryColor: _secondaryColor,
                      isFinished: _isFinished,
                      timeLeft: _timeLeft,
                      pulseAnim: _pulseAnim,
                      isRunning: _isRunning,
                    ),

                    const SizedBox(height: 32),

                    // Kontroller
                    if (_isFinished)
                      _FinishedControls(
                        onVoting: () => context.push('/voting'),
                        onHome: () {
                          ref.read(interstitialAdProvider).showAdWithFrequencyControl(
                            onAdDismissed: () => context.go('/'),
                          );
                        },
                      )
                    else
                      _RunningControls(
                        isRunning: _isRunning,
                        onToggle: _togglePause,
                        onRestart: _restart,
                        onStop: _stop,
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Oyuncu sayısı (sağ üst) ──
            if (!_isFinished)
              Positioned(
                top: MediaQuery.of(context).padding.top +16,
                right: 16,
                child: _PlayerCountBadge(
                  count: playerCount,
                  color: _primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GLOW PAINTER
// ---------------------------------------------------------------------------

class _GlowPainter extends CustomPainter {
  final Color color;
  final double alpha;

  _GlowPainter({required this.color, required this.alpha});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(alpha * 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 3),
        radius: 400,
      ));
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 3), 400, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.alpha != alpha || old.color != color;
}

// ---------------------------------------------------------------------------
// STATUS CARD
// ---------------------------------------------------------------------------

class _StatusCard extends StatelessWidget {
  final bool isFinished;
  final bool isRunning;
  final Color primaryColor;

  const _StatusCard({
    required this.isFinished,
    required this.isRunning,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = isFinished
        ? 'SÜRE BİTTİ!'
        : isRunning
        ? 'OYUN DEVAM EDİYOR'
        : 'DURAKLATILDI';

    final statusColor = isFinished
        ? const Color(0xFFEF4444)
        : isRunning
        ? const Color(0xFF10B981)
        : const Color(0xFFFBBF24);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            statusText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor,
              letterSpacing: 2,
            ),
          ),
          if (!isFinished) ...[
            const SizedBox(height: 8),
            const Text(
              "SPY'I YAKALAYABILECEK MİSİN?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TIMER DIAL
// ---------------------------------------------------------------------------

class _TimerDial extends StatelessWidget {
  final String timeString;
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isFinished;
  final int timeLeft;
  final Animation<double> pulseAnim;
  final bool isRunning;

  const _TimerDial({
    required this.timeString,
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isFinished,
    required this.timeLeft,
    required this.pulseAnim,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    final shouldPulse = timeLeft <= 10 && timeLeft > 0 && isRunning;

    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) {
        final scale = shouldPulse ? pulseAnim.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress ring
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: progress,
                    color: primaryColor.withOpacity(0.6),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                  ),
                ),

                // İç kart
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFinished
                            ? 'BİTTİ'
                            : timeLeft <= 10
                            ? 'ACELE ET!'
                            : 'KALAN SÜRE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor.withOpacity(0.8),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// RUNNING CONTROLS
// ---------------------------------------------------------------------------

class _RunningControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onRestart;
  final VoidCallback onStop;

  const _RunningControls({
    required this.isRunning,
    required this.onToggle,
    required this.onRestart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Duraklat / Başlat
          _FabButton(
            onTap: onToggle,
            color: isRunning
                ? const Color(0xFFFBBF24)
                : const Color(0xFF10B981),
            iconColor: Colors.black,
            icon: isRunning ? Icons.pause : Icons.play_arrow,
          ),

          // Yeniden başlat
          _FabButton(
            onTap: onRestart,
            color: const Color(0xFF3B82F6),
            iconColor: Colors.white,
            icon: Icons.refresh,
          ),

          // Bitir
          _FabButton(
            onTap: onStop,
            color: const Color(0xFFEF4444),
            iconColor: Colors.white,
            icon: Icons.stop,
          ),
        ],
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;
  final IconData icon;

  const _FabButton({
    required this.onTap,
    required this.color,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 36),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FINISHED CONTROLS
// ---------------------------------------------------------------------------

class _FinishedControls extends StatelessWidget {
  final VoidCallback onVoting;
  final VoidCallback onHome;

  const _FinishedControls({
    required this.onVoting,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bilgi kartı
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Oyun bitti! Şimdi SPY'ı bulma zamanı!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Oylama butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton.icon(
              onPressed: onVoting,
              icon: const Icon(Icons.how_to_vote, size: 28),
              label: const Text(
                'OYLAMA BAŞLAT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Ana menü butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: onHome,
              icon: const Icon(Icons.home),
              label: const Text(
                'Ana Menü',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PLAYER COUNT BADGE
// ---------------------------------------------------------------------------

class _PlayerCountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _PlayerCountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}