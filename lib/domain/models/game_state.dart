import 'package:freezed_annotation/freezed_annotation.dart';

import 'player.dart';
import 'category.dart';
import 'game_settings.dart';
import 'voting_result.dart';

part 'game_state.freezed.dart';

// ── Phase ─────────────────────────────────────────────────────────────────────

enum GamePhase {
  setup,
  playerSetup,
  categorySelect,
  roleReveal,
  timer,
  voting,
  results,
}

// ── State ─────────────────────────────────────────────────────────────────────

@freezed
class GameState with _$GameState {
  const factory GameState({
    @Default(GameSettings()) GameSettings settings,

    /// Plain players as entered on PlayerSetupScreen.
    @Default([]) List<Player> players,

    /// Selected sub-category for this round.
    SubCategory? selectedSubCategory,

    /// Players with roles — populated after GameEngine.assignRoles.
    @Default([]) List<GamePlayer> gamePlayers,

    /// Currently active phase.
    @Default(GamePhase.setup) GamePhase phase,

    /// Index of the player whose role card is being shown.
    @Default(0) int currentPlayerIndex,

    /// Populated after the voting phase completes.
    VotingResult? votingResult,
  }) = _GameState;
}
