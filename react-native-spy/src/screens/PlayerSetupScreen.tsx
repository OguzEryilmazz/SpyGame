import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ScrollView,
  SafeAreaView,
  Alert,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import LinearGradient from 'react-native-linear-gradient';
import { useGameStore } from '../store/gameStore';
import { VibrationHelper } from '../platform/VibrationHelper';
import { PlayerManager } from '../domain/PlayerManager';
import { Player } from '../types';

type RootStackParamList = {
  Setup: undefined;
  PlayerSetup: undefined;
  Category: undefined;
  Game: undefined;
  Timer: undefined;
  Voting: undefined;
};

type NavigationProp = NativeStackNavigationProp<
  RootStackParamList,
  'PlayerSetup'
>;

export const PlayerSetupScreen: React.FC = () => {
  const navigation = useNavigation<NavigationProp>();
  const { settings, players: storedPlayers, setPlayers } = useGameStore();
  const [players, setLocalPlayers] = useState<Player[]>([]);
  const playerManager = new PlayerManager();

  useEffect(() => {
    const defaultPlayers = playerManager.createDefaultPlayers(
      settings.playerCount,
      storedPlayers
    );
    setLocalPlayers(defaultPlayers);
  }, [settings.playerCount]);

  const updatePlayerName = (index: number, name: string) => {
    const updated = [...players];
    updated[index] = { ...updated[index], name };
    setLocalPlayers(updated);
  };

  const handleColorSelect = (index: number) => {
    VibrationHelper.vibrateLight();
    const availableColors = playerManager.getAvailableColors(
      players[index].selectedColor,
      players
    );

    if (availableColors.length === 0) return;

    const currentIndex = availableColors.indexOf(players[index].selectedColor);
    const nextIndex = (currentIndex + 1) % availableColors.length;
    const nextColor = availableColors[nextIndex];

    const updated = [...players];
    updated[index] = { ...updated[index], selectedColor: nextColor };
    setLocalPlayers(updated);
  };

  const handleNext = () => {
    const validation = playerManager.validatePlayers(players);

    if (!validation.isValid) {
      VibrationHelper.vibrateError();
      Alert.alert('Validation Error', validation.errors.join('\n'));
      return;
    }

    VibrationHelper.vibrateMedium();
    setPlayers(players);
    navigation.navigate('Category');
  };

  const handleBack = () => {
    VibrationHelper.vibrateLight();
    navigation.goBack();
  };

  return (
    <LinearGradient
      colors={['#1a237e', '#283593', '#3949ab']}
      style={styles.container}
    >
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.header}>
          <TouchableOpacity onPress={handleBack} style={styles.backButton}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Player Setup</Text>
          <View style={styles.backButton} />
        </View>

        <ScrollView
          style={styles.scrollView}
          contentContainerStyle={styles.scrollContent}
        >
          {players.map((player, index) => (
            <View key={player.id} style={styles.playerCard}>
              <View style={styles.playerHeader}>
                <Text style={styles.playerNumber}>Player {index + 1}</Text>
                <TouchableOpacity
                  style={[
                    styles.colorCircle,
                    { backgroundColor: player.selectedColor },
                  ]}
                  onPress={() => handleColorSelect(index)}
                />
              </View>
              <TextInput
                style={styles.input}
                value={player.name}
                onChangeText={(text) => updatePlayerName(index, text)}
                placeholder={`Enter name for Player ${index + 1}`}
                placeholderTextColor="rgba(255, 255, 255, 0.5)"
                maxLength={20}
              />
            </View>
          ))}
        </ScrollView>

        <View style={styles.footer}>
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
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
  },
  backButton: {
    width: 80,
  },
  backButtonText: {
    fontSize: 16,
    color: '#ffffff',
    fontWeight: '600',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ffffff',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: 20,
    paddingTop: 0,
  },
  playerCard: {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 15,
    padding: 15,
    marginBottom: 15,
  },
  playerHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  playerNumber: {
    fontSize: 16,
    fontWeight: '600',
    color: '#ffffff',
  },
  colorCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 3,
    borderColor: '#ffffff',
  },
  input: {
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    borderRadius: 10,
    padding: 12,
    fontSize: 16,
    color: '#ffffff',
  },
  footer: {
    padding: 20,
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
