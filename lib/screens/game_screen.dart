import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/game_player.dart';
import '../models/character_avatar.dart';
import 'category_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int _currentIndex = 0;
  late int _timeLeft;
  bool _isTimerRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final gs = ref.read(gameStateProvider);
    _timeLeft = (gs?.durationMinutes ?? 5) * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _isTimerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        t.cancel();
        setState(() => _isTimerRunning = false);
      }
    });
  }

  String get _timeString {
    final prefix = _isTimerRunning ? '▶' : '⏸';
    final m = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_timeLeft % 60).toString().padLeft(2, '0');
    return '$prefix $m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final gs = ref.watch(gameStateProvider);
    if (gs == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.pop());
      return const SizedBox.shrink();
    }

    final players = gs.players;
    final isLastPlayer = _currentIndex == players.length - 1;

    return _PlayerGameScreen(
      player: players[_currentIndex],
      playerIndex: _currentIndex,
      totalPlayers: players.length,
      category: gs.category,
      timeString: _timeString,
      showHints: gs.showHints,
      isLastPlayer: isLastPlayer,
      onBack: () => context.pop(),
      onNext: () {
        if (_currentIndex < players.length - 1) {
          setState(() => _currentIndex++);
        }
      },
      onPrevious: () {
        if (_currentIndex > 0) {
          setState(() => _currentIndex--);
        }
      },
      onStartTimer: () {
        _startTimer();
        context.push('/timer');
      },
    );
  }
}

// ---------------------------------------------------------------------------
// PLAYER GAME SCREEN
// ---------------------------------------------------------------------------

class _PlayerGameScreen extends StatefulWidget {
  final GamePlayer player;
  final int playerIndex;
  final int totalPlayers;
  final Category category;
  final String timeString;
  final bool showHints;
  final bool isLastPlayer;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onStartTimer;

  const _PlayerGameScreen({
    required this.player,
    required this.playerIndex,
    required this.totalPlayers,
    required this.category,
    required this.timeString,
    required this.showHints,
    required this.isLastPlayer,
    required this.onBack,
    required this.onNext,
    required this.onPrevious,
    required this.onStartTimer,
  });

  @override
  State<_PlayerGameScreen> createState() => _PlayerGameScreenState();
}

class _PlayerGameScreenState extends State<_PlayerGameScreen>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _isDragging = false;

  late AnimationController _arrowCtrl;
  late Animation<double> _arrowAnim;

  double _maxPullUp = 300.0;
  static const double _revealThreshold = 0.2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maxPullUp = MediaQuery.of(context).size.height * 0.45;
  }

  @override
  void initState() {
    super.initState();
    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _arrowAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_PlayerGameScreen old) {
    super.didUpdateWidget(old);
    if (old.playerIndex != widget.playerIndex) {
      setState(() {
        _dragOffset = 0.0;
        _isDragging = false;
      });
    }
  }

  @override
  void dispose() {
    _arrowCtrl.dispose();
    super.dispose();
  }

  void _onDragEnd() {
    if (_dragOffset < _maxPullUp * _revealThreshold) {
      setState(() {
        _dragOffset = 0.0;
        _isDragging = false;
      });
    } else {
      setState(() => _isDragging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.player;
    final revealHeight = _dragOffset.clamp(0.0, _maxPullUp);
    final showReveal = revealHeight > _maxPullUp * _revealThreshold;
    final playerColor = p.selectedColor ?? const Color(0xFF9E9E9E);

    return Scaffold(
      body: GestureDetector(
        onDoubleTap: () {
          if (!widget.isLastPlayer) widget.onNext();
        },
        onLongPress: widget.onPrevious,
        onVerticalDragStart: (_) => setState(() => _isDragging = true),
        onVerticalDragUpdate: (d) {
          setState(() {
            _dragOffset =
                (_dragOffset - d.delta.dy).clamp(0.0, _maxPullUp);
          });
        },
        onVerticalDragEnd: (_) => _onDragEnd(),
        // ── STACK: renkli alan sabit, reveal paneli üstte kayar ──
        child: Stack(
          children: [
            // ── Katman 1: renkli arka plan (tam ekran, asla küçülmez) ──
            Positioned.fill(
              child: Container(
                color: playerColor,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _Header(
                        timeString: widget.timeString,
                        onBack: widget.onBack,
                      ),
                      Expanded(
                        child: _PlayerInfo(
                          player: p,
                          playerIndex: widget.playerIndex,
                          totalPlayers: widget.totalPlayers,
                          isLastPlayer: widget.isLastPlayer,
                          arrowAnim: _arrowAnim,
                          // reveal açıldıkça ok'u gizle (opsiyonel)
                          revealProgress:
                          revealHeight / _maxPullUp,
                        ),
                      ),
                      // Son oyuncu butonu
                      if (widget.isLastPlayer && revealHeight < 40)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: _StartTimerButton(
                            playerColor: playerColor,
                            onPressed: widget.onStartTimer,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Katman 2: siyah reveal paneli, ekranın altından yukarı açılır ──
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: _isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: revealHeight,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  // Üst köşeleri yuvarlat (opsiyonel, güzel görünür)
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                // İçerik tam ortada
                child: showReveal
                    ? Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: _RoleReveal(
                      player: p,
                      showHints: widget.showHints,
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HEADER
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final String timeString;
  final VoidCallback onBack;

  const _Header({required this.timeString, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  timeString,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

// ---------------------------------------------------------------------------
// PLAYER INFO
// ---------------------------------------------------------------------------

class _PlayerInfo extends StatelessWidget {
  final GamePlayer player;
  final int playerIndex;
  final int totalPlayers;
  final bool isLastPlayer;
  final Animation<double> arrowAnim;
  final double revealProgress; // 0.0 → 1.0

  const _PlayerInfo({
    required this.player,
    required this.playerIndex,
    required this.totalPlayers,
    required this.isLastPlayer,
    required this.arrowAnim,
    this.revealProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availH = constraints.maxHeight;
        final avatarSize = availH < 580 ? 120.0 : 160.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Avatar — her zaman aynı boyutta, hareket etmez
              if (player.selectedCharacter != null)
                Image.asset(
                  player.selectedCharacter!.assetPath,
                  width: avatarSize,
                  height: avatarSize,
                )
              else
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    player.name.characters.first.toUpperCase(),
                    style: TextStyle(
                      fontSize: avatarSize * 0.4,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),

              const Spacer(flex: 1),

              Text(
                player.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                '${playerIndex + 1} / $totalPlayers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),

              const Spacer(flex: 2),

              // Reveal başlayınca talimatları gizle
              AnimatedOpacity(
                opacity: revealProgress > 0.3 ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Text(
                      'Yukarı kaydır ve rolünü gör',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isLastPlayer
                          ? 'Basılı tut ve geri dön'
                          : 'Çift tıkla ve ileri geç • Basılı tut ve geri dön',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    AnimatedBuilder(
                      animation: arrowAnim,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, arrowAnim.value),
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 44,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// ROLE REVEAL — tam ortada, overflow yok
// ---------------------------------------------------------------------------

class _RoleReveal extends StatelessWidget {
  final GamePlayer player;
  final bool showHints;

  const _RoleReveal({required this.player, required this.showHints});

  @override
  Widget build(BuildContext context) {
    final isSpy = player.isSpy;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // ← ortalı
        children: [
          if (isSpy) ...[
            Image.asset(
              'assets/my_imposter.png',
              width: 80,
              height: 80,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person_off_rounded,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'IMPOSTER',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.red,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            if (showHints &&
                player.hint != null &&
                player.hint!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                player.hint!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ] else ...[
            Text(
              player.assignedWord.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            if (showHints &&
                player.hint != null &&
                player.hint!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                player.hint!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// START TIMER BUTTON
// ---------------------------------------------------------------------------

class _StartTimerButton extends StatelessWidget {
  final Color playerColor;
  final VoidCallback onPressed;

  const _StartTimerButton({
    required this.playerColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: playerColor,
          elevation: 8,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Zamanlayıcıyı Başlat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}