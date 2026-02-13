package com.oguz.spy.ux

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.core.content.edit

@Composable
fun TutorialScreen(
    navController: NavController,
) {
    val context = LocalContext.current
    val prefs = context.getSharedPreferences("spy_game_prefs", android.content.Context.MODE_PRIVATE)

    var dontShowAgain by remember { mutableStateOf(false) }

    // Tutorial gösterilme sayısını artır
    LaunchedEffect(Unit) {
        val currentCount = prefs.getInt("tutorial_count", 0)
        prefs.edit { putInt("tutorial_count", currentCount + 1) }
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
            modifier = Modifier.fillMaxSize()
        ) {
            // Header
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 40.dp, horizontal = 24.dp)
            ) {

                // Merkez - Logo ve başlık
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    androidx.compose.foundation.Image(
                        painter = androidx.compose.ui.res.painterResource(id = com.oguz.spy.R.drawable.my_imposter),
                        contentDescription = "Spy Logo",
                        modifier = Modifier.size(80.dp)
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = "SPY OYUNU",
                        fontSize = 32.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Text(
                        text = "Nasıl Oynanır?",
                        fontSize = 16.sp,
                        color = Color.White.copy(alpha = 0.8f),
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
            }

            // Content
            Column(
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 24.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // 1. Oyunun Amacı
                TutorialSection(
                    icon = Icons.Default.PlayArrow,
                    iconColor = Color(0xFFFF9800),
                    title = "Oyunun Amacı",
                    description = "Oyunculardan biri Imposter'dır! Diğer oyuncular seçilen kategoriden rastgele bir kelimeyi bilirken, Imposter bu kelimeyi bilmez. Imposter, kelimeyi tahmin etmeye çalışırken, diğer oyuncular Imposter'ı bulmaya çalışır."
                )

                // 2. Kategoriler Nasıl Çalışır?
                TutorialSection(
                    icon = Icons.Default.Category,
                    iconColor = Color(0xFF2196F3),
                    title = "Kategoriler Nasıl Çalışır?",
                    description = "Önce bir kategori seçilir (Meslekler, Yiyecekler, Sporcular vb.). Seçilen kategoriden rastgele bir kelime belirlenir. Normal oyuncular bu kelimeyi görür, Imposter göremez ancak kategoriyi bilir (İpucu açıksa)."
                )

                // 3. Oyuncu Rolleri
                TutorialSection(
                    icon = Icons.Default.Groups,
                    iconColor = Color(0xFF4CAF50),
                    title = "Oyuncu Rolleri",
                    description = "• Normal Oyuncular: Kelimeyi görebilir ve Imposter'ı bulmaya çalışır.\n• Imposter: Kelimeyi göremez, kategori ipucuyla ve diğer oyuncuları gözlemleyerek kelimeyi tahmin etmeye çalışır."
                )

                // 4. YENİ - Kart Gösterme
                TutorialSection(
                    icon = Icons.Default.Smartphone,
                    iconColor = Color(0xFF9C27B0),
                    title = "Kartlar Nasıl Gösterilir?",
                    description = "Oyun başladığında her oyuncu sırayla kartını görür. Kartınızı gördükten sonra 'Sonraki Oyuncu' butonuna basarak telefonu bir sonrakine verin. Kartınızı kimseye göstermeyin!"
                )

                // 5. İpucu Ayarı Açıklaması
                TutorialSection(
                    icon = Icons.Default.Lightbulb,
                    iconColor = Color(0xFFFFEB3B),
                    title = "İpucu Ayarı",
                    description = "İpucu AÇIK: Imposter kategoriye ait ipucu görür (örn: 'Meslekler')\n\nİpucu KAPALI: Imposter hiçbir ipucu görmez, sadece 'SPY' yazısını görür - daha zor mod!"
                )

                // 6. Oyun Süreci (Güncellenmiş)
                TutorialSection(
                    icon = Icons.Default.Chat,
                    iconColor = Color(0xFF00BCD4),
                    title = "Oyun Süreci",
                    description = "1. Herkes kartını kontrol eder\n2. Oyuncular birbirine kelimeyle ilgili sorular sorar\n3. Cevaplar vererek birbirinizi test edin\n4. Süre bitince oylama başlar"
                )

                // 7. YENİ - Zamanlayıcı
                TutorialSection(
                    icon = Icons.Default.Timer,
                    iconColor = Color(0xFFE91E63),
                    title = "Zamanlayıcı",
                    description = "Oyun başladığında süre akmaya başlar. Duraklatma, yeniden başlatma ve erken bitirme seçenekleri vardır. Süre bitince otomatik olarak oylama ekranına geçilir!"
                )

                // 8. YENİ - Oylama Sistemi (Detaylı)
                TutorialSection(
                    icon = Icons.Default.HowToVote,
                    iconColor = Color(0xFF673AB7),
                    title = "Oylama Sistemi",
                    description = "Süre bitince her oyuncu sırayla şüphelendiği kişiye oy verir. Oylar gizlidir. En çok oy alan kişi açıklanır ve Imposter ise Normal Oyuncular kazanır!"
                )

                // 9. Kazanma Koşulları (Sadeleştirilmiş)
                TutorialSection(
                    icon = Icons.Default.EmojiEvents,
                    iconColor = Color(0xFFFF5722),
                    title = "Kazanma Koşulları",
                    description = "• Normal Oyuncular: Imposter'ı doğru tahmin ederse kazanır\n\n• Imposter: Yakalanmadan kalır ve kelimeyi tahmin ederse kazanır"
                )

                // 10. Örnek
                TutorialSection(
                    icon = Icons.Default.Description,
                    iconColor = Color(0xFF795548),
                    title = "Örnek: Meslekler Kategorisi",
                    description = "Kategori: Meslekler → Rastgele kelime: 'Doktor' seçilir\n\n• Normal oyuncular 'Doktor' kelimesini görür\n• Imposter sadece 'Meslekler' kategorisini bilir (ipucu açıksa)\n• Oyuncular sorular sorarak Imposter'ı bulmaya çalışır"
                )

                Spacer(modifier = Modifier.height(8.dp))
            }

            // Footer
            Box(
                modifier = Modifier
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
                Column(
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.Start,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Checkbox(
                            checked = dontShowAgain,
                            onCheckedChange = { dontShowAgain = it },
                            colors = CheckboxDefaults.colors(
                                checkedColor = Color.White,
                                uncheckedColor = Color.White.copy(alpha = 0.6f),
                                checkmarkColor = Color(0xFFE91E63)
                            )
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Bir daha gösterme",
                            fontSize = 14.sp,
                            color = Color.White,
                            fontWeight = FontWeight.Medium
                        )
                    }

                    Button(
                        onClick = {
                            if (dontShowAgain) {
                                // 10 seferde bir göster - counter'ı sıfırla
                                prefs.edit()
                                    .putBoolean("show_every_10", true)
                                    .putInt("tutorial_counter_for_interval", 0)
                                    .apply()
                            } else {
                                // Normal mod - her seferinde göster
                                prefs.edit()
                                    .putBoolean("show_every_10", false)
                                    .apply()
                            }
                            navController.navigate("setUpScreen") {
                                popUpTo("tutorialScreen") { inclusive = true }
                            }
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
                            text = "OYUNA BAŞLA",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFFE91E63)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun TutorialSection(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    iconColor: Color,
    title: String,
    description: String,
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = Color.White.copy(alpha = 0.1f)
        ),
        shape = RoundedCornerShape(16.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = iconColor,
                modifier = Modifier.size(28.dp)
            )
            Column(
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Text(
                    text = title,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Text(
                    text = description,
                    fontSize = 14.sp,
                    color = Color.White.copy(alpha = 0.85f),
                    lineHeight = 20.sp
                )
            }
        }
    }
}