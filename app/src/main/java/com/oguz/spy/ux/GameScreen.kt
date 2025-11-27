package com.oguz.spy.ux

import android.annotation.SuppressLint
import android.app.Activity
import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalContext
import androidx.navigation.NavController
import com.oguz.spy.ads.InterstitialAdManager
import com.oguz.spy.ux.components.PlayerGameScreen
import kotlinx.coroutines.delay

@SuppressLint("DefaultLocale")
@Composable
fun GameScreen(
    navController: NavController,
    gamePlayers: List<GamePlayer>,
    category: Category,
    interstitialAdManager: InterstitialAdManager,
    gameDurationMinutes: Int,
    showHints: Boolean,
) {
    val context = LocalContext.current
    val activity = context as? Activity

    var currentPlayerIndex by remember { mutableStateOf(0) }
    var timeLeft by remember { mutableStateOf(gameDurationMinutes * 60) }
    var isTimerRunning by remember { mutableStateOf(false) }

    // Zamanlayıcı sadece başlatıldığında çalışır
    LaunchedEffect(isTimerRunning, timeLeft) {
        if (isTimerRunning && timeLeft > 0) {
            delay(1000L)
            timeLeft--
        } else if (isTimerRunning && timeLeft <= 0) {
            isTimerRunning = false
        }
    }

    val timeString = "${if (isTimerRunning) "▶" else "⏸"} ${String.format("%02d:%02d", timeLeft / 60, timeLeft % 60)}"

    PlayerGameScreen(
        player = gamePlayers[currentPlayerIndex],
        playerIndex = currentPlayerIndex,
        totalPlayers = gamePlayers.size,
        category = category,
        timeString = timeString,
        showHints = showHints,
        isLastPlayer = currentPlayerIndex == gamePlayers.size - 1,
        onBack = { navController.popBackStack() },
        onNext = {
            if (currentPlayerIndex < gamePlayers.size - 1) {
                currentPlayerIndex++
            }
        },
        onPrevious = {
            if (currentPlayerIndex > 0) {
                currentPlayerIndex--
            }
        },
        onStartTimer = {
            // ✅ Oyun başlarken reklam göster (sıklık kontrolü ile)
            activity?.let {
                interstitialAdManager.showAdWithFrequencyControl(
                    activity = it,
                    onAdDismissed = {
                        navController.navigate("timerScreen")
                    },
                    onAdShowFailed = { error ->
                        println("Reklam gösterilemedi: $error")
                        navController.navigate("timerScreen")
                    }
                )
            } ?: run {
                navController.navigate("timerScreen")
            }
        }
    )
}