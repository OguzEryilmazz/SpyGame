package com.example.spy.ux

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.filled.AccessTime
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController
import com.example.spy.ux.components.CounterRow
import com.example.spy.ux.components.SettingItem

@Composable
fun SetupScreen(
    navController: NavController,
    initialPlayerCount: Int = 4,
    initialGameDuration: Int = 5,
    initialShowHints: Boolean = true,
    onSettingsChange: (Int, Int, Boolean) -> Unit = { _, _, _ -> }
) {
    var playerCount by remember { mutableStateOf(initialPlayerCount) }
    var gameDuration by remember { mutableStateOf(initialGameDuration) }
    var showHints by remember { mutableStateOf(initialShowHints) }

    // Değişiklikleri parent'a bildir
    LaunchedEffect(playerCount, gameDuration, showHints) {
        onSettingsChange(playerCount, gameDuration, showHints)
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFFE91E63), // Pink
                        Color(0xFF9C27B0), // Purple
                        Color(0xFFF44336)  // Red
                    )
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp)
                .padding(bottom = 80.dp) // Bottom button için alan bırak
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(40.dp))

            // Header
            Text(
                text = "Spy - Haini Bul",
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )

            Text(
                text = "Oyun ayarlarını seç ve başla!",
                fontSize = 16.sp,
                color = Color.White.copy(alpha = 0.8f),
                modifier = Modifier.padding(top = 8.dp)
            )

            Spacer(modifier = Modifier.height(40.dp))

            // Settings Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = CardDefaults.cardColors(
                    containerColor = Color.White.copy(alpha = 0.1f)
                )
            ) {
                Column(
                    modifier = Modifier.padding(24.dp)
                ) {
                    // Oyuncu Sayısı
                    SettingItem(
                        icon = Icons.Default.People,
                        title = "Oyuncu Sayısı",
                        subtitle = "Kaç kişi oynayacak?",
                        iconColor = Color(0xFFFF9800) // Orange
                    ) {
                        CounterRow(
                            value = playerCount,
                            onDecrease = {
                                if (playerCount > 3) playerCount--
                            },
                            onIncrease = {
                                if (playerCount < 10) playerCount++
                            }
                        )
                    }

                    Spacer(modifier = Modifier.height(32.dp))

                    // Oyun Süresi
                    SettingItem(
                        icon = Icons.Default.AccessTime,
                        title = "Oyun Süresi",
                        subtitle = "Kaç dakika oynanacak?",
                        iconColor = Color(0xFF2196F3) // Blue
                    ) {
                        CounterRow(
                            value = gameDuration,
                            onDecrease = {
                                if (gameDuration > 1) gameDuration--
                            },
                            onIncrease = {
                                if (gameDuration < 15) gameDuration++
                            },
                            suffix = " dk"
                        )
                    }

                    Spacer(modifier = Modifier.height(32.dp))

                    // İpucu Ayarı - Güncellenmiş
                    SettingItem(
                        icon = if (showHints) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                        title = "Imposter İpucu",
                        subtitle = "Imposter'a ipucu gösterilsin mi?",
                        iconColor = if(showHints) Color(0xFF4CAF50) else Color(0xFFF44336), // Green/Red
                        onIconClick = { showHints = !showHints }
                    ){}
                }
            }

            Spacer(modifier = Modifier.height(40.dp))
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
                .padding(24.dp)
        ) {
            Button(
                onClick = {
                    navController.navigate("playerSetUpScreen/$playerCount")
                    println("Oyun başlatılıyor: $playerCount oyuncu, $gameDuration dk, İpucu: $showHints")
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White
                ),
                shape = RoundedCornerShape(16.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.PlayArrow,
                    contentDescription = null,
                    tint = Color(0xFFE91E63),
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Devam Et",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFFE91E63)
                )
            }
        }
    }
}

@Composable
@Preview(showBackground = true)
fun Pre() {
    SetupScreen(navController = rememberNavController())
}