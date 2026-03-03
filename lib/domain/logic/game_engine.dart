import 'dart:math';

import '../models/player.dart';
import '../models/category.dart';
import '../models/voting_result.dart';

// ── Result types ──────────────────────────────────────────────────────────────

class GameValidationResult {
  final bool isValid;
  final List<String> errors;
  const GameValidationResult({required this.isValid, required this.errors});
}

// ── Engine ────────────────────────────────────────────────────────────────────

/// Pure Dart — zero Flutter / Android imports.
/// Direct port of GameEngine.kt.
class GameEngine {
  final Random _rng;

  GameEngine({Random? random}) : _rng = random ?? Random();

  // ── Role assignment ────────────────────────────────────────────────────────

  /// Mirrors Kotlin assignRoles():
  ///   • Shuffles players randomly.
  ///   • Picks one random spy.
  ///   • Picks a random word from the sub-category.
  ///   • Optionally picks a random spy hint when [hintsEnabled] is true.
  List<GamePlayer> assignRoles({
    required List<Player> players,
    required SubCategory subCategory,
    bool hintsEnabled = true,
  }) {
    if (players.isEmpty) return [];
    if (subCategory.items.isEmpty) return [];

    final shuffled = List<Player>.from(players)..shuffle(_rng);
    final spyIndex = _rng.nextInt(shuffled.length);
    final word = subCategory.items[_rng.nextInt(subCategory.items.length)];

    final String? spyHint = hintsEnabled && subCategory.hints.isNotEmpty
        ? subCategory.hints[_rng.nextInt(subCategory.hints.length)]
        : null;

    return List.generate(shuffled.length, (i) {
      final p = shuffled[i];
      if (i == spyIndex) {
        return GamePlayer(
          id: p.id,
          name: p.name,
          colorIndex: p.colorIndex,
          avatarIndex: p.avatarIndex,
          role: PlayerRole.spy,
          word: null,
          spyHint: spyHint,
        );
      } else {
        return GamePlayer(
          id: p.id,
          name: p.name,
          colorIndex: p.colorIndex,
          avatarIndex: p.avatarIndex,
          role: PlayerRole.civilian,
          word: word,
          spyHint: null,
        );
      }
    });
  }

  // ── Voting ─────────────────────────────────────────────────────────────────

  /// Mirrors Kotlin calculateVotingResults().
  ///
  /// [votes] maps voter-id → voted-player-name (same key type as Kotlin's
  /// `Map<String, String>`).
  VotingResult calculateVotingResults({
    required Map<String, String> votes,
    required List<GamePlayer> gamePlayers,
  }) {
    final spy = gamePlayers.firstWhere(
      (p) => p.isSpy,
      orElse: () => gamePlayers.first,
    );

    if (votes.isEmpty) {
      return VotingResult(
        mostVotedPlayer: null,
        spyPlayer: spy,
        isSpyCaught: false,
        voteCounts: const {},
      );
    }

    // Tally votes: playerName → count
    final tally = <String, int>{};
    for (final votedName in votes.values) {
      tally[votedName] = (tally[votedName] ?? 0) + 1;
    }

    // Find the most-voted name
    final sorted = tally.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Tie → mostVotedPlayer stays null
    final isTie = sorted.length > 1 && sorted[0].value == sorted[1].value;
    final mostVotedName = isTie ? null : sorted.first.key;
    final mostVoted = mostVotedName == null
        ? null
        : gamePlayers.cast<GamePlayer?>().firstWhere(
            (p) => p?.name == mostVotedName,
            orElse: () => null,
          );

    return VotingResult(
      mostVotedPlayer: mostVoted,
      spyPlayer: spy,
      isSpyCaught: mostVoted?.id == spy.id,
      voteCounts: tally,
    );
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  /// Mirrors Kotlin validateGameSetup().
  GameValidationResult validateGameSetup({
    required int playerCount,
    required int durationMinutes,
  }) {
    final errors = <String>[];

    if (playerCount < 3) errors.add('En az 3 oyuncu gereklidir');
    if (playerCount > 9) errors.add('En fazla 9 oyuncu olabilir');
    if (durationMinutes < 1) errors.add('Oyun süresi en az 1 dakika olmalıdır');
    if (durationMinutes > 15) errors.add('Oyun süresi en fazla 15 dakika olabilir');

    return GameValidationResult(isValid: errors.isEmpty, errors: errors);
  }
}
