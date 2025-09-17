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
    import androidx.compose.material.icons.filled.KeyboardArrowUp
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
    import androidx.compose.ui.unit.dp
    import androidx.compose.ui.unit.sp
    import androidx.compose.ui.tooling.preview.Preview
    import androidx.navigation.NavController
    import androidx.navigation.compose.rememberNavController
    import kotlinx.coroutines.delay

    @Composable
    fun GameScreen(
        navController: NavController,
        gamePlayers: List<GamePlayer>,
        category: Category,
        gameDurationMinutes: Int,
        showHints: Boolean,
    ) {
        var currentPlayerIndex by remember { mutableStateOf(0) }
        var timeLeft by remember { mutableStateOf(gameDurationMinutes * 60) }

        LaunchedEffect(timeLeft) {
            if (timeLeft > 0) {
                delay(1000L)
                timeLeft--
            }
        }

        val timeString = String.format("%02d:%02d", timeLeft / 60, timeLeft % 60)

        PlayerGameScreen(
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
                }
            },
            onPrevious = {
                if (currentPlayerIndex > 0) {
                    currentPlayerIndex--
                }
            }
        )
    }

    @Composable
    fun PlayerGameScreen(
        player: GamePlayer,
        playerIndex: Int,
        totalPlayers: Int,
        category: Category,
        timeString: String,
        showHints: Boolean,
        onBack: () -> Unit,
        onNext: () -> Unit,
        onPrevious: () -> Unit,
    ) {
        var cardOffset by remember { mutableStateOf(0f) }
        var isDragging by remember { mutableStateOf(false) }
        var clickCount by remember { mutableStateOf(0) }

        LaunchedEffect(clickCount) {
            if (clickCount == 1) {
                delay(300) // 300ms içinde ikinci tıklama bekle
                if (clickCount == 1) {
                    clickCount = 0 // Tek tıklama ise sıfırla
                }
            }
        }

        val density = LocalDensity.current
        val screenHeight = with(density) { 800.dp.toPx() }
        val maxPullUp = screenHeight * 0.33f // Ekranın 3'te 1'i

        // Reset when player changes
        LaunchedEffect(playerIndex) {
            cardOffset = 0f
            isDragging = false
            clickCount = 0
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

        Box(modifier = Modifier.fillMaxSize()) {
            // Ana oyuncu ekranı
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .background(player.color)
                    .padding(top = 20.dp)
                    .clickable {
                        clickCount++
                        if (clickCount == 2) {
                            clickCount = 0
                            onNext()
                        }
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

                    Spacer(modifier = Modifier.height(60.dp))

                    // Yukarı kaydır talimatı
                    Text(
                        text = "Yukarı kaydır ve rolünü gör",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White.copy(alpha = 0.8f),
                        textAlign = TextAlign.Center
                    )

                    Spacer(modifier = Modifier.height(20.dp))

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

                    Icon(
                        imageVector = Icons.Default.KeyboardArrowUp,
                        contentDescription = null,
                        tint = Color.White.copy(alpha = 0.8f),
                        modifier = Modifier
                            .size(48.dp)
                            .offset(y = arrowOffset.dp)
                    )
                }

                // Alt navigasyon
                Row(
                    modifier = Modifier
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
                            text = "← Önceki",
                            color = if (playerIndex > 0) Color.White else Color.Transparent
                        )
                    }

                }
            }

            // Alt siyah ekran - Role reveal alanı
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height((animatedOffset / density.density).dp)
                    .align(Alignment.BottomCenter)
                    .background(Color.Black)
            ) {
                if (cardOffset > maxPullUp * 0.2f) { // Belirli bir mesafe kaydırıldığında göster
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(32.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        if (player.role == "SPY") {
                            // SPY için emoji
                            Text(
                                text = "🕵️",
                                fontSize = 80.sp,
                                textAlign = TextAlign.Center
                            )

                            Spacer(modifier = Modifier.height(20.dp))

                            // İMPOSTOR yazısı
                            Text(
                                text = "İMPOSTOR",
                                fontSize = 32.sp,
                                fontWeight = FontWeight.Black,
                                color = Color.Red,
                                textAlign = TextAlign.Center,
                                letterSpacing = 2.sp
                            )

                            // Hint varsa küçük harflerle
                            if (showHints && !player.hint.isNullOrEmpty()) {
                                Spacer(modifier = Modifier.height(16.dp))
                                Text(
                                    text = player.hint!!,
                                    fontSize = 16.sp,
                                    fontWeight = FontWeight.Normal,
                                    color = Color.Red.copy(alpha = 0.8f),
                                    textAlign = TextAlign.Center
                                )
                            }
                        } else {
                            // Normal oyuncular için sadece büyük beyaz yazı
                            Text(
                                text = player.role.uppercase(),
                                fontSize = 36.sp,
                                fontWeight = FontWeight.Black,
                                color = Color.White,
                                textAlign = TextAlign.Center,
                                letterSpacing = 2.sp
                            )

                            // Hint varsa kelimeyi göster
                            if (showHints && !player.hint.isNullOrEmpty()) {
                                Spacer(modifier = Modifier.height(20.dp))
                                Text(
                                    text = player.hint!!,
                                    fontSize = 24.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Color.White,
                                    textAlign = TextAlign.Center
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    @Composable
    @Preview(showBackground = true)
    fun PreGame() {
        val samplePlayers = listOf(
            GamePlayer(
                id = 1,
                name = "Ahmet",
                role = "SPY",
                hint = "Konuyu tahmin et!",
                color = Color(0xFF4CAF50) // yeşil
            ),
            GamePlayer(
                id = 2,
                name = "Zeynep",
                role = "Oyuncu",
                hint = "Doktor",
                color = Color(0xFF2196F3) // mavi
            ),
            GamePlayer(
                id = 3,
                name = "Mehmet",
                role = "Oyuncu",
                hint = "Doktor",
                color = Color(0xFFFF9800) // turuncu
            )
        )

        val sampleCategory = Category(
            id = "professions",
            name = "Meslekler",
            items = listOf(
                "Doktor",
                "Mühendis",
                "Avukat"
            ), // örnek: painterResource olabilir ama preview için null bırak
            color = Color(0xFF2196F3),// hex değerinden üretilmiş renk
            hints = listOf("Sağlıkla ilgili", "Hastanede bulunur"), // sahte ipuçları
            isLocked = false,
            price = 0,
            icon = Icons.Default.Timer
        )

        GameScreen(
            navController = rememberNavController(),
            gamePlayers = samplePlayers,
            category = sampleCategory,
            gameDurationMinutes = 5,
            showHints = true
        )
    }
