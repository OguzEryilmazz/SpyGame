package com.oguz.spy.domain

import com.oguz.spy.ux.Category
import com.oguz.spy.ux.GamePlayer
import com.oguz.spy.ux.Player

class GameStateManager {

    private var currentGameState: GameState = GameState()

    fun updateSettings(playerCount: Int, gameDuration: Int, showHints: Boolean) {
        currentGameState = currentGameState.copy(
            playerCount = playerCount,
            gameDurationMinutes = gameDuration,
            showHints = showHints
        )
    }

    fun setPlayers(players: List<Player>) {
        currentGameState = currentGameState.copy(players = players)
    }

    fun startGame(category: Category, gamePlayers: List<GamePlayer>) {
        currentGameState = currentGameState.copy(
            selectedCategory = category,
            gamePlayers = gamePlayers,
            currentPhase = GamePhase.GAME_STARTED
        )
    }

    fun moveToPhase(phase: GamePhase) {
        currentGameState = currentGameState.copy(currentPhase = phase)
    }

    fun resetGame() {
        currentGameState = currentGameState.copy(
            selectedCategory = null,
            gamePlayers = emptyList(),
            currentPhase = GamePhase.SETUP
        )
    }

    fun getCurrentState(): GameState = currentGameState

    data class GameState(
        val playerCount: Int = 4,
        val gameDurationMinutes: Int = 5,
        val showHints: Boolean = true,
        val players: List<Player> = emptyList(),
        val selectedCategory: Category? = null,
        val gamePlayers: List<GamePlayer> = emptyList(),
        val currentPhase: GamePhase = GamePhase.SETUP
    )

    enum class GamePhase {
        SETUP,
        PLAYER_SETUP,
        CATEGORY_SELECTION,
        GAME_STARTED,
        TIMER_RUNNING,
        VOTING,
        RESULTS
    }
}
