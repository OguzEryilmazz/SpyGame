import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/ad_manager.dart';
import '../../../domain/logic/player_manager.dart';
import '../../../domain/models/player.dart';
import '../../providers/game_provider.dart';

// ── Avatar helper (re-use same mapping as PlayerCard) ─────────────────────────

String _avatarAsset(int index) => 'assets/images/pic_${index + 1}.png';

// ── GameRevealScreen ──────────────────────────────────────────────────────────

/// Mirrors Kotlin GameScreen.kt → PlayerGameScreen composable.
///
/// Each player sees a cover screen in their colour.
/// They swipe **up** to reveal the black role panel at the bottom,
/// which shows their role (and hint if hintsEnabled).
/// - Non-last players: double-tap the cover → advance to next player.
/// - Last player: tap the "Zamanlayıcıyı Başlat" button → navigate to timer.
///
/// Navigation is injected via [onBack] / [onNext] so the screen stays
/// decoupled from any routing package.
class GameRevealScreen extends ConsumerWidget {
  const GameRevealScreen({
    super.key,
    required this.onBack,
    required this.onNext,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);

    // Guard: if roles haven't been assigned yet, bail out gracefully.
    if (state.gamePlayers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final player = state.gamePlayers[state.currentPlayerIndex];
    final isLast = state.currentPlayerIndex == state.gamePlayers.length - 1;
    final settings = state.settings;

    return _PlayerRevealCard(
      key: ValueKey(state.currentPlayerIndex), // full rebuild on player change
      player: player,
      playerIndex: state.currentPlayerIndex,
      totalPlayers: state.gamePlayers.length,
      hintsEnabled: settings.hintsEnabled,
      isLastPlayer: isLast,
      onBack: onBack,
      onNext: () => notifier.nextPlayer(),
      onStartTimer: () {
        AdManager.instance.showInterstitialWithCallback(() {
          notifier.nextPlayer(); // advances phase → timer
          onNext();
        });
      },
    );
  }
}

// ── _PlayerRevealCard ─────────────────────────────────────────────────────────

/// Stateful card for one player's reveal turn.
/// Rebuilt from scratch each time [playerIndex] changes (via [ValueKey]).
class _PlayerRevealCard extends StatefulWidget {
  const _PlayerRevealCard({
    super.key,
    required this.player,
    required this.playerIndex,
    required this.totalPlayers,
    required this.hintsEnabled,
    required this.isLastPlayer,
    required this.onBack,
    required this.onNext,
    required this.onStartTimer,
  });

  final GamePlayer player;
  final int playerIndex;
  final int totalPlayers;
  final bool hintsEnabled;
  final bool isLastPlayer;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onStartTimer;

  @override
  State<_PlayerRevealCard> createState() => _PlayerRevealCardState();
}

class _PlayerRevealCardState extends State<_PlayerRevealCard>
    with SingleTickerProviderStateMixin {
  // ── Drag / reveal state ───────────────────────────────────────────────────

  /// How far the role panel has been dragged up (pixels, 0 = hidden).
  double _dragPixels = 0;

  /// Maximum reveal height: 55 % of screen height.
  static const double _revealFraction = 0.55;

  double get _maxPull => MediaQuery.of(context).size.height * _revealFraction;

  /// Role panel is "revealed" once dragged past 20 % of the max.
  bool get _revealed => _dragPixels > _maxPull * 0.20;

  // ── Arrow bounce animation ───────────────────────────────────────────────

  late final AnimationController _arrowCtrl;
  late final Animation<double> _arrowAnim;

  @override
  void initState() {
    super.initState();
    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _arrowAnim = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _arrowCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Color get _playerColor =>
      PlayerManager.availableColors[widget.player.colorIndex %
          PlayerManager.availableColors.length];

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    setState(() {
      // Negative dy = dragging up → increase reveal
      _dragPixels = (_dragPixels - d.delta.dy).clamp(0, _maxPull);
    });
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    // Snap back unless past the reveal threshold
    if (!_revealed) {
      setState(() => _dragPixels = 0);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final panelH = _dragPixels.clamp(0.0, _maxPull);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        onDoubleTap: widget.isLastPlayer ? null : widget.onNext,
        onLongPress: widget.onBack,
        child: Stack(
          children: [
            // ── Cover layer (player identity) ──────────────────────────
            _CoverLayer(
              player: widget.player,
              playerIndex: widget.playerIndex,
              totalPlayers: widget.totalPlayers,
              playerColor: _playerColor,
              isLastPlayer: widget.isLastPlayer,
              arrowAnim: _arrowAnim,
              panelH: panelH,
              screenH: screenH,
              onBack: widget.onBack,
            ),

            // ── Role reveal panel (slides up from bottom) ──────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                onDoubleTap: widget.isLastPlayer ? null : widget.onNext,
                child: _RolePanel(
                  height: panelH,
                  player: widget.player,
                  hintsEnabled: widget.hintsEnabled,
                  playerColor: _playerColor,
                ),
              ),
            ),

            // ── "Start timer" button — only for last player ────────────
            if (widget.isLastPlayer)
              Positioned(
                bottom: panelH + 24,
                left: 0,
                right: 0,
                child: Center(
                  child: _StartTimerButton(
                    playerColor: _playerColor,
                    onTap: widget.onStartTimer,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── _CoverLayer ───────────────────────────────────────────────────────────────

/// The coloured cover that shows the player's name, avatar, and instructions.
/// Slides upward as the role panel grows.
class _CoverLayer extends StatelessWidget {
  const _CoverLayer({
    required this.player,
    required this.playerIndex,
    required this.totalPlayers,
    required this.playerColor,
    required this.isLastPlayer,
    required this.arrowAnim,
    required this.panelH,
    required this.screenH,
    required this.onBack,
  });

  final GamePlayer player;
  final int playerIndex;
  final int totalPlayers;
  final Color playerColor;
  final bool isLastPlayer;
  final Animation<double> arrowAnim;
  final double panelH;
  final double screenH;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    // Shift the cover up exactly as far as the panel has grown.
    return Transform.translate(
      offset: Offset(0, -panelH),
      child: Container(
        height: screenH,
        color: playerColor,
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 16,
                16,
                0,
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Player counter pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${playerIndex + 1} / $totalPlayers',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Player avatar + name ───────────────────────────────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar circle
                  _AvatarCircle(player: player, playerColor: playerColor),

                  const SizedBox(height: 28),

                  // Player name
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: .5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // ── Swipe hint ───────────────────────────────────────
                  Text(
                    'Yukarı kaydır ve rolünü gör',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: .85),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Instruction line — differs for last player
                  Text(
                    isLastPlayer
                        ? 'Basılı tut ve geri dön'
                        : 'Çift tıkla ve ileri geç  •  Basılı tut ve geri dön',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: .65),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Bouncing arrow
                  AnimatedBuilder(
                    animation: arrowAnim,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, arrowAnim.value),
                      child: child,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.white.withValues(alpha: .8),
                      size: 48,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _AvatarCircle ─────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.player, required this.playerColor});

  final GamePlayer player;
  final Color playerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .25),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        _avatarAsset(player.avatarIndex),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Center(
          child: Text(
            player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── _RolePanel ────────────────────────────────────────────────────────────────

/// The black panel that slides up from the bottom revealing the player's role.
///
/// Spy:      red "IMPOSTER" + imposter image + optional hint text.
/// Civilian: white role word + optional word (the shared location/word).
class _RolePanel extends StatelessWidget {
  const _RolePanel({
    required this.height,
    required this.player,
    required this.hintsEnabled,
    required this.playerColor,
  });

  final double height;
  final GamePlayer player;
  final bool hintsEnabled;
  final Color playerColor;

  /// Reveal content appears after 20 % of max height is reached.
  bool get _showContent => height > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _showContent
          ? OverflowBox(
              maxHeight: double.infinity,
              alignment: Alignment.topCenter,
              child: player.isSpy
                  ? _SpyContent(player: player, hintsEnabled: hintsEnabled)
                  : _CivilianContent(
                      player: player,
                      hintsEnabled: hintsEnabled,
                    ),
            )
          : const SizedBox.shrink(),
    );
  }
}

// ── _SpyContent ───────────────────────────────────────────────────────────────

class _SpyContent extends StatelessWidget {
  const _SpyContent({required this.player, required this.hintsEnabled});

  final GamePlayer player;
  final bool hintsEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imposter illustration
          Image.asset(
            'assets/images/imposter.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) =>
                const Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 80),
          ),

          const SizedBox(height: 18),

          // Role label
          const Text(
            'IMPOSTER',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.red,
              letterSpacing: 3,
            ),
            textAlign: TextAlign.center,
          ),

          // Spy hint (shown only when hintsEnabled)
          if (hintsEnabled &&
              player.spyHint != null &&
              player.spyHint!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              player.spyHint!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red.withValues(alpha: .8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ── _CivilianContent ──────────────────────────────────────────────────────────

class _CivilianContent extends StatelessWidget {
  const _CivilianContent({required this.player, required this.hintsEnabled});

  final GamePlayer player;
  final bool hintsEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shared word (the category item assigned to this player)
          if (player.word != null && player.word!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                player.word!,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── _StartTimerButton ─────────────────────────────────────────────────────────

/// Shown only on the last player's card; floats above the role panel.
class _StartTimerButton extends StatelessWidget {
  const _StartTimerButton({required this.playerColor, required this.onTap});

  final Color playerColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: playerColor, size: 26),
            const SizedBox(width: 8),
            Text(
              'Zamanlayıcıyı Başlat',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: playerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
