import 'package:freezed_annotation/freezed_annotation.dart';

import 'player.dart';

part 'voting_result.freezed.dart';

@freezed
class VotingResult with _$VotingResult {
  const VotingResult._(); // enables custom getters

  const factory VotingResult({
    /// Player who received the most votes. null on a tie.
    GamePlayer? mostVotedPlayer,

    /// The actual spy in this round.
    required GamePlayer spyPlayer,

    /// True when the most-voted player IS the spy.
    @Default(false) bool isSpyCaught,

    /// playerName → vote count
    @Default({}) Map<String, int> voteCounts,
  }) = _VotingResult;

  bool get isTie => mostVotedPlayer == null;
}
