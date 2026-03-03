import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';

// ── Role ─────────────────────────────────────────────────────────────────────

enum PlayerRole { spy, civilian }

// ── Setup-time player ────────────────────────────────────────────────────────
// Stores display data only — no role assigned yet.

@freezed
class Player with _$Player {
  const factory Player({
    required String id,
    required String name,

    /// Index into PlayerManager.availableColors
    required int colorIndex,

    /// 0-based index into CharacterAvatar (0–8)
    @Default(0) int avatarIndex,
  }) = _Player;
}

// ── In-game player (after GameEngine.assignRoles) ─────────────────────────────

@freezed
class GamePlayer with _$GamePlayer {
  const GamePlayer._(); // enables custom getters

  const factory GamePlayer({
    required String id,
    required String name,
    required int colorIndex,
    required int avatarIndex,
    required PlayerRole role,

    /// Shared word that civilians see. null for the spy.
    String? word,

    /// Hint shown only to the spy when hintsEnabled is true.
    String? spyHint,
  }) = _GamePlayer;

  bool get isSpy => role == PlayerRole.spy;
}
