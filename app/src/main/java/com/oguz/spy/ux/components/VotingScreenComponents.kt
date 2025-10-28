package com.oguz.spy.ux.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.oguz.spy.ux.GamePlayer

@Composable
fun VotingInterface(
    players: List<GamePlayer>,
    currentVoter: GamePlayer,
    voterIndex: Int,
    totalVoters: Int,
    onPlayerSelect: (String) -> Unit,
    onBack: () -> Unit,
    onPrevious: () -> Unit,
) {
    val votablePlayers = players.filter { it.name != currentVoter.name }

    var cardOffset by remember { mutableStateOf(0f) }
    var isDragging by remember { mutableStateOf(false) }

    val density = LocalDensity.current
    val screenHeight = with(density) { 800.dp.toPx() }
    val maxPullUp = screenHeight * 1f

    // Reset when voter changes
    LaunchedEffect(voterIndex) {
        cardOffset = 0f
        isDragging = false
    }

    // Smooth animation for card movement
    val animatedOffset by animateFloatAsState(
        targetValue = if (isDragging) cardOffset else 0f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium
        ),
        label = "cardOffset"
    )

    // Animasyonlu ok
    val infiniteTransition = rememberInfiniteTransition(label = "arrow")
    val arrowOffset by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = -10f,
        animationSpec = infiniteRepeatable(
            animation = tween(1000, easing = EaseInOutSine),
            repeatMode = RepeatMode.Reverse
        ),
        label = "arrowOffset"
    )

    Box(modifier = Modifier.fillMaxSize()) {
        // Ana oyuncu ekranı
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(currentVoter.color)
                .padding(top = 20.dp)
                .pointerInput(Unit) {
                    detectTapGestures(
                        onLongPress = {
                            // Basılı tutma ile önceki oyuncuya dön
                            onPrevious()
                        }
                    )
                }
                .pointerInput(Unit) {
                    detectVerticalDragGestures(
                        onDragStart = {
                            isDragging = true
                        },
                        onDragEnd = {
                            if (cardOffset < maxPullUp * 0.3f) {
                                cardOffset = 0f
                                isDragging = false
                            }
                        }
                    ) { _, dragAmount ->
                        val newOffset = (cardOffset - dragAmount).coerceIn(0f, maxPullUp)
                        cardOffset = newOffset
                    }
                }
        ) {
            // Üst header
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
                        contentDescription = "Geri",
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
                            imageVector = Icons.Default.HowToVote,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = "${voterIndex + 1}/${totalVoters}",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }
                }
            }

            // Oyuncu bilgileri ve drag alanı
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(32.dp)
                    .offset(y = (-animatedOffset / density.density).dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                // Avatar
                if (currentVoter.selectedCharacter != null) {
                    Image(
                        painter = painterResource(id = currentVoter.selectedCharacter.drawableRes),
                        contentDescription = "${currentVoter.name} avatar",
                        modifier = Modifier.size(200.dp)
                    )
                } else {
                    Box(
                        modifier = Modifier
                            .size(160.dp)
                            .clip(CircleShape)
                            .background(Color.Black.copy(alpha = 0.3f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = currentVoter.name.first().uppercase(),
                            fontSize = 64.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = Color.White
                        )
                    }
                }

                Spacer(modifier = Modifier.height(32.dp))

                Text(
                    text = currentVoter.name.uppercase(),
                    fontSize = 36.sp,
                    fontWeight = FontWeight.ExtraBold,
                    color = Color.White,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = "${voterIndex + 1} / $totalVoters",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White.copy(alpha = 0.8f)
                )

                Spacer(modifier = Modifier.height(60.dp))

                // Yukarı kaydır talimatı
                Text(
                    text = "🔍",
                    fontSize = 48.sp
                )

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = "Yukarı kaydır ve oy ver",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White.copy(alpha = 0.9f),
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(20.dp))

                // Alt bilgi metni
                Text(
                    text = "Basılı tut ve geri dön",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.White.copy(alpha = 0.7f),
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(20.dp))

                // Animasyonlu ok
                Icon(
                    imageVector = Icons.Default.KeyboardArrowUp,
                    contentDescription = null,
                    tint = Color.White.copy(alpha = 0.8f),
                    modifier = Modifier
                        .size(48.dp)
                        .offset(y = arrowOffset.dp)
                )
            }
        }

        // Alt siyah ekran - Oyuncu listesi
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height((animatedOffset / density.density).dp)
                .align(Alignment.BottomCenter)
                .background(Color.Black)
        ) {
            if (cardOffset > maxPullUp * 0.3f) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(32.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "SPY KİMDİR?",
                        fontSize = 32.sp,
                        fontWeight = FontWeight.Black,
                        color = Color(0xFFEF4444),
                        textAlign = TextAlign.Center,
                        letterSpacing = 3.sp
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    Text(
                        text = "Çift tıkla ve oy ver",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Medium,
                        color = Color.White.copy(alpha = 0.7f),
                        textAlign = TextAlign.Center
                    )

                    Spacer(modifier = Modifier.height(24.dp))

                    // Oyuncular listesi
                    LazyColumn(
                        modifier = Modifier.weight(1f),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        items(votablePlayers) { player ->
                            VotePlayerCard(
                                player = player,
                                onDoubleTap = {
                                    onPlayerSelect(player.name)
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun VotePlayerCard(
    player: GamePlayer,
    onDoubleTap: () -> Unit,
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .pointerInput(Unit) {
                detectTapGestures(
                    onDoubleTap = { onDoubleTap() }
                )
            },
        colors = CardDefaults.cardColors(
            containerColor = Color.Black.copy(alpha = 0.5f)
        ),
        shape = RoundedCornerShape(20.dp),
        elevation = CardDefaults.cardElevation(4.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Avatar
            Box(
                modifier = Modifier
                    .size(64.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(
                            colors = listOf(
                                player.color.copy(alpha = 0.8f),
                                player.color.copy(alpha = 0.6f)
                            )
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (player.selectedCharacter != null) {
                    Image(
                        painter = painterResource(id = player.selectedCharacter.drawableRes),
                        contentDescription = null,
                        modifier = Modifier.size(56.dp)
                    )
                } else {
                    Text(
                        text = player.name.first().uppercase(),
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Black,
                        color = Color.White
                    )
                }
            }

            Spacer(modifier = Modifier.width(16.dp))

            // İsim ve durum
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = player.name.uppercase(),
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    letterSpacing = 1.sp
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "Çift tıkla",
                    fontSize = 12.sp,
                    color = Color.White.copy(alpha = 0.6f),
                    fontWeight = FontWeight.Medium
                )
            }
        }
    }
}

@Composable
fun VotingResultsScreen(
    impostor: GamePlayer?,
    mostVotedPlayer: GamePlayer?,
    votes: Map<String, Int>,
    gamePlayers: List<GamePlayer>,
    onPlayAgain: () -> Unit,
    onMainMenu: () -> Unit,
) {
    val isImpostorCaught = mostVotedPlayer?.role == "SPY"

    val backgroundColor = if (isImpostorCaught) Color(0xFF0D1B2A) else Color(0xFF1A0A0A)
    val titleColor = if (isImpostorCaught) Color(0xFF4ECDC4) else Color(0xFFFF3939)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(backgroundColor)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {

            Spacer(modifier = Modifier.height(20.dp))
            // Ana başlık
            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "OYUN BITTI",
                    fontSize = 52.sp,
                    fontWeight = FontWeight.Black,
                    color = titleColor,
                    textAlign = TextAlign.Center,
                    letterSpacing = 5.sp,
                    lineHeight = 50.sp,
                )

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = if (isImpostorCaught)
                        "Oyuncular Kazandı"
                    else
                        "Spy Kazandı",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White.copy(alpha = 0.9f),
                    textAlign = TextAlign.Center
                )
            }

            // Ortadaki karakter gösterimi
            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                if (mostVotedPlayer != null) {
                    Box(
                        modifier = Modifier
                            .size(140.dp)
                            .clip(CircleShape)
                            .background(
                                if (isImpostorCaught)
                                    mostVotedPlayer.color
                                else
                                    impostor?.color ?: Color.Gray
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        val displayPlayer = if (isImpostorCaught) mostVotedPlayer else impostor

                        if (displayPlayer?.selectedCharacter != null) {
                            Image(
                                painter = painterResource(id = displayPlayer.selectedCharacter.drawableRes),
                                contentDescription = null,
                                modifier = Modifier.size(120.dp)
                            )
                        } else {
                            Text(
                                text = (displayPlayer?.name?.first()?.uppercase() ?: "?"),
                                fontSize = 64.sp,
                                fontWeight = FontWeight.Black,
                                color = Color.White
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    Text(
                        text = if (isImpostorCaught)
                            mostVotedPlayer.name.uppercase()
                        else
                            impostor?.name?.uppercase() ?: "",
                        fontSize = 32.sp,
                        fontWeight = FontWeight.Black,
                        color = Color.White,
                        textAlign = TextAlign.Center
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    Text(
                        text = "Gerçek Spy",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Medium,
                        color = titleColor,
                        textAlign = TextAlign.Center
                    )

                    if (isImpostorCaught) {
                        Spacer(modifier = Modifier.height(16.dp))

                        Box(
                            modifier = Modifier
                                .background(
                                    Color.White.copy(alpha = 0.1f),
                                    RoundedCornerShape(20.dp)
                                )
                                .padding(horizontal = 24.dp, vertical = 12.dp)
                        ) {
                            Text(
                                text = "${votes[mostVotedPlayer.name] ?: 0} oy",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color.White.copy(alpha = 0.8f)
                            )
                        }
                    }
                }
            }

            // Alt butonlar
            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Button(
                    onClick = onPlayAgain,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(64.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = titleColor
                    ),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text(
                        text = "TEKRAR OYNA",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Black,
                        letterSpacing = 2.sp
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))
            }
        }
    }
}