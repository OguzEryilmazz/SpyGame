import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../domain/logic/timer_manager.dart';
import '../../providers/game_provider.dart';

// ── TimerScreen ────────────────────────────────────────────────────────────────

/// Mirrors Kotlin TimerScreen.kt.
///
/// Owns a local [TimerState] driven by a manual 1-second [Timer], not by
/// [TimerManager.startCountdown], so pause/resume can be implemented simply
/// without cancelling and restarting a stream.
///
/// Navigation injected via [onBack] / [onNext] (→ voting screen).
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({
    super.key,
    required this.onBack,
    required this.onNext,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with SingleTickerProviderStateMixin {
  // ── Timer state ────────────────────────────────────────────────────────────
  late int _totalSeconds;
  late int _timeLeft;
  bool _running = true;
  bool _finished = false;

  Timer? _ticker;

  // ── Pulse animation ────────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(gameStateProvider).settings;
    _totalSeconds = settings.durationMinutes * 60;
    _timeLeft = _totalSeconds;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.0).animate(_pulseCtrl);

    WakelockPlus.enable();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseCtrl.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  // ── Ticker logic ───────────────────────────────────────────────────────────

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running || _finished) return;
      if (_timeLeft <= 0) {
        _onTimerFinished();
        return;
      }
      setState(() {
        _timeLeft--;
        _updatePulse();
        if (_timeLeft <= 0) _onTimerFinished();
      });
    });
  }

  void _updatePulse() {
    final level = _timerManager.warningLevelFor(_timeLeft);
    final newDuration = switch (level) {
      WarningLevel.critical => const Duration(milliseconds: 400),
      WarningLevel.warning => const Duration(milliseconds: 800),
      _ => const Duration(milliseconds: 1500),
    };
    final newEnd = level == WarningLevel.critical ? 1.08 : 1.0;

    if (_pulseCtrl.duration != newDuration) {
      _pulseCtrl.duration = newDuration;
      _pulseAnim = Tween<double>(begin: 1.0, end: newEnd).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
      );
    }
  }

  void _onTimerFinished() {
    _ticker?.cancel();
    setState(() {
      _finished = true;
      _running = false;
      _timeLeft = 0;
    });
    _vibrate();
  }

  Future<void> _vibrate() async {
    try {
      final hasVibrator = (await Vibration.hasVibrator()) == true;
      if (!hasVibrator) return;
      // Pattern mirrors Kotlin: 0, 500, 200, 500, 200, 500
      Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500]);
    } catch (_) {
      // Vibration not available on this device/emulator — ignore.
    }
  }

  // ── Controls ───────────────────────────────────────────────────────────────

  void _togglePause() {
    setState(() => _running = !_running);
  }

  void _restart() {
    setState(() {
      _timeLeft = _totalSeconds;
      _running = true;
      _finished = false;
      _updatePulse();
    });
  }

  void _endGame() {
    _ticker?.cancel();
    _vibrate();
    setState(() {
      _timeLeft = 0;
      _running = false;
      _finished = true;
    });
  }

  // ── Derived display values ─────────────────────────────────────────────────

  TimerManager get _timerManager => ref.read(timerManagerProvider);

  String get _formattedTime => _timerManager.formatTime(_timeLeft);

  double get _progress =>
      _totalSeconds > 0 ? _timeLeft / _totalSeconds : 0.0;

  WarningLevel get _level => _timerManager.warningLevelFor(_timeLeft);

  Color get _primaryColor => switch (_level) {
        WarningLevel.critical => const Color(0xFFEF4444),
        WarningLevel.warning => const Color(0xFFFBBF24),
        WarningLevel.finished => const Color(0xFF6B7280),
        WarningLevel.normal => const Color(0xFF3B82F6),
      };

  Color get _secondaryColor => switch (_level) {
        WarningLevel.critical => const Color(0xFFFCA5A5),
        WarningLevel.warning => const Color(0xFFFDE68A),
        WarningLevel.finished => const Color(0xFF9CA3AF),
        WarningLevel.normal => const Color(0xFF60A5FA),
      };

  Color get _bgColor => _finished
      ? const Color(0xFF1a1625)
      : _level == WarningLevel.critical || _level == WarningLevel.warning
          ? const Color(0xFF1f1416)
          : const Color(0xFF0a0e27);

  String get _statusLabel {
    if (_finished) return 'SÜRE BİTTİ!';
    if (!_running) return 'DURAKLATILDI';
    return 'OYUN DEVAM EDİYOR';
  }

  Color get _statusColor {
    if (_finished) return const Color(0xFFEF4444);
    if (!_running) return const Color(0xFFFBBF24);
    return const Color(0xFF10B981);
  }

  String get _countdownLabel {
    if (_finished) return 'BİTTİ';
    if (_level == WarningLevel.critical) return 'ACELE ET!';
    return 'KALAN SÜRE';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final gamePlayers = ref.watch(gameStateProvider.select((s) => s.gamePlayers));

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Glowing background rings ─────────────────────────────────
            _GlowRings(primaryColor: _primaryColor, secondaryColor: _secondaryColor),

            // ── Main scrollable content ──────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // ── Status header card ─────────────────────────────────
                  _StatusCard(
                    label: _statusLabel,
                    labelColor: _statusColor,
                    finished: _finished,
                  ),

                  const SizedBox(height: 32),

                  // ── Circular timer ─────────────────────────────────────
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: child,
                    ),
                    child: _CircularTimer(
                      formattedTime: _formattedTime,
                      progress: _progress,
                      primaryColor: _primaryColor,
                      secondaryColor: _secondaryColor,
                      label: _countdownLabel,
                      isCritical: _level == WarningLevel.critical && !_finished && _running,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Controls ───────────────────────────────────────────
                  if (_finished)
                    _FinishedControls(
                      onVoting: () {
                        ref.read(gameStateProvider.notifier).goToVoting();
                        widget.onNext();
                      },
                      onBack: widget.onBack,
                    )
                  else
                    _ActiveControls(
                      isRunning: _running,
                      onTogglePause: _togglePause,
                      onRestart: _restart,
                      onEnd: _endGame,
                    ),
                ],
              ),
            ),

            // ── Player count chip (top-right) ────────────────────────────
            if (!_finished)
              Positioned(
                top: 16,
                right: 16,
                child: _PlayerCountChip(
                  count: gamePlayers.length,
                  color: _primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── _GlowRings ────────────────────────────────────────────────────────────────

/// Blurred radial gradient rings in the background — mirrors the Kotlin Canvas effect.
class _GlowRings extends StatefulWidget {
  const _GlowRings({required this.primaryColor, required this.secondaryColor});
  final Color primaryColor;
  final Color secondaryColor;

  @override
  State<_GlowRings> createState() => _GlowRingsState();
}

class _GlowRingsState extends State<_GlowRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return CustomPaint(
          painter: _GlowPainter(
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            alpha: _anim.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.alpha,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 3);

    canvas.drawCircle(
      center,
      400,
      Paint()
        ..shader = RadialGradient(
          colors: [primaryColor.withValues(alpha: alpha * 0.3), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: 400)),
    );
    canvas.drawCircle(
      center,
      250,
      Paint()
        ..shader = RadialGradient(
          colors: [secondaryColor.withValues(alpha: alpha * 0.2), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: 250)),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.alpha != alpha ||
      old.primaryColor != primaryColor ||
      old.secondaryColor != secondaryColor;
}

// ── _StatusCard ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.label,
    required this.labelColor,
    required this.finished,
  });

  final String label;
  final Color labelColor;
  final bool finished;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: labelColor,
              letterSpacing: 2,
            ),
          ),
          if (!finished) ...[
            const SizedBox(height: 8),
            const Text(
              "SPY'I YAKALAYABILECEK MİSİN?",
              style: TextStyle(
                fontSize: 18,
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

// ── _CircularTimer ────────────────────────────────────────────────────────────

class _CircularTimer extends StatelessWidget {
  const _CircularTimer({
    required this.formattedTime,
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.label,
    required this.isCritical,
  });

  final String formattedTime;
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final String label;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              strokeWidth: 12,
              color: primaryColor.withValues(alpha: .5),
              backgroundColor: Colors.white.withValues(alpha: .05),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Critical pulse glow ring
          if (isCritical)
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: .25),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          // Inner card
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: .55),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 20),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 58,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                    letterSpacing: 4,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor.withValues(alpha: .8),
                    letterSpacing: 2,
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

// ── _ActiveControls ───────────────────────────────────────────────────────────

/// Pause / Restart / End buttons shown while the timer is running.
class _ActiveControls extends StatelessWidget {
  const _ActiveControls({
    required this.isRunning,
    required this.onTogglePause,
    required this.onRestart,
    required this.onEnd,
  });

  final bool isRunning;
  final VoidCallback onTogglePause;
  final VoidCallback onRestart;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pause / Resume
          _ControlFAB(
            icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: isRunning
                ? const Color(0xFFFBBF24)
                : const Color(0xFF10B981),
            iconColor: Colors.black,
            onTap: onTogglePause,
          ),
          // Restart
          _ControlFAB(
            icon: Icons.refresh_rounded,
            color: const Color(0xFF3B82F6),
            iconColor: Colors.white,
            onTap: onRestart,
          ),
          // End
          _ControlFAB(
            icon: Icons.stop_rounded,
            color: const Color(0xFFEF4444),
            iconColor: Colors.white,
            onTap: onEnd,
          ),
        ],
      ),
    );
  }
}

class _ControlFAB extends StatelessWidget {
  const _ControlFAB({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

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
              color: color.withValues(alpha: .4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 36),
      ),
    );
  }
}

// ── _FinishedControls ─────────────────────────────────────────────────────────

/// Controls shown when the countdown reaches zero.
class _FinishedControls extends StatelessWidget {
  const _FinishedControls({required this.onVoting, required this.onBack});

  final VoidCallback onVoting;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Explanation card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Oyun bitti! Şimdi SPY'ı bulma zamanı!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),

        // Start voting
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: onVoting,
            icon: const Icon(Icons.how_to_vote_rounded, size: 26),
            label: const Text(
              'OYLAMA BAŞLAT',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
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
        const SizedBox(height: 12),

        // Back to category (instead of "main menu" — no nav stack here)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.home_rounded, size: 22),
            label: const Text(
              'Ana Menü',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── _PlayerCountChip ──────────────────────────────────────────────────────────

class _PlayerCountChip extends StatelessWidget {
  const _PlayerCountChip({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_rounded, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

