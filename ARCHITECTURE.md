# Clean Architecture - Spy Game

This document outlines the refactored clean architecture of the Spy party game Android application.

## Architecture Overview

The application follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│                  (UI / Jetpack Compose)                      │
│  ux/                                                          │
│  ├── SetupScreen.kt                                          │
│  ├── PlayerSetupScreen.kt                                    │
│  ├── CategoryScreen.kt                                       │
│  ├── GameScreen.kt                                           │
│  ├── TimerScreen.kt                                          │
│  └── VotingScreen.kt                                         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       Domain Layer                           │
│                   (Pure Business Logic)                      │
│  domain/                                                      │
│  ├── GameEngine.kt        - Role assignment, voting logic    │
│  ├── TimerManager.kt      - Timer countdown logic            │
│  ├── PlayerManager.kt     - Player validation & creation     │
│  └── GameStateManager.kt  - Game state coordination          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Platform Layer                          │
│              (Android-Specific Services)                     │
│  platform/                                                    │
│  ├── VibrationHelper.kt   - Device vibration                │
│  └── ScreenHelper.kt      - Screen wake lock                │
│                                                               │
│  ads/                                                         │
│  ├── BannerAdManager.kt   - Banner ads (AdMob)              │
│  ├── InterstitialAdManager.kt - Interstitial ads            │
│  └── RewardedAdManager.kt - Rewarded ads                    │
│                                                               │
│  billing/                                                     │
│  └── BillingManager.kt    - In-app purchases                │
│                                                               │
│  datamanagement/                                             │
│  └── CategoryDataManager.kt - Category persistence          │
└─────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### 1. Presentation Layer (`ux/`)

**Purpose**: Display UI and handle user interactions

**Responsibilities**:
- Render Compose UI components
- Handle user input (clicks, text input)
- Display game state
- Navigate between screens
- Call domain layer for business logic

**Key Files**:
- `SetupScreen.kt` - Game settings configuration
- `PlayerSetupScreen.kt` - Player name, color, avatar selection
- `CategoryScreen.kt` - Category selection with IAP
- `GameScreen.kt` - Player role reveal flow
- `TimerScreen.kt` - Game timer countdown
- `VotingScreen.kt` - Voting and results

**Rules**:
- ✅ Can call domain layer
- ✅ Can use platform helpers
- ❌ No business logic
- ❌ No direct platform API calls

---

### 2. Domain Layer (`domain/`)

**Purpose**: Pure business logic - platform independent

**Responsibilities**:
- Game rules and mechanics
- Data validation
- Calculations and algorithms
- State management

**Key Classes**:

#### `GameEngine.kt`
Core game logic:
- `assignRoles()` - Randomly assign SPY and distribute words/hints
- `calculateVotingResults()` - Tally votes and determine winner
- `validateGameSetup()` - Validate player count and duration

```kotlin
val gameEngine = GameEngine()
val gamePlayers = gameEngine.assignRoles(
    players = players,
    items = category.items,
    hints = category.hints,
    showHints = true
)
```

#### `TimerManager.kt`
Timer logic:
- `startCountdown()` - Reactive countdown Flow
- `formatTime()` - Format seconds to MM:SS
- `getTimeWarningLevel()` - Determine urgency (NORMAL/WARNING/CRITICAL)

```kotlin
val timerManager = TimerManager()
timerManager.startCountdown(300).collect { state ->
    // state.formattedTime = "05:00"
    // state.warningLevel = WarningLevel.NORMAL
}
```

#### `PlayerManager.kt`
Player management:
- `createDefaultPlayers()` - Initialize player list
- `validatePlayers()` - Check name uniqueness, color conflicts
- `isPlayerSetupValid()` - Quick validation check
- `getAvailableColor()` - Find unused color
- `getAvailableCharacter()` - Find unused avatar

```kotlin
val playerManager = PlayerManager()
val players = playerManager.createDefaultPlayers(
    count = 5,
    existingPlayers = savedPlayers
)
val isValid = playerManager.isPlayerSetupValid(players)
```

#### `GameStateManager.kt`
Centralized state coordination:
- `updateSettings()` - Save game configuration
- `setPlayers()` - Store player list
- `startGame()` - Initialize game with category
- `moveToPhase()` - Track game progression
- `resetGame()` - Clear game data

**Rules**:
- ✅ Pure Kotlin - no Android imports
- ✅ Testable without Android framework
- ❌ No UI code
- ❌ No Android APIs

---

### 3. Platform Layer

**Purpose**: Android-specific integrations

#### `platform/`

**VibrationHelper.kt** - Device vibration
```kotlin
VibrationHelper.vibratePattern(context)
VibrationHelper.vibrateSingle(context, 100)
```

**ScreenHelper.kt** - Keep screen on
```kotlin
ScreenHelper.keepScreenOn(activity)
ScreenHelper.allowScreenOff(activity)
```

#### `ads/`
AdMob integration:
- `BannerAdManager` - Bottom banner ads
- `InterstitialAdManager` - Full-screen ads with frequency control
- `RewardedAdManager` - Watch-to-unlock subcategories

#### `billing/`
Google Play In-App Purchases:
- `BillingManager` - Purchase flow, product validation

#### `datamanagement/`
Local data persistence:
- `CategoryDataManager` - SharedPreferences for categories, favorites, purchases

**Rules**:
- ✅ Android framework APIs allowed
- ✅ Third-party SDKs (AdMob, Billing)
- ❌ No business logic
- ✅ Can be called by UI layer

---

## Data Flow Examples

### Example 1: Starting a Game

```
1. User clicks "Start Game" in CategoryScreen
   ↓
2. UI calls domain layer:
   val gamePlayers = GameEngine().assignRoles(...)
   ↓
3. Domain assigns SPY randomly and returns GamePlayer list
   ↓
4. UI navigates to GameScreen with gamePlayers
   ↓
5. UI displays each player's role one-by-one
```

### Example 2: Voting

```
1. Each player votes in VotingScreen
   ↓
2. All votes collected in Map<String, String>
   ↓
3. UI calls:
   val result = GameEngine().calculateVotingResults(votes, gamePlayers)
   ↓
4. Domain calculates vote counts and determines winner
   ↓
5. UI displays results with spy reveal
```

### Example 3: Timer Countdown

```
1. TimerScreen launched
   ↓
2. UI calls:
   TimerManager().startCountdown(300).collect { state -> }
   ↓
3. Domain emits TimerState every second
   ↓
4. UI updates countdown display and warning colors
   ↓
5. When finished, UI calls VibrationHelper.vibratePattern()
```

---

## Benefits of This Architecture

### ✅ Testability
- Domain layer has **zero Android dependencies**
- Can unit test game logic without emulators
- Example: Test `assignRoles()` ensures exactly 1 SPY

### ✅ Maintainability
- Clear separation: UI vs Logic vs Platform
- Changes to UI don't affect game rules
- Easy to locate bugs

### ✅ Reusability
- Domain layer can be reused in:
  - iOS app (Kotlin Multiplatform)
  - Desktop app
  - Backend game server

### ✅ Single Responsibility
- Each class has one clear purpose
- `GameEngine` only handles game mechanics
- `TimerManager` only handles time logic
- Screens only display UI

### ✅ Dependency Rule
```
UI → Domain → Platform
   ↓         ↓
  (uses)   (uses)
```
- UI depends on Domain
- Domain depends on NOTHING
- Platform is used by UI when needed

---

## File Organization

```
app/src/main/java/com/oguz/spy/
├── domain/                     # ✅ Pure business logic
│   ├── GameEngine.kt
│   ├── TimerManager.kt
│   ├── PlayerManager.kt
│   └── GameStateManager.kt
│
├── platform/                   # 🔧 Android-specific helpers
│   ├── VibrationHelper.kt
│   └── ScreenHelper.kt
│
├── ux/                        # 🎨 UI Screens
│   ├── SetupScreen.kt
│   ├── PlayerSetUpScreen.kt
│   ├── CategoryScreen.kt
│   ├── GameScreen.kt
│   ├── TimerScreen.kt
│   ├── VotingScreen.kt
│   └── components/            # Reusable UI components
│
├── ads/                       # 💰 AdMob integration
│   ├── BannerAdManager.kt
│   ├── InterstitialAdManager.kt
│   └── RewardedAdManager.kt
│
├── billing/                   # 💳 In-app purchases
│   └── BillingManager.kt
│
├── datamanagment/            # 💾 Data persistence
│   └── CategoryDataManager.kt
│
├── models/                    # 📦 Data models
│   └── CharacterAvatar.kt
│
└── MainActivity.kt            # 🚀 Entry point
```

---

## Migration Guide

### Before (Tight Coupling)
```kotlin
// Business logic mixed in UI
@Composable
fun VotingScreen(...) {
    fun calculateResults() {
        val voteCount = mutableMapOf<String, Int>()
        votes.values.forEach { votedPlayerName ->
            voteCount[votedPlayerName] = voteCount.getOrDefault(votedPlayerName, 0) + 1
        }
        mostVotedPlayer = voteCount.maxByOrNull { it.value }?.let { ... }
    }
}
```

### After (Clean Separation)
```kotlin
// UI only calls domain
@Composable
fun VotingScreen(...) {
    fun calculateResults() {
        val gameEngine = GameEngine()
        val result = gameEngine.calculateVotingResults(votes, gamePlayers)
        mostVotedPlayer = result.mostVotedPlayer
    }
}

// Business logic in domain
class GameEngine {
    fun calculateVotingResults(...): VotingResult {
        // Pure logic here
    }
}
```

---

## Testing Strategy

### Unit Tests (Domain Layer)
```kotlin
@Test
fun `assignRoles should always assign exactly one spy`() {
    val gameEngine = GameEngine()
    val players = createTestPlayers(5)

    val result = gameEngine.assignRoles(
        players, items, hints, true
    )

    val spyCount = result.count { it.role == "SPY" }
    assertEquals(1, spyCount)
}
```

### Integration Tests (UI + Domain)
```kotlin
@Test
fun `voting screen displays correct winner`() {
    composeTestRule.setContent {
        VotingScreen(...)
    }
    // Simulate votes
    // Verify UI shows correct result
}
```

---

## Future Improvements

1. **ViewModel Integration**
   - Add ViewModels between UI and Domain
   - Better state management with StateFlow

2. **Repository Pattern**
   - Abstract data sources
   - Interface for CategoryRepository

3. **Dependency Injection**
   - Use Hilt for automatic injection
   - Easier testing with mocks

4. **Use Cases**
   - One use case per user action
   - e.g., `StartGameUseCase`, `SubmitVoteUseCase`

---

## Code Standards

### Domain Layer Rules
- ✅ Pure Kotlin (no `import android.*`)
- ✅ Immutable data classes
- ✅ Return sealed classes for complex results
- ❌ No coroutines (use Flow for streams)

### UI Layer Rules
- ✅ Composables are stateless when possible
- ✅ Use `remember` for local state
- ✅ Call domain functions, don't reimplement logic
- ❌ No business calculations in Composables

### Platform Layer Rules
- ✅ Create helper objects/classes
- ✅ Handle Android API version differences
- ✅ Catch and log exceptions
- ❌ No business logic

---

## Summary

This refactoring achieves:

✅ **Separation of Concerns** - UI, Logic, Platform isolated
✅ **Testability** - Pure functions in domain layer
✅ **Maintainability** - Easy to find and fix bugs
✅ **Scalability** - Ready for feature additions
✅ **Reusability** - Domain logic portable to other platforms

The game functionality remains **100% identical** - only the architecture improved.
