# SPY Game - React Native

A cross-platform party game built with React Native and TypeScript, migrated from the original Android Kotlin/Jetpack Compose version.

## Project Structure

```
react-native-spy/
├── src/
│   ├── domain/           # Pure TypeScript business logic (platform-independent)
│   │   ├── GameEngine.ts
│   │   ├── TimerManager.ts
│   │   ├── PlayerManager.ts
│   │   └── GameStateManager.ts
│   ├── platform/         # iOS + Android abstractions
│   │   ├── VibrationHelper.ts
│   │   └── ScreenHelper.ts
│   ├── store/            # Zustand state management
│   │   ├── gameStore.ts
│   │   └── categoryStore.ts
│   ├── services/         # AdMob and IAP integration
│   │   ├── AdService.ts
│   │   └── PurchaseService.ts
│   ├── screens/          # React Native UI screens
│   │   ├── SetupScreen.tsx
│   │   ├── PlayerSetupScreen.tsx
│   │   ├── CategoryScreen.tsx
│   │   ├── GameScreen.tsx
│   │   ├── TimerScreen.tsx
│   │   └── VotingScreen.tsx
│   ├── navigation/       # React Navigation setup
│   │   └── RootNavigator.tsx
│   ├── types/            # TypeScript type definitions
│   │   ├── game.types.ts
│   │   ├── player.types.ts
│   │   └── category.types.ts
│   └── data/             # Mock data
│       └── mockCategories.ts
├── __tests__/            # Unit tests for domain layer
│   └── domain/
│       ├── GameEngine.test.ts
│       ├── TimerManager.test.ts
│       └── PlayerManager.test.ts
├── App.tsx               # Entry point
├── package.json
└── tsconfig.json
```

## Tech Stack

- **Framework**: React Native 0.73
- **Language**: TypeScript
- **State Management**: Zustand with AsyncStorage persistence
- **Navigation**: React Navigation (Native Stack)
- **Ads**: react-native-google-mobile-ads
- **In-App Purchases**: react-native-iap
- **Haptic Feedback**: react-native-haptic-feedback
- **UI**: react-native-linear-gradient

## Installation

```bash
# Install dependencies
npm install

# iOS specific (Mac only)
cd ios && pod install && cd ..

# Run on iOS
npm run ios

# Run on Android
npm run android
```

## Architecture

### Clean Architecture Layers

1. **Domain Layer** (Pure TypeScript)
   - Zero platform dependencies
   - Contains all game logic
   - Fully testable with Jest
   - Can run in Node.js, web, or any JavaScript runtime

2. **Platform Layer** (iOS + Android Abstractions)
   - Hides platform differences
   - Provides unified APIs for vibration, screen wake, etc.

3. **UI Layer** (React Native)
   - Uses domain logic via Zustand stores
   - No business logic in components
   - Type-safe navigation

4. **Services Layer**
   - AdMob integration (cross-platform)
   - IAP integration (StoreKit + Play Billing)

## Key Features

- **Game Setup**: Configure player count (3-12), duration (1-15 min), hints toggle
- **Player Setup**: Assign names, colors, and avatars
- **Category Selection**: 
  - Free and paid categories
  - Favorites system
  - Subcategories with rewarded ad unlocks
  - Search and filter
- **Role Assignment**: 1 SPY + regular players (via GameEngine)
- **Role Reveal**: Animated flip cards with role display
- **Timer**: Countdown with vibration warnings, screen wake lock
- **Voting**: Each player votes for suspected spy
- **Results**: Shows vote breakdown and spy reveal

## Domain Layer Examples

```typescript
// GameEngine - Role assignment
const gameEngine = new GameEngine();
const gamePlayers = gameEngine.assignRoles(
  players,      // Player[]
  items,        // string[] (category words)
  hints,        // string[] (hints for spy)
  showHints     // boolean
);
// Returns: GamePlayer[] with exactly 1 SPY

// TimerManager - Countdown
const timerManager = new TimerManager();
const cleanup = timerManager.startCountdown(
  300,          // durationSeconds
  (state) => {  // onUpdate callback
    console.log(state.formattedTime); // "05:00"
    console.log(state.warningLevel);  // NORMAL, WARNING, CRITICAL, FINISHED
  },
  () => {       // onFinish callback
    console.log('Timer finished!');
  }
);

// PlayerManager - Player creation and validation
const playerManager = new PlayerManager();
const players = playerManager.createDefaultPlayers(4);
const validation = playerManager.validatePlayers(players);
if (!validation.isValid) {
  console.log(validation.errors); // ['Player names must be unique', ...]
}
```

## State Management Examples

```typescript
// Using gameStore (Zustand)
const { settings, updateSettings, startGame, moveToPhase } = useGameStore();

// Update game settings
updateSettings({ playerCount: 6, gameDurationMinutes: 7 });

// Start game with category
startGame(category, subcategory); // Calls GameEngine internally

// Move to next phase
moveToPhase('voting');
```

## Platform Helper Examples

```typescript
// Vibration (iOS + Android)
VibrationHelper.vibrateLight();      // Tap feedback
VibrationHelper.vibrateMedium();     // Button press
VibrationHelper.vibrateSuccess();    // Action success
VibrationHelper.vibrateError();      // Error occurred

// Screen Wake Lock
await ScreenHelper.keepScreenOn();   // During timer
ScreenHelper.allowScreenOff();       // After timer ends
```

## Testing

```bash
# Run unit tests
npm test

# Run tests in watch mode
npm test -- --watch

# Run tests with coverage
npm test -- --coverage
```

## AdMob Integration

```typescript
// Initialize AdMob
await AdService.initialize();

// Banner ad (in CategoryScreen)
<BannerAd unitId={AdService.getBannerAdUnitId()} size={BannerAdSize.ANCHORED_ADAPTIVE_BANNER} />

// Interstitial ad (with frequency control)
AdService.showInterstitialWithFrequency(() => {
  navigation.navigate('Game');
});

// Rewarded ad (unlock subcategory)
AdService.showRewardedAd(
  (amount) => {
    unlockSubcategory(subcategoryId);
  }
);
```

## In-App Purchases

```typescript
// Initialize IAP
await PurchaseService.initialize();

// Get products
const products = await PurchaseService.getProducts();

// Purchase category
PurchaseService.purchaseProduct(
  'category_animals',
  (purchase) => {
    unlockCategory('animals');
  },
  (error) => {
    console.error('Purchase failed:', error);
  }
);

// Restore purchases (iOS)
PurchaseService.restorePurchases((purchases) => {
  purchases.forEach(p => unlockCategory(p.productId));
});
```

## Differences from Android Version

| Aspect | Android (Kotlin) | React Native (TypeScript) |
|--------|------------------|---------------------------|
| UI Framework | Jetpack Compose | React Native |
| State | remember/mutableStateOf | Zustand + AsyncStorage |
| Navigation | Compose Navigation | React Navigation |
| Vibration | Android Vibrator API | Platform-specific helpers |
| Ads | Google Mobile Ads SDK | react-native-google-mobile-ads |
| IAP | Google Play Billing | react-native-iap (both platforms) |
| Business Logic | Pure Kotlin classes | Pure TypeScript classes |

## License

This project is part of a migration from Android to React Native. All game logic and functionality are preserved from the original Kotlin version.
