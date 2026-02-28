import { activateKeepAwakeAsync, deactivateKeepAwake } from 'expo-keep-awake';

export class ScreenHelper {
  private static isKeepAwakeActive = false;

  static async keepScreenOn(): Promise<void> {
    if (!this.isKeepAwakeActive) {
      try {
        await activateKeepAwakeAsync();
        this.isKeepAwakeActive = true;
      } catch (error) {
        console.error('Failed to activate keep awake:', error);
      }
    }
  }

  static allowScreenOff(): void {
    if (this.isKeepAwakeActive) {
      try {
        deactivateKeepAwake();
        this.isKeepAwakeActive = false;
      } catch (error) {
        console.error('Failed to deactivate keep awake:', error);
      }
    }
  }

  static isScreenLockActive(): boolean {
    return this.isKeepAwakeActive;
  }
}
