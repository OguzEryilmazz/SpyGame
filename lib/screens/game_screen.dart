import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_player.dart';
import '../ads/ad_providers.dart';
import '../widgets/first_player_intro.dart';
import '../utils/app_haptics.dart';
import '../utils/route_observer.dart';
import 'category_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with RouteAware {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _timer?.cancel();
    super.dispose();
  }

  // YENİ: Timer ekranından ("hazır değiliz, rollere bak") geri
  // dönüldüğünde bu ekran tekrar görünür olur. Kaldığı yerden
  // (son oyuncu) değil, en baştan (ilk oyuncu) başlasın.
  @override
  void didPopNext() {
    if (mounted && _currentIndex != 0) {
      setState(() => _currentIndex = 0);
    }
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
    final m = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_timeLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
        final interstitial = ref.read(interstitialAdProvider);
        interstitial.showAdWithFrequencyControl(
          onAdDismissed: () => context.push('/timer'),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// PLAYER GAME SCREEN
// ---------------------------------------------------------------------------

class _PlayerGameScreen extends ConsumerStatefulWidget {
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
  ConsumerState<_PlayerGameScreen> createState() => _PlayerGameScreenState();
}

class _PlayerGameScreenState extends ConsumerState<_PlayerGameScreen>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _isDragging = false;
  bool _revealHapticFired = false;

  // YENİ: Zamanlayıcının birden fazla kez tetiklenmesini önlemek için
  bool _hasTriggeredTimer = false;

  late AnimationController _arrowCtrl;
  late Animation<double> _arrowAnim;

  bool _showIntro = false;
  bool _introIsFlying = false;

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

    if (widget.playerIndex == 0) {
      _showIntro = true;
      _checkIntroSeenStatus();
    }
  }

  Future<void> _checkIntroSeenStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('intro_seen') ?? false;
    if (seen && mounted) {
      setState(() {
        _showIntro = false;
      });
    }
  }

  void _openIntro() {
    setState(() {
      _showIntro = true;
      _introIsFlying = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _introIsFlying = false;
        });
      }
    });
  }

  void _closeIntro() {
    setState(() {
      _introIsFlying = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showIntro = false;
          _introIsFlying = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(_PlayerGameScreen old) {
    super.didUpdateWidget(old);
    if (old.playerIndex != widget.playerIndex) {
      setState(() {
        _dragOffset = 0.0;
        _isDragging = false;
        _revealHapticFired = false;
        _hasTriggeredTimer = false; // YENİ: Yeni oyuncuda tetikleyiciyi sıfırla
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

    // YENİ: Son oyuncuysa panelin daha fazla yukarı çekilebilmesi için ekstra 140px pay veriyoruz.
    final pullLimit = widget.isLastPlayer ? _maxPullUp + 140.0 : _maxPullUp;
    final revealHeight = _dragOffset.clamp(0.0, pullLimit);
    final showReveal = revealHeight > _maxPullUp * _revealThreshold;
    final playerColor = p.selectedColor ?? const Color(0xFF9E9E9E);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onDoubleTap: () {
          // YENİ: Son oyuncu için çift tıklamayı tamamen iptal ettik, sadece kaydırma çalışacak
          if (_showIntro || widget.isLastPlayer) return;
          AppHaptics.click(ref);
          widget.onNext();
        },
        onLongPress: () {
          if (_showIntro) return;
          AppHaptics.click(ref);
          widget.onPrevious();
        },
        onVerticalDragStart: (_) {
          if (_showIntro) return;
          setState(() => _isDragging = true);
        },
        onVerticalDragUpdate: (d) {
          if (_showIntro) return;

          setState(() {
            _dragOffset = (_dragOffset - d.delta.dy).clamp(0.0, pullLimit);
          });

          final crossed = _dragOffset > _maxPullUp * _revealThreshold;
          if (crossed && !_revealHapticFired) {
            _revealHapticFired = true;
            AppHaptics.medium(ref);
          } else if (!crossed) {
            _revealHapticFired = false;
          }

          // YENİ: Son oyuncu paneli en yukarı kadar çekerse zamanlayıcıyı otomatik başlat
          if (widget.isLastPlayer &&
              _dragOffset > _maxPullUp + 80.0 &&
              !_hasTriggeredTimer) {
            _hasTriggeredTimer = true;
            AppHaptics.heavy(ref); // Tok bir titreşim
            widget.onStartTimer(); // Parmak izli ekrana geçiş
          }
        },
        onVerticalDragEnd: (_) {
          if (_showIntro) return;
          _onDragEnd();
        },
        child: Stack(
          children: [
            // ── Katman 1: Renkli arka plan ──
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _showIntro,
                child: Container(
                  color: playerColor,
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _Header(
                          timeString: widget.timeString,
                          onBack: widget.onBack,
                          onPrevious:
                          widget.playerIndex > 0 ? widget.onPrevious : null,
                          onInfo: _openIntro,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: _PlayerInfo(
                                  player: p,
                                  playerIndex: widget.playerIndex,
                                  totalPlayers: widget.totalPlayers,
                                  isLastPlayer: widget.isLastPlayer,
                                  arrowAnim: _arrowAnim,
                                  revealProgress: revealHeight / _maxPullUp,
                                ),
                              ),
                              // DİKKAT: _StartTimerButton'ı sildik! Artık buton yok.
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Katman 2: Siyah reveal paneli ──
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: _showIntro,
                child: AnimatedContainer(
                  duration: _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  height: revealHeight,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: showReveal
                      ? Stack(
                    alignment: Alignment.center,
                    children: [
                      SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: _RoleReveal(
                          player: p,
                          showHints: widget.showHints,
                        ),
                      ),
                      // YENİ: Son oyuncu için panelin altına "Kaydırmaya Devam Et" uyarısı ekledik
                      if (widget.isLastPlayer)
                        Positioned(
                          bottom: 40,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            // Panel normal açılma seviyesini biraz geçince yazıyı göster
                            opacity:
                            _dragOffset > _maxPullUp + 10 ? 1.0 : 0.0,
                            child: Column(
                              children: [
                                AnimatedBuilder(
                                  animation: _arrowCtrl,
                                  builder: (_, __) => Transform.translate(
                                    offset: Offset(0, _arrowAnim.value),
                                    child: const Icon(
                                      Icons
                                          .keyboard_double_arrow_up_rounded,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Oyuna geçmek için\nkaydırmaya devam et',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            // ── Katman 3: Animasyonlu İlk Oyuncu İntrosu ──
            if (_showIntro)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: _introIsFlying,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    alignment: const Alignment(0.85, -0.9),
                    scale: _introIsFlying ? 0.05 : 1.0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: _introIsFlying ? 0.0 : 1.0,
                      child: FirstPlayerIntro(
                        accentColor: playerColor,
                        onFinished: _closeIntro,
                      ),
                    ),
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
// HEADER
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final String timeString;
  final VoidCallback onBack;
  final VoidCallback? onPrevious;
  final VoidCallback onInfo;

  const _Header({
    required this.timeString,
    required this.onBack,
    required this.onInfo,
    this.onPrevious,
  });

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
          if (onPrevious != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onPrevious,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.skip_previous_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
          const Spacer(),
          // Timer container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeString,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          GestureDetector(
            onTap: onInfo,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded,
                  // İkon shopping cart konseptine uyarlandı
                  color: Colors.white,
                  size: 22),
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
                          ? 'Çift tıkla ve zamanlayıcıya geç • Basılı tut ve geri dön'
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
          ],
        ],
      ),
    );
  }
}