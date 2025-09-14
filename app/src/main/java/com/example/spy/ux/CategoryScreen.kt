package com.example.spy.ux

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Work
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material.icons.filled.Sports
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController

// Kategori data class'ı
data class Category(
    val id: String,
    val name: String,
    val icon: ImageVector,
    val color: Color,
    val items: List<String>,
    val hints: List<String>,
    val isLocked : Boolean
)

// Oyuncu ve rol data class'ları
data class GamePlayer(
    val id: Int,
    val name: String,
    val color: Color,
    val role: String,
    val hint: String? = null // sadece spy için
)

@Composable
fun CategoryScreen(
    navController: NavController,
    players: List<Player> = emptyList()
) {
    // Kategoriler - Bunlar normalde local storage'dan gelecek
    val categories = remember {
        listOf(
            Category(
                id = "professions",
                name = "Meslekler",
                icon = Icons.Default.Work,
                color = Color(0xFF2196F3),
                items = listOf(
                    "Doktor", "Öğretmen", "Mühendis", "Avukat", "Hemşire",
                    "Polis", "İtfaiyeci", "Pilot", "Şoför", "Aşçı",
                    "Berber", "Terzi", "Elektrikçi", "Teknisyen", "Satış Danışmanı"
                ),
                hints = listOf(
                    "İnsanlara yardım eder", "Eğitim verir", "Teknik işler yapar",
                    "Hukuki konularda yardım eder", "Sağlık hizmeti verir"
                ),
                isLocked = false
            ),
            Category(
                id = "places",
                name = "Yerler",
                icon = Icons.Default.Home,
                color = Color(0xFF4CAF50),
                items = listOf(
                    "Hastane", "Okul", "Market", "Restoran", "Sinema",
                    "Park", "Kütüphane", "Müze", "Plaj", "Dağ",
                    "Cafe", "Spor Salonu", "Kuaför", "Otopark", "Havaalanı"
                ),
                hints = listOf(
                    "İnsanlar buraya belirli ihtiyaçları için gelir",
                    "Sosyal aktivite yapılan yer", "Hizmet verilen mekan"
                ),
                isLocked = true
            ),
            Category(
                id = "animals",
                name = "Hayvanlar",
                icon = Icons.Default.Sports,
                color = Color(0xFFFF9800),
                items = listOf(
                    "Kedi", "Köpek", "Kuş", "Balık", "At",
                    "İnek", "Koyun", "Tavuk", "Aslan", "Kaplan",
                    "Fil", "Maymun", "Ayı", "Kurt", "Tavşan"
                ),
                hints = listOf(
                    "Canlı bir varlık", "Doğada yaşar", "Hareket edebilir"
                ),
                isLocked = true
            ),
            Category(
                id = "foods",
                name = "Yiyecekler",
                icon = Icons.Default.Restaurant,
                color = Color(0xFFE91E63),
                items = listOf(
                    "Pizza", "Hamburger", "Makarna", "Pilav", "Çorba",
                    "Salata", "Kebap", "Döner", "Lahmacun", "Börek",
                    "Tost", "Sandviç", "Omlet", "Pancake", "Waffle"
                ),
                hints = listOf(
                    "Beslenme için tüketilir", "Lezzetli", "Hazırlanması gerekir"
                ),
                isLocked = false
            )
        )
    }

    var selectedCategory by remember { mutableStateOf<Category?>(null) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFFE91E63),
                        Color(0xFF9C27B0),
                        Color(0xFFF44336)
                    )
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(bottom = 80.dp)
        ) {
            // Top Bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(
                    onClick = { navController.popBackStack() },
                    modifier = Modifier
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.2f))
                ) {
                    Icon(
                        imageVector = Icons.Default.ArrowBack,
                        contentDescription = "Geri",
                        tint = Color.White
                    )
                }

                Spacer(modifier = Modifier.width(16.dp))

                Column {
                    Text(
                        text = "Kategori Seç",
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Text(
                        text = "Oyun kategorisini belirleyin",
                        fontSize = 14.sp,
                        color = Color.White.copy(alpha = 0.8f)
                    )
                }
            }

            // Categories List
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                items(categories) { category ->
                    CategoryCard(
                        category = category,
                        isSelected = selectedCategory?.id == category.id,
                        onClick = {
                            if (!category.isLocked) {
                                selectedCategory = if (selectedCategory?.id == category.id) null else category
                            }
                        }
                    )
                }

                // Extra spacing for last item
                item {
                    Spacer(modifier = Modifier.height(16.dp))
                }
            }
        }

        // Start Game Button
        selectedCategory?.let { category ->
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
                    .padding(16.dp)
            ) {
                Button(
                    onClick = {
                        // Oyun başlat - Rolleri ata
                        val gamePlayers = assignRoles(players, category)

                        // Debug için konsola yazdır
                        println("=== OYUN BAŞLIYOR ===")
                        println("Kategori: ${category.name}")
                        gamePlayers.forEach { player ->
                            println("${player.name}: ${player.role}" +
                                    if (player.hint != null) " (İpucu: ${player.hint})" else "")
                        }

                        // Game screen'e geç (henüz yok)
                        // navController.navigate("gameScreen")
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color.White
                    ),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Text(
                        text = "Oyunu Başlat - ${category.name}",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFFE91E63)
                    )
                }
            }
        }
    }
}

@Composable
fun CategoryCard(
    category: Category,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(enabled = !category.isLocked) { onClick() },
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = when {
                category.isLocked -> Color.White.copy(alpha = 0.1f)
                isSelected -> Color.White.copy(alpha = 0.3f)
                else -> Color.White.copy(alpha = 0.15f)
            }
        )
    ) {
        Box {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(20.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Icon
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(CircleShape)
                        .background(
                            if (category.isLocked)
                                Color.Gray.copy(alpha = 0.5f)
                            else
                                category.color
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = category.icon,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(28.dp)
                    )
                }

                Spacer(modifier = Modifier.width(16.dp))

                // Content
                Column(
                    modifier = Modifier.weight(1f)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = category.name,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = if (category.isLocked)
                                Color.White.copy(alpha = 0.5f)
                            else
                                Color.White
                        )

                        if (category.isLocked) {
                            Spacer(modifier = Modifier.width(8.dp))
                            Icon(
                                imageVector = Icons.Default.Lock,
                                contentDescription = "Kilitli",
                                tint = Color.White.copy(alpha = 0.7f),
                                modifier = Modifier.size(16.dp)
                            )
                        }
                    }

                    Text(
                        text = if (category.isLocked) "Kilitli" else "${category.items.size} öğe",
                        fontSize = 14.sp,
                        color = if (category.isLocked)
                            Color.White.copy(alpha = 0.4f)
                        else
                            Color.White.copy(alpha = 0.7f)
                    )

                    // İlk birkaç öğeyi göster (sadece kilitli değilse)
                    if (!category.isLocked) {
                        Text(
                            text = category.items.take(3).joinToString(", ") +
                                    if (category.items.size > 3) "..." else "",
                            fontSize = 12.sp,
                            color = Color.White.copy(alpha = 0.6f),
                            modifier = Modifier.padding(top = 4.dp)
                        )
                    }
                }

                // Selection indicator
                if (isSelected && !category.isLocked) {
                    Box(
                        modifier = Modifier
                            .size(24.dp)
                            .clip(CircleShape)
                            .background(Color.White),
                        contentAlignment = Alignment.Center
                    ) {
                        Box(
                            modifier = Modifier
                                .size(12.dp)
                                .clip(CircleShape)
                                .background(Color(0xFFE91E63))
                        )
                    }
                }
            }

            // Locked overlay
            if (category.isLocked) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.Black.copy(alpha = 0.2f))
                )
            }
        }
    }
}

// Rolleri ata function'ı
fun assignRoles(players: List<Player>, category: Category): List<GamePlayer> {
    val shuffledPlayers = players.shuffled()
    val spyIndex = (0 until players.size).random()
    val selectedRole = category.items.random()
    val spyHint = category.hints.random()

    return shuffledPlayers.mapIndexed { index, player ->
        if (index == spyIndex) {
            GamePlayer(
                id = player.id,
                name = player.name,
                color = player.selectedColor,
                role = "SPY",
                hint = spyHint
            )
        } else {
            GamePlayer(
                id = player.id,
                name = player.name,
                color = player.selectedColor,
                role = selectedRole
            )
        }
    }
}

@Preview
@Composable
fun CategoryScreenPreview() {
    CategoryScreen(navController = rememberNavController())
}