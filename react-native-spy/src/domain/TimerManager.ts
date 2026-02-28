import { TimerState, WarningLevel } from '../types';

export class TimerManager {
  private intervalId: NodeJS.Timeout | null = null;
  private readonly WARNING_THRESHOLD = 0.3;
  private readonly CRITICAL_THRESHOLD = 0.1;

  startCountdown(
    durationSeconds: number,
    onUpdate: (state: TimerState) => void,
    onFinish: () => void
  ): () => void {
    this.stopCountdown();

    let timeLeft = durationSeconds;
    const totalDuration = durationSeconds;

    const emitState = () => {
      const state: TimerState = {
        timeLeft,
        isRunning: timeLeft > 0,
        warningLevel: this.getTimeWarningLevel(timeLeft, totalDuration),
        formattedTime: this.formatTime(timeLeft),
      };
      onUpdate(state);
    };

    emitState();

    this.intervalId = setInterval(() => {
      timeLeft--;

      if (timeLeft <= 0) {
        this.stopCountdown();
        const finalState: TimerState = {
          timeLeft: 0,
          isRunning: false,
          warningLevel: WarningLevel.FINISHED,
          formattedTime: this.formatTime(0),
        };
        onUpdate(finalState);
        onFinish();
      } else {
        emitState();
      }
    }, 1000);

    return () => this.stopCountdown();
  }

  stopCountdown(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs
      .toString()
      .padStart(2, '0')}`;
  }

  getTimeWarningLevel(
    timeLeft: number,
    totalDuration: number
  ): WarningLevel {
    if (timeLeft <= 0) {
      return WarningLevel.FINISHED;
    }

    const ratio = timeLeft / totalDuration;

    if (ratio <= this.CRITICAL_THRESHOLD) {
      return WarningLevel.CRITICAL;
    }

    if (ratio <= this.WARNING_THRESHOLD) {
      return WarningLevel.WARNING;
    }

    return WarningLevel.NORMAL;
  }

  shouldVibrate(timeLeft: number): boolean {
    return timeLeft <= 10 && timeLeft > 0;
  }

  getTimerColor(warningLevel: WarningLevel): string {
    switch (warningLevel) {
      case WarningLevel.CRITICAL:
        return '#F44336';
      case WarningLevel.WARNING:
        return '#FF9800';
      case WarningLevel.FINISHED:
        return '#9E9E9E';
      default:
        return '#4CAF50';
    }
  }

  calculateProgress(timeLeft: number, totalDuration: number): number {
    if (totalDuration <= 0) return 0;
    return timeLeft / totalDuration;
  }
}
