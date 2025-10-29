package com.oguz.spy.ux

import android.R
import android.annotation.SuppressLint
import android.app.Activity
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
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
import com.oguz.spy.billing.BillingManager
import com.oguz.spy.datamanagment.CategoryDataManager
import com.oguz.spy.models.CharacterAvatar
import com.oguz.spy.ux.components.CategoryCard
import com.oguz.spy.ux.components.EmptyFavoritesComponent
import com.oguz.spy.ux.components.assignRoles
import kotlinx.coroutines.launch

// Kategori data class'ı
data class Subcategory(
    val id: String,
    val name: String,
    val items: List<String>,
    val hints: List<String>,
    val unlockedByAd: Boolean,
    val isUnlocked: Boolean,
)

data class Category(
    val id: String,
    val name: String,
    val icon: ImageVector,
    val color: Color,
    val items: List<String>,
    val hints: List<String>,
    val isLocked: Boolean,
    val priceTL: Double,
    val isFavorite: Boolean,
    val hasSubcategories: Boolean = false,
    val subcategories: List<Subcategory> = emptyList(),
    val isRandomCategory: Boolean = false,
)

// Oyuncu ve rol data class'ları
data class GamePlayer(
    val id: Int,
    val name: String,
    val color: Color,
    val selectedCharacter: CharacterAvatar? = null,
    val role: String,
    val hint: String? = null, // sadece spy için
)

enum class FilterType {
    ALL, FAVORITES, UNLOCKED
}

@SuppressLint("ContextCastToActivity")
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CategoryScreen(
    navController: NavController,
    players: List<Player> = emptyList(),
    onCategorySelected: (Category, List<GamePlayer>) -> Unit = { _, _ -> },
) {
    val context = LocalContext.current
    val activity = context as? Activity

    val categoryManager = remember { CategoryDataManager(context) }
    val coroutineScope = rememberCoroutineScope()

    // BillingManager'ı oluştur
    val billingManager = remember {
        BillingManager(context, coroutineScope)
    }

    var categories by remember { mutableStateOf<List<Category>>(emptyList()) }
    var isLoading by remember { mutableStateOf(true) }
    var isRefreshing by remember { mutableStateOf(false) }
    var selectedCategory by remember { mutableStateOf<Category?>(null) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var purchasingCategoryId by remember { mutableStateOf<String?>(null) }

    var searchText by remember { mutableStateOf(TextFieldValue()) }
    var isSearchActive by remember { mutableStateOf(false) }
    var currentFilter by remember { mutableStateOf(FilterType.ALL) }

    // BillingManager product details'i izle
    val productDetails by billingManager.productDetails.collectAsState()

    var showSubcategoryDialog by remember { mutableStateOf(false) }
    var selectedCategoryForSubcategories by remember { mutableStateOf<Category?>(null) }
    var selectedSubcategory by remember { mutableStateOf<Subcategory?>(null) }

    // Satın alma durumunu izle
    LaunchedEffect(Unit) {
        billingManager.purchaseState.collect { state ->
            when (state) {
                is BillingManager.PurchaseState.Success -> {
                    // Satın alma başarılı
                    categoryManager.markAsPurchased(state.categoryId)
                    categories = categoryManager.getCategories()
                    purchasingCategoryId = null
                    errorMessage = "Kategori başarıyla satın alındı!"

                    // 2 saniye sonra mesajı temizle
                    kotlinx.coroutines.delay(2000)
                    errorMessage = null
                }

                is BillingManager.PurchaseState.Error -> {
                    purchasingCategoryId = null
                    errorMessage = state.message
                }

                is BillingManager.PurchaseState.Loading -> {
                    // Loading state
                }

                is BillingManager.PurchaseState.Idle -> {
                    purchasingCategoryId = null
                }
            }
        }
    }

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
                errorMessage = "Favori güncelleme hatası: ${e.message}"
            }
        }
    }

    val filteredCategories = remember(categories, searchText, currentFilter) {
        var filtered = categories

        if (searchText.text.isNotBlank()) {
            filtered = filtered.filter {
                it.name.contains(searchText.text, ignoreCase = true)
            }
        }

        filtered = when (currentFilter) {
            FilterType.ALL -> filtered
            FilterType.FAVORITES -> filtered.filter { it.isFavorite }
            FilterType.UNLOCKED -> filtered.filter { !it.isLocked }
        }

        filtered
    }

    LaunchedEffect(Unit) {
        loadCategories()
    }

    // Cleanup
    DisposableEffect(Unit) {
        onDispose {
            billingManager.destroy()
        }
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

    // Error message auto-clear
    errorMessage?.let { error ->
        LaunchedEffect(error) {
            kotlinx.coroutines.delay(3000)
            errorMessage = null
        }
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

            // Error/Success Message
            errorMessage?.let { error ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                        .padding(bottom = 8.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = if (error.contains("başarıyla"))
                            Color.Green.copy(alpha = 0.9f)
                        else
                            Color.Red.copy(alpha = 0.9f)
                    )
                ) {
                    Text(
                        text = error,
                        color = Color.White,
                        modifier = Modifier.padding(12.dp),
                        fontSize = 14.sp
                    )
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

            // Categories Grid
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
                        val productPrice = billingManager.getProductPrice(category.id)
                        val isLoadingPurchase = purchasingCategoryId == category.id

                        CategoryCard(
                            category = category,
                            isSelected = selectedCategory?.id == category.id,
                            onClick = {
                                if (!category.isLocked) {
                                    if (category.isRandomCategory) {
                                        // Rastgele kategoriyi sadece işaretle, seçim oyun başlatılınca yapılacak
                                        selectedCategory =
                                            if (selectedCategory?.id == category.id) null else category
                                        selectedSubcategory = null
                                    } else if (category.hasSubcategories) {
                                        // Normal alt kategori seçimi
                                        selectedCategoryForSubcategories = category
                                        showSubcategoryDialog = true
                                    } else {
                                        selectedCategory =
                                            if (selectedCategory?.id == category.id) null else category
                                        selectedSubcategory = null
                                    }
                                }
                            },
                            onUnlockClick = {
                                if (activity != null && category.isLocked) {
                                    purchasingCategoryId = category.id
                                    billingManager.launchPurchaseFlow(
                                        activity = activity,
                                        productId = "category_${category.id}"
                                    )
                                }
                            },
                            onFavoriteClick = {
                                if (!category.isRandomCategory) {
                                    toggleFavorite(category.id)
                                }
                            },
                            productPrice = productPrice,
                            isLoading = isLoadingPurchase
                        )
                    }
                }
            }
        }
        if (showSubcategoryDialog && selectedCategoryForSubcategories != null) {
            SubcategorySelectionDialog(
                category = selectedCategoryForSubcategories!!,
                onSubcategorySelected = { subcategory ->
                    selectedCategory = selectedCategoryForSubcategories
                    selectedSubcategory = subcategory
                    showSubcategoryDialog = false
                },
                onWatchAdForSubcategory = { subcategory ->
                    categoryManager.unlockSubcategoryWithAd(subcategory.id)
                    loadCategories()
                    showSubcategoryDialog = false
                },
                onDismiss = {
                    showSubcategoryDialog = false
                    selectedCategoryForSubcategories = null
                }
            )
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
                        if (category.isRandomCategory) {
                            // Açık kategorileri topla
                            val unlockedCategories = categories.filter {
                                !it.isLocked && !it.isRandomCategory
                            }

                            if (unlockedCategories.isEmpty()) {
                                errorMessage = "Henüz açık kategori bulunmuyor!"
                                return@Button
                            }

                            // Rastgele bir kategori seç
                            val randomCategory = unlockedCategories.random()

                            val itemsToUse: List<String>
                            val hintsToUse: List<String>

                            if (randomCategory.hasSubcategories) {
                                // Alt kategorileri olan kategoriden rastgele alt kategori seç
                                val unlockedSubs =
                                    randomCategory.subcategories.filter { it.isUnlocked }

                                if (unlockedSubs.isEmpty()) {
                                    errorMessage =
                                        "Rastgele seçilen kategoride açık alt kategori yok!"
                                    return@Button
                                }

                                val randomSub = unlockedSubs.random()
                                itemsToUse = randomSub.items
                                hintsToUse = randomSub.hints
                            } else {
                                itemsToUse = randomCategory.items
                                hintsToUse = randomCategory.hints
                            }

                            // Geçici kategori oluştur (seçilen itemlar ile)
                            val categoryWithSelectedItems = randomCategory.copy(
                                items = itemsToUse,
                                hints = hintsToUse
                            )

                            val gamePlayers = assignRoles(players, categoryWithSelectedItems)
                            onCategorySelected(categoryWithSelectedItems, gamePlayers)
                        } else {
                            // NORMAL KATEGORİLER İÇİN
                            val itemsToUse =
                                if (category.hasSubcategories && selectedSubcategory != null) {
                                    selectedSubcategory!!.items
                                } else {
                                    category.items
                                }

                            val hintsToUse =
                                if (category.hasSubcategories && selectedSubcategory != null) {
                                    selectedSubcategory!!.hints
                                } else {
                                    category.hints
                                }

                            // Geçici kategori oluştur (seçilen itemlar ile)
                            val categoryWithSelectedItems = category.copy(
                                items = itemsToUse,
                                hints = hintsToUse
                            )

                            val gamePlayers = assignRoles(players, categoryWithSelectedItems)
                            onCategorySelected(categoryWithSelectedItems, gamePlayers)
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color.White
                    ),
                    shape = RoundedCornerShape(16.dp),
                    enabled = if (category.hasSubcategories) selectedSubcategory != null else true
                ) {
                    val buttonText = if (category.isRandomCategory) {
                        val unlockedCategories = categories.filter {
                            !it.isLocked && !it.isRandomCategory
                        }
                        val totalUnlockedItems = unlockedCategories.sumOf { cat ->
                            if (cat.hasSubcategories) {
                                cat.subcategories.filter { it.isUnlocked }.sumOf { it.items.size }
                            } else {
                                cat.items.size
                            }
                        }
                        "Oyunu Başlat - Rastgele ($totalUnlockedItems öge)"
                    } else if (category.hasSubcategories && selectedSubcategory != null) {
                        "Oyunu Başlat - ${selectedSubcategory!!.name}"
                    } else if (category.hasSubcategories) {
                        "Alt Kategori Seçin"
                    } else {
                        "Oyunu Başlat - ${category.name}"
                    }

                    Text(
                        text = buttonText,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = if (category.hasSubcategories && selectedSubcategory == null) {
                            Color.Gray
                        } else {
                            Color(0xFFE91E63)
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun SubcategorySelectionDialog(
    category: Category,
    onSubcategorySelected: (Subcategory) -> Unit,
    onWatchAdForSubcategory: (Subcategory) -> Unit,
    onDismiss: () -> Unit,
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = Color.White,
        title = {
            Column {
                Text(
                    text = category.name,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = category.color
                )
                Text(
                    text = "Alt Kategori Seçin",
                    fontSize = 14.sp,
                    color = Color.Gray,
                    fontWeight = FontWeight.Normal
                )
            }
        },
        text = {
            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(category.subcategories) { subcategory ->
                    SubcategoryItem(
                        subcategory = subcategory,
                        categoryColor = category.color,
                        onClick = {
                            if (subcategory.isUnlocked) {
                                onSubcategorySelected(subcategory)
                            } else {
                                onWatchAdForSubcategory(subcategory)
                            }
                        }
                    )
                }
            }
        },
        confirmButton = {},
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Kapat", color = category.color)
            }
        }
    )
}

@Composable
fun SubcategoryItem(
    subcategory: Subcategory,
    categoryColor: Color,
    onClick: () -> Unit,
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(90.dp),
        onClick = onClick,
        colors = CardDefaults.cardColors(
            containerColor = if (subcategory.isUnlocked)
                Color.White
            else
                Color.LightGray
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        shape = RoundedCornerShape(12.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Icon
            Box(
                modifier = Modifier
                    .size(45.dp)
                    .clip(CircleShape)
                    .background(
                        if (subcategory.isUnlocked)
                            categoryColor.copy(alpha = 0.1f)
                        else
                            Color.Gray.copy(alpha = 0.2f)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = if (subcategory.isUnlocked)
                        Icons.Default.CheckCircle
                    else
                        Icons.Default.Lock,
                    contentDescription = null,
                    tint = if (subcategory.isUnlocked)
                        categoryColor
                    else
                        Color.Gray,
                    modifier = Modifier.size(24.dp)
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            // Text
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = subcategory.name,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = if (subcategory.isUnlocked)
                        Color.Black
                    else
                        Color.Gray
                )
                Text(
                    text = "${subcategory.items.size} kelime",
                    fontSize = 12.sp,
                    color = Color.Gray
                )
            }

            // Action Button
            if (!subcategory.isUnlocked && subcategory.unlockedByAd) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(color = Color.White)
                        .padding(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.PlayArrow,
                        contentDescription = "Reklam İzle",
                        tint = categoryColor,
                        modifier = Modifier.size(18.dp)
                    )
                    Text(
                        text = "İzle",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                        color = categoryColor
                    )
                }
            } else if (subcategory.isUnlocked) {
                Icon(
                    imageVector = Icons.Default.ArrowForward,
                    contentDescription = "Seç",
                    tint = categoryColor,
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}
