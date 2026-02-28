# Quick Start Guide

## Installation

```bash
cd react-native-spy
npm install

# iOS only (requires Mac)
cd ios && pod install && cd ..
```

## Running the App

```bash
# iOS
npm run ios

# Android
npm run android

# Start Metro bundler separately
npm start
```

## Running Tests

```bash
# Run all tests
npm test

# Watch mode
npm test -- --watch

# With coverage
npm test -- --coverage
```

## Quick Code Examples

### 1. Using GameEngine

```typescript
import { GameEngine } from './src/domain/GameEngine';

const gameEngine = new GameEngine();

// Assign roles (1 SPY + regular players)
const gamePlayers = gameEngine.assignRoles(
  players,              // Player[]
  ['Dog', 'Cat', ...],  // items: string[]
  ['Barks', 'Meows'], // hints: string[]
  true                  // showHints: boolean
);

// Calculate voting results
const result = gameEngine.calculateVotingResults(
  { '1': '2', '2': '3', '3': '2' },  // votes: Record<string, string>
  gamePlayers                         // GamePlayer[]
);

console.log(result.isSpyCaught);  // boolean
console.log(result.spyPlayer);    // GamePlayer
```

### 2. Using TimerManager

```typescript
import { TimerManager } from './src/domain/TimerManager';

const timerManager = new TimerManager();

// Start countdown
const cleanup = timerManager.startCountdown(
  300,  // 5 minutes in seconds
  (state) => {
    console.log(state.formattedTime);  // "05:00"
    console.log(state.warningLevel);   // NORMAL, WARNING, CRITICAL
  },
  () => {
    console.log('Timer finished!');
  }
);

// Stop countdown
timerManager.stopCountdown();

// Or use cleanup function
cleanup();
```

### 3. Using PlayerManager

```typescript
import { PlayerManager } from './src/domain/PlayerManager';

const playerManager = new PlayerManager();

// Create default players
const players = playerManager.createDefaultPlayers(4);
// Returns 4 players with auto-assigned colors and avatars

// Validate players
const validation = playerManager.validatePlayers(players);
if (!validation.isValid) {
  console.error(validation.errors);
}
```

### 4. Using Zustand Stores

```typescript
import { useGameStore } from './src/store/gameStore';

function MyComponent() {
  const { 
    settings, 
    updateSettings, 
    players,
    setPlayers,
    startGame,
    moveToPhase
  } = useGameStore();

  // Update settings
  updateSettings({ playerCount: 6 });

  // Start game
  startGame(category, subcategory);

  // Move to next phase
  moveToPhase('voting');
}
```

### 5. Using Platform Helpers

```typescript
import { VibrationHelper } from './src/platform/VibrationHelper';
import { ScreenHelper } from './src/platform/ScreenHelper';

// Vibration
VibrationHelper.vibrateLight();      // Tap
VibrationHelper.vibrateMedium();     // Button
VibrationHelper.vibrateSuccess();    // Success
VibrationHelper.vibrateError();      // Error

// Screen wake
await ScreenHelper.keepScreenOn();   // Keep screen on
ScreenHelper.allowScreenOff();       // Allow screen to sleep
```

### 6. Using AdService

```typescript
import { AdService } from './src/services/AdService';

// Initialize (in App.tsx)
await AdService.initialize();
await AdService.loadInterstitialAd();

// Show banner (in JSX)
<BannerAd 
  unitId={AdService.getBannerAdUnitId()} 
  size={BannerAdSize.ANCHORED_ADAPTIVE_BANNER} 
/>

// Show interstitial with frequency control
AdService.showInterstitialWithFrequency(() => {
  navigation.navigate('Game');
});

// Show rewarded ad
AdService.showRewardedAd(
  (amount) => {
    console.log('Rewarded:', amount);
    unlockContent();
  }
);
```

### 7. Using PurchaseService

```typescript
import { PurchaseService } from './src/services/PurchaseService';

// Initialize (in App.tsx)
await PurchaseService.initialize();

// Get products
const products = await PurchaseService.getProducts();

// Purchase
PurchaseService.purchaseProduct(
  'category_animals',
  (purchase) => {
    console.log('Purchase successful:', purchase);
  },
  (error) => {
    console.error('Purchase failed:', error);
  }
);
```

## Project Structure Quick Reference

```
src/
├── domain/       - Pure TypeScript business logic (NO React Native imports)
├── platform/     - iOS + Android platform abstractions
├── store/        - Zustand state management
├── services/     - AdMob and IAP integration
├── screens/      - React Native UI screens
├── navigation/   - React Navigation setup
├── types/        - TypeScript type definitions
└── data/         - Mock data
```

## Common Tasks

### Add a New Category

Edit `src/data/mockCategories.ts`:

```typescript
{
  id: 'newcategory',
  name: 'New Category',
  emoji: '🎮',
  isLocked: false,
  hasSubcategories: false,
  items: ['Item1', 'Item2', 'Item3'],
  hints: ['Hint1', 'Hint2'],
}
```

### Change Game Settings Defaults

Edit `src/store/gameStore.ts`:

```typescript
settings: {
  playerCount: 4,           // Change default player count
  gameDurationMinutes: 5,   // Change default duration
  showHints: true,          // Change hints default
}
```

### Add Production Ad IDs

Edit `src/services/AdService.ts`:

```typescript
const AD_UNIT_IDS = {
  banner: __DEV__ || true  // Change to false for production
    ? TestIds.BANNER
    : Platform.OS === 'ios'
    ? 'ca-app-pub-YOUR_ID/banner'      // Add your iOS banner ID
    : 'ca-app-pub-YOUR_ID/banner',     // Add your Android banner ID
  // ... same for interstitial and rewarded
};
```

### Add Production IAP Product IDs

Edit `src/services/PurchaseService.ts`:

```typescript
const PRODUCT_IDS = {
  category_animals: Platform.select({
    ios: 'com.yourapp.category.animals',      // Your iOS product ID
    android: 'com.yourapp.category.animals',  // Your Android product ID
  })!,
  // ...
};
```

## Troubleshooting

### iOS Build Issues

```bash
cd ios
pod deintegrate
pod install
cd ..
npm run ios
```

### Android Build Issues

```bash
cd android
./gradlew clean
cd ..
npm run android
```

### Metro Bundler Issues

```bash
npm start -- --reset-cache
```

### TypeScript Errors

```bash
npm run lint
```

## Next Steps

1. ✅ Install dependencies
2. ✅ Run on device/simulator
3. ✅ Test all screens
4. ✅ Run unit tests
5. ⬜ Configure production Ad IDs
6. ⬜ Configure IAP products in App Store Connect / Play Console
7. ⬜ Add app icons and splash screens
8. ⬜ Build for production
9. ⬜ Submit to App Store / Play Store
