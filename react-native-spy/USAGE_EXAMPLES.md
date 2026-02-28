# Usage Examples - React Native Spy Game

Complete examples showing how to use domain logic, platform helpers, state management, and services.

---

## 🧠 Domain Layer Usage

### GameEngine - Role Assignment

```typescript
import { GameEngine } from '../domain/GameEngine';
import { Player } from '../types/game.types';

// Create instance
const gameEngine = new GameEngine();

// Example players
const players: Player[] = [
  { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
  { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
  { id: 3, name: 'Charlie', selectedColor: '#4CAF50', selectedCharacter: null },
  { id: 4, name: 'Diana', selectedColor: '#FF9800', selectedCharacter: null },
];

// Category words and hints
const items = ['Titanic', 'Avatar', 'Inception', 'The Matrix'];
const hints = ['Director', 'Year', 'Genre', 'Main Actor'];

// Assign roles
const gamePlayers = gameEngine.assignRoles(players, items, hints, true);

console.log(gamePlayers);
/*
[
  { id: 1, name: 'Alice', role: 'Titanic', hint: null, ... },
  { id: 2, name: 'Bob', role: 'SPY', hint: 'Director', ... },
  { id: 3, name: 'Charlie', role: 'Titanic', hint: null, ... },
  { id: 4, name: 'Diana', role: 'Titanic', hint: null, ... },
]
*/

// Verify exactly 1 SPY
const spyCount = gamePlayers.filter(p => p.role === 'SPY').length;
console.log('SPY count:', spyCount); // 1

// Get SPY player
const spyPlayer = gameEngine.getSpyPlayer(gamePlayers);
console.log('SPY is:', spyPlayer?.name); // 'Bob'

// Get regular players
const regularPlayers = gameEngine.getRegularPlayers(gamePlayers);
console.log('Regular players:', regularPlayers.length); // 3
```

---

### GameEngine - Voting Calculation

```typescript
import { GameEngine } from '../domain/GameEngine';

const gameEngine = new GameEngine();

// Votes (voter name -> voted name)
const votes: Record<string, string> = {
  'Alice': 'Bob',
  'Bob': 'Charlie',
  'Charlie': 'Bob',
  'Diana': 'Bob',
};

// Calculate results
const result = gameEngine.calculateVotingResults(votes, gamePlayers);

console.log('Most voted:', result.mostVotedPlayer?.name); // 'Bob'
console.log('Spy caught:', result.isSpyCaught); // true (if Bob is SPY)
console.log('Vote counts:', result.voteCounts); // { Bob: 3, Charlie: 1 }
console.log('Actual SPY:', result.spyPlayer?.name);
```

**Use in component:**

```typescript
function VotingScreen() {
  const { gamePlayers } = useGameStore();
  const [votes, setVotes] = useState<Record<string, string>>({});
  const gameEngine = new GameEngine();

  const handleShowResults = () => {
    const result = gameEngine.calculateVotingResults(votes, gamePlayers);

    if (result.isSpyCaught) {
      Alert.alert('Başarılı!', 'Spy yakalandı!');
    } else {
      Alert.alert('Kaçtı!', `Spy: ${result.spyPlayer?.name}`);
    }
  };
}
```

---

### GameEngine - Validation

```typescript
const gameEngine = new GameEngine();

// Validate game setup
const validation = gameEngine.validateGameSetup(5, 10);

if (!validation.isValid) {
  Alert.alert('Hata', validation.error);
} else {
  console.log('Setup valid!');
}

// Examples
gameEngine.validateGameSetup(2, 10); // { isValid: false, error: 'Minimum 3 players' }
gameEngine.validateGameSetup(15, 10); // { isValid: false, error: 'Maximum 10 players' }
gameEngine.validateGameSetup(5, 0); // { isValid: false, error: 'Minimum 1 minute' }
gameEngine.validateGameSetup(5, 10); // { isValid: true }
```

---

### TimerManager - Countdown

```typescript
import { TimerManager } from '../domain/TimerManager';
import { TimerState } from '../types/game.types';

const timerManager = new TimerManager();

// Start 5-minute countdown
const cleanup = timerManager.startCountdown(
  300, // 5 minutes in seconds

  // Update callback (called every second)
  (state: TimerState) => {
    console.log(state.formattedTime); // "05:00" -> "04:59" -> ...
    console.log(state.warningLevel); // NORMAL, WARNING, CRITICAL, FINISHED
    console.log(state.timeLeft); // 300, 299, 298, ...
    console.log(state.isFinished); // false... false... true

    // Update UI
    setTimerState(state);

    // Vibrate at critical times
    if (timerManager.shouldVibrate(state.timeLeft)) {
      VibrationHelper.vibrateSingle(50);
    }
  },

  // Finish callback
  () => {
    console.log('Timer finished!');
    VibrationHelper.vibratePattern();
    navigation.navigate('Voting');
  }
);

// Cleanup when component unmounts
return () => cleanup();
```

**Full React component example:**

```typescript
function TimerScreen() {
  const { getGameDurationSeconds } = useGameStore();
  const [timerState, setTimerState] = useState<TimerState | null>(null);
  const timerManager = new TimerManager();

  useEffect(() => {
    const durationSeconds = getGameDurationSeconds();

    const cleanup = timerManager.startCountdown(
      durationSeconds,
      (state) => {
        setTimerState(state);

        if (timerManager.shouldVibrate(state.timeLeft)) {
          VibrationHelper.vibrateSingle(50);
        }
      },
      () => {
        VibrationHelper.vibratePattern();
        navigation.navigate('Voting');
      }
    );

    return cleanup;
  }, []);

  if (!timerState) return null;

  const backgroundColor = timerManager.getWarningColor(timerState.warningLevel);
  const progress = timerManager.getProgress(timerState.timeLeft, durationSeconds);

  return (
    <View style={{ backgroundColor }}>
      <Text>{timerState.formattedTime}</Text>
      <ProgressBar progress={progress} />
    </View>
  );
}
```

---

### TimerManager - Formatting

```typescript
const timerManager = new TimerManager();

// Format seconds to MM:SS
console.log(timerManager.formatTime(300)); // "05:00"
console.log(timerManager.formatTime(65)); // "01:05"
console.log(timerManager.formatTime(9)); // "00:09"
console.log(timerManager.formatTime(0)); // "00:00"

// Warning levels
console.log(timerManager.getTimeWarningLevel(300, 300)); // NORMAL (100%)
console.log(timerManager.getTimeWarningLevel(50, 300)); // WARNING (16%)
console.log(timerManager.getTimeWarningLevel(10, 300)); // CRITICAL (3%)
console.log(timerManager.getTimeWarningLevel(0, 300)); // FINISHED (0%)

// Warning colors
console.log(timerManager.getWarningColor(WarningLevel.NORMAL)); // '#4CAF50' (green)
console.log(timerManager.getWarningColor(WarningLevel.WARNING)); // '#FF9800' (orange)
console.log(timerManager.getWarningColor(WarningLevel.CRITICAL)); // '#F44336' (red)
```

---

### PlayerManager - Player Creation

```typescript
import { PlayerManager } from '../domain/PlayerManager';

const playerManager = new PlayerManager();

// Create 5 default players
const players = playerManager.createDefaultPlayers(5);

console.log(players);
/*
[
  { id: 1, name: 'Player 1', selectedColor: '#E91E63', selectedCharacter: 'pic_1' },
  { id: 2, name: 'Player 2', selectedColor: '#9C27B0', selectedCharacter: 'pic_2' },
  { id: 3, name: 'Player 3', selectedColor: '#3F51B5', selectedCharacter: 'pic_3' },
  { id: 4, name: 'Player 4', selectedColor: '#2196F3', selectedCharacter: 'pic_4' },
  { id: 5, name: 'Player 5', selectedColor: '#00BCD4', selectedCharacter: 'pic_5' },
]
*/

// Reuse existing players
const existingPlayers = [
  { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: 'pic_1' },
];

const reusedPlayers = playerManager.createDefaultPlayers(3, existingPlayers);
/*
[
  { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: 'pic_1' },
  { id: 2, name: 'Player 2', selectedColor: '#9C27B0', selectedCharacter: 'pic_2' },
  { id: 3, name: 'Player 3', selectedColor: '#3F51B5', selectedCharacter: 'pic_3' },
]
*/
```

---

### PlayerManager - Validation

```typescript
const playerManager = new PlayerManager();

const players = [
  { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
  { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
  { id: 3, name: '', selectedColor: '#4CAF50', selectedCharacter: null }, // Empty name
  { id: 4, name: 'Alice', selectedColor: '#FF9800', selectedCharacter: null }, // Duplicate
];

// Full validation
const validation = playerManager.validatePlayers(players);
console.log(validation.isValid); // false
console.log(validation.errors);
/*
[
  'All players must have names',
  'Player names must be unique'
]
*/

// Quick validation
const isValid = playerManager.isPlayerSetupValid(players);
console.log(isValid); // false

// Check if valid
const validPlayers = [
  { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
  { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
];

console.log(playerManager.isPlayerSetupValid(validPlayers)); // true
```

---

### PlayerManager - Helpers

```typescript
const playerManager = new PlayerManager();

// Get all available colors
const colors = playerManager.getAllColors();
console.log(colors); // ['#E91E63', '#9C27B0', ...]

// Get available color (not used)
const usedColors = ['#E91E63', '#9C27B0'];
const availableColor = playerManager.getAvailableColor(usedColors);
console.log(availableColor); // '#3F51B5'

// Get all characters
const characters = playerManager.getAllCharacters();
console.log(characters); // [CharacterAvatar.PIC_1, ...]

// Check name uniqueness
const isUnique = playerManager.isNameUnique(players, 'NewName');
console.log(isUnique); // true

const isDuplicate = playerManager.isNameUnique(players, 'Alice');
console.log(isDuplicate); // false
```

---

## 🔧 Platform Layer Usage

### VibrationHelper - Haptic Feedback

```typescript
import { VibrationHelper } from '../platform/VibrationHelper';

// Success feedback (for successful actions)
VibrationHelper.vibrateSuccess();

// Warning feedback (for warnings)
VibrationHelper.vibrateWarning();

// Error feedback (for errors)
VibrationHelper.vibrateError();

// Light impact (for button presses)
VibrationHelper.vibrateLight();

// Medium impact (for important actions)
VibrationHelper.vibrateMedium();

// Heavy impact (for critical actions)
VibrationHelper.vibrateHeavy();

// Selection feedback (for pickers)
VibrationHelper.vibrateSelection();

// Custom pattern
VibrationHelper.vibratePattern([0, 200, 100, 200, 100, 400]);

// Single vibration
VibrationHelper.vibrateSingle(100); // 100ms

// Cancel vibration
VibrationHelper.cancel();
```

**Use in components:**

```typescript
// Button press
<TouchableOpacity onPress={() => {
  VibrationHelper.vibrateLight();
  handleAction();
}}>
  <Text>Press Me</Text>
</TouchableOpacity>

// Success action
const handleSubmit = async () => {
  try {
    await saveData();
    VibrationHelper.vibrateSuccess();
    Alert.alert('Success', 'Data saved!');
  } catch (error) {
    VibrationHelper.vibrateError();
    Alert.alert('Error', 'Failed to save');
  }
};

// Timer vibration
useEffect(() => {
  if (timeLeft <= 10 && timeLeft > 0) {
    VibrationHelper.vibrateSingle(50);
  }
  if (timeLeft === 0) {
    VibrationHelper.vibratePattern();
  }
}, [timeLeft]);
```

---

### ScreenHelper - Keep Screen Awake

```typescript
import { ScreenHelper } from '../platform/ScreenHelper';

// Keep screen on (prevent auto-lock)
await ScreenHelper.keepScreenOn();

// Allow screen to turn off
ScreenHelper.allowScreenOff();

// Check status
const isKeptOn = ScreenHelper.isScreenKeptOn();
console.log('Screen kept on:', isKeptOn);
```

**Use in TimerScreen:**

```typescript
function TimerScreen() {
  useEffect(() => {
    // Keep screen on when timer starts
    ScreenHelper.keepScreenOn();

    return () => {
      // Allow screen off when component unmounts
      ScreenHelper.allowScreenOff();
    };
  }, []);

  return <View>...</View>;
}
```

---

## 📦 State Management (Zustand)

### Reading State

```typescript
import { useGameStore } from '../store/gameStore';

function MyComponent() {
  // Get specific values
  const { settings, players, gamePlayers } = useGameStore();

  // Get all state
  const gameState = useGameStore();

  // Get computed values
  const duration = useGameStore(state => state.getGameDurationSeconds());
  const inProgress = useGameStore(state => state.isGameInProgress());

  return (
    <View>
      <Text>Players: {settings.playerCount}</Text>
      <Text>Duration: {duration} seconds</Text>
      <Text>In Progress: {inProgress ? 'Yes' : 'No'}</Text>
    </View>
  );
}
```

---

### Updating State

```typescript
function SetupScreen() {
  const { settings, updateSettings } = useGameStore();

  const incrementPlayers = () => {
    updateSettings({ playerCount: settings.playerCount + 1 });
  };

  const decrementPlayers = () => {
    updateSettings({ playerCount: settings.playerCount - 1 });
  };

  const toggleHints = () => {
    updateSettings({ showHints: !settings.showHints });
  };

  return (
    <View>
      <Button onPress={incrementPlayers} title="+" />
      <Text>{settings.playerCount}</Text>
      <Button onPress={decrementPlayers} title="-" />

      <Switch value={settings.showHints} onValueChange={toggleHints} />
    </View>
  );
}
```

---

### Starting Game Workflow

```typescript
function CategoryScreen() {
  const { players, startGame } = useGameStore();

  const handleCategorySelect = (category: Category) => {
    // Zustand store's startGame uses GameEngine internally
    startGame(category);

    // Navigate to game screen
    navigation.navigate('Game');
  };

  return <CategoryList onSelect={handleCategorySelect} />;
}
```

**What happens internally:**

```typescript
// Inside gameStore.ts
startGame: (category, subcategory) => {
  const { players, settings } = get();
  const gameEngine = new GameEngine();

  const items = subcategory?.items || category.items;
  const hints = subcategory?.hints || category.hints;

  const gamePlayers = gameEngine.assignRoles(
    players,
    items,
    hints,
    settings.showHints
  );

  set({
    gamePlayers,
    selectedCategory: category,
    selectedSubcategory: subcategory || null,
    currentPhase: 'game',
  });
}
```

---

### Resetting Game

```typescript
function VotingScreen() {
  const { resetGame } = useGameStore();

  const handlePlayAgain = () => {
    resetGame();
    navigation.navigate('Setup');
  };

  return (
    <Button onPress={handlePlayAgain} title="Play Again" />
  );
}
```

---

## 🌐 Services Usage

### AdService - AdMob Integration

```typescript
import { AdService } from '../services/AdService';

// Initialize in App.tsx
useEffect(() => {
  AdService.initialize();
  AdService.loadInterstitialAd();
  AdService.loadRewardedAd();
}, []);

// Show interstitial with frequency control
AdService.showInterstitialWithFrequency(() => {
  console.log('Ad dismissed, continue game');
  navigation.navigate('NextScreen');
});

// Show interstitial (always)
await AdService.showInterstitialAd(() => {
  console.log('Ad dismissed');
});

// Show rewarded ad
await AdService.showRewardedAd(
  (amount) => {
    console.log('Reward earned:', amount);
    unlockSubcategory();
  },
  () => {
    console.log('Ad dismissed');
  }
);

// Check if ad is ready
if (AdService.isInterstitialReady()) {
  await AdService.showInterstitialAd();
}

// Reset counter
AdService.resetInterstitialCounter();
```

---

### PurchaseService - IAP

```typescript
import { PurchaseService } from '../services/PurchaseService';

// Initialize
await PurchaseService.initialize();

// Load products
const products = await PurchaseService.loadProducts();
console.log('Available products:', products);

// Get product price
const price = PurchaseService.getProductPrice('category_movies');
console.log('Price:', price); // "$9.99"

// Purchase product
await PurchaseService.purchaseProduct(
  'category_movies',
  (purchase) => {
    console.log('Purchase successful:', purchase);
    unlockCategory('movies');
  },
  (error) => {
    console.error('Purchase failed:', error);
    Alert.alert('Error', 'Purchase failed');
  }
);

// Restore purchases (iOS only)
const purchases = await PurchaseService.restorePurchases();
console.log('Restored purchases:', purchases);

// Check if purchased
const isPurchased = await PurchaseService.isPurchased('category_movies');
if (isPurchased) {
  console.log('User owns this category');
}
```

---

## 🎯 Complete Workflows

### Complete Game Flow

```typescript
// 1. Setup Screen
function SetupScreen() {
  const { updateSettings } = useGameStore();

  const handleContinue = () => {
    updateSettings({ playerCount: 5, gameDurationMinutes: 10 });
    navigation.navigate('PlayerSetup');
  };
}

// 2. Player Setup Screen
function PlayerSetupScreen() {
  const { players, setPlayers } = useGameStore();
  const playerManager = new PlayerManager();

  useEffect(() => {
    const defaultPlayers = playerManager.createDefaultPlayers(5);
    setPlayers(defaultPlayers);
  }, []);

  const handleContinue = () => {
    if (playerManager.isPlayerSetupValid(players)) {
      navigation.navigate('Category');
    }
  };
}

// 3. Category Screen
function CategoryScreen() {
  const { startGame } = useGameStore();

  const handleSelect = (category: Category) => {
    startGame(category);

    AdService.showInterstitialWithFrequency(() => {
      navigation.navigate('Game');
    });
  };
}

// 4. Game Screen (role reveal)
function GameScreen() {
  const { gamePlayers } = useGameStore();
  // Show each player's role one by one
  // Navigate to Timer when done
}

// 5. Timer Screen
function TimerScreen() {
  const timerManager = new TimerManager();
  const { getGameDurationSeconds } = useGameStore();

  useEffect(() => {
    ScreenHelper.keepScreenOn();

    const cleanup = timerManager.startCountdown(
      getGameDurationSeconds(),
      (state) => setTimerState(state),
      () => {
        VibrationHelper.vibratePattern();
        ScreenHelper.allowScreenOff();
        navigation.navigate('Voting');
      }
    );

    return cleanup;
  }, []);
}

// 6. Voting Screen
function VotingScreen() {
  const { gamePlayers } = useGameStore();
  const gameEngine = new GameEngine();

  const handleShowResults = () => {
    const result = gameEngine.calculateVotingResults(votes, gamePlayers);

    Alert.alert(
      result.isSpyCaught ? 'Spy Caught!' : 'Spy Escaped!',
      `The spy was: ${result.spyPlayer?.name}`
    );
  };
}
```

---

**All examples preserve clean architecture with domain logic separated from UI!** 🎉
