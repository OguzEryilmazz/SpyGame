import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  SafeAreaView,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import LinearGradient from 'react-native-linear-gradient';
import { useGameStore } from '../store/gameStore';
import { VibrationHelper } from '../platform/VibrationHelper';
import { ScreenHelper } from '../platform/ScreenHelper';
import { TimerManager } from '../domain/TimerManager';
import { TimerState, WarningLevel } from '../types';

type RootStackParamList = {
  Setup: undefined;
  PlayerSetup: undefined;
  Category: undefined;
  Game: undefined;
  Timer: undefined;
  Voting: undefined;
};

type NavigationProp = NativeStackNavigationProp<RootStackParamList, 'Timer'>;

export const TimerScreen: React.FC = () => {
  const navigation = useNavigation<NavigationProp>();
  const { settings, moveToPhase } = useGameStore();
  const [timerState, setTimerState] = useState<TimerState>({
    timeLeft: settings.gameDurationMinutes * 60,
    isRunning: false,
    warningLevel: WarningLevel.NORMAL,
    formattedTime: '00:00',
  });
  const [isPaused, setIsPaused] = useState(false);

  const timerManager = new TimerManager();

  useEffect(() => {
    ScreenHelper.keepScreenOn();

    const cleanup = timerManager.startCountdown(
      settings.gameDurationMinutes * 60,
      (state) => {
        setTimerState(state);

        if (timerManager.shouldVibrate(state.timeLeft)) {
          VibrationHelper.vibrateSingle(50);
        }
      },
      () => {
        VibrationHelper.vibratePattern([0, 200, 100, 200]);
        ScreenHelper.allowScreenOff();
        moveToPhase('voting');
        navigation.navigate('Voting');
      }
    );

    return () => {
      cleanup();
      ScreenHelper.allowScreenOff();
    };
  }, []);

  const handleEnd = () => {
    VibrationHelper.vibrateMedium();
    timerManager.stopCountdown();
    ScreenHelper.allowScreenOff();
    moveToPhase('voting');
    navigation.navigate('Voting');
  };

  const getGradientColors = (): string[] => {
    switch (timerState.warningLevel) {
      case WarningLevel.CRITICAL:
        return ['#D32F2F', '#F44336', '#E57373'];
      case WarningLevel.WARNING:
        return ['#F57C00', '#FF9800', '#FFB74D'];
      case WarningLevel.FINISHED:
        return ['#616161', '#757575', '#9E9E9E'];
      default:
        return ['#1976D2', '#2196F3', '#64B5F6'];
    }
  };

  const progress = timerManager.calculateProgress(
    timerState.timeLeft,
    settings.gameDurationMinutes * 60
  );

  return (
    <LinearGradient colors={getGradientColors()} style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.content}>
          <Text style={styles.title}>Game Timer</Text>

          <View style={styles.timerContainer}>
            <View style={styles.circleProgress}>
              <View
                style={[
                  styles.circleProgressFill,
                  {
                    height: `${progress * 100}%`,
                  },
                ]}
              />
              <View style={styles.timerContent}>
                <Text style={styles.timerText}>{timerState.formattedTime}</Text>
                <Text style={styles.timerLabel}>
                  {timerState.warningLevel === WarningLevel.CRITICAL
                    ? 'Hurry Up!'
                    : timerState.warningLevel === WarningLevel.WARNING
                    ? 'Time Running Out'
                    : timerState.warningLevel === WarningLevel.FINISHED
                    ? 'Time\'s Up!'
                    : 'Remaining Time'}
                </Text>
              </View>
            </View>
          </View>

          <View style={styles.actions}>
            <TouchableOpacity style={styles.endButton} onPress={handleEnd}>
              <Text style={styles.endButtonText}>End Game</Text>
            </TouchableOpacity>
          </View>
        </View>
      </SafeAreaView>
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
  },
  content: {
    flex: 1,
    justifyContent: 'space-between',
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#ffffff',
    textAlign: 'center',
    marginTop: 20,
  },
  timerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  circleProgress: {
    width: 280,
    height: 280,
    borderRadius: 140,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    overflow: 'hidden',
    position: 'relative',
  },
  circleProgressFill: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
  },
  timerContent: {
    position: 'absolute',
    alignItems: 'center',
  },
  timerText: {
    fontSize: 72,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 8,
  },
  timerLabel: {
    fontSize: 18,
    color: '#ffffff',
    opacity: 0.9,
  },
  actions: {
    gap: 15,
  },
  endButton: {
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    borderRadius: 15,
    paddingVertical: 18,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#ffffff',
  },
  endButtonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#ffffff',
  },
});
