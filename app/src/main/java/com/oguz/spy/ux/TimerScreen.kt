package com.oguz.spy.ux

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.WindowManager
import androidx.annotation.RequiresPermission
import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import kotlinx.coroutines.delay
import kotlin.math.cos
import kotlin.math.sin
import androidx.activity.ComponentActivity

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
    val activity = context as? ComponentActivity

    // Ekranın kapanmasını engelle
    DisposableEffect(Unit) {
        activity?.window?.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        onDispose {
            activity?.window?.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }

    LaunchedEffect(isTimerRunning, timeLeft) {
        if (isTimerRunning && timeLeft > 0) {
            delay(1000L)
            timeLeft--
        } else if (timeLeft <= 0 && !isGameFinished) {
            isTimerRunning = false
            isGameFinished = true
            vibratePhone(context)
        }
    }

    // Animasyonlar
    val infiniteTransition = rememberInfiniteTransition(label = "timer")

    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = if (timeLeft <= 10 && timeLeft > 0 && isTimerRunning) 1.08f else 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(if (timeLeft <= 10) 400 else 2000, easing = EaseInOutCubic),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse"
    )

    val rotationAngle by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(20000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotation"
    )

    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 0.6f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500, easing = EaseInOutSine),
            repeatMode = RepeatMode.Reverse
        ),
        label = "glow"
    )

    // Renk geçişleri
    val backgroundColor = when {
        isGameFinished -> Color(0xFF1a1625)
        timeLeft <= 30 -> Color(0xFF1f1416)
        else -> Color(0xFF0a0e27)
    }

    val primaryColor = when {
        isGameFinished -> Color(0xFF6B7280)
        timeLeft <= 10 -> Color(0xFFEF4444)
        timeLeft <= 30 -> Color(0xFFFBBF24)
        else -> Color(0xFF3B82F6)
    }

    val secondaryColor = when {
        isGameFinished -> Color(0xFF9CA3AF)
        timeLeft <= 10 -> Color(0xFFFCA5A5)
        timeLeft <= 30 -> Color(0xFFFDE68A)
        else -> Color(0xFF60A5FA)
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.radialGradient(
                    colors = listOf(
                        backgroundColor.copy(alpha = 0.8f),
                        backgroundColor,
                        Color.Black
                    ),
                    center = Offset(0.5f, 0.3f)
                )
            )
    ) {
        // Arka plan animasyonlu halkalar
        Canvas(
            modifier = Modifier
                .fillMaxSize()
                .blur(50.dp)
        ) {
            val centerX = size.width / 2
            val centerY = size.height / 3

            // Dış halka
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        primaryColor.copy(alpha = glowAlpha * 0.3f),
                        Color.Transparent
                    )
                ),
                radius = 400f,
                center = Offset(centerX, centerY)
            )

            // İç halka
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        secondaryColor.copy(alpha = glowAlpha * 0.2f),
                        Color.Transparent
                    )
                ),
                radius = 250f,
                center = Offset(centerX, centerY)
            )
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(60.dp))

            // Üst başlık
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(
                    containerColor = Color.Black.copy(alpha = 0.4f)
                )
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = if (isGameFinished) "SÜRE BİTTİ!"
                        else if (!isTimerRunning) "DURAKLATILDI"
                        else "OYUN DEVAM EDİYOR",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = when {
                            isGameFinished -> Color(0xFFEF4444)
                            !isTimerRunning -> Color(0xFFFBBF24)
                            else -> Color(0xFF10B981)
                        },
                        letterSpacing = 2.sp
                    )

                    if (!isGameFinished) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "SPY'I YAKALAYABILECEK MİSİN?",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Black,
                            color = Color.White,
                            textAlign = TextAlign.Center,
                            letterSpacing = 1.sp
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.weight(0.3f))

            // Ana zamanlayıcı
            Box(
                contentAlignment = Alignment.Center
            ) {
                // Arka plan halka - progress indicator
                CircularProgressIndicator(
                    progress = { (timeLeft.toFloat() / (gameDuration * 60)) },
                    modifier = Modifier
                        .size(320.dp)
                        .scale(pulseScale),
                    color = primaryColor.copy(alpha = 0.3f),
                    strokeWidth = 12.dp,
                    trackColor = Color.White.copy(alpha = 0.05f),
                    strokeCap = StrokeCap.Round
                )

                // Ana zaman kartı
                Card(
                    modifier = Modifier
                        .size(280.dp)
                        .scale(pulseScale),
                    shape = CircleShape,
                    colors = CardDefaults.cardColors(
                        containerColor = Color.Black.copy(alpha = 0.5f)
                    ),
                    elevation = CardDefaults.cardElevation(
                        defaultElevation = 20.dp
                    )
                ) {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            // Ana zaman
                            Text(
                                text = String.format("%02d:%02d", timeLeft / 60, timeLeft % 60),
                                fontSize = 72.sp,
                                fontWeight = FontWeight.Black,
                                color = primaryColor,
                                textAlign = TextAlign.Center,
                                letterSpacing = 4.sp
                            )

                            // Alt etiket
                            Text(
                                text = if (isGameFinished) "BİTTİ"
                                else if (timeLeft <= 10) "ACELE ET!"
                                else "KALAN SÜRE",
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Bold,
                                color = secondaryColor.copy(alpha = 0.8f),
                                letterSpacing = 2.sp
                            )
                        }
                    }
                }

                // Parlama efekti
                if (timeLeft <= 10 && !isGameFinished && isTimerRunning) {
                    Canvas(
                        modifier = Modifier
                            .size(320.dp)
                            .scale(pulseScale)
                    ) {
                        val radius = size.minDimension / 2
                        drawCircle(
                            brush = Brush.radialGradient(
                                colors = listOf(
                                    Color.Transparent,
                                    primaryColor.copy(alpha = 0.2f),
                                    Color.Transparent
                                )
                            ),
                            radius = radius
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.weight(0.5f))

            // Alt kontroller
            if (isGameFinished) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.padding(bottom = 32.dp)
                ) {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp),
                        shape = RoundedCornerShape(20.dp),
                        colors = CardDefaults.cardColors(
                            containerColor = Color.Black.copy(alpha = 0.4f)
                        )
                    ) {
                        Text(
                            text = "Oyun bitti! Şimdi SPY'ı bulma zamanı!",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Medium,
                            color = Color.White.copy(alpha = 0.9f),
                            textAlign = TextAlign.Center,
                            modifier = Modifier.padding(20.dp)
                        )
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    // Oylama butonu
                    Button(
                        onClick = { navController.navigate("votingScreen") },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(64.dp)
                            .padding(horizontal = 16.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFF3B82F6)
                        ),
                        shape = RoundedCornerShape(16.dp),
                        elevation = ButtonDefaults.buttonElevation(
                            defaultElevation = 8.dp
                        )
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.HowToVote,
                                contentDescription = null,
                                modifier = Modifier.size(28.dp)
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            Text(
                                text = "OYLAMA BAŞLAT",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Black,
                                letterSpacing = 1.sp
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Ana menü butonu
                    OutlinedButton(
                        onClick = {
                            navController.navigate("categoryScreen") {
                                popUpTo("categoryScreen") { inclusive = true }
                            }
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(56.dp)
                            .padding(horizontal = 16.dp),
                        shape = RoundedCornerShape(16.dp),
                        colors = ButtonDefaults.outlinedButtonColors(
                            contentColor = Color.White
                        ),
                        border = ButtonDefaults.outlinedButtonBorder.copy(
                            width = 2.dp,
                            brush = Brush.linearGradient(
                                colors = listOf(Color(0xFF10B981), Color(0xFF3B82F6))
                            )
                        )
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.Home,
                                contentDescription = null,
                                modifier = Modifier.size(24.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "Ana Menü",
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            } else {
                // Oyun devam ederken kontroller
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 32.dp),
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = Color.Black.copy(alpha = 0.5f)
                    )
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(24.dp),
                        horizontalArrangement = Arrangement.SpaceEvenly,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // Duraklat/Başlat
                        FloatingActionButton(
                            onClick = { isTimerRunning = !isTimerRunning },
                            containerColor = if (isTimerRunning)
                                Color(0xFFFBBF24) else Color(0xFF10B981),
                            contentColor = Color.Black,
                            modifier = Modifier.size(72.dp)
                        ) {
                            Icon(
                                imageVector = if (isTimerRunning)
                                    Icons.Default.Pause else Icons.Default.PlayArrow,
                                contentDescription = null,
                                modifier = Modifier.size(36.dp)
                            )
                        }

                        // Yeniden başlat
                        FloatingActionButton(
                            onClick = {
                                timeLeft = gameDuration * 60
                                isTimerRunning = true
                                isGameFinished = false
                            },
                            containerColor = Color(0xFF3B82F6),
                            contentColor = Color.White,
                            modifier = Modifier.size(72.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Refresh,
                                contentDescription = "Yeniden Başlat",
                                modifier = Modifier.size(36.dp)
                            )
                        }

                        // Bitir
                        FloatingActionButton(
                            onClick = {
                                isTimerRunning = false
                                isGameFinished = true
                                timeLeft = 0
                                vibratePhone(context)
                            },
                            containerColor = Color(0xFFEF4444),
                            contentColor = Color.White,
                            modifier = Modifier.size(72.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Stop,
                                contentDescription = "Bitir",
                                modifier = Modifier.size(36.dp)
                            )
                        }
                    }
                }
            }
        }

        // Oyuncu sayısı göstergesi (üst sağ)
        if (!isGameFinished) {
            Card(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(16.dp),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(
                    containerColor = Color.Black.copy(alpha = 0.6f)
                )
            ) {
                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.People,
                        contentDescription = null,
                        tint = primaryColor,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "${gamePlayers.size}",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
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