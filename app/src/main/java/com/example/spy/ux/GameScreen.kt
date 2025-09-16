package com.example.spy.ux

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import kotlinx.coroutines.delay
import kotlin.math.roundToInt

@Composable
fun GameScreen(
    navController: NavController,
    gamePlayers: List<GamePlayer>,
    category: Category,
    gameDurationMinutes: Int,
    showHints: Boolean
) {
    var currentPlayerIndex by remember { mutableStateOf(0) }
    var gameStarted by remember { mutableStateOf(false) }
    var timeLeft by remember { mutableStateOf(gameDurationMinutes * 60) }

    LaunchedEffect(gameStarted, timeLeft) {
        if (gameStarted && timeLeft > 0) {
            delay(1000L)
            timeLeft--
        }
    }

    val timeString = String.format("%02d:%02d", timeLeft / 60, timeLeft % 60)

    if (!gameStarted) {
        PlayerScreen(
            player = gamePlayers[currentPlayerIndex],
            playerIndex = currentPlayerIndex,
            totalPlayers = gamePlayers.size,
            category = category,
            timeString = timeString,
            showHints = showHints,
            onBack = { navController.popBackStack() },
            onNext = {
                if (currentPlayerIndex < gamePlayers.size - 1) {
                    currentPlayerIndex++
                } else {
                    gameStarted = true
                }
            },
            onPrevious = {
                if (currentPlayerIndex > 0) {
                    currentPlayerIndex--
                }
            }
        )
    } else {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "Game Started!\nTime: $timeString",
                color = Color.White,
                fontSize = 24.sp,
                textAlign = TextAlign.Center
            )
        }
    }
}

@Composable
fun PlayerScreen(
    player: GamePlayer,
    playerIndex: Int,
    totalPlayers: Int,
    category: Category,
    timeString: String,
    showHints: Boolean,
    onBack: () -> Unit,
    onNext: () -> Unit,
    onPrevious: () -> Unit
) {
    var showRole by remember { mutableStateOf(false) }
    var cardOffset by remember { mutableStateOf(0f) }

    val density = LocalDensity.current
    val screenHeight = with(density) { 800.dp.toPx() }
    val maxPullUp = screenHeight * 0.35f

    // Reset when player changes
    LaunchedEffect(playerIndex) {
        showRole = false
        cardOffset = 0f
    }

    // Smooth animation for card movement
    val animatedOffset by animateFloatAsState(
        targetValue = if (showRole) maxPullUp else 0f, // Basit: açık ise maxPullUp, kapalı ise 0f
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium
        ),
        label = "cardOffset"
    )

    Box(modifier = Modifier.fillMaxSize()) {
        // Main player screen
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(player.color)
        ) {
            // Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(
                    onClick = onBack,
                    modifier = Modifier
                        .clip(CircleShape)
                        .background(Color.Black.copy(alpha = 0.2f))
                ) {
                    Icon(
                        imageVector = Icons.Default.ArrowBack,
                        contentDescription = "Back",
                        tint = Color.White
                    )
                }

                Spacer(modifier = Modifier.weight(1f))

                Surface(
                    shape = RoundedCornerShape(16.dp),
                    color = Color.Black.copy(alpha = 0.2f)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.Timer,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = timeString,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }
                }
            }

            // Player info
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(32.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                // Avatar
                Box(
                    modifier = Modifier
                        .size(160.dp)
                        .clip(CircleShape)
                        .background(Color.Black.copy(alpha = 0.3f)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = player.name.first().toString().uppercase(),
                        fontSize = 64.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color = Color.White
                    )
                }

                Spacer(modifier = Modifier.height(32.dp))

                Text(
                    text = player.name,
                    fontSize = 36.sp,
                    fontWeight = FontWeight.ExtraBold,
                    color = Color.White,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = "${playerIndex + 1} / $totalPlayers",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White.copy(alpha = 0.8f)
                )

                Spacer(modifier = Modifier.height(80.dp))

                // Instructions and reveal button
                Text(
                    text = if (showRole) "Drag down to close" else "Tap to reveal your role",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White.copy(alpha = 0.8f),
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(32.dp))

                if (!showRole) {
                    // Estetik reveal butonu
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(60.dp)
                            .clickable { showRole = true },
                        shape = RoundedCornerShape(30.dp),
                        colors = CardDefaults.cardColors(
                            containerColor = Color.White.copy(alpha = 0.15f)
                        ),
                        elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
                    ) {
                        Box(
                            modifier = Modifier.fillMaxSize(),
                            contentAlignment = Alignment.Center
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.Center
                            ) {

                                Text(
                                    text = "REVEAL ROLE",
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.ExtraBold,
                                    color = Color.White,
                                    letterSpacing = 1.sp
                                )

                            }
                        }
                    }
                }
            }
        }

        // Navigation at bottom
        Row(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .padding(20.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Button(
                onClick = onPrevious,
                enabled = playerIndex > 0,
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White.copy(alpha = 0.2f),
                    disabledContainerColor = Color.Transparent
                ),
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = "← Previous",
                    color = if (playerIndex > 0) Color.White else Color.Transparent
                )
            }


            Button(
                onClick = onNext,
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White.copy(alpha = 0.2f)
                ),
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = if (playerIndex < totalPlayers - 1) "Next →" else "START →",
                    color = Color.White
                )
            }
        }

        // Black reveal card - sadece aşağı sürükleyerek kapatma
        if (showRole) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black)
                    .pointerInput(showRole) {
                        detectVerticalDragGestures(
                            onDragEnd = {
                                // Aşağı sürükleyince kapat
                                if (cardOffset < maxPullUp * 0.5f) {
                                    showRole = false
                                    cardOffset = 0f
                                }
                            }
                        ) { _, dragAmount ->
                            // Sadece aşağı drag'e izin ver
                            if (dragAmount > 0) {
                                val newOffset = cardOffset - dragAmount
                                cardOffset = newOffset.coerceAtLeast(0f)
                            }
                        }
                    }
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(32.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    // Drag handle at top
                    Box(
                        modifier = Modifier
                            .align(Alignment.CenterHorizontally)
                            .width(60.dp)
                            .height(5.dp)
                            .clip(RoundedCornerShape(2.5.dp))
                            .background(Color.White.copy(alpha = 0.5f))
                    )

                    Spacer(modifier = Modifier.height(80.dp))

                    // Player name
                    Text(
                        text = player.name,
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        textAlign = TextAlign.Center
                    )

                    Spacer(modifier = Modifier.height(60.dp))

                    // ROLE YAZISI - ANA GÖSTERIM
                    if (player.role == "SPY") {
                        // Impostor için
                        Text(
                            text = "IMPOSTOR",
                            fontSize = 56.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = Color(0xFFF44336),
                            textAlign = TextAlign.Center
                        )

                        // Hint varsa göster
                        if (showHints && !player.hint.isNullOrEmpty()) {
                            Spacer(modifier = Modifier.height(40.dp))
                            Text(
                                text = player.hint!!,
                                fontSize = 22.sp,
                                fontWeight = FontWeight.Medium,
                                color = Color(0xFFFF8A80),
                                textAlign = TextAlign.Center
                            )
                        }
                    } else {
                        // Normal rol için
                        Text(
                            text = player.role.uppercase(),
                            fontSize = 48.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = Color.White,
                            textAlign = TextAlign.Center
                        )

                        // Normal roller için de hint varsa göster
                        if (showHints && !player.hint.isNullOrEmpty()) {
                            Spacer(modifier = Modifier.height(40.dp))
                            Text(
                                text = player.hint!!,
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Medium,
                                color = Color.White.copy(alpha = 0.8f),
                                textAlign = TextAlign.Center
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(100.dp))

                    Text(
                        text = "⬇ Drag down to close",
                        fontSize = 16.sp,
                        color = Color.White.copy(alpha = 0.7f),
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}