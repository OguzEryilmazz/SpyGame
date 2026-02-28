import { Platform, Vibration } from 'react-native';
import ReactNativeHapticFeedback from 'react-native-haptic-feedback';

export class VibrationHelper {
  private static isEnabled = true;

  static setEnabled(enabled: boolean): void {
    this.isEnabled = enabled;
  }

  static vibrateLight(): void {
    if (!this.isEnabled) return;

    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('impactLight', {
        enableVibrateFallback: true,
        ignoreAndroidSystemSettings: false,
      });
    } else {
      Vibration.vibrate(10);
    }
  }

  static vibrateMedium(): void {
    if (!this.isEnabled) return;

    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('impactMedium', {
        enableVibrateFallback: true,
        ignoreAndroidSystemSettings: false,
      });
    } else {
      Vibration.vibrate(20);
    }
  }

  static vibrateHeavy(): void {
    if (!this.isEnabled) return;

    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('impactHeavy', {
        enableVibrateFallback: true,
        ignoreAndroidSystemSettings: false,
      });
    } else {
      Vibration.vibrate(40);
    }
  }

  static vibrateSuccess(): void {
    if (!this.isEnabled) return;

    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('notificationSuccess', {
        enableVibrateFallback: true,
        ignoreAndroidSystemSettings: false,
      });
    } else {
      Vibration.vibrate([0, 50, 50, 50]);
    }
  }

  static vibrateWarning(): void {
    if (!this.isEnabled) return;

    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('notificationWarning', {
        enableVibrateFallback: true,
        ignoreAndroidSystemSettings: false,
      });
    } else {
      Vibration.vibrate([0, 100, 100, 100]);
    }
  }

  static vibrateError(): void {
    if (!this.isEnabled) return;

    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('notificationError', {
        enableVibrateFallback: true,
        ignoreAndroidSystemSettings: false,
      });
    } else {
      Vibration.vibrate([0, 50, 100, 50]);
    }
  }

  static vibrateSingle(duration: number = 50): void {
    if (!this.isEnabled) return;

    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('impactMedium', {
        enableVibrateFallback: true,
        ignoreAndroidSystemSettings: false,
      });
    } else {
      Vibration.vibrate(duration);
    }
  }

  static vibratePattern(pattern?: number[]): void {
    if (!this.isEnabled) return;

    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('notificationWarning', {
        enableVibrateFallback: true,
        ignoreAndroidSystemSettings: false,
      });
    } else {
      Vibration.vibrate(pattern || [0, 200, 100, 200]);
    }
  }

  static cancel(): void {
    Vibration.cancel();
  }
}
