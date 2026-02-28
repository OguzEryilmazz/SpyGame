# Project Structure - Clean Architecture

## Complete File Organization

```
spy-game/
│
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/oguz/spy/
│   │   │   │   │
│   │   │   │   ├── 📦 domain/ ..................... DOMAIN LAYER (Pure Business Logic)
│   │   │   │   │   ├── GameEngine.kt .............. Role assignment, voting, validation
│   │   │   │   │   ├── TimerManager.kt ............ Timer countdown, formatting
│   │   │   │   │   ├── PlayerManager.kt ........... Player creation, validation
│   │   │   │   │   └── GameStateManager.kt ........ Game state coordination
│   │   │   │   │
│   │   │   │   ├── 🔧 platform/ ................... PLATFORM LAYER (Android APIs)
│   │   │   │   │   ├── VibrationHelper.kt ......... Device vibration
│   │   │   │   │   └── ScreenHelper.kt ............ Screen wake lock
│   │   │   │   │
│   │   │   │   ├── 🎨 ux/ ......................... PRESENTATION LAYER (UI)
│   │   │   │   │   ├── SetUpScreen.kt ............. Game settings screen
│   │   │   │   │   ├── PlayerSetUpScreen.kt ....... Player configuration
│   │   │   │   │   ├── CategoryScreen.kt .......... Category selection
│   │   │   │   │   ├── GameScreen.kt .............. Role reveal flow
│   │   │   │   │   ├── TimerScreen.kt ............. Game timer
│   │   │   │   │   ├── VotingScreen.kt ............ Voting & results
│   │   │   │   │   ├── TutorialScreen.kt .......... Tutorial slides
│   │   │   │   │   └── components/ ................ Reusable UI components
│   │   │   │   │       ├── CategoryScreenComponents.kt
│   │   │   │   │       ├── EmptyFavoritesComponent.kt
│   │   │   │   │       ├── GameScreenComponents.kt
│   │   │   │   │       ├── PageTransitionComponents.kt
│   │   │   │   │       ├── PlayerSetUpComponents.kt
│   │   │   │   │       ├── SetUpScreenComponents.kt
│   │   │   │   │       └── VotingScreenComponents.kt
│   │   │   │   │
│   │   │   │   ├── 💰 ads/ ........................ AD MANAGEMENT
│   │   │   │   │   ├── AdIds.kt ................... Ad unit IDs
│   │   │   │   │   ├── BannerAdManager.kt ......... Bottom banner ads
│   │   │   │   │   ├── InterstitialAdManager.kt ... Full-screen ads
│   │   │   │   │   └── RewardedAdManager.kt ....... Rewarded video ads
│   │   │   │   │
│   │   │   │   ├── 💳 billing/ ................... IN-APP PURCHASES
│   │   │   │   │   └── BillingManager.kt .......... Google Play Billing
│   │   │   │   │
│   │   │   │   ├── 💾 datamanagment/ ............. DATA PERSISTENCE
│   │   │   │   │   └── CategoryDataManager.kt ..... Category storage
│   │   │   │   │
│   │   │   │   ├── 🎭 models/ .................... DATA MODELS
│   │   │   │   │   └── CharacterAvatar.kt ......... Avatar enum
│   │   │   │   │
│   │   │   │   ├── 🎨 ui/theme/ .................. UI THEME
│   │   │   │   │   ├── Color.kt ................... Color palette
│   │   │   │   │   ├── Theme.kt ................... Material theme
│   │   │   │   │   └── Type.kt .................... Typography
│   │   │   │   │
│   │   │   │   ├── 🏠 app/ ....................... APPLICATION
│   │   │   │   │   └── MyApplication.kt ........... App class
│   │   │   │   │
│   │   │   │   ├── MainActivity.kt ................ Main entry point
│   │   │   │   └── PageTransition.kt .............. Navigation graph
│   │   │   │
│   │   │   ├── res/
│   │   │   │   ├── drawable/ ..................... Images & icons
│   │   │   │   │   ├── pic_1.png to pic_9.png .... Character avatars
│   │   │   │   │   ├── my_icon.png
│   │   │   │   │   └── ...
│   │   │   │   ├── raw/
│   │   │   │   │   └── categories.json ........... Category data
│   │   │   │   ├── values/
│   │   │   │   │   ├── colors.xml
│   │   │   │   │   ├── strings.xml
│   │   │   │   │   └── themes.xml
│   │   │   │   └── mipmap-*/ .................... Launcher icons
│   │   │   │
│   │   │   └── AndroidManifest.xml
│   │   │
│   │   ├── androidTest/ .......................... Instrumented tests
│   │   │   └── java/com/oguz/spy/
│   │   │       └── ExampleInstrumentedTest.kt
│   │   │
│   │   └── test/ ................................. Unit tests
│   │       └── java/com/oguz/spy/
│   │           └── ExampleUnitTest.kt
│   │
│   ├── build.gradle.kts ........................... App build config
│   └── proguard-rules.pro
│
├── gradle/
│   ├── libs.versions.toml ......................... Dependency versions
│   └── wrapper/
│
├── build.gradle.kts ............................... Project build config
├── settings.gradle.kts
├── gradle.properties
├── gradlew
├── gradlew.bat
├── .gitignore
│
├── 📄 ARCHITECTURE.md ............................. Architecture guide
├── 📄 REFACTORING_SUMMARY.md ...................... Refactoring details
└── 📄 PROJECT_STRUCTURE.md ........................ This file
```

---

## Layer Breakdown

### 📦 Domain Layer (7 classes, ~250 lines)
**Purpose**: Pure business logic, no Android dependencies

| File | Lines | Purpose |
|------|-------|---------|
| `GameEngine.kt` | ~95 | Role assignment, voting calculation |
| `TimerManager.kt` | ~60 | Timer countdown logic |
| `PlayerManager.kt` | ~85 | Player management & validation |
| `GameStateManager.kt` | ~45 | Game state coordination |

**Key Principle**: 100% testable without Android framework

---

### 🔧 Platform Layer (2 helpers, ~50 lines)
**Purpose**: Android-specific APIs isolated

| File | Lines | Purpose |
|------|-------|---------|
| `VibrationHelper.kt` | ~30 | Device vibration (handles API versions) |
| `ScreenHelper.kt` | ~20 | Screen wake lock management |

**Key Principle**: Shields UI from platform complexity

---

### 🎨 UI Layer (7 screens + components, ~1,200 lines)
**Purpose**: Jetpack Compose screens, no business logic

#### Main Screens
| Screen | Lines | Purpose |
|--------|-------|---------|
| `SetUpScreen.kt` | ~230 | Game settings (player count, duration, hints) |
| `PlayerSetUpScreen.kt` | ~160 | Player names, colors, avatars |
| `CategoryScreen.kt` | ~810 | Category selection, IAP, subcategories |
| `GameScreen.kt` | ~78 | Player role reveal flow |
| `TimerScreen.kt` | ~545 | Countdown timer with animations |
| `VotingScreen.kt` | ~145 | Voting interface & results |
| `TutorialScreen.kt` | ~? | First-time tutorial |

#### Reusable Components
| Component | Purpose |
|-----------|---------|
| `CategoryScreenComponents.kt` | Category cards, subcategory dialogs |
| `GameScreenComponents.kt` | Player reveal cards |
| `PlayerSetUpComponents.kt` | Player input cards, color picker |
| `VotingScreenComponents.kt` | Vote buttons, results display |
| `SetUpScreenComponents.kt` | Counter rows, setting items |
| `PageTransitionComponents.kt` | Banner ad component |

**Key Principle**: Only UI rendering, delegates logic to domain

---

### 💰 Ad Management (4 classes, ~400 lines)
**Purpose**: AdMob integration

| File | Purpose |
|------|---------|
| `AdIds.kt` | Test & production ad unit IDs |
| `BannerAdManager.kt` | Bottom banner ads |
| `InterstitialAdManager.kt` | Full-screen ads with frequency control |
| `RewardedAdManager.kt` | Watch-to-unlock subcategories |

---

### 💳 Billing (1 class, ~300 lines)
**Purpose**: Google Play In-App Purchases

| File | Purpose |
|------|---------|
| `BillingManager.kt` | Purchase flow, product validation, restore |

---

### 💾 Data Management (1 class, ~250 lines)
**Purpose**: Local data persistence

| File | Purpose |
|------|---------|
| `CategoryDataManager.kt` | Load categories, favorites, purchases |

---

## Dependency Graph

```
                    ┌─────────────────┐
                    │  MainActivity   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ PageTransition  │ (Navigation)
                    └────────┬────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
    ┌─────▼─────┐    ┌──────▼──────┐   ┌──────▼──────┐
    │  Screens  │    │ AdManagers  │   │   Billing   │
    └─────┬─────┘    └─────────────┘   └─────────────┘
          │
    ┌─────▼─────┐
    │  Domain   │ ← Pure Kotlin, no Android imports
    │  Layer    │
    └───────────┘

    ┌───────────┐
    │ Platform  │ ← Used by screens when needed
    │  Helpers  │
    └───────────┘
```

---

## Data Flow: Starting a Game

```
1. SetUpScreen
   ↓ (User configures: 5 players, 10 min, hints ON)

2. PlayerSetUpScreen
   ↓ Uses: PlayerManager.createDefaultPlayers()
   ↓ User enters names, picks colors/avatars

3. CategoryScreen
   ↓ User selects "Movies" category
   ↓ Uses: GameEngine.assignRoles()
   ↓ Output: 1 SPY + 4 Players with "Titanic"

4. GameScreen
   ↓ Each player views role individually
   ↓ Shows ad (InterstitialAdManager)

5. TimerScreen
   ↓ Uses: TimerManager.startCountdown()
   ↓ Uses: ScreenHelper.keepScreenOn()
   ↓ On finish: VibrationHelper.vibratePattern()

6. VotingScreen
   ↓ Players vote on who is SPY
   ↓ Uses: GameEngine.calculateVotingResults()
   ↓ Shows results: SPY caught? YES/NO
```

---

## Testing Strategy

### Unit Tests (Domain Layer)
```kotlin
src/test/java/com/oguz/spy/domain/
├── GameEngineTest.kt
├── TimerManagerTest.kt
├── PlayerManagerTest.kt
└── GameStateManagerTest.kt
```

Example:
```kotlin
class GameEngineTest {
    @Test
    fun `assignRoles should assign exactly one SPY`() {
        val engine = GameEngine()
        val result = engine.assignRoles(...)
        assertEquals(1, result.count { it.role == "SPY" })
    }
}
```

### Integration Tests (UI + Domain)
```kotlin
src/androidTest/java/com/oguz/spy/
├── SetupScreenTest.kt
├── PlayerSetupScreenTest.kt
├── VotingScreenTest.kt
└── EndToEndGameTest.kt
```

---

## Build Configuration

### Dependencies
```kotlin
// Jetpack Compose
implementation("androidx.compose.ui:ui")
implementation("androidx.compose.material3:material3")
implementation("androidx.navigation:navigation-compose")

// AdMob
implementation("com.google.android.gms:play-services-ads")

// In-App Billing
implementation("com.android.billingclient:billing-ktx")

// Testing
testImplementation("junit:junit")
androidTestImplementation("androidx.compose.ui:ui-test-junit4")
```

---

## Architecture Compliance

### ✅ Rules Enforced

#### Domain Layer
- [ ] No `import android.*`
- [ ] No `import androidx.*`
- [ ] Only pure Kotlin code
- [ ] All classes testable without Android

#### UI Layer
- [ ] No business logic calculations
- [ ] Calls domain layer for logic
- [ ] Uses platform helpers for Android APIs
- [ ] Pure Compose UI rendering

#### Platform Layer
- [ ] Only Android-specific code
- [ ] No business logic
- [ ] Helper objects/classes only
- [ ] Handles API version differences

---

## File Size Summary

| Layer | Files | Total Lines | Avg per File |
|-------|-------|-------------|--------------|
| Domain | 4 | ~250 | 62 |
| Platform | 2 | ~50 | 25 |
| UI (Screens) | 7 | ~1,200 | 171 |
| UI (Components) | 7 | ~800 | 114 |
| Ads | 4 | ~400 | 100 |
| Billing | 1 | ~300 | 300 |
| Data | 1 | ~250 | 250 |
| **Total** | **26** | **~3,250** | **125** |

---

## Quick Navigation

### Find By Feature

**Role Assignment**
- Logic: `domain/GameEngine.kt` → `assignRoles()`
- UI: `ux/GameScreen.kt`
- Helper: `ux/components/CategoryScreenComponents.kt`

**Voting**
- Logic: `domain/GameEngine.kt` → `calculateVotingResults()`
- UI: `ux/VotingScreen.kt`
- Components: `ux/components/VotingScreenComponents.kt`

**Timer**
- Logic: `domain/TimerManager.kt`
- UI: `ux/TimerScreen.kt`
- Platform: `platform/VibrationHelper.kt`, `platform/ScreenHelper.kt`

**Player Setup**
- Logic: `domain/PlayerManager.kt`
- UI: `ux/PlayerSetUpScreen.kt`
- Components: `ux/components/PlayerSetUpComponents.kt`

**Categories**
- Data: `datamanagment/CategoryDataManager.kt`
- UI: `ux/CategoryScreen.kt`
- Components: `ux/components/CategoryScreenComponents.kt`

**Ads**
- Banner: `ads/BannerAdManager.kt`
- Interstitial: `ads/InterstitialAdManager.kt`
- Rewarded: `ads/RewardedAdManager.kt`

**Purchases**
- Billing: `billing/BillingManager.kt`
- UI: `ux/CategoryScreen.kt` (purchase dialogs)

---

## Documentation

- `ARCHITECTURE.md` - Detailed architecture explanation
- `REFACTORING_SUMMARY.md` - What changed and why
- `PROJECT_STRUCTURE.md` - This file (file organization)

---

## Summary

✅ **Clean separation** of UI, domain, and platform
✅ **Organized by layer**, not by feature
✅ **Easy to navigate** - clear file naming
✅ **Scalable** - add features without mess
✅ **Testable** - domain layer is pure Kotlin

The project structure now follows industry-standard clean architecture!
