package com.oguz.spy.ux

import android.app.Activity
import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalContext
import androidx.navigation.NavController
import com.oguz.spy.ads.InterstitialAdManager
import com.oguz.spy.ux.components.VotingInterface
import com.oguz.spy.ux.components.VotingResultsScreen

@Composable
fun VotingScreen(
    navController: NavController,
    gamePlayers: List<GamePlayer>,
    interstitialAdManager: InterstitialAdManager
) {
    val context = LocalContext.current
    val activity = context as? Activity

    var votingPhase by remember { mutableStateOf(VotingPhase.VOTING) }
    var currentVoterIndex by remember { mutableStateOf(0) }
    var votes by remember { mutableStateOf(mutableMapOf<String, String>()) }
    var mostVotedPlayer by remember { mutableStateOf<GamePlayer?>(null) }

    val impostor = gamePlayers.find { it.role == "SPY" }
    val currentVoter = if (currentVoterIndex < gamePlayers.size) {
        gamePlayers[currentVoterIndex]
    } else {
        null
    }

    // Oylama sonuçlarını hesapla
    fun calculateResults() {
        val voteCount = mutableMapOf<String, Int>()
        votes.values.forEach { votedPlayerName ->
            voteCount[votedPlayerName] = voteCount.getOrDefault(votedPlayerName, 0) + 1
        }

        mostVotedPlayer = voteCount.maxByOrNull { it.value }?.let { (playerName, _) ->
            gamePlayers.find { it.name == playerName }
        }

        votingPhase = VotingPhase.RESULTS
    }

    // Oy ver ve devam et
    fun submitVote(playerName: String) {
        if (currentVoter != null) {
            votes[currentVoter.name] = playerName

            if (currentVoterIndex < gamePlayers.size - 1) {
                currentVoterIndex++
            } else {
                calculateResults()
            }
        }
    }

    // Önceki oyuncuya dön
    fun goToPreviousVoter() {
        if (currentVoterIndex > 0) {
            currentVoterIndex--
            // Önceki oyuncunun oyunu sil
            if (currentVoter != null) {
                votes.remove(currentVoter.name)
            }
        }
    }

    when {
        // Sonuç ekranı
        votingPhase == VotingPhase.RESULTS -> {
            VotingResultsScreen(
                impostor = impostor,
                mostVotedPlayer = mostVotedPlayer,
                votes = votes.values.groupingBy { it }.eachCount(),
                gamePlayers = gamePlayers,
                onPlayAgain = {
                    // ✅ Tekrar oyna butonunda reklam göster (sıklık kontrolü ile)
                    activity?.let {
                        interstitialAdManager.showAdWithFrequencyControl(
                            activity = it,
                            onAdDismissed = {
                                navController.navigate("categoryScreen") {
                                    popUpTo("categoryScreen") { inclusive = true }
                                }
                            },
                            onAdShowFailed = { error ->
                                println("Reklam gösterilemedi: $error")
                                navController.navigate("categoryScreen") {
                                    popUpTo("categoryScreen") { inclusive = true }
                                }
                            }
                        )
                    } ?: run {
                        navController.navigate("categoryScreen") {
                            popUpTo("categoryScreen") { inclusive = true }
                        }
                    }
                },
                onMainMenu = {
                    // ✅ Ana menü butonunda reklam göster (sıklık kontrolü ile)
                    activity?.let {
                        interstitialAdManager.showAdWithFrequencyControl(
                            activity = it,
                            onAdDismissed = {
                                navController.navigate("categoryScreen") {
                                    popUpTo("categoryScreen") { inclusive = true }
                                }
                            },
                            onAdShowFailed = { error ->
                                println("Reklam gösterilemedi: $error")
                                navController.navigate("categoryScreen") {
                                    popUpTo("categoryScreen") { inclusive = true }
                                }
                            }
                        )
                    } ?: run {
                        navController.navigate("categoryScreen") {
                            popUpTo("categoryScreen") { inclusive = true }
                        }
                    }
                }
            )
        }

        // Ana oylama ekranı
        votingPhase == VotingPhase.VOTING && currentVoter != null -> {
            VotingInterface(
                players = gamePlayers,
                currentVoter = currentVoter,
                voterIndex = currentVoterIndex,
                totalVoters = gamePlayers.size,
                onPlayerSelect = { playerName ->
                    submitVote(playerName)
                },
                onBack = { navController.popBackStack() },
                onPrevious = {
                    goToPreviousVoter()
                }
            )
        }
    }
}

enum class VotingPhase {
    VOTING,
    RESULTS
}