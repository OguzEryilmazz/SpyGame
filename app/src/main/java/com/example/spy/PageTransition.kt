package com.example.spy

import androidx.compose.runtime.*
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.spy.ux.*
import com.example.spy.models.CharacterAvatar // YENİ IMPORT

@Composable
fun PageTransition() {
    val navController = rememberNavController()

    // Oyun ayarları state'leri
    var gamePlayerCount by remember { mutableStateOf(4) }
    var gameDuration by remember { mutableStateOf(5) }
    var showHints by remember { mutableStateOf(true) }

    // Oyuncu verileri - Bu veriler tüm navigation boyunca korunacak
    // Player data class'ı artık selectedCharacter alanını da içeriyor
    var playersData by remember { mutableStateOf<List<Player>>(emptyList()) }

    // Seçilen kategori ve oyun verileri
    var selectedCategory by remember { mutableStateOf<Category?>(null) }
    var gamePlayersData by remember { mutableStateOf<List<GamePlayer>>(emptyList()) }

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
        ) { backStackEntry ->
            val playerCount = backStackEntry.arguments?.getInt("playerCount") ?: 4
            PlayerSetupScreen(
                navController = navController,
                playerCount = playerCount,
                existingPlayers = playersData.take(playerCount),
                onBackClick = {
                    navController.popBackStack()
                },
                onStartGame = { players ->
                    // Oyuncu verilerini kaydet (artık karakter seçimi de dahil)
                    playersData = players
                    navController.navigate("categoryScreen")
                }
            )
        }

        composable("categoryScreen") {
            CategoryScreen(
                navController = navController,
                players = playersData,
                onCategorySelected = { category, gamePlayers ->
                    // Seçilen kategori ve oyun oyuncularını kaydet
                    selectedCategory = category
                    gamePlayersData = gamePlayers
                    navController.navigate("gameScreen")
                }
            )
        }

        composable("gameScreen") {
            // Eğer gerekli veriler yoksa geri dön
            val category = selectedCategory
            if (category == null || gamePlayersData.isEmpty()) {
                LaunchedEffect(Unit) {
                    navController.popBackStack("setUpScreen", inclusive = false)
                }
                return@composable
            }

            GameScreen(
                navController = navController,
                gamePlayers = gamePlayersData,
                category = category,
                gameDurationMinutes = gameDuration,
                showHints = showHints
            )
        }

        composable("timerScreen") {
            TimerScreen(navController, gameDuration)
        }
    }
}