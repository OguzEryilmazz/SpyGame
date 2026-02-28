import { TimerManager } from '../../src/domain/TimerManager';
import { WarningLevel } from '../../src/types/game.types';

describe('TimerManager', () => {
  let timerManager: TimerManager;

  beforeEach(() => {
    timerManager = new TimerManager();
    jest.useFakeTimers();
  });

  afterEach(() => {
    timerManager.stop();
    jest.clearAllTimers();
    jest.useRealTimers();
  });

  describe('formatTime', () => {
    it('should format time correctly', () => {
      expect(timerManager.formatTime(300)).toBe('05:00');
      expect(timerManager.formatTime(65)).toBe('01:05');
      expect(timerManager.formatTime(9)).toBe('00:09');
      expect(timerManager.formatTime(0)).toBe('00:00');
      expect(timerManager.formatTime(3661)).toBe('61:01');
    });

    it('should handle negative time', () => {
      expect(timerManager.formatTime(-10)).toBe('00:00');
    });

    it('should pad single digits with zero', () => {
      expect(timerManager.formatTime(9)).toBe('00:09');
      expect(timerManager.formatTime(60)).toBe('01:00');
      expect(timerManager.formatTime(69)).toBe('01:09');
    });
  });

  describe('getTimeWarningLevel', () => {
    const totalDuration = 300; // 5 minutes

    it('should return NORMAL when time > 25%', () => {
      const level = timerManager.getTimeWarningLevel(300, totalDuration);
      expect(level).toBe(WarningLevel.NORMAL);
    });

    it('should return WARNING when time <= 25% and > 10%', () => {
      const level = timerManager.getTimeWarningLevel(50, totalDuration);
      expect(level).toBe(WarningLevel.WARNING);
    });

    it('should return CRITICAL when time <= 10% and > 0', () => {
      const level = timerManager.getTimeWarningLevel(10, totalDuration);
      expect(level).toBe(WarningLevel.CRITICAL);
    });

    it('should return FINISHED when time <= 0', () => {
      const level = timerManager.getTimeWarningLevel(0, totalDuration);
      expect(level).toBe(WarningLevel.FINISHED);

      const levelNegative = timerManager.getTimeWarningLevel(-5, totalDuration);
      expect(levelNegative).toBe(WarningLevel.FINISHED);
    });

    it('should handle edge cases correctly', () => {
      expect(timerManager.getTimeWarningLevel(76, totalDuration)).toBe(WarningLevel.NORMAL); // 25.3%
      expect(timerManager.getTimeWarningLevel(75, totalDuration)).toBe(WarningLevel.WARNING); // 25%
      expect(timerManager.getTimeWarningLevel(31, totalDuration)).toBe(WarningLevel.CRITICAL); // 10.3%
      expect(timerManager.getTimeWarningLevel(30, totalDuration)).toBe(WarningLevel.CRITICAL); // 10%
      expect(timerManager.getTimeWarningLevel(1, totalDuration)).toBe(WarningLevel.CRITICAL);
      expect(timerManager.getTimeWarningLevel(0, totalDuration)).toBe(WarningLevel.FINISHED);
    });
  });

  describe('getWarningColor', () => {
    it('should return correct colors for warning levels', () => {
      expect(timerManager.getWarningColor(WarningLevel.NORMAL)).toBe('#4CAF50');
      expect(timerManager.getWarningColor(WarningLevel.WARNING)).toBe('#FF9800');
      expect(timerManager.getWarningColor(WarningLevel.CRITICAL)).toBe('#F44336');
      expect(timerManager.getWarningColor(WarningLevel.FINISHED)).toBe('#9E9E9E');
    });
  });

  describe('getProgress', () => {
    it('should calculate progress percentage correctly', () => {
      expect(timerManager.getProgress(300, 300)).toBe(100);
      expect(timerManager.getProgress(150, 300)).toBe(50);
      expect(timerManager.getProgress(0, 300)).toBe(0);
      expect(timerManager.getProgress(75, 300)).toBe(25);
    });

    it('should handle edge cases', () => {
      expect(timerManager.getProgress(0, 0)).toBe(0);
      expect(timerManager.getProgress(300, 0)).toBe(0);
      expect(timerManager.getProgress(-10, 300)).toBe(0);
      expect(timerManager.getProgress(400, 300)).toBe(100); // Capped at 100
    });
  });

  describe('shouldVibrate', () => {
    it('should vibrate for last 10 seconds', () => {
      expect(timerManager.shouldVibrate(10)).toBe(true);
      expect(timerManager.shouldVibrate(5)).toBe(true);
      expect(timerManager.shouldVibrate(1)).toBe(true);
      expect(timerManager.shouldVibrate(0)).toBe(true);
    });

    it('should not vibrate above 10 seconds', () => {
      expect(timerManager.shouldVibrate(11)).toBe(false);
      expect(timerManager.shouldVibrate(60)).toBe(false);
      expect(timerManager.shouldVibrate(300)).toBe(false);
    });

    it('should not vibrate for negative time', () => {
      expect(timerManager.shouldVibrate(-1)).toBe(false);
    });
  });

  describe('startCountdown', () => {
    it('should call onUpdate every second', () => {
      const onUpdate = jest.fn();
      const onFinish = jest.fn();

      timerManager.startCountdown(5, onUpdate, onFinish);

      // Initial call
      expect(onUpdate).toHaveBeenCalledTimes(1);

      // After 1 second
      jest.advanceTimersByTime(1000);
      expect(onUpdate).toHaveBeenCalledTimes(2);

      // After 2 seconds
      jest.advanceTimersByTime(1000);
      expect(onUpdate).toHaveBeenCalledTimes(3);
    });

    it('should call onFinish when countdown reaches 0', () => {
      const onUpdate = jest.fn();
      const onFinish = jest.fn();

      timerManager.startCountdown(3, onUpdate, onFinish);

      // Fast forward to completion
      jest.advanceTimersByTime(3000);

      expect(onFinish).toHaveBeenCalledTimes(1);
    });

    it('should emit correct timer states', () => {
      const onUpdate = jest.fn();
      const onFinish = jest.fn();

      timerManager.startCountdown(3, onUpdate, onFinish);

      // Check initial state
      expect(onUpdate).toHaveBeenNthCalledWith(1, {
        timeLeft: 3,
        formattedTime: '00:03',
        warningLevel: WarningLevel.CRITICAL,
        isFinished: false,
      });

      // After 1 second
      jest.advanceTimersByTime(1000);
      expect(onUpdate).toHaveBeenNthCalledWith(2, {
        timeLeft: 2,
        formattedTime: '00:02',
        warningLevel: WarningLevel.CRITICAL,
        isFinished: false,
      });
    });

    it('should stop after countdown finishes', () => {
      const onUpdate = jest.fn();
      const onFinish = jest.fn();

      timerManager.startCountdown(2, onUpdate, onFinish);

      // Fast forward past completion
      jest.advanceTimersByTime(3000);

      // Should not call onUpdate more than expected
      expect(onUpdate.mock.calls.length).toBeLessThan(5);
    });

    it('should return cleanup function', () => {
      const onUpdate = jest.fn();
      const onFinish = jest.fn();

      const cleanup = timerManager.startCountdown(10, onUpdate, onFinish);

      expect(typeof cleanup).toBe('function');

      // Cleanup should stop timer
      cleanup();

      const callCountBeforeCleanup = onUpdate.mock.calls.length;
      jest.advanceTimersByTime(5000);
      expect(onUpdate).toHaveBeenCalledTimes(callCountBeforeCleanup);
    });
  });

  describe('stop', () => {
    it('should stop the countdown', () => {
      const onUpdate = jest.fn();
      const onFinish = jest.fn();

      timerManager.startCountdown(10, onUpdate, onFinish);

      const callCountBeforeStop = onUpdate.mock.calls.length;

      timerManager.stop();

      // Advance time and verify no more calls
      jest.advanceTimersByTime(5000);
      expect(onUpdate).toHaveBeenCalledTimes(callCountBeforeStop);
      expect(onFinish).not.toHaveBeenCalled();
    });

    it('should be safe to call multiple times', () => {
      const onUpdate = jest.fn();
      const onFinish = jest.fn();

      timerManager.startCountdown(10, onUpdate, onFinish);

      expect(() => {
        timerManager.stop();
        timerManager.stop();
        timerManager.stop();
      }).not.toThrow();
    });
  });
});
