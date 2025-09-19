package com.example.spy.ux

import androidx.compose.runtime.*
import androidx.navigation.NavController
import com.example.spy.ux.components.VotingInterface
import com.example.spy.ux.components.VotingResultsScreen

@Composable
fun VotingScreen(
    navController: NavController,
    gamePlayers: List<GamePlayer>
) {
    var selectedPlayerName by remember { mutableStateOf<String?>(null) }
    var votingPhase by remember { mutableStateOf(VotingPhase.VOTING) }
    var currentVoterIndex by remember { mutableStateOf(0) }
    var votes by remember { mutableStateOf(mutableMapOf<String, String>()) } // Kimin kime oy verdiği
    var mostVotedPlayer by remember { mutableStateOf<GamePlayer?>(null) }

    val impostor = gamePlayers.find { it.role == "SPY" }
    val currentVoter = if (currentVoterIndex < gamePlayers.size) gamePlayers[currentVoterIndex] else null

    // Oylama sonuçlarını hesapla
    fun calculateResults() {
        // Oy sayılarını hesapla
        val voteCount = mutableMapOf<String, Int>()
        votes.values.forEach { votedPlayerName ->
            voteCount[votedPlayerName] = voteCount.getOrDefault(votedPlayerName, 0) + 1
        }

        // En çok oy alan oyuncuyu bul
        mostVotedPlayer = voteCount.maxByOrNull { it.value }?.let { (playerName, _) ->
            gamePlayers.find { it.name == playerName }
        }

        votingPhase = VotingPhase.RESULTS
    }

    // Sıradaki oyuncuya geç
    fun nextVoter() {
        if (selectedPlayerName != null && currentVoter != null) {
            votes[currentVoter.name] = selectedPlayerName!!
            selectedPlayerName = null

            if (currentVoterIndex < gamePlayers.size - 1) {
                currentVoterIndex++
            } else {
                calculateResults()
            }
        }
    }

    when (votingPhase) {
        VotingPhase.VOTING -> {
            if (currentVoter != null) {
                VotingInterface(
                    players = gamePlayers,
                    currentVoter = currentVoter,
                    selectedPlayerName = selectedPlayerName,
                    onPlayerSelect = { selectedPlayerName = it },
                    onVoteSubmit = { nextVoter() },
                    onBack = { navController.popBackStack() },
                    votingProgress = (currentVoterIndex + 1) to gamePlayers.size
                )
            }
        }
        VotingPhase.RESULTS -> {
            VotingResultsScreen(
                impostor = impostor,
                mostVotedPlayer = mostVotedPlayer,
                votes = votes.values.groupingBy { it }.eachCount(),
                gamePlayers = gamePlayers,
                onPlayAgain = {
                    navController.navigate("categoryScreen") {
                        popUpTo("categoryScreen") { inclusive = true }
                    }
                },
                onMainMenu = {
                    navController.navigate("categoryScreen") {
                        popUpTo("categoryScreen") { inclusive = true }
                    }
                }
            )
        }
    }
}

enum class VotingPhase {
    VOTING,
    RESULTS
}
