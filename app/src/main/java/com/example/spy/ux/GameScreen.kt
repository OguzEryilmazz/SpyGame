package com.example.spy.ux

import android.annotation.SuppressLint
import androidx.compose.runtime.*
import androidx.navigation.NavController
import com.example.spy.ux.components.PlayerGameScreen
import kotlinx.coroutines.delay

@SuppressLint("DefaultLocale")
@Composable
fun GameScreen(
    navController: NavController,
    gamePlayers: List<GamePlayer>,
    category: Category,
    gameDurationMinutes: Int,
    showHints: Boolean,
) {
    var currentPlayerIndex by remember { mutableStateOf(0) }
    var timeLeft by remember { mutableStateOf(gameDurationMinutes * 60) }
    var isTimerRunning by remember { mutableStateOf(false) }

    // Zamanlayıcı sadece başlatıldığında çalışır
    LaunchedEffect(isTimerRunning, timeLeft) {
        if (isTimerRunning && timeLeft > 0) {
            delay(1000L)
            timeLeft--
        } else if (isTimerRunning && timeLeft <= 0) {
            // Zaman dolduğunda zamanlayıcıyı durdur
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
            } else {
                println("DEBUG: Son oyuncudayız, index artırılmadı")
            }
        },
        onPrevious = {
            if (currentPlayerIndex > 0) {
                currentPlayerIndex--
            }
        },
        onStartTimer = {
            navController.navigate("timerScreen")
        }
    )
}
