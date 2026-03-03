import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_settings.freezed.dart';

@freezed
class GameSettings with _$GameSettings {
  const GameSettings._(); // enables custom getters

  const factory GameSettings({
    /// 3–9 inclusive (mirrors Kotlin validation)
    @Default(4) int playerCount,

    /// 1–15 minutes inclusive
    @Default(5) int durationMinutes,

    /// Whether a hint is shown to the spy
    @Default(true) bool hintsEnabled,
  }) = _GameSettings;

  int get durationSeconds => durationMinutes * 60;
}
