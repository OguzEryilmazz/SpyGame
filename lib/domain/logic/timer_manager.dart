import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_manager.freezed.dart';

// ── Warning level ─────────────────────────────────────────────────────────────

enum WarningLevel { normal, warning, critical, finished }

// ── Timer state (freezed) ─────────────────────────────────────────────────────

@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    required int timeLeft,
    required String formattedTime,
    /// 1.0 = full, 0.0 = done
    required double progress,
    required bool isFinished,
    required WarningLevel warningLevel,
  }) = _TimerState;
}

// ── Manager ───────────────────────────────────────────────────────────────────

/// Pure Dart — direct port of TimerManager.kt (Kotlin Flow → Dart Stream).
class TimerManager {
  /// Emits one [TimerState] per second then a final finished state.
  /// Mirrors Kotlin startCountdown() / `Flow<TimerState>`.
  Stream<TimerState> startCountdown(int durationInSeconds) async* {
    var timeLeft = durationInSeconds;

    while (timeLeft > 0) {
      yield _build(timeLeft, durationInSeconds);
      await Future<void>.delayed(const Duration(seconds: 1));
      timeLeft--;
    }

    yield TimerState(
      timeLeft: 0,
      formattedTime: '00:00',
      progress: 0.0,
      isFinished: true,
      warningLevel: WarningLevel.finished,
    );
  }

  /// Formats total seconds as MM:SS — mirrors Kotlin formatTime().
  String formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Mirrors Kotlin getTimeWarningLevel().
  WarningLevel warningLevelFor(int timeLeft) {
    if (timeLeft <= 0) return WarningLevel.finished;
    if (timeLeft <= 10) return WarningLevel.critical;
    if (timeLeft <= 30) return WarningLevel.warning;
    return WarningLevel.normal;
  }

  TimerState _build(int timeLeft, int total) => TimerState(
        timeLeft: timeLeft,
        formattedTime: formatTime(timeLeft),
        progress: total > 0 ? timeLeft / total : 0.0,
        isFinished: false,
        warningLevel: warningLevelFor(timeLeft),
      );
}
