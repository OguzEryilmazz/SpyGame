package com.example.spy.ux

import androidx.compose.runtime.Composable
import androidx.navigation.NavController

import androidx.compose.foundation.background

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.compose.rememberNavController
import com.example.spy.ux.components.PlayerCard

data class Player(
    val id: Int,
    var name: String = "",
    var selectedColor: Color = Color.Gray
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PlayerSetupScreen(
    navController: NavController,
    playerCount: Int = 4,
    existingPlayers: List<Player> = emptyList(),
    onBackClick: () -> Unit = { navController.popBackStack() },
    onStartGame: (List<Player>) -> Unit = { navController.navigate("categoryScreen") }
) {
    // Mevcut renkler
    val availableColors = listOf(
        Color(0xFFE91E63), // Pink
        Color(0xFF9C27B0), // Purple
        Color(0xFF3F51B5), // Indigo
        Color(0xFF2196F3), // Blue
        Color(0xFF00BCD4), // Cyan
        Color(0xFF4CAF50), // Green
        Color(0xFF8BC34A), // Light Green
        Color(0xFFFFEB3B), // Yellow
        Color(0xFFFF9800), // Orange
        Color(0xFFFF5722), // Deep Orange
        Color(0xFF795548), // Brown
        Color(0xFF607D8B)  // Blue Grey
    )

    // Oyuncular listesi
    var players by remember {
        mutableStateOf(
            if (existingPlayers.isNotEmpty() && existingPlayers.size >= playerCount) {
                // Mevcut oyuncular varsa ve yeterli sayıda ise onları kullan
                existingPlayers.take(playerCount).mapIndexed { index, existingPlayer ->
                    existingPlayer.copy(id = index + 1)
                }
            } else {
                // Mevcut oyuncuları kullan ve eksik olanları ekle
                val existingPlayersToUse = existingPlayers.take(playerCount)
                val missingPlayersCount = playerCount - existingPlayersToUse.size

                val allPlayers = mutableListOf<Player>()

                // Mevcut oyuncuları ekle
                existingPlayersToUse.forEachIndexed { index, player ->
                    allPlayers.add(player.copy(id = index + 1))
                }

                // Eksik oyuncuları ekle
                repeat(missingPlayersCount) { index ->
                    val playerId = existingPlayersToUse.size + index + 1
                    val usedColors = allPlayers.map { it.selectedColor }
                    val availableColor = availableColors.firstOrNull {
                        !usedColors.contains(it)
                    } ?: availableColors[(playerId - 1) % availableColors.size]

                    allPlayers.add(
                        Player(
                            id = playerId,
                            name = "Oyuncu $playerId",
                            selectedColor = availableColor
                        )
                    )
                }

                allPlayers
            }
        )
    }

    // Form valid mi kontrol et
    val isFormValid = players.all { it.name.isNotBlank() } &&
            players.map { it.selectedColor }.distinct().size == players.size

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFFE91E63),
                        Color(0xFF9C27B0),
                        Color(0xFFF44336)
                    )
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(bottom = 80.dp , top = 20.dp) // Button için alan bırak
        ) {
            // Top Bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(
                    onClick = onBackClick,
                    modifier = Modifier
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.2f))
                ) {
                    Icon(
                        imageVector = Icons.Default.ArrowBack,
                        contentDescription = "Geri",
                        tint = Color.White
                    )
                }

                Spacer(modifier = Modifier.width(16.dp))

                Column {
                    Text(
                        text = "Oyuncular",
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Text(
                        text = "İsim ve renk seçin",
                        fontSize = 14.sp,
                        color = Color.White.copy(alpha = 0.8f)
                    )
                }
            }

            // Players List - Scrollable içerik
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                itemsIndexed(players) { index, player ->
                    PlayerCard(
                        player = player,
                        availableColors = availableColors,
                        usedColors = players.mapNotNull { if (it.id != player.id) it.selectedColor else null },
                        onNameChange = { newName ->
                            players = players.map {
                                if (it.id == player.id) it.copy(name = newName) else it
                            }
                        },
                        onColorChange = { newColor ->
                            players = players.map {
                                if (it.id == player.id) it.copy(selectedColor = newColor) else it
                            }
                        }
                    )
                }

                // Extra spacing for last item
                item {
                    Spacer(modifier = Modifier.height(16.dp))
                }
            }
        }


        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color.Transparent,
                            Color.Black.copy(alpha = 0.3f)
                        )
                    )
                )
                .padding(16.dp)
        ) {
            Button(
                onClick = {
                    navController.navigate("categoryScreen")

                    players.forEach { player ->
                        println("${player.name} - Renk: ${player.selectedColor}")
                    }
                    // CategoryScreen'e geç
                    onStartGame(players)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                enabled = isFormValid,
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White,
                    disabledContainerColor = Color.White.copy(alpha = 0.5f)
                ),
                shape = RoundedCornerShape(16.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.PlayArrow,
                    contentDescription = null,
                    tint = if (isFormValid) Color(0xFFE91E63) else Color.Gray,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Kategori Seç",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = if (isFormValid) Color(0xFFE91E63) else Color.Gray
                )
            }
        }
    }
}

@Composable
@Preview(showBackground = true)
fun Prre(){
    PlayerSetupScreen(navController = rememberNavController())
}