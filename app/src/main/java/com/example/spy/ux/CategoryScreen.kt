package com.example.spy.ux

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Star
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
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.example.spy.datamanagment.CategoryDataManager
import com.example.spy.models.CharacterAvatar
import com.example.spy.ux.components.CategoryCard
import com.example.spy.ux.components.EmptyFavoritesComponent
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
    val price : Int = 0,
    val isFavorite: Boolean = false
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

enum class FilterType {
    ALL, FAVORITES, UNLOCKED
}

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

    // Search states
    var searchText by remember { mutableStateOf(TextFieldValue()) }
    var isSearchActive by remember { mutableStateOf(false) }
    var currentFilter by remember { mutableStateOf(FilterType.ALL) }

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

    // Favori toggle function
    fun toggleFavorite(categoryId: String) {
        coroutineScope.launch {
            try {
                categoryManager.toggleFavorite(categoryId)
                categories = categories.map { category ->
                    if (category.id == categoryId) {
                        category.copy(isFavorite = !category.isFavorite)
                    } else {
                        category
                    }
                }
            } catch (e: Exception) {
                // Handle error
            }
        }
    }

    // Filtreleme ve arama
    val filteredCategories = remember(categories, searchText, currentFilter) {
        var filtered = categories

        // Arama filtresi
        if (searchText.text.isNotBlank()) {
            filtered = filtered.filter {
                it.name.contains(searchText.text, ignoreCase = true)
            }
        }

        // Tip filtresi
        filtered = when (currentFilter) {
            FilterType.ALL -> filtered
            FilterType.FAVORITES -> filtered.filter { it.isFavorite }
            FilterType.UNLOCKED -> filtered.filter { !it.isLocked }
        }

        filtered
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
                .padding(bottom = 80.dp, top = 20.dp)
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

                // Search Button
                IconButton(
                    onClick = { isSearchActive = !isSearchActive },
                    modifier = Modifier
                        .clip(CircleShape)
                        .background(
                            if (isSearchActive) Color.White.copy(alpha = 0.3f)
                            else Color.White.copy(alpha = 0.2f)
                        )
                ) {
                    Icon(
                        imageVector = Icons.Default.Search,
                        contentDescription = "Ara",
                        tint = Color.White
                    )
                }

                Spacer(modifier = Modifier.width(8.dp))

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

            // Search Bar
            if (isSearchActive) {
                OutlinedTextField(
                    value = searchText,
                    onValueChange = { searchText = it },
                    placeholder = {
                        Text(
                            "Kategori ara...",
                            color = Color.White.copy(alpha = 0.7f)
                        )
                    },
                    leadingIcon = {
                        Icon(
                            Icons.Default.Search,
                            contentDescription = null,
                            tint = Color.White.copy(alpha = 0.7f)
                        )
                    },
                    trailingIcon = {
                        if (searchText.text.isNotEmpty()) {
                            IconButton(
                                onClick = { searchText = TextFieldValue() }
                            ) {
                                Icon(
                                    Icons.Default.Close,
                                    contentDescription = "Temizle",
                                    tint = Color.White.copy(alpha = 0.7f)
                                )
                            }
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                        .padding(bottom = 8.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedBorderColor = Color.White.copy(alpha = 0.7f),
                        unfocusedBorderColor = Color.White.copy(alpha = 0.5f),
                        cursorColor = Color.White
                    ),
                    shape = RoundedCornerShape(12.dp),
                    singleLine = true
                )

                // Filter Buttons
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                        .padding(bottom = 8.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    FilterChip(
                        selected = currentFilter == FilterType.ALL,
                        onClick = { currentFilter = FilterType.ALL },
                        label = { Text("Tümü") },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = Color.White.copy(alpha = 0.3f),
                            selectedLabelColor = Color.White,
                            containerColor = Color.White.copy(alpha = 0.1f),
                            labelColor = Color.White.copy(alpha = 0.8f)
                        )
                    )

                    val favoriteCount = categories.count { it.isFavorite }
                    FilterChip(
                        selected = currentFilter == FilterType.FAVORITES,
                        onClick = { currentFilter = FilterType.FAVORITES },
                        label = { Text("Favoriler ($favoriteCount)") },
                        leadingIcon = {
                            Icon(
                                Icons.Default.Star,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp)
                            )
                        },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = Color.White.copy(alpha = 0.3f),
                            selectedLabelColor = Color.White,
                            containerColor = Color.White.copy(alpha = 0.1f),
                            labelColor = Color.White.copy(alpha = 0.8f)
                        )
                    )

                    val unlockedCount = categories.count { !it.isLocked }
                    FilterChip(
                        selected = currentFilter == FilterType.UNLOCKED,
                        onClick = { currentFilter = FilterType.UNLOCKED },
                        label = { Text("Açık ($unlockedCount)") },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = Color.White.copy(alpha = 0.3f),
                            selectedLabelColor = Color.White,
                            containerColor = Color.White.copy(alpha = 0.1f),
                            labelColor = Color.White.copy(alpha = 0.8f)
                        )
                    )
                }
            }

            // Categories Grid or Empty State
            if (filteredCategories.isEmpty() && currentFilter == FilterType.FAVORITES) {
                EmptyFavoritesComponent(
                    onAddFavoriteClick = {
                        currentFilter = FilterType.ALL
                        isSearchActive = true
                    }
                )
            } else if (filteredCategories.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = if (searchText.text.isNotBlank())
                            "Arama kriterlerinize uygun kategori bulunamadı"
                        else "Henüz kategori bulunmuyor",
                        color = Color.White.copy(alpha = 0.7f),
                        fontSize = 16.sp
                    )
                }
            } else {
                LazyVerticalGrid(
                    columns = GridCells.Fixed(1),
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                    contentPadding = PaddingValues(bottom = 16.dp)
                ) {
                    items(filteredCategories) { category ->
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
                            },
                            onFavoriteClick = {
                                toggleFavorite(category.id)
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