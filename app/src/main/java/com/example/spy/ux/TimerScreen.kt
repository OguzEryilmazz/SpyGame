package com.example.spy.ux

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.annotation.RequiresPermission
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import kotlinx.coroutines.delay

@SuppressLint("MissingPermission")
@Composable
fun TimerScreen(
    navController: NavController,
    gameDuration: Int,
    gamePlayers: List<GamePlayer>
) {
    var timeLeft by remember { mutableStateOf(gameDuration * 60) }
    var isTimerRunning by remember { mutableStateOf(true) }
    var isGameFinished by remember { mutableStateOf(false) }
    val context = LocalContext.current

    LaunchedEffect(isTimerRunning, timeLeft) {
        if (isTimerRunning && timeLeft > 0) {
            delay(1000L)
            timeLeft--
        } else if (timeLeft <= 0 && !isGameFinished) {
            isTimerRunning = false
            isGameFinished = true
            // Zaman bittiğinde titreşim
            vibratePhone(context)
        }
    }

    val infiniteTransition = rememberInfiniteTransition(label = "timer")
    val scale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = if (timeLeft <= 10 && timeLeft > 0 && isTimerRunning) 1.1f else 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(500, easing = EaseInOutSine),
            repeatMode = RepeatMode.Reverse
        ),
        label = "scale"
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                if (isGameFinished) Color(0xFF1A1A1A)
                else if (timeLeft <= 30) Color(0xFF2D1B1B)
                else Color.Black
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Üst kısım - Durum mesajı
            if (isGameFinished) {
                Text(
                    text = "SÜRE BİTTİ!",
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.Red,
                    textAlign = TextAlign.Center,
                    letterSpacing = 4.sp
                )
            } else {
                Text(
                    text = "İMPOSTOR'U BUL!",
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.Red,
                    textAlign = TextAlign.Center,
                    letterSpacing = 3.sp
                )
            }

            Spacer(modifier = Modifier.height(60.dp))

            // Zamanlayıcı göstergesi
            Card(
                modifier = Modifier
                    .size(280.dp)
                    .scale(scale),
                shape = CircleShape,
                colors = CardDefaults.cardColors(
                    containerColor = when {
                        isGameFinished -> Color.Gray.copy(alpha = 0.3f)
                        timeLeft <= 10 -> Color.Red.copy(alpha = 0.2f)
                        timeLeft <= 30 -> Color.Yellow.copy(alpha = 0.2f)
                        else -> Color.White.copy(alpha = 0.1f)
                    }
                ),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
            ) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = String.format("%02d:%02d", timeLeft / 60, timeLeft % 60),
                        fontSize = 64.sp,
                        fontWeight = FontWeight.Black,
                        color = when {
                            isGameFinished -> Color.Gray
                            timeLeft <= 10 -> Color.Red
                            timeLeft <= 30 -> Color.Yellow
                            else -> Color.White
                        },
                        textAlign = TextAlign.Center
                    )
                }
            }

            Spacer(modifier = Modifier.height(80.dp))

            // Alt kısım - Kontrol butonları veya oyun sonu mesajı
            if (isGameFinished) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Oyun bitti! Şimdi oylama zamanı!",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Medium,
                        color = Color.White.copy(alpha = 0.8f),
                        textAlign = TextAlign.Center
                    )

                    Spacer(modifier = Modifier.height(40.dp))

                    // Oylama ekranına git
                    Button(
                        onClick = {
                            navController.navigate("votingScreen")
                        },
                        modifier = Modifier
                            .width(200.dp)
                            .height(60.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFF2196F3),
                            contentColor = Color.White
                        ),
                        shape = RoundedCornerShape(30.dp)
                    ) {
                        Text(
                            text = "Oylama",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Ana menüye dön
                    Button(
                        onClick = {
                            navController.navigate("categoryScreen") {
                                popUpTo("categoryScreen") { inclusive = true }
                            }
                        },
                        modifier = Modifier
                            .width(200.dp)
                            .height(60.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFF4CAF50),
                            contentColor = Color.White
                        ),
                        shape = RoundedCornerShape(30.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.Refresh,
                                contentDescription = null,
                                modifier = Modifier.size(24.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "Ana Menü",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            } else {
                // Kontrol butonları
                Row(
                    horizontalArrangement = Arrangement.spacedBy(20.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Duraklat/Başlat butonu
                    FloatingActionButton(
                        onClick = { isTimerRunning = !isTimerRunning },
                        containerColor = if (isTimerRunning) Color.Yellow else Color.Green,
                        contentColor = Color.Black,
                        modifier = Modifier.size(70.dp)
                    ) {
                        Icon(
                            imageVector = if (isTimerRunning) Icons.Default.Pause else Icons.Default.PlayArrow,
                            contentDescription = if (isTimerRunning) "Duraklat" else "Başlat",
                            modifier = Modifier.size(32.dp)
                        )
                    }

                    // Bitir butonu
                    FloatingActionButton(
                        onClick = {
                            isTimerRunning = false
                            isGameFinished = true
                            timeLeft = 0
                            vibratePhone(context)
                        },
                        containerColor = Color.Red,
                        contentColor = Color.White,
                        modifier = Modifier.size(70.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Stop,
                            contentDescription = "Bitir",
                            modifier = Modifier.size(32.dp)
                        )
                    }
                }
            }
        }

        // Durum çubuğu
        if (!isGameFinished) {
            Card(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .padding(top = 40.dp),
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(
                    containerColor = Color.Black.copy(alpha = 0.7f)
                )
            ) {
                Text(
                    text = if (isTimerRunning) "⏳ OYUN DEVAM EDİYOR" else "⏸️ OYUN DURAKLATILDI",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = if (isTimerRunning) Color.Green else Color.Yellow,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                )
            }
        }
    }
}

@RequiresPermission(Manifest.permission.VIBRATE)
private fun vibratePhone(context: Context) {
    try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            val vibrator = vibratorManager.defaultVibrator
            vibrator.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 500, 200, 500, 200, 500), -1))
        } else {
            @Suppress("DEPRECATION")
            val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 500, 200, 500, 200, 500), -1))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(longArrayOf(0, 500, 200, 500, 200, 500), -1)
            }
        }
    } catch (e: Exception) {
        e.printStackTrace()
    }
}