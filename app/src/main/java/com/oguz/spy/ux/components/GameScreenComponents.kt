package com.oguz.spy.ux.components

import androidx.compose.animation.core.EaseInOutSine
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.oguz.spy.R
import com.oguz.spy.ux.Category
import com.oguz.spy.ux.GamePlayer

@Composable
fun PlayerGameScreen(
    player: GamePlayer,
    playerIndex: Int,
    totalPlayers: Int,
    category: Category,
    timeString: String,
    showHints: Boolean,
    isLastPlayer: Boolean,
    onBack: () -> Unit,
    onNext: () -> Unit,
    onPrevious: () -> Unit,
    onStartTimer: () -> Unit,
) {
    var cardOffset by remember { mutableStateOf(0f) }
    var isDragging by remember { mutableStateOf(false) }

    val density = LocalDensity.current
    val screenHeight = with(density) { 800.dp.toPx() }
    val maxPullUp = screenHeight * 0.33f // Ekranın 3'te 1'i

    // Reset when player changes
    LaunchedEffect(playerIndex) {
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

    Box(modifier = Modifier.fillMaxSize()) {
        // Ana oyuncu ekranı
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(player.color)
                .padding(top = 20.dp)
                .pointerInput(Unit) {
                    detectTapGestures(
                        onLongPress = {
                            // Basılı tutma ile önceki oyuncuya dön
                            onPrevious()
                        },
                        onDoubleTap = {
                            println("DEBUG: Çift tıklama algılandı - isLastPlayer: $isLastPlayer, playerIndex: $playerIndex, totalPlayers: $totalPlayers")
                            if (!isLastPlayer) {
                                // Diğer oyuncularda çift tıklama ile sonraki oyuncuya geç
                                println("DEBUG: Normal oyuncu çift tıkladı - sonraki oyuncuya geçiliyor")
                                onNext()
                            }
                            // Son oyuncuda çift tıklama artık çalışmaz, sadece buton ile başlatılır
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
                if (player.selectedCharacter != null) {
                    Image(
                        painter = painterResource(id = player.selectedCharacter.drawableRes),
                        contentDescription = "${player.name} avatar",
                        modifier = Modifier
                            .size(200.dp)  ,
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
                            text = player.name.first().toString().uppercase(),
                            fontSize = 64.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = Color.White
                        )
                    }
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

                // Alt bilgi metni - son oyuncu için farklı
                Text(
                    text = if (isLastPlayer) {
                        "Basılı tut ve geri dön"
                    } else {
                        "Çift tıkla ve ileri geç • Basılı tut ve geri dön"
                    },
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.White.copy(alpha = 0.7f),
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
        }

        // Son oyuncu için zamanlayıcı başlat butonu
        if (isLastPlayer) {
            Button(
                onClick = onStartTimer,
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 40.dp)
                    .height(60.dp)
                    .width(200.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White,
                    contentColor = player.color
                ),
                shape = RoundedCornerShape(30.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.PlayArrow,
                        contentDescription = null,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Zamanlayıcıyı Başlat",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.fillMaxWidth(),
                        textAlign = TextAlign.Center
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

                        Image(
                            painter = painterResource(id = R.drawable.my_imposter), // kendi görselin ismini yaz
                            contentDescription = null,
                            modifier = Modifier
                                .size(100.dp) // boyutu unplayabilityg
                        )


                        Spacer(modifier = Modifier.height(20.dp))

                        // İMPOSTOR yazısı
                        Text(
                            text = "IMPOSTER",
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
                            letterSpacing = 2.sp,
                            lineHeight = 40.sp,
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
