package com.oguz.spy.ux

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import com.oguz.spy.R
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import kotlinx.coroutines.delay
import kotlin.math.*
import androidx.compose.material3.Text
import androidx.compose.ui.platform.LocalContext
import android.content.Context
import androidx.compose.foundation.Image
import androidx.compose.ui.res.painterResource


@Composable
fun SplashScreen(navController: NavController) {

    val context = LocalContext.current
    val prefs = remember {
        context.getSharedPreferences("spy_game_prefs", Context.MODE_PRIVATE)
    }

    // ── Genel fade-out (ekrandan çıkarken) ──────────────────────────────────
    var fadeOut by remember { mutableStateOf(false) }
    val globalAlpha by animateFloatAsState(
        targetValue = if (fadeOut) 0f else 1f,
        animationSpec = tween(500),
        label = "globalFade"
    )

    // ── Logo: scale bounce + fade ────────────────────────────────────────────
    var logoVisible by remember { mutableStateOf(false) }
    val logoScale by animateFloatAsState(
        targetValue = if (logoVisible) 1f else 0f,
        animationSpec = keyframes {
            durationMillis = 900
            0.0f at 0 using LinearEasing
            1.18f at 630 using FastOutSlowInEasing
            1.0f at 900 using FastOutSlowInEasing
        },
        label = "logoScale"
    )
    val logoAlpha by animateFloatAsState(
        targetValue = if (logoVisible) 1f else 0f,
        animationSpec = tween(450),
        label = "logoAlpha"
    )

    // ── Başlık: slide + fade ─────────────────────────────────────────────────
    var titleVisible by remember { mutableStateOf(false) }
    val titleAlpha by animateFloatAsState(
        targetValue = if (titleVisible) 1f else 0f,
        animationSpec = tween(700),
        label = "titleAlpha"
    )
    val titleOffsetY by animateFloatAsState(
        targetValue = if (titleVisible) 0f else 40f,
        animationSpec = tween(700, easing = FastOutSlowInEasing),
        label = "titleSlide"
    )

    // ── Tagline + alt label ──────────────────────────────────────────────────
    var tagVisible by remember { mutableStateOf(false) }
    val tagAlpha by animateFloatAsState(
        targetValue = if (tagVisible) 1f else 0f,
        animationSpec = tween(600),
        label = "tagAlpha"
    )

    // ── Sonar (sonsuz tekrar) ────────────────────────────────────────────────
    val sonarTransition = rememberInfiniteTransition(label = "sonar")
    val sonarProgress by sonarTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(1800, easing = LinearEasing)
        ),
        label = "sonarProgress"
    )

    // ── Parçacıklar (sonsuz tekrar) ──────────────────────────────────────────
    val particleTransition = rememberInfiniteTransition(label = "particles")
    val particleProgress by particleTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(4000, easing = LinearEasing)
        ),
        label = "particleProgress"
    )

    // Parçacık listesi — sadece bir kez üret
    val particles = remember { generateParticles(22) }

    // ── Animasyon sırası + navigation ────────────────────────────────────────
    LaunchedEffect(Unit) {
        delay(200)
        logoVisible = true

        delay(600)
        titleVisible = true

        delay(400)
        tagVisible = true

        delay(2000)

        // Tutorial gösterilecek mi?
        val shouldShowTutorial = run {
            val showEvery10 = prefs.getBoolean("show_every_10", false)
            val tutorialCount = prefs.getInt("tutorial_count", 0)

            if (showEvery10) {
                val counter = prefs.getInt("tutorial_counter_for_interval", 0)
                val shouldShow = counter % 10 == 0
                prefs.edit().putInt("tutorial_counter_for_interval", counter + 1).apply()
                shouldShow
            } else {
                tutorialCount < 15
            }
        }

        fadeOut = true
        delay(500) // fade bitmesini bekle

        val destination = if (shouldShowTutorial) "tutorialScreen" else "setUpScreen"
        navController.navigate(destination) {
            popUpTo("splashScreen") { inclusive = true }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .alpha(globalAlpha)
            .background(Color.Black)
    ) {

        // Arka plan gradyanı
        Canvas(modifier = Modifier.fillMaxSize()) {
            drawRect(
                brush = Brush.radialGradient(
                    colors = listOf(
                        Color(0xFF1a0a2e),
                        Color(0xFF0d0d1a),
                        Color.Black
                    ),
                    center = Offset(size.width / 2f, size.height * 0.3f),
                    radius = size.width * 0.9f
                )
            )
        }

        // Grid çizgileri
        Canvas(modifier = Modifier.fillMaxSize()) {
            drawGrid(this)
        }

        // Yüzen parçacıklar
        Canvas(modifier = Modifier.fillMaxSize()) {
            drawParticles(this, particles, particleProgress)
        }

        // Sonar halkaları
        Canvas(modifier = Modifier.fillMaxSize()) {
            drawSonar(this, sonarProgress)
        }

        // Ana içerik
        Column(
            modifier = Modifier.align(Alignment.Center),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {

            // Logo dairesi
            Box(
                modifier = Modifier
                    .scale(logoScale)
                    .alpha(logoAlpha)
                    .size(120.dp)
                    .clip(CircleShape)
                    .background(
                        brush = SweepGradient(
                            colors = listOf(
                                Color(0xFF6C00FF),
                                Color(0xFFFF3CAC),
                                Color(0xFF784BA0),
                                Color(0xFF6C00FF)
                            )
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                // İç koyu daire
                Box(
                    modifier = Modifier
                        .size(114.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF0d0d1a)),
                    contentAlignment = Alignment.Center
                ) {
                    // Buraya Image(painterResource(R.drawable.my_imposter), ...) koy
                    // Şimdilik fallback ikon:
                    Image(
                        painter = painterResource(id = R.drawable.my_imposter),
                        contentDescription = null,
                        modifier = Modifier.size(70.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(36.dp))

            // SPY başlığı
            Column(
                modifier = Modifier
                    .alpha(titleAlpha)
                    .offset(y = titleOffsetY.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "SPY",
                    fontSize = 72.sp,
                    fontWeight = FontWeight.Black,
                    letterSpacing = 20.sp,
                    style = androidx.compose.ui.text.TextStyle(
                        brush = Brush.linearGradient(
                            colors = listOf(
                                Color(0xFFFF3CAC),
                                Color.White,
                                Color(0xFF784BA0)
                            )
                        )
                    )
                )

                Spacer(modifier = Modifier.height(4.dp))

                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .width(40.dp)
                            .height(1.5.dp)
                            .background(Color(0xFFFF3CAC).copy(alpha = 0.6f))
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(
                        text = "HAİNİ BUL",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = Color(0xFFFF3CAC),
                        letterSpacing = 6.sp
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Box(
                        modifier = Modifier
                            .width(40.dp)
                            .height(1.5.dp)
                            .background(Color(0xFFFF3CAC).copy(alpha = 0.6f))
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Tagline
            Text(
                text = "Kim güvenilir ki?",
                fontSize = 15.sp,
                fontWeight = FontWeight.Light,
                fontStyle = FontStyle.Italic,
                color = Color.White.copy(alpha = 0.45f),
                letterSpacing = 1.5.sp,
                modifier = Modifier.alpha(tagAlpha)
            )
        }

        // Alt yükleniyor göstergesi
        Column(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 48.dp)
                .alpha(tagAlpha),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                listOf(false, true, false).forEachIndexed { i, isMiddle ->
                    Box(
                        modifier = Modifier
                            .padding(horizontal = 3.dp)
                            .width(if (isMiddle) 20.dp else 6.dp)
                            .height(4.dp)
                            .background(
                                color = if (isMiddle) Color(0xFFFF3CAC) else Color.White.copy(alpha = 0.2f),
                                shape = androidx.compose.foundation.shape.RoundedCornerShape(2.dp)
                            )
                    )
                }
            }
            Spacer(modifier = Modifier.height(12.dp))
            Text(
                text = "YÜKLENIYOR",
                fontSize = 10.sp,
                letterSpacing = 4.sp,
                color = Color.White.copy(alpha = 0.25f),
                fontWeight = FontWeight.Medium
            )
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// CANVAS HELPERS
// ─────────────────────────────────────────────────────────────────────────────

private fun drawGrid(scope: DrawScope) {
    val paint = androidx.compose.ui.graphics.Paint().apply {
        color = Color.White.copy(alpha = 0.03f)
        strokeWidth = 0.5.dp.value
    }
    val step = 40.dp.value
    var x = 0f
    while (x < scope.size.width) {
        scope.drawLine(
            color = Color.White.copy(alpha = 0.03f),
            start = Offset(x, 0f),
            end = Offset(x, scope.size.height),
            strokeWidth = 0.5f
        )
        x += step
    }
    var y = 0f
    while (y < scope.size.height) {
        scope.drawLine(
            color = Color.White.copy(alpha = 0.03f),
            start = Offset(0f, y),
            end = Offset(scope.size.width, y),
            strokeWidth = 0.5f
        )
        y += step
    }
}

private fun drawSonar(scope: DrawScope, progress: Float) {
    val center = Offset(scope.size.width / 2f, scope.size.height / 2f)
    val maxRadius = scope.size.width * 0.45f

    for (i in 0..2) {
        val phase = (progress - i * 0.25f).coerceIn(0f, 1f)
        if (phase <= 0f) continue

        scope.drawCircle(
            color = Color(0xFF6C00FF).copy(alpha = (1f - phase) * (1f - i * 0.3f) * 0.6f),
            radius = maxRadius * phase,
            center = center,
            style = Stroke(width = 1.5f)
        )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTICLE SYSTEM
// ─────────────────────────────────────────────────────────────────────────────

private data class Particle(
    val x: Float,
    val y: Float,
    val size: Float,
    val speed: Float,
    val phase: Float,
)

private fun generateParticles(count: Int): List<Particle> {
    val rng = java.util.Random()
    return List(count) {
        Particle(
            x = rng.nextFloat(),
            y = rng.nextFloat(),
            size = rng.nextFloat() * 3f + 1f,
            speed = rng.nextFloat() * 0.3f + 0.1f,
            phase = rng.nextFloat()
        )
    }
}

private fun drawParticles(scope: DrawScope, particles: List<Particle>, progress: Float) {
    for (p in particles) {
        val t = ((progress * p.speed + p.phase) % 1.0f)
        val y = ((p.y - t * 0.4f) % 1.0f + 1.0f) % 1.0f
        val opacity = (sin(t * Math.PI).toFloat() * 0.5f).coerceIn(0f, 1f)

        scope.drawCircle(
            color = Color(0xFFFF3CAC).copy(alpha = opacity * 0.4f),
            radius = p.size,
            center = Offset(p.x * scope.size.width, y * scope.size.height)
        )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// SWEEP GRADIENT HELPER (Canvas için değil Modifier için)
// ─────────────────────────────────────────────────────────────────────────────

private fun SweepGradient(colors: List<Color>): Brush {
    return Brush.sweepGradient(colors)
}