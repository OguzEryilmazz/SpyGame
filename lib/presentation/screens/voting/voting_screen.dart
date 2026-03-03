import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/logic/player_manager.dart';
import '../../../domain/models/player.dart';
import '../../../domain/models/voting_result.dart';
import '../../providers/game_provider.dart';

// ── Avatar helper ─────────────────────────────────────────────────────────────

String _avatarAsset(int index) => 'assets/images/pic_${index + 1}.png';

// ── VotingScreen ──────────────────────────────────────────────────────────────

/// Mirrors Kotlin VotingScreen.kt.
///
/// Phase 1 — VotingInterface: each player swipes up to see the candidate list
///            and double-taps to cast their vote.
/// Phase 2 — VotingResultsScreen: shows who was caught (or spy won).
///
/// Navigation injected via [onBack] / [onPlayAgain] / [onMainMenu].
class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({
    super.key,
    required this.onBack,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  final VoidCallback onBack;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

enum _VotingPhase { voting, results }

class _VotingScreenState extends ConsumerState<VotingScreen> {
  _VotingPhase _phase = _VotingPhase.voting;

  // voterName → voted-player-name
  final Map<String, String> _votes = {};
  int _voterIndex = 0;

  void _submitVote(String votedPlayerName) {
    final gamePlayers = ref.read(gameStateProvider).gamePlayers;
    final voter = gamePlayers[_voterIndex];
    _votes[voter.name] = votedPlayerName;

    if (_voterIndex < gamePlayers.length - 1) {
      setState(() => _voterIndex++);
    } else {
      // All votes cast → compute results
      ref.read(gameStateProvider.notifier).submitVotes(_votes);
      setState(() => _phase = _VotingPhase.results);
    }
  }

  void _goToPreviousVoter() {
    if (_voterIndex > 0) {
      final gamePlayers = ref.read(gameStateProvider).gamePlayers;
      final prevVoter = gamePlayers[_voterIndex - 1];
      setState(() {
        _votes.remove(prevVoter.name);
        _voterIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);

    if (state.gamePlayers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return switch (_phase) {
      _VotingPhase.voting => _VotingInterface(
          key: ValueKey(_voterIndex),
          gamePlayers: state.gamePlayers,
          currentVoterIndex: _voterIndex,
          onVote: _submitVote,
          onBack: widget.onBack,
          onPrevious: _goToPreviousVoter,
        ),
      _VotingPhase.results => _ResultsScreen(
          result: state.votingResult!,
          gamePlayers: state.gamePlayers,
          onPlayAgain: widget.onPlayAgain,
          onMainMenu: widget.onMainMenu,
        ),
    };
  }
}

// ── _VotingInterface ──────────────────────────────────────────────────────────

/// Mirrors Kotlin VotingInterface composable.
///
/// The voter's colour fills the screen. Swiping up reveals the black voting
/// panel with the candidate list. Double-tapping a card casts the vote.
class _VotingInterface extends StatefulWidget {
  const _VotingInterface({
    super.key,
    required this.gamePlayers,
    required this.currentVoterIndex,
    required this.onVote,
    required this.onBack,
    required this.onPrevious,
  });

  final List<GamePlayer> gamePlayers;
  final int currentVoterIndex;
  final ValueChanged<String> onVote;
  final VoidCallback onBack;
  final VoidCallback onPrevious;

  @override
  State<_VotingInterface> createState() => _VotingInterfaceState();
}

class _VotingInterfaceState extends State<_VotingInterface>
    with SingleTickerProviderStateMixin {
  double _dragPixels = 0;
  static const double _revealFraction = 0.65; // 65 % of screen — enough for list

  double get _maxPull =>
      MediaQuery.of(context).size.height * _revealFraction;

  bool get _revealed => _dragPixels > _maxPull * 0.30;

  // Arrow bounce
  late final AnimationController _arrowCtrl;
  late final Animation<double> _arrowAnim;

  @override
  void initState() {
    super.initState();
    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _arrowAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _arrowCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _dragPixels = (_dragPixels - d.delta.dy).clamp(0, _maxPull);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_revealed) setState(() => _dragPixels = 0);
  }

  @override
  Widget build(BuildContext context) {
    final voter = widget.gamePlayers[widget.currentVoterIndex];
    final candidates = widget.gamePlayers
        .where((p) => p.id != voter.id)
        .toList();
    final screenH = MediaQuery.of(context).size.height;
    final panelH = _dragPixels.clamp(0.0, _maxPull);
    final voterColor = PlayerManager.availableColors[
        voter.colorIndex % PlayerManager.availableColors.length];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        onLongPress: widget.onPrevious,
        child: Stack(
          children: [
            // ── Cover ──────────────────────────────────────────────────
            Transform.translate(
              offset: Offset(0, -panelH),
              child: Container(
                height: screenH,
                color: voterColor,
                child: _VoterCover(
                  voter: voter,
                  voterColor: voterColor,
                  voterIndex: widget.currentVoterIndex,
                  totalVoters: widget.gamePlayers.length,
                  arrowAnim: _arrowAnim,
                  onBack: widget.onBack,
                ),
              ),
            ),

            // ── Voting panel (slides up) ──────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: _VotingPanel(
                  height: panelH,
                  candidates: candidates,
                  revealed: _revealed,
                  onVote: widget.onVote,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _VoterCover ───────────────────────────────────────────────────────────────

class _VoterCover extends StatelessWidget {
  const _VoterCover({
    required this.voter,
    required this.voterColor,
    required this.voterIndex,
    required this.totalVoters,
    required this.arrowAnim,
    required this.onBack,
  });

  final GamePlayer voter;
  final Color voterColor;
  final int voterIndex;
  final int totalVoters;
  final Animation<double> arrowAnim;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 20),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.how_to_vote_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${voterIndex + 1}/$totalVoters',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Avatar + name + instruction
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .25),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  _avatarAsset(voter.avatarIndex),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Center(
                    child: Text(
                      voter.name.isNotEmpty ? voter.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                voter.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${voterIndex + 1} / $totalVoters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: .7),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                '🔍',
                style: TextStyle(fontSize: 44),
              ),
              const SizedBox(height: 12),
              const Text(
                'Yukarı kaydır ve oy ver',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Basılı tut ve geri dön',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: .65),
                ),
              ),
              const SizedBox(height: 16),
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
    );
  }
}

// ── _VotingPanel ──────────────────────────────────────────────────────────────

/// Black panel that slides up from the bottom with the candidate list.
class _VotingPanel extends StatelessWidget {
  const _VotingPanel({
    required this.height,
    required this.candidates,
    required this.revealed,
    required this.onVote,
  });

  final double height;
  final List<GamePlayer> candidates;
  final bool revealed;
  final ValueChanged<String> onVote;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      height: height,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: revealed
          ? OverflowBox(
              maxHeight: double.infinity,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'SPY KİMDİR?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFEF4444),
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Çift tıkla ve oy ver',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: .6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: candidates.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      return _VoteCandidateCard(
                        player: candidate,
                        onDoubleTap: () => onVote(candidate.name),
                      );
                    },
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

// ── _VoteCandidateCard ────────────────────────────────────────────────────────

/// Mirrors Kotlin VotePlayerCard composable.
class _VoteCandidateCard extends StatelessWidget {
  const _VoteCandidateCard({
    required this.player,
    required this.onDoubleTap,
  });

  final GamePlayer player;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final playerColor = PlayerManager.availableColors[
        player.colorIndex % PlayerManager.availableColors.length];

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: .08)),
        ),
        child: Row(
          children: [
            // Avatar circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: playerColor.withValues(alpha: .8),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                _avatarAsset(player.avatarIndex),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Center(
                  child: Text(
                    player.name.isNotEmpty
                        ? player.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Çift tıkla',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: .55),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.touch_app_rounded,
              color: Colors.white.withValues(alpha: .3),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ── _ResultsScreen ────────────────────────────────────────────────────────────

/// Mirrors Kotlin VotingResultsScreen composable.
///
/// Shows:
///  • "OYUN BİTTİ" header coloured by outcome.
///  • Big avatar circle for the revealed spy (or incorrectly voted player).
///  • Vote count badge.
///  • Full vote tally for all players.
///  • "TEKRAR OYNA" / "Ana Menü" buttons.
class _ResultsScreen extends StatelessWidget {
  const _ResultsScreen({
    required this.result,
    required this.gamePlayers,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  final VotingResult result;
  final List<GamePlayer> gamePlayers;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;

  @override
  Widget build(BuildContext context) {
    final caught = result.isSpyCaught;
    final bgColor =
        caught ? const Color(0xFF0D1B2A) : const Color(0xFF1A0A0A);
    final titleColor =
        caught ? const Color(0xFF4ECDC4) : const Color(0xFFFF3939);

    // The "hero" player shown in the big circle:
    // caught → the voted spy; not caught → the actual spy
    final hero = caught ? result.mostVotedPlayer! : result.spyPlayer;
    final heroColor = PlayerManager.availableColors[
        hero.colorIndex % PlayerManager.availableColors.length];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              // ── Outcome header ───────────────────────────────────────
              Text(
                'OYUN BİTTİ',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                  letterSpacing: 4,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                caught ? 'Oyuncular Kazandı' : 'Spy Kazandı',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // ── Hero avatar ──────────────────────────────────────────
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: heroColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: heroColor.withValues(alpha: .5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  _avatarAsset(hero.avatarIndex),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Center(
                    child: Text(
                      hero.name.isNotEmpty ? hero.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                hero.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Gerçek Spy',
                style: TextStyle(
                  fontSize: 20,
                  color: titleColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              // Vote count badge (caught case)
              if (caught) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${result.voteCounts[hero.name] ?? 0} oy',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: .8),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ── Vote tally ───────────────────────────────────────────
              _VoteTally(
                gamePlayers: gamePlayers,
                voteCounts: result.voteCounts,
                spyId: result.spyPlayer.id,
                titleColor: titleColor,
              ),

              const SizedBox(height: 32),

              // ── Action buttons ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onPlayAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: titleColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'TEKRAR OYNA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onMainMenu,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    'Ana Menü',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: .35), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _VoteTally ────────────────────────────────────────────────────────────────

/// Shows every player's vote count sorted descending.
class _VoteTally extends StatelessWidget {
  const _VoteTally({
    required this.gamePlayers,
    required this.voteCounts,
    required this.spyId,
    required this.titleColor,
  });

  final List<GamePlayer> gamePlayers;
  final Map<String, int> voteCounts;
  final String spyId;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    // Sort by votes descending
    final sorted = [...gamePlayers]..sort((a, b) {
        final va = voteCounts[a.name] ?? 0;
        final vb = voteCounts[b.name] ?? 0;
        return vb.compareTo(va);
      });
    final maxVotes =
        sorted.isNotEmpty ? (voteCounts[sorted.first.name] ?? 0) : 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Oy Dağılımı',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: titleColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          ...sorted.map((p) {
            final votes = voteCounts[p.name] ?? 0;
            final fraction = maxVotes > 0 ? votes / maxVotes : 0.0;
            final isSpy = p.id == spyId;
            final playerColor = PlayerManager.availableColors[
                p.colorIndex % PlayerManager.availableColors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Small avatar
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: playerColor,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          _avatarAsset(p.avatarIndex),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Center(
                            child: Text(
                              p.name.isNotEmpty ? p.name[0] : '?',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          p.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSpy ? titleColor : Colors.white,
                          ),
                        ),
                      ),
                      if (isSpy)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: titleColor.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SPY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '$votes oy',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: .7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Vote bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction.toDouble(),
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: .08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isSpy ? titleColor : playerColor.withValues(alpha: .7),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
