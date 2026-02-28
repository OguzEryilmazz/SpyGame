import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Switch,
  SafeAreaView,
  StatusBar,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import LinearGradient from 'react-native-linear-gradient';
import { useGameStore } from '../store/gameStore';
import { VibrationHelper } from '../platform/VibrationHelper';
import { GameEngine } from '../domain/GameEngine';

type RootStackParamList = {
  Setup: undefined;
  PlayerSetup: undefined;
  Category: undefined;
  Game: undefined;
  Timer: undefined;
  Voting: undefined;
};

type NavigationProp = NativeStackNavigationProp<RootStackParamList, 'Setup'>;

export const SetupScreen: React.FC = () => {
  const navigation = useNavigation<NavigationProp>();
  const { settings, updateSettings } = useGameStore();
  const gameEngine = new GameEngine();

  const incrementPlayers = () => {
    if (settings.playerCount < 12) {
      VibrationHelper.vibrateLight();
      updateSettings({ playerCount: settings.playerCount + 1 });
    }
  };

  const decrementPlayers = () => {
    if (settings.playerCount > 3) {
      VibrationHelper.vibrateLight();
      updateSettings({ playerCount: settings.playerCount - 1 });
    }
  };

  const incrementDuration = () => {
    if (settings.gameDurationMinutes < 15) {
      VibrationHelper.vibrateLight();
      updateSettings({
        gameDurationMinutes: settings.gameDurationMinutes + 1,
      });
    }
  };

  const decrementDuration = () => {
    if (settings.gameDurationMinutes > 1) {
      VibrationHelper.vibrateLight();
      updateSettings({
        gameDurationMinutes: settings.gameDurationMinutes - 1,
      });
    }
  };

  const toggleHints = () => {
    VibrationHelper.vibrateLight();
    updateSettings({ showHints: !settings.showHints });
  };

  const handleNext = () => {
    const validation = gameEngine.validateGameSetup(
      settings.playerCount,
      settings.gameDurationMinutes
    );

    if (!validation.isValid) {
      VibrationHelper.vibrateError();
      return;
    }

    VibrationHelper.vibrateMedium();
    navigation.navigate('PlayerSetup');
  };

  return (
    <LinearGradient
      colors={['#1a237e', '#283593', '#3949ab']}
      style={styles.container}
    >
      <StatusBar barStyle="light-content" />
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.content}>
          <Text style={styles.title}>SPY GAME</Text>
          <Text style={styles.subtitle}>Game Setup</Text>

          <View style={styles.settingsContainer}>
            <View style={styles.settingRow}>
              <Text style={styles.label}>Number of Players</Text>
              <View style={styles.counter}>
                <TouchableOpacity
                  style={[
                    styles.counterButton,
                    settings.playerCount <= 3 && styles.counterButtonDisabled,
                  ]}
                  onPress={decrementPlayers}
                  disabled={settings.playerCount <= 3}
                >
                  <Text style={styles.counterButtonText}>-</Text>
                </TouchableOpacity>
                <Text style={styles.counterValue}>{settings.playerCount}</Text>
                <TouchableOpacity
                  style={[
                    styles.counterButton,
                    settings.playerCount >= 12 && styles.counterButtonDisabled,
                  ]}
                  onPress={incrementPlayers}
                  disabled={settings.playerCount >= 12}
                >
                  <Text style={styles.counterButtonText}>+</Text>
                </TouchableOpacity>
              </View>
            </View>

            <View style={styles.settingRow}>
              <Text style={styles.label}>Game Duration (minutes)</Text>
              <View style={styles.counter}>
                <TouchableOpacity
                  style={[
                    styles.counterButton,
                    settings.gameDurationMinutes <= 1 &&
                      styles.counterButtonDisabled,
                  ]}
                  onPress={decrementDuration}
                  disabled={settings.gameDurationMinutes <= 1}
                >
                  <Text style={styles.counterButtonText}>-</Text>
                </TouchableOpacity>
                <Text style={styles.counterValue}>
                  {settings.gameDurationMinutes}
                </Text>
                <TouchableOpacity
                  style={[
                    styles.counterButton,
                    settings.gameDurationMinutes >= 15 &&
                      styles.counterButtonDisabled,
                  ]}
                  onPress={incrementDuration}
                  disabled={settings.gameDurationMinutes >= 15}
                >
                  <Text style={styles.counterButtonText}>+</Text>
                </TouchableOpacity>
              </View>
            </View>

            <View style={styles.settingRow}>
              <Text style={styles.label}>Show Hints to Spy</Text>
              <Switch
                value={settings.showHints}
                onValueChange={toggleHints}
                trackColor={{ false: '#757575', true: '#4CAF50' }}
                thumbColor={settings.showHints ? '#ffffff' : '#f4f3f4'}
              />
            </View>
          </View>

          <TouchableOpacity style={styles.nextButton} onPress={handleNext}>
            <LinearGradient
              colors={['#4CAF50', '#66BB6A']}
              style={styles.nextButtonGradient}
            >
              <Text style={styles.nextButtonText}>Next</Text>
            </LinearGradient>
          </TouchableOpacity>
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
    padding: 20,
    justifyContent: 'center',
  },
  title: {
    fontSize: 48,
    fontWeight: 'bold',
    color: '#ffffff',
    textAlign: 'center',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 24,
    color: '#ffffff',
    textAlign: 'center',
    marginBottom: 50,
    opacity: 0.9,
  },
  settingsContainer: {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 20,
    padding: 20,
    marginBottom: 30,
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 25,
  },
  label: {
    fontSize: 18,
    color: '#ffffff',
    flex: 1,
  },
  counter: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 15,
  },
  counterButton: {
    width: 45,
    height: 45,
    borderRadius: 22.5,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  counterButtonDisabled: {
    opacity: 0.3,
  },
  counterButtonText: {
    fontSize: 24,
    color: '#ffffff',
    fontWeight: 'bold',
  },
  counterValue: {
    fontSize: 24,
    color: '#ffffff',
    fontWeight: 'bold',
    minWidth: 40,
    textAlign: 'center',
  },
  nextButton: {
    borderRadius: 30,
    overflow: 'hidden',
  },
  nextButtonGradient: {
    paddingVertical: 18,
    alignItems: 'center',
  },
  nextButtonText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#ffffff',
  },
});
