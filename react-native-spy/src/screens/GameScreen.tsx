import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
  Dimensions,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import LinearGradient from 'react-native-linear-gradient';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { RootStackParamList } from '../navigation/types';
import { useGameStore } from '../store/gameStore';
import { VibrationHelper } from '../platform/VibrationHelper';

type NavigationProp = NativeStackNavigationProp<RootStackParamList, 'Game'>;

const { width, height } = Dimensions.get('window');

export default function GameScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { gamePlayers } = useGameStore();

  const [currentPlayerIndex, setCurrentPlayerIndex] = useState(0);
  const [isRevealed, setIsRevealed] = useState(false);
  const [flipAnim] = useState(new Animated.Value(0));
  const [scaleAnim] = useState(new Animated.Value(1));

  if (gamePlayers.length === 0) {
    return (
      <LinearGradient colors={['#E91E63', '#9C27B0', '#F44336']} style={styles.container}>
        <Text style={styles.errorText}>Oyun başlatılmadı</Text>
        <TouchableOpacity
          style={styles.errorButton}
          onPress={() => navigation.navigate('Setup')}
        >
          <Text style={styles.errorButtonText}>Ana Menüye Dön</Text>
        </TouchableOpacity>
      </LinearGradient>
    );
  }

  const currentPlayer = gamePlayers[currentPlayerIndex];
  const isSpy = currentPlayer.role === 'SPY';
  const isLastPlayer = currentPlayerIndex === gamePlayers.length - 1;

  const handleReveal = () => {
    if (isRevealed) return;

    VibrationHelper.vibrateMedium();
    setIsRevealed(true);

    // Flip animation
    Animated.sequence([
      Animated.timing(scaleAnim, {
        toValue: 1.1,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.timing(flipAnim, {
        toValue: 1,
        duration: 400,
        useNativeDriver: true,
      }),
      Animated.timing(scaleAnim, {
        toValue: 1,
        duration: 100,
        useNativeDriver: true,
      }),
    ]).start();
  };

  const handleNext = () => {
    VibrationHelper.vibrateLight();

    if (isLastPlayer) {
      // All players have seen their roles, go to timer
      navigation.navigate('Timer');
    } else {
      // Move to next player
      setCurrentPlayerIndex(currentPlayerIndex + 1);
      setIsRevealed(false);

      // Reset animations
      flipAnim.setValue(0);
      scaleAnim.setValue(1);
    }
  };

  const handleSkip = () => {
    VibrationHelper.vibrateLight();
    navigation.navigate('Timer');
  };

  const flipInterpolate = flipAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '180deg'],
  });

  const frontOpacity = flipAnim.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: [1, 0, 0],
  });

  const backOpacity = flipAnim.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: [0, 0, 1],
  });

  return (
    <LinearGradient
      colors={
        isRevealed && isSpy
          ? ['#F44336', '#E91E63', '#9C27B0']
          : ['#E91E63', '#9C27B0', '#F44336']
      }
      style={styles.container}
    >
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.progressContainer}>
          <Text style={styles.progressText}>
            {currentPlayerIndex + 1} / {gamePlayers.length}
          </Text>
          <View style={styles.progressBar}>
            <View
              style={[
                styles.progressFill,
                {
                  width: `${((currentPlayerIndex + 1) / gamePlayers.length) * 100}%`,
                },
              ]}
            />
          </View>
        </View>
        <TouchableOpacity style={styles.skipButton} onPress={handleSkip}>
          <Text style={styles.skipButtonText}>Geç</Text>
        </TouchableOpacity>
      </View>

      {/* Player Card */}
      <View style={styles.content}>
        <Text style={styles.instruction}>
          {isRevealed ? 'Rolünü gördün!' : 'Sıra sende!'}
        </Text>

        <Animated.View
          style={[
            styles.cardContainer,
            {
              transform: [{ rotateY: flipInterpolate }, { scale: scaleAnim }],
            },
          ]}
        >
          {/* Front - Player Name */}
          <Animated.View style={[styles.card, styles.cardFront, { opacity: frontOpacity }]}>
            <View
              style={[styles.playerAvatar, { backgroundColor: currentPlayer.selectedColor }]}
            >
              <Text style={styles.playerInitial}>
                {currentPlayer.name.charAt(0).toUpperCase()}
              </Text>
            </View>
            <Text style={styles.playerName}>{currentPlayer.name}</Text>
            <Text style={styles.tapToReveal}>Dokunarak rolünü gör</Text>
            <Icon name="visibility" size={40} color="rgba(255, 255, 255, 0.5)" />
          </Animated.View>

          {/* Back - Role */}
          <Animated.View
            style={[
              styles.card,
              styles.cardBack,
              { opacity: backOpacity, backgroundColor: isSpy ? '#F44336' : '#4CAF50' },
            ]}
          >
            <Text style={styles.roleLabel}>{isSpy ? 'Sen SPYSIN!' : 'Senin Kelimen'}</Text>

            {isSpy ? (
              <>
                <View style={styles.spyIcon}>
                  <Icon name="visibility-off" size={80} color="#fff" />
                </View>
                <Text style={styles.spyText}>Kimliğini Gizle</Text>
                {currentPlayer.hint && (
                  <View style={styles.hintContainer}>
                    <Icon name="lightbulb" size={20} color="#FFD700" />
                    <Text style={styles.hintText}>{currentPlayer.hint}</Text>
                  </View>
                )}
              </>
            ) : (
              <>
                <View style={styles.wordContainer}>
                  <Text style={styles.word}>{currentPlayer.role}</Text>
                </View>
                <Text style={styles.regularText}>Spy'ı Bul!</Text>
              </>
            )}
          </Animated.View>
        </Animated.View>

        {/* Action Button */}
        {!isRevealed ? (
          <TouchableOpacity style={styles.revealButton} onPress={handleReveal}>
            <Icon name="touch-app" size={24} color="#fff" />
            <Text style={styles.revealButtonText}>Rolümü Göster</Text>
          </TouchableOpacity>
        ) : (
          <TouchableOpacity style={styles.nextButton} onPress={handleNext}>
            <Text style={styles.nextButtonText}>
              {isLastPlayer ? 'Oyunu Başlat' : 'Sıradaki Oyuncu'}
            </Text>
            <Icon name="arrow-forward" size={24} color="#E91E63" />
          </TouchableOpacity>
        )}
      </View>

      {/* Warning */}
      {isRevealed && (
        <View style={styles.warning}>
          <Icon name="warning" size={20} color="#FFD700" />
          <Text style={styles.warningText}>
            Rolünü kimseye gösterme!
          </Text>
        </View>
      )}
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingTop: 60,
    paddingBottom: 20,
  },
  progressContainer: { flex: 1, marginRight: 16 },
  progressText: {
    fontSize: 14,
    color: '#fff',
    fontWeight: '600',
    marginBottom: 8,
  },
  progressBar: {
    height: 6,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#fff',
    borderRadius: 3,
  },
  skipButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
  },
  skipButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#fff',
  },
  content: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  instruction: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 40,
    textAlign: 'center',
  },
  cardContainer: {
    width: width - 48,
    height: height * 0.5,
    marginBottom: 40,
  },
  card: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    backgroundColor: '#fff',
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    backfaceVisibility: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.3,
    shadowRadius: 16,
    elevation: 16,
  },
  cardFront: {},
  cardBack: {
    transform: [{ rotateY: '180deg' }],
  },
  playerAvatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 20,
  },
  playerInitial: {
    fontSize: 48,
    fontWeight: 'bold',
    color: '#fff',
  },
  playerName: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#212121',
    marginBottom: 16,
  },
  tapToReveal: {
    fontSize: 16,
    color: '#757575',
    marginBottom: 20,
  },
  roleLabel: {
    fontSize: 20,
    fontWeight: '600',
    color: '#fff',
    marginBottom: 24,
  },
  spyIcon: {
    marginBottom: 24,
  },
  spyText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
  },
  hintContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 12,
    marginTop: 20,
  },
  hintText: {
    fontSize: 16,
    color: '#fff',
    marginLeft: 8,
    fontWeight: '600',
  },
  wordContainer: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    paddingHorizontal: 32,
    paddingVertical: 20,
    borderRadius: 16,
    marginBottom: 24,
  },
  word: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#fff',
    textAlign: 'center',
  },
  regularText: {
    fontSize: 20,
    fontWeight: '600',
    color: '#fff',
  },
  revealButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    paddingHorizontal: 32,
    paddingVertical: 16,
    borderRadius: 16,
    borderWidth: 2,
    borderColor: '#fff',
  },
  revealButtonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
    marginLeft: 8,
  },
  nextButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    paddingHorizontal: 32,
    paddingVertical: 16,
    borderRadius: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  nextButtonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#E91E63',
    marginRight: 8,
  },
  warning: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    paddingVertical: 16,
    paddingHorizontal: 24,
  },
  warningText: {
    fontSize: 14,
    color: '#fff',
    marginLeft: 8,
    fontWeight: '600',
  },
  errorText: {
    fontSize: 20,
    color: '#fff',
    textAlign: 'center',
  },
  errorButton: {
    backgroundColor: '#fff',
    paddingHorizontal: 32,
    paddingVertical: 16,
    borderRadius: 12,
    marginTop: 24,
  },
  errorButtonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#E91E63',
  },
});
