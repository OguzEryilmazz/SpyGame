import 'dart:ui' show Color;

import '../models/player.dart';

// ── Validation result ─────────────────────────────────────────────────────────

class PlayerValidationResult {
  final bool isValid;
  final List<String> errors;
  const PlayerValidationResult({required this.isValid, required this.errors});
}

// ── Manager ───────────────────────────────────────────────────────────────────

/// Pure Dart — direct port of PlayerManager.kt.
/// Uses dart:ui Color so it stays decoupled from Flutter widgets.
class PlayerManager {
  /// Same hex values and order as Kotlin availableColors.
  static const List<Color> availableColors = [
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
    Color(0xFFFFEB3B),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
    Color(0xFF795548),
    Color(0xFF607D8B),
  ];

  static const int avatarCount = 9; // pic_1 … pic_9

  // ── Create ──────────────────────────────────────────────────────────────────

  /// Mirrors Kotlin createDefaultPlayers().
  ///
  /// Preserves [existing] players up to [count], then fills the rest with
  /// auto-generated players that avoid already-used colors and avatars.
  List<Player> createDefaultPlayers(
    int count, {
    List<Player> existing = const [],
  }) {
    final result = <Player>[];

    for (var i = 0; i < existing.length && i < count; i++) {
      result.add(existing[i].copyWith(id: '${i + 1}'));
    }

    final missing = count - result.length;
    for (var i = 0; i < missing; i++) {
      final playerId = result.length + 1;
      final usedColorIndices = result.map((p) => p.colorIndex).toSet();
      final usedAvatarIndices = result.map((p) => p.avatarIndex).toSet();

      final colorIndex = _firstUnused(
        availableColors.length,
        usedColorIndices,
        fallback: (playerId - 1) % availableColors.length,
      );
      final avatarIndex = _firstUnused(
        avatarCount,
        usedAvatarIndices,
        fallback: (playerId - 1) % avatarCount,
      );

      result.add(Player(
        id: '$playerId',
        name: 'Oyuncu $playerId',
        colorIndex: colorIndex,
        avatarIndex: avatarIndex,
      ));
    }

    return result;
  }

  // ── Validate ────────────────────────────────────────────────────────────────

  /// Mirrors Kotlin validatePlayers().
  PlayerValidationResult validatePlayers(List<Player> players) {
    final errors = <String>[];

    if (players.any((p) => p.name.trim().isEmpty)) {
      errors.add('Tüm oyuncuların isimleri dolu olmalıdır');
    }

    final nameCounts = <String, int>{};
    for (final p in players) {
      final key = p.name.trim();
      nameCounts[key] = (nameCounts[key] ?? 0) + 1;
    }
    if (nameCounts.values.any((c) => c > 1)) {
      errors.add('Oyuncu isimleri benzersiz olmalıdır');
    }

    final colorCounts = <int, int>{};
    for (final p in players) {
      colorCounts[p.colorIndex] = (colorCounts[p.colorIndex] ?? 0) + 1;
    }
    if (colorCounts.values.any((c) => c > 1)) {
      errors.add('Her oyuncunun benzersiz bir rengi olmalıdır');
    }

    return PlayerValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Quick check — used to enable/disable the "Next" button in the UI.
  bool isSetupValid(List<Player> players) {
    if (players.isEmpty) return false;
    if (players.any((p) => p.name.trim().isEmpty)) return false;
    return players.map((p) => p.colorIndex).toSet().length == players.length;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Color colorAt(int index) => availableColors[index % availableColors.length];

  int firstAvailableColorIndex(Set<int> usedIndices) =>
      _firstUnused(availableColors.length, usedIndices, fallback: 0);

  int firstAvailableAvatarIndex(Set<int> usedIndices) =>
      _firstUnused(avatarCount, usedIndices, fallback: 0);

  int _firstUnused(int total, Set<int> used, {required int fallback}) {
    for (var i = 0; i < total; i++) {
      if (!used.contains(i)) return i;
    }
    return fallback;
  }
}
