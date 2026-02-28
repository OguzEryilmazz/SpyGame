package com.oguz.spy.domain

import com.oguz.spy.ux.GamePlayer
import com.oguz.spy.ux.Player

class GameEngine {

    fun assignRoles(
        players: List<Player>,
        items: List<String>,
        hints: List<String>,
        showHints: Boolean
    ): List<GamePlayer> {
        if (players.isEmpty()) return emptyList()
        if (items.isEmpty()) return emptyList()

        val shuffledPlayers = players.shuffled()
        val spyIndex = shuffledPlayers.indices.random()
        val chosenItem = items.random()
        val spyHint = if (showHints && hints.isNotEmpty()) hints.random() else null

        return shuffledPlayers.mapIndexed { index, player ->
            if (index == spyIndex) {
                GamePlayer(
                    id = player.id,
                    name = player.name,
                    color = player.selectedColor,
                    selectedCharacter = player.selectedCharacter,
                    role = "SPY",
                    hint = spyHint
                )
            } else {
                GamePlayer(
                    id = player.id,
                    name = player.name,
                    color = player.selectedColor,
                    selectedCharacter = player.selectedCharacter,
                    role = chosenItem,
                    hint = null
                )
            }
        }
    }

    fun calculateVotingResults(
        votes: Map<String, String>,
        gamePlayers: List<GamePlayer>
    ): VotingResult {
        if (votes.isEmpty() || gamePlayers.isEmpty()) {
            return VotingResult(
                mostVotedPlayer = null,
                spyPlayer = gamePlayers.find { it.role == "SPY" },
                isSpyCaught = false,
                voteCounts = emptyMap()
            )
        }

        val voteCount = mutableMapOf<String, Int>()
        votes.values.forEach { votedPlayerName ->
            voteCount[votedPlayerName] = voteCount.getOrDefault(votedPlayerName, 0) + 1
        }

        val mostVotedPlayerName = voteCount.maxByOrNull { it.value }?.key
        val mostVotedPlayer = gamePlayers.find { it.name == mostVotedPlayerName }
        val spyPlayer = gamePlayers.find { it.role == "SPY" }
        val isSpyCaught = mostVotedPlayer?.id == spyPlayer?.id

        return VotingResult(
            mostVotedPlayer = mostVotedPlayer,
            spyPlayer = spyPlayer,
            isSpyCaught = isSpyCaught,
            voteCounts = voteCount
        )
    }

    fun validateGameSetup(
        playerCount: Int,
        gameDuration: Int
    ): GameValidationResult {
        val errors = mutableListOf<String>()

        if (playerCount < 3) {
            errors.add("En az 3 oyuncu gereklidir")
        }
        if (playerCount > 9) {
            errors.add("En fazla 9 oyuncu olabilir")
        }
        if (gameDuration < 1) {
            errors.add("Oyun süresi en az 1 dakika olmalıdır")
        }
        if (gameDuration > 15) {
            errors.add("Oyun süresi en fazla 15 dakika olabilir")
        }

        return GameValidationResult(
            isValid = errors.isEmpty(),
            errors = errors
        )
    }

    data class VotingResult(
        val mostVotedPlayer: GamePlayer?,
        val spyPlayer: GamePlayer?,
        val isSpyCaught: Boolean,
        val voteCounts: Map<String, Int>
    )

    data class GameValidationResult(
        val isValid: Boolean,
        val errors: List<String>
    )
}
