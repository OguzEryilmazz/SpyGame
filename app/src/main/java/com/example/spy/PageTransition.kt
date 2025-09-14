package com.example.spy

import androidx.compose.runtime.*
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.spy.ux.CategoryScreen
import com.example.spy.ux.PlayerSetupScreen
import com.example.spy.ux.SetupScreen
import com.example.spy.ux.Player

@Composable
fun PageTransition() {
    val navController = rememberNavController()

    // Oyun ayarları
    var gamePlayerCount by remember { mutableStateOf(4) }
    var gameDuration by remember { mutableStateOf(5) }
    var showHints by remember { mutableStateOf(true) }

    // Oyuncu verileri - Bu veriler tüm navigation boyunca korunacak
    var playersData by remember { mutableStateOf<List<Player>>(emptyList()) }

    NavHost(navController = navController, startDestination = "setUpScreen") {

        composable("setUpScreen") {
            SetupScreen(
                navController = navController,
                initialPlayerCount = gamePlayerCount,
                initialGameDuration = gameDuration,
                initialShowHints = showHints,
                onSettingsChange = { playerCount, duration, hints ->
                    gamePlayerCount = playerCount
                    gameDuration = duration
                    showHints = hints
                }
            )
        }

        composable(
            "playerSetUpScreen/{playerCount}",
            arguments = listOf(
                navArgument("playerCount") { type = NavType.IntType },
            )
        ) {
            val playerCount = it.arguments?.getInt("playerCount")!!
            PlayerSetupScreen(
                navController = navController,
                playerCount = playerCount,
                existingPlayers = playersData.take(playerCount), // Mevcut oyuncu verilerini geç
                onBackClick = {
                    navController.popBackStack()
                },
                onStartGame = { players ->
                    // Oyuncu verilerini kaydet
                    playersData = players
                }
            )
        }

        composable("categoryScreen") {
            CategoryScreen(
                navController = navController
            )
        }
    }
}