import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ads/ad_providers.dart';
import '../models/game_player.dart';
import 'category_screen.dart'; // gameStateProvider

// ---------------------------------------------------------------------------
// VOTING SCREEN — Riverpod entry point
// ---------------------------------------------------------------------------

enum _VotingPhase { voting, results }

class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({super.key});

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  _VotingPhase _phase = _VotingPhase.voting;
  int _currentVoterIndex = 0;

  /// voterName → votedPlayerName
  final Map<String, String> _votes = {};

  GamePlayer? _mostVotedPlayer;

  // ── helpers ──────────────────────────────────────────────────────────────

  void _submitVote(List<GamePlayer> players, String votedName) {
    final voter = players[_currentVoterIndex];
    setState(() {
      _votes[voter.name] = votedName;
      if (_currentVoterIndex < players.length - 1) {
        _currentVoterIndex++;
      } else {
        _calculateResults(players);
      }
    });
  }

  void _goToPrevious(List<GamePlayer> players) {
    if (_currentVoterIndex <= 0) return;
    setState(() {
      // Önceki oyuncunun oyunu sil
      final prevVoter = players[_currentVoterIndex - 1];
      _votes.remove(prevVoter.name);
      _currentVoterIndex--;
    });
  }

  void _calculateResults(List<GamePlayer> players) {
    final voteCount = <String, int>{};
    for (final voted in _votes.values) {
      voteCount[voted] = (voteCount[voted] ?? 0) + 1;
    }
    final topName =
        voteCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    _mostVotedPlayer = players.firstWhere((p) => p.name == topName);
    _phase = _VotingPhase.results;
  }

  Map<String, int> get _voteCounts {
    final counts = <String, int>{};
    for (final v in _votes.values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    return counts;
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final gs = ref.watch(gameStateProvider);
    if (gs == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => context.pop());
      return const SizedBox.shrink();
    }

    final players = gs.players;
    final impostor = players.firstWhere(
          (p) => p.isSpy,
      orElse: () => players.first,
    );

    if (_phase == _VotingPhase.results) {
      return _VotingResultsScreen(
        impostor: impostor,
        mostVotedPlayer: _mostVotedPlayer,
        voteCounts: _voteCounts,
        onPlayAgain: () {
          ref.read(interstitialAdProvider).showAdWithFrequencyControl(
            onAdDismissed: () => context.go('/'),
          );
        },
        onMainMenu: () {
          ref.read(interstitialAdProvider).showAdWithFrequencyControl(
            onAdDismissed: () => context.go('/'),
          );
        },
      );
    }

    // oylama aşaması
    final currentVoter = players[_currentVoterIndex];

    return _VotingInterface(
      players: players,
      currentVoter: currentVoter,
      voterIndex: _currentVoterIndex,
      totalVoters: players.length,
      onPlayerSelect: (name) => _submitVote(players, name),
      onBack: () => context.pop(),
      onPrevious: () => _goToPrevious(players),
    );
  }
}

// ---------------------------------------------------------------------------
// VOTING INTERFACE  (GameScreen'deki kaydırma mimarisiyle birebir)
// ---------------------------------------------------------------------------

class _VotingInterface extends StatefulWidget {
  final List<GamePlayer> players;
  final GamePlayer currentVoter;
  final int voterIndex;
  final int totalVoters;
  final ValueChanged<String> onPlayerSelect;
  final VoidCallback onBack;
  final VoidCallback onPrevious;

  const _VotingInterface({
    required this.players,
    required this.currentVoter,
    required this.voterIndex,
    required this.totalVoters,
    required this.onPlayerSelect,
    required this.onBack,
    required this.onPrevious,
  });

  @override
  State<_VotingInterface> createState() => _VotingInterfaceState();
}

class _VotingInterfaceState extends State<_VotingInterface>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _isDragging = false;
  double _maxPullUp = 400.0;

  static const double _revealThreshold = 0.25;

  // Animasyonlu ok
  late AnimationController _arrowCtrl;
  late Animation<double> _arrowAnim;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maxPullUp = MediaQuery.of(context).size.height * 0.65;
  }

  @override
  void didUpdateWidget(_VotingInterface old) {
    super.didUpdateWidget(old);
    if (old.voterIndex != widget.voterIndex) {
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
    final p = widget.currentVoter;
    final playerColor = p.selectedColor ?? const Color(0xFF9E9E9E);
    final revealHeight = _dragOffset.clamp(0.0, _maxPullUp);
    final showReveal = revealHeight > _maxPullUp * _revealThreshold;

    // Oy verilebilecek oyuncular (kendisi hariç)
    final votable =
    widget.players.where((pl) => pl.name != p.name).toList();

    return Scaffold(
      body: GestureDetector(
        onLongPress: widget.onPrevious,
        onVerticalDragStart: (_) => setState(() => _isDragging = true),
        onVerticalDragUpdate: (d) => setState(() {
          _dragOffset =
              (_dragOffset - d.delta.dy).clamp(0.0, _maxPullUp);
        }),
        onVerticalDragEnd: (_) => _onDragEnd(),
        child: Stack(
          children: [
            // ── Katman 1: Oyuncunun renkli arka planı ──
            Positioned.fill(
              child: Container(
                color: playerColor,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _VotingHeader(
                        voterIndex: widget.voterIndex,
                        totalVoters: widget.totalVoters,
                        onBack: widget.onBack,
                      ),
                      Expanded(
                        child: _VoterInfo(
                          player: p,
                          voterIndex: widget.voterIndex,
                          totalVoters: widget.totalVoters,
                          arrowAnim: _arrowAnim,
                          revealProgress: revealHeight / _maxPullUp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Katman 2: Siyah panel, alttan yukarı açılır ──
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
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: showReveal
                    ? _VoteList(
                  votablePlayers: votable,
                  onPlayerSelect: widget.onPlayerSelect,
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
// VOTING HEADER
// ---------------------------------------------------------------------------

class _VotingHeader extends StatelessWidget {
  final int voterIndex;
  final int totalVoters;
  final VoidCallback onBack;

  const _VotingHeader({
    required this.voterIndex,
    required this.totalVoters,
    required this.onBack,
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
                const Icon(Icons.how_to_vote_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${voterIndex + 1} / $totalVoters',
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
// VOTER INFO (renkli alanda görünen orta alan)
// ---------------------------------------------------------------------------

class _VoterInfo extends StatelessWidget {
  final GamePlayer player;
  final int voterIndex;
  final int totalVoters;
  final Animation<double> arrowAnim;
  final double revealProgress;

  const _VoterInfo({
    required this.player,
    required this.voterIndex,
    required this.totalVoters,
    required this.arrowAnim,
    required this.revealProgress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final avatarSize =
        constraints.maxHeight < 580 ? 120.0 : 160.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Avatar
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
                player.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                '${voterIndex + 1} / $totalVoters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),

              const Spacer(flex: 2),

              // Talimatlar — reveal açılınca solar
              AnimatedOpacity(
                opacity: revealProgress > 0.3 ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    const Text(
                      '🔍',
                      style: TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yukarı kaydır ve oy ver',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Basılı tut ve geri dön',
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
// VOTE LIST (siyah panel içi)
// ---------------------------------------------------------------------------

class _VoteList extends StatelessWidget {
  final List<GamePlayer> votablePlayers;
  final ValueChanged<String> onPlayerSelect;

  const _VoteList({
    required this.votablePlayers,
    required this.onPlayerSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: votablePlayers.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final pl = votablePlayers[i];
                return _VotePlayerCard(
                  player: pl,
                  onDoubleTap: () => onPlayerSelect(pl.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// VOTE PLAYER CARD
// ---------------------------------------------------------------------------

class _VotePlayerCard extends StatelessWidget {
  final GamePlayer player;
  final VoidCallback onDoubleTap;

  const _VotePlayerCard({
    required this.player,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = player.selectedColor ?? const Color(0xFF9E9E9E);

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: player.selectedCharacter != null
                  ? Image.asset(
                player.selectedCharacter!.assetPath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : Text(
                player.name.characters.first.toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // İsim
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
                  const SizedBox(height: 2),
                  Text(
                    'Çift tıkla',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Ok işareti
            Icon(
              Icons.how_to_vote_outlined,
              color: color.withOpacity(0.7),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// VOTING RESULTS SCREEN
// ---------------------------------------------------------------------------

class _VotingResultsScreen extends StatelessWidget {
  final GamePlayer impostor;
  final GamePlayer? mostVotedPlayer;
  final Map<String, int> voteCounts;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;

  const _VotingResultsScreen({
    required this.impostor,
    required this.mostVotedPlayer,
    required this.voteCounts,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  bool get _isImpostorCaught =>
      mostVotedPlayer != null && mostVotedPlayer!.isSpy;

  @override
  Widget build(BuildContext context) {
    final caught = _isImpostorCaught;
    final bgColor =
    caught ? const Color(0xFF0D1B2A) : const Color(0xFF1A0A0A);
    final titleColor =
    caught ? const Color(0xFF4ECDC4) : const Color(0xFFFF3939);

    // Sonuç ekranında gösterilecek oyuncu:
    // - Yakalandıysa: en çok oy alan (= spy)
    // - Yakalanmadıysa: gerçek spy
    final displayPlayer =
    caught ? mostVotedPlayer! : impostor;
    final displayColor =
        displayPlayer.selectedColor ?? const Color(0xFF9E9E9E);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              // ── Başlık ──
              Text(
                'OYUN BİTTİ',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                caught ? 'Oyuncular Kazandı!' : 'Spy Kazandı!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // ── Kazanan görseli ──
              Image.asset(
                caught ? 'assets/my_crew.png' : 'assets/my_imposter.png',
                width: caught ? 150 : 100,
                height: caught ? 150 : 100,
                errorBuilder: (_, __, ___) => Icon(
                  caught ? Icons.groups_rounded : Icons.person_off_rounded,
                  size: 80,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 4),

              // ── Avatar ──
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: displayColor,
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: displayPlayer.selectedCharacter != null
                    ? Image.asset(
                  displayPlayer.selectedCharacter!.assetPath,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                )
                    : Text(
                  displayPlayer.name.characters.first
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                displayPlayer.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Gerçek Spy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
              ),

              // Oy sayısı (yakalandıysa)
              if (caught && mostVotedPlayer != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${voteCounts[mostVotedPlayer!.name] ?? 0} oy',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // ── Butonlar ──
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: onPlayAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: titleColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'TEKRAR OYNA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: onMainMenu,
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
                    side: BorderSide(color: titleColor, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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