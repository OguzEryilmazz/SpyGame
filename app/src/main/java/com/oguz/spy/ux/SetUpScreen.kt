package com.oguz.spy.ux

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.filled.AccessTime
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController
import com.oguz.spy.datamanagment.CategoryDataManager
import com.oguz.spy.ux.components.CounterRow
import com.oguz.spy.ux.components.SettingItem

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

    // ── Kupon kodu (gizli, başlığa uzun basınca açılır) ─────────────────────
    val context = LocalContext.current
    val categoryDataManager = remember { CategoryDataManager(context) }
    var showCouponDialog by remember { mutableStateOf(false) }

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
                color = Color.White,
                modifier = Modifier.pointerInput(Unit) {
                    detectTapGestures(onLongPress = { showCouponDialog = true })
                }
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
                                if (playerCount < 9) playerCount++
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

                    // İpucu Ayarı
                    SettingItem(
                        icon = if (showHints) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                        title = "Imposter İpucu",
                        subtitle = "Imposter'a ipucu gösterilsin mi?",
                        iconColor = if(showHints) Color(0xFF4CAF50) else Color(0xFFF44336), // Green/Red
                        onIconClick = { showHints = !showHints }
                    ){}

                    // İpucu Açıklama Notu

                    Spacer(modifier = Modifier.height(12.dp))

                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(12.dp),
                        colors = CardDefaults.cardColors(
                            containerColor = Color(0xFF4CAF50).copy(alpha = 0.15f)
                        )
                    ) {
                        Row(
                            modifier = Modifier.padding(12.dp),
                            verticalAlignment = Alignment.Top
                        ) {
                            Icon(
                                imageVector = Icons.Default.Info,
                                contentDescription = null,
                                tint = Color(0xFF4CAF50),
                                modifier = Modifier.size(20.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "İpuçlarını açtığınız takdirde Imposter'a kategori hakkında ipucu verilecektir.",
                                fontSize = 14.sp,
                                color = Color.White.copy(alpha = 0.9f),
                                lineHeight = 18.sp,
                            )
                        }
                    }
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

        if (showCouponDialog) {
            CouponDialog(
                onDismiss = { showCouponDialog = false },
                onSubmit = { code ->
                    val success = categoryDataManager.redeemCoupon(code)
                    showCouponDialog = false
                    Toast.makeText(
                        context,
                        if (success) "Tüm kategoriler açıldı! 🎉" else "Geçersiz kod, bize mail atın",
                        Toast.LENGTH_LONG
                    ).show()
                }
            )
        }
    }
}

// ── Kupon kodu dialogu ──────────────────────────────────────────────────────
//
// Görünürde hiçbir buton/ikon yok — "Spy - Haini Bul" başlığına uzun basınca
// açılır. Geçerli kod tüm kategori/alt kategorileri kalıcı olarak açar
// (bkz. CategoryDataManager.redeemCoupon). Spy_IOS branch'indeki setup_screen.dart
// ile aynı UX.
@Composable
private fun CouponDialog(
    onDismiss: () -> Unit,
    onSubmit: (String) -> Unit
) {
    var code by remember { mutableStateOf(TextFieldValue("")) }

    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = Color(0xFF1A0A2E),
        title = {
            Text("Kupon Kodu", color = Color.White, fontWeight = FontWeight.Bold)
        },
        text = {
            OutlinedTextField(
                value = code,
                onValueChange = { code = it },
                singleLine = true,
                placeholder = { Text("Kodu buraya gir", color = Color.White.copy(alpha = 0.4f)) },
                keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Characters),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White,
                    focusedBorderColor = Color(0xFFE91E63),
                    unfocusedBorderColor = Color.White.copy(alpha = 0.3f),
                    cursorColor = Color.White
                )
            )
        },
        confirmButton = {
            TextButton(onClick = { onSubmit(code.text) }) {
                Text("Onayla", color = Color(0xFFE91E63), fontWeight = FontWeight.Bold)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("İptal", color = Color.White.copy(alpha = 0.7f))
            }
        }
    )
}

@Composable
@Preview(showBackground = true)
fun Pre() {
    SetupScreen(navController = rememberNavController())
}