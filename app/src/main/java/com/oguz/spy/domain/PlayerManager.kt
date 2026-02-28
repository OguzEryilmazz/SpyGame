package com.oguz.spy.domain

import androidx.compose.ui.graphics.Color
import com.oguz.spy.models.CharacterAvatar
import com.oguz.spy.ux.Player

class PlayerManager {

    private val availableColors = listOf(
        Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF3F51B5),
        Color(0xFF2196F3), Color(0xFF00BCD4), Color(0xFF4CAF50),
        Color(0xFF8BC34A), Color(0xFFFFEB3B), Color(0xFFFF9800),
        Color(0xFFFF5722), Color(0xFF795548), Color(0xFF607D8B)
    )

    fun createDefaultPlayers(count: Int, existingPlayers: List<Player> = emptyList()): List<Player> {
        val players = mutableListOf<Player>()

        existingPlayers.take(count).forEachIndexed { index, player ->
            players.add(player.copy(id = index + 1))
        }

        val missingCount = count - existingPlayers.size
        repeat(missingCount) { index ->
            val playerId = existingPlayers.size + index + 1
            val usedColors = players.map { it.selectedColor }
            val usedCharacters = players.mapNotNull { it.selectedCharacter }

            val availableColor = availableColors.firstOrNull {
                !usedColors.contains(it)
            } ?: availableColors[(playerId - 1) % availableColors.size]

            val availableCharacter = CharacterAvatar.values().firstOrNull {
                !usedCharacters.contains(it)
            }

            players.add(
                Player(
                    id = playerId,
                    name = "Oyuncu $playerId",
                    selectedColor = availableColor,
                    selectedCharacter = availableCharacter
                )
            )
        }

        return players
    }

    fun validatePlayers(players: List<Player>): PlayerValidationResult {
        val errors = mutableListOf<String>()

        if (players.any { it.name.isBlank() }) {
            errors.add("Tüm oyuncuların isimleri dolu olmalıdır")
        }

        val duplicateNames = players.groupBy { it.name }
            .filter { it.value.size > 1 }
            .keys

        if (duplicateNames.isNotEmpty()) {
            errors.add("Oyuncu isimleri benzersiz olmalıdır")
        }

        val duplicateColors = players.groupBy { it.selectedColor }
            .filter { it.value.size > 1 }

        if (duplicateColors.isNotEmpty()) {
            errors.add("Her oyuncunun benzersiz bir rengi olmalıdır")
        }

        return PlayerValidationResult(
            isValid = errors.isEmpty(),
            errors = errors
        )
    }

    fun isPlayerSetupValid(players: List<Player>): Boolean {
        return players.all { it.name.isNotBlank() } &&
                players.map { it.selectedColor }.distinct().size == players.size
    }

    fun getAvailableColors(): List<Color> = availableColors

    fun getAvailableColor(usedColors: List<Color>, preferredIndex: Int): Color {
        return availableColors.firstOrNull { !usedColors.contains(it) }
            ?: availableColors[preferredIndex % availableColors.size]
    }

    fun getAvailableCharacter(usedCharacters: List<CharacterAvatar>): CharacterAvatar? {
        return CharacterAvatar.values().firstOrNull { !usedCharacters.contains(it) }
    }

    data class PlayerValidationResult(
        val isValid: Boolean,
        val errors: List<String>
    )
}
