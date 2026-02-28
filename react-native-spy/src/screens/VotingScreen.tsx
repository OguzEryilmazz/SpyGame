import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
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
import { GameEngine } from '../domain/GameEngine';

type RootStackParamList = {
  Setup: undefined;
  PlayerSetup: undefined;
  Category: undefined;
  Game: undefined;
  Timer: undefined;
  Voting: undefined;
};

type NavigationProp = NativeStackNavigationProp<RootStackParamList, 'Voting'>;

export const VotingScreen: React.FC = () => {
  const navigation = useNavigation<NavigationProp>();
  const { gamePlayers, recordVote, resetGame } = useGameStore();
  const [selectedVotes, setSelectedVotes] = useState<Record<string, string>>({});
  const [showResults, setShowResults] = useState(false);
  const gameEngine = new GameEngine();

  const handleVote = (voterId: string, votedPlayerId: string) => {
    VibrationHelper.vibrateLight();
    setSelectedVotes((prev) => ({
      ...prev,
      [voterId]: votedPlayerId,
    }));
  };

  const handleSubmitVotes = () => {
    const allVoted = gamePlayers.every((player) =>
      selectedVotes.hasOwnProperty(player.id.toString())
    );

    if (!allVoted) {
      VibrationHelper.vibrateError();
      Alert.alert('Incomplete Votes', 'All players must cast their votes');
      return;
    }

    Object.entries(selectedVotes).forEach(([voterId, votedPlayerId]) => {
      recordVote(voterId, votedPlayerId);
    });

    VibrationHelper.vibrateMedium();
    setShowResults(true);
  };

  const handlePlayAgain = () => {
    VibrationHelper.vibrateLight();
    resetGame();
    navigation.navigate('Setup');
  };

  const result = gameEngine.calculateVotingResults(selectedVotes, gamePlayers);
  const spyPlayer = gamePlayers.find((p) => p.role === 'SPY');

  if (showResults) {
    return (
      <LinearGradient
        colors={
          result.isSpyCaught
            ? ['#4CAF50', '#66BB6A', '#81C784']
            : ['#F44336', '#E57373', '#EF5350']
        }
        style={styles.container}
      >
        <SafeAreaView style={styles.safeArea}>
          <View style={styles.resultsContainer}>
            <Text style={styles.resultsTitle}>
              {result.isSpyCaught ? '🎉 Spy Caught!' : '😈 Spy Escaped!'}
            </Text>

            <View style={styles.resultsCard}>
              <Text style={styles.resultsLabel}>The Spy Was:</Text>
              <View
                style={[
                  styles.spyAvatar,
                  { backgroundColor: spyPlayer?.selectedColor || '#E91E63' },
                ]}
              >
                <Text style={styles.spyInitial}>
                  {spyPlayer?.name.charAt(0).toUpperCase()}
                </Text>
              </View>
              <Text style={styles.spyName}>{spyPlayer?.name}</Text>
            </View>

            <TouchableOpacity style={styles.playAgainButton} onPress={handlePlayAgain}>
              <Text style={styles.playAgainText}>Play Again</Text>
            </TouchableOpacity>
          </View>
        </SafeAreaView>
      </LinearGradient>
    );
  }

  return (
    <LinearGradient colors={['#5E35B1', '#7E57C2', '#9575CD']} style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.header}>
          <Text style={styles.title}>Vote for the Spy</Text>
        </View>

        <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
          {gamePlayers.map((voter) => {
            const selectedPlayer = selectedVotes[voter.id.toString()];

            return (
              <View key={voter.id} style={styles.voterCard}>
                <View style={styles.voterHeader}>
                  <View style={[styles.voterAvatar, { backgroundColor: voter.selectedColor }]}>
                    <Text style={styles.voterInitial}>
                      {voter.name.charAt(0).toUpperCase()}
                    </Text>
                  </View>
                  <Text style={styles.voterName}>{voter.name}</Text>
                </View>

                <View style={styles.candidatesContainer}>
                  {gamePlayers
                    .filter((p) => p.id !== voter.id)
                    .map((candidate) => {
                      const isSelected = selectedPlayer === candidate.id.toString();

                      return (
                        <TouchableOpacity
                          key={candidate.id}
                          style={[
                            styles.candidateButton,
                            isSelected && styles.candidateButtonSelected,
                          ]}
                          onPress={() => handleVote(voter.id.toString(), candidate.id.toString())}
                        >
                          <View
                            style={[
                              styles.candidateAvatar,
                              { backgroundColor: candidate.selectedColor },
                            ]}
                          >
                            <Text style={styles.candidateInitial}>
                              {candidate.name.charAt(0).toUpperCase()}
                            </Text>
                          </View>
                          <Text style={styles.candidateName}>{candidate.name}</Text>
                        </TouchableOpacity>
                      );
                    })}
                </View>
              </View>
            );
          })}
        </ScrollView>

        <View style={styles.footer}>
          <TouchableOpacity style={styles.submitButton} onPress={handleSubmitVotes}>
            <Text style={styles.submitButtonText}>Show Results</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1 },
  safeArea: { flex: 1 },
  header: { padding: 20 },
  title: { fontSize: 28, fontWeight: 'bold', color: '#ffffff', textAlign: 'center' },
  scrollView: { flex: 1 },
  scrollContent: { padding: 20, paddingTop: 0 },
  voterCard: { backgroundColor: 'rgba(255, 255, 255, 0.95)', borderRadius: 15, padding: 15, marginBottom: 15 },
  voterHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 15 },
  voterAvatar: { width: 50, height: 50, borderRadius: 25, justifyContent: 'center', alignItems: 'center' },
  voterInitial: { fontSize: 20, fontWeight: 'bold', color: '#ffffff' },
  voterName: { fontSize: 18, fontWeight: '600', color: '#212121', marginLeft: 12 },
  candidatesContainer: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  candidateButton: { backgroundColor: '#f5f5f5', borderRadius: 12, padding: 10, alignItems: 'center', minWidth: 80, borderWidth: 2, borderColor: 'transparent' },
  candidateButtonSelected: { backgroundColor: '#E8F5E9', borderColor: '#4CAF50' },
  candidateAvatar: { width: 40, height: 40, borderRadius: 20, justifyContent: 'center', alignItems: 'center', marginBottom: 6 },
  candidateInitial: { fontSize: 16, fontWeight: 'bold', color: '#ffffff' },
  candidateName: { fontSize: 12, fontWeight: '600', color: '#212121' },
  footer: { padding: 20 },
  submitButton: { backgroundColor: '#4CAF50', borderRadius: 15, paddingVertical: 18, alignItems: 'center' },
  submitButtonText: { fontSize: 18, fontWeight: 'bold', color: '#ffffff' },
  resultsContainer: { flex: 1, justifyContent: 'center', padding: 20 },
  resultsTitle: { fontSize: 36, fontWeight: 'bold', color: '#ffffff', textAlign: 'center', marginBottom: 30 },
  resultsCard: { backgroundColor: 'rgba(255, 255, 255, 0.95)', borderRadius: 20, padding: 25, alignItems: 'center', marginBottom: 20 },
  resultsLabel: { fontSize: 18, color: '#757575', marginBottom: 15 },
  spyAvatar: { width: 100, height: 100, borderRadius: 50, justifyContent: 'center', alignItems: 'center', marginBottom: 15 },
  spyInitial: { fontSize: 40, fontWeight: 'bold', color: '#ffffff' },
  spyName: { fontSize: 28, fontWeight: 'bold', color: '#212121' },
  playAgainButton: { backgroundColor: '#ffffff', borderRadius: 15, paddingVertical: 18, alignItems: 'center' },
  playAgainText: { fontSize: 18, fontWeight: 'bold', color: '#5E35B1' },
});
