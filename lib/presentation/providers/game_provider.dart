import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/game_state.dart';
import '../../domain/models/player.dart';
import '../../domain/models/category.dart';
import '../../domain/logic/game_engine.dart';
import '../../domain/logic/player_manager.dart';
import '../../domain/logic/timer_manager.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

final gameEngineProvider = Provider<GameEngine>((_) => GameEngine());
final playerManagerProvider = Provider<PlayerManager>((_) => PlayerManager());
final timerManagerProvider = Provider<TimerManager>((_) => TimerManager());

// ── Game state provider ───────────────────────────────────────────────────────

final gameStateProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);

// ── Notifier ──────────────────────────────────────────────────────────────────

/// Riverpod Notifier — replaces the old StateNotifier + GameStateManager.kt.
/// All game-flow mutations live here; pure domain classes do the actual logic.
class GameNotifier extends Notifier<GameState> {
  late GameEngine _engine;
  late PlayerManager _playerManager;

  @override
  GameState build() {
    _engine = ref.read(gameEngineProvider);
    _playerManager = ref.read(playerManagerProvider);
    return const GameState();
  }

  // ── Setup screen ────────────────────────────────────────────────────────────

  void updatePlayerCount(int count) {
    final validation = _engine.validateGameSetup(
      playerCount: count,
      durationMinutes: state.settings.durationMinutes,
    );
    if (!validation.isValid) return;

    // Keep existing players, extending or trimming the list as needed.
    final updatedPlayers = _playerManager.createDefaultPlayers(
      count,
      existing: state.players,
    );
    state = state.copyWith(
      settings: state.settings.copyWith(playerCount: count),
      players: updatedPlayers,
    );
  }

  void updateDuration(int minutes) {
    state = state.copyWith(
      settings: state.settings.copyWith(durationMinutes: minutes),
    );
  }

  void toggleHints() {
    state = state.copyWith(
      settings: state.settings.copyWith(
        hintsEnabled: !state.settings.hintsEnabled,
      ),
    );
  }

  void goToPlayerSetup() {
    final players = _playerManager.createDefaultPlayers(
      state.settings.playerCount,
      existing: state.players,
    );
    state = state.copyWith(
      players: players,
      phase: GamePhase.playerSetup,
    );
  }

  // ── Player setup screen ─────────────────────────────────────────────────────

  void updatePlayer(Player updated) {
    final players = [
      for (final p in state.players)
        if (p.id == updated.id) updated else p,
    ];
    state = state.copyWith(players: players);
  }

  void goToCategorySelect() {
    final result = _playerManager.validatePlayers(state.players);
    if (!result.isValid) return;
    state = state.copyWith(phase: GamePhase.categorySelect);
  }

  void goBackToSetup() {
    state = state.copyWith(phase: GamePhase.setup);
  }

  void goBackToPlayerSetup() {
    state = state.copyWith(phase: GamePhase.playerSetup);
  }

  void goBackToCategorySelect() {
    state = state.copyWith(phase: GamePhase.categorySelect);
  }

  // ── Category screen ─────────────────────────────────────────────────────────

  void selectSubCategory(SubCategory subCategory) {
    final gamePlayers = _engine.assignRoles(
      players: state.players,
      subCategory: subCategory,
      hintsEnabled: state.settings.hintsEnabled,
    );
    state = state.copyWith(
      selectedSubCategory: subCategory,
      gamePlayers: gamePlayers,
      currentPlayerIndex: 0,
      phase: GamePhase.roleReveal,
    );
  }

  // ── Role reveal screen ──────────────────────────────────────────────────────

  /// Advance to the next player's card, or move to the timer phase.
  void nextPlayer() {
    final next = state.currentPlayerIndex + 1;
    if (next >= state.gamePlayers.length) {
      state = state.copyWith(
        phase: GamePhase.timer,
        currentPlayerIndex: 0,
      );
    } else {
      state = state.copyWith(currentPlayerIndex: next);
    }
  }

  // ── Timer screen ────────────────────────────────────────────────────────────

  void goToVoting() {
    state = state.copyWith(phase: GamePhase.voting);
  }

  // ── Voting screen ───────────────────────────────────────────────────────────

  /// [votes] maps voter-id → voted-player-name (matches Kotlin `Map<String,String>`).
  void submitVotes(Map<String, String> votes) {
    final result = _engine.calculateVotingResults(
      votes: votes,
      gamePlayers: state.gamePlayers,
    );
    state = state.copyWith(
      votingResult: result,
      phase: GamePhase.results,
    );
  }

  // ── Global ──────────────────────────────────────────────────────────────────

  void resetGame() => state = const GameState();
}
