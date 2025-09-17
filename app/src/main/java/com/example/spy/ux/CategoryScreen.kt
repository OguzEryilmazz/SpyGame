package com.example.spy.ux

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController
import com.example.spy.datamanagment.CategoryDataManager
import com.example.spy.models.CharacterAvatar
import com.example.spy.ux.components.CategoryCard
import com.example.spy.ux.components.assignRoles
import kotlinx.coroutines.launch

// Kategori data class'ı
data class Category(
    val id: String,
    val name: String,
    val icon: ImageVector,
    val color: Color,
    val items: List<String>,
    val hints: List<String>,
    val isLocked: Boolean,
    val price : Int =0
)

// Oyuncu ve rol data class'ları
data class GamePlayer(
    val id: Int,
    val name: String,
    val color: Color,
    val selectedCharacter: CharacterAvatar? = null,
    val role: String,
    val hint: String? = null // sadece spy için
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CategoryScreen(
    navController: NavController,
    players: List<Player> = emptyList(),
    onCategorySelected: (Category, List<GamePlayer>) -> Unit = { _, _ -> }
) {
    val context = LocalContext.current
    val categoryManager = remember { CategoryDataManager(context) }
    val coroutineScope = rememberCoroutineScope()

    var categories by remember { mutableStateOf<List<Category>>(emptyList()) }
    var isLoading by remember { mutableStateOf(true) }
    var isRefreshing by remember { mutableStateOf(false) }
    var selectedCategory by remember { mutableStateOf<Category?>(null) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    // Kategorileri yükle
    fun loadCategories() {
        coroutineScope.launch {
            try {
                isRefreshing = true
                categories = categoryManager.getCategories()
                errorMessage = null
            } catch (e: Exception) {
                errorMessage = "Kategoriler yüklenirken hata oluştu: ${e.message}"
            } finally {
                isLoading = false
                isRefreshing = false
            }
        }
    }

    // İlk yükleme
    LaunchedEffect(Unit) {
        loadCategories()
    }

    // Loading State
    if (isLoading) {
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
                ),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                CircularProgressIndicator(
                    color = Color.White,
                    modifier = Modifier.size(48.dp)
                )
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = "Kategoriler yükleniyor...",
                    color = Color.White,
                    fontSize = 16.sp
                )
            }
        }
        return
    }

    // Error State
    errorMessage?.let { error ->
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
                ),
            contentAlignment = Alignment.Center
        ) {
            Card(
                modifier = Modifier.padding(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Hata",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.Red
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = error,
                        fontSize = 14.sp,
                        color = Color.Gray
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    Button(
                        onClick = { loadCategories() },
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFFE91E63)
                        )
                    ) {
                        Text("Tekrar Dene")
                    }
                }
            }
        }
        return
    }

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
                .padding(bottom = 80.dp , top = 20.dp)
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

                Column(
                    modifier = Modifier.weight(1f)
                ) {
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

                // Refresh Button
                IconButton(
                    onClick = { loadCategories() },
                    modifier = Modifier
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.2f))
                ) {
                    if (isRefreshing) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(20.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Icon(
                            imageVector = Icons.Default.Refresh,
                            contentDescription = "Yenile",
                            tint = Color.White
                        )
                    }
                }
            }

            // Categories Grid - 2x2 Layout
            if (categories.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Henüz kategori bulunmuyor",
                        color = Color.White.copy(alpha = 0.7f),
                        fontSize = 16.sp
                    )
                }
            } else {
                LazyVerticalGrid(
                    columns = GridCells.Fixed(1), // 2 kolon - yan yana
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                    contentPadding = PaddingValues(bottom = 16.dp)
                ) {
                    items(categories) { category ->
                        CategoryCard(
                            category = category,
                            isSelected = selectedCategory?.id == category.id,
                            onClick = {
                                if (!category.isLocked) {
                                    selectedCategory = if (selectedCategory?.id == category.id) null else category
                                } else {
                                    // Kategori kilitli - ileride unlock logic'i burada olacak
                                }
                            },
                            onUnlockClick = {
                                // Unlock functionality - ileride implement edilecek
                                coroutineScope.launch {
                                    categoryManager.purchaseCategory(category.id)
                                    loadCategories() // Kategorileri yeniden yükle
                                }
                            }
                        )
                    }
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
                        // Rolleri ata ve game screen'e callback ile veri gönder
                        val gamePlayers = assignRoles(players, category)

                        // Debug için konsola yazdır
                        println("=== OYUN BAŞLIYOR ===")
                        println("Kategori: ${category.name}")
                        gamePlayers.forEach { player ->
                            println("${player.name}: ${player.role}" +
                                    if (player.hint != null) " (İpucu: ${player.hint})" else "")
                        }

                        // Callback ile veriyi üst bileşene gönder
                        onCategorySelected(category, gamePlayers)
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