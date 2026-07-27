package com.oguz.spy.ux

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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.oguz.spy.ads.RewardedAdManager
import com.oguz.spy.billing.BillingManager
import com.oguz.spy.billing.PurchaseState
import com.oguz.spy.billing.PromoCodeManager
import com.oguz.spy.datamanagment.CategoryDataManager
import com.oguz.spy.models.CharacterAvatar
import com.oguz.spy.ux.components.CategoryCard
import com.oguz.spy.ux.components.EmptyFavoritesComponent
import com.oguz.spy.ux.components.assignRoles
import kotlinx.coroutines.launch

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

data class GamePlayer(
    val id: Int,
    val name: String,
    val color: Color,
    val selectedCharacter: CharacterAvatar? = null,
    val role: String,
    val hint: String? = null,
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
    rewardedAdManager: RewardedAdManager,
) {
    val context = LocalContext.current
    val activity = context as? Activity

    val categoryManager = remember { CategoryDataManager(context) }
    val coroutineScope = rememberCoroutineScope()

    val billingManager = remember { BillingManager(context, coroutineScope) }

    var categories by remember { mutableStateOf<List<Category>>(emptyList()) }
    var isLoading by remember { mutableStateOf(true) }
    var isRefreshing by remember { mutableStateOf(false) }

    var selectedCategories by remember { mutableStateOf<List<Pair<Category, Subcategory?>>>(emptyList()) }
    var expandedCategoryId by remember { mutableStateOf<String?>(null) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var purchasingCategoryId by remember { mutableStateOf<String?>(null) }

    var searchText by remember { mutableStateOf(TextFieldValue()) }
    var isSearchActive by remember { mutableStateOf(false) }
    var currentFilter by remember { mutableStateOf(FilterType.ALL) }
    var showSubcategoryDialog by remember { mutableStateOf(false) }
    var selectedCategoryForSubcategories by remember { mutableStateOf<Category?>(null) }

    var isWatchingAdForSubcategory by remember { mutableStateOf<String?>(null) }
    var adLoadingMessage by remember { mutableStateOf<String?>(null) }
    var showSubcategoryUnlockDialog by remember { mutableStateOf(false) }
    var subcategoryToUnlock by remember { mutableStateOf<Subcategory?>(null) }
    var isLoadingAdForUnlock by remember { mutableStateOf(false) }

    // Promo açık kategorileri — Flow olarak dinle
    val promoUnlocked by PromoCodeManager
        .getPromoUnlockedCategories(context)
        .collectAsState(initial = emptySet())

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

    fun showRewardedAdForSubcategory(activity: Activity, subcategoryId: String) {
        isWatchingAdForSubcategory = subcategoryId
        adLoadingMessage = null
        isLoadingAdForUnlock = false

        rewardedAdManager.showAd(
            activity = activity,
            onUserEarnedReward = { _, _ ->
                categoryManager.grantSingleUseAccess(subcategoryId)
                loadCategories()

                selectedCategoryForSubcategories?.let { category ->
                    coroutineScope.launch {
                        val updatedCategories = categoryManager.getCategories()
                        selectedCategoryForSubcategories =
                            updatedCategories.find { it.id == category.id }
                    }
                }

                errorMessage = "🎉 Alt kategori bir oyunluk başarıyla açıldı!"
                isWatchingAdForSubcategory = null
                showSubcategoryUnlockDialog = false
            },
            onAdDismissed = {
                isWatchingAdForSubcategory = null
                isLoadingAdForUnlock = false
                showSubcategoryUnlockDialog = false
                rewardedAdManager.loadAd()
            },
            onAdShowFailed = { error ->
                errorMessage = "Reklam gösterilemedi: $error"
                isWatchingAdForSubcategory = null
                isLoadingAdForUnlock = false
                showSubcategoryUnlockDialog = false
                rewardedAdManager.loadAd()
            }
        )
    }

    fun watchAdForSubcategory(subcategoryId: String) {
        if (activity == null) { errorMessage = "Activity bulunamadı!"; return }

        if (!rewardedAdManager.isAdReady()) {
            isLoadingAdForUnlock = true
            adLoadingMessage = "Reklam yükleniyor, lütfen bekleyin..."
            rewardedAdManager.loadAd(
                onAdLoaded = {
                    adLoadingMessage = null
                    showRewardedAdForSubcategory(activity, subcategoryId)
                },
                onAdFailedToLoad = { _ ->
                    adLoadingMessage = null
                    isLoadingAdForUnlock = false
                    errorMessage = "Reklam yüklenemedi. Lütfen internet bağlantınızı kontrol edin."
                }
            )
        } else {
            showRewardedAdForSubcategory(activity, subcategoryId)
        }
    }

    fun toggleFavorite(categoryId: String) {
        coroutineScope.launch {
            try {
                categoryManager.toggleFavorite(categoryId)
                categories = categories.map { category ->
                    if (category.id == categoryId)
                        category.copy(isFavorite = !category.isFavorite)
                    else
                        category
                }
            } catch (e: Exception) {
                errorMessage = "Favori güncelleme hatası: ${e.message}"
            }
        }
    }

    fun purchaseCategory(categoryId: String) {
        if (activity == null) { errorMessage = "Activity bulunamadı!"; return }
        purchasingCategoryId = categoryId
        billingManager.launchPurchaseFlow(activity = activity, productId = categoryId)
    }

    LaunchedEffect(Unit) {
        billingManager.purchaseState.collect { state ->
            when (state) {
                is PurchaseState.Success -> {
                    val productId = state.categoryId
                    val isSubcategory = categories.any { cat ->
                        cat.subcategories.any { it.id == productId }
                    }
                    if (isSubcategory) {
                        categoryManager.markSubcategoryAsPurchased(productId)
                        showSubcategoryUnlockDialog = false
                    } else {
                        categoryManager.markAsPurchased(productId)
                    }
                    categories = categoryManager.getCategories()
                    purchasingCategoryId = null
                    selectedCategoryForSubcategories?.let { category ->
                        coroutineScope.launch {
                            val updated = categoryManager.getCategories()
                            selectedCategoryForSubcategories = updated.find { it.id == category.id }
                        }
                    }
                }
                is PurchaseState.Error -> {
                    purchasingCategoryId = null
                    errorMessage = state.message
                    kotlinx.coroutines.delay(3000)
                    errorMessage = null
                }
                is PurchaseState.Loading -> {}
                is PurchaseState.Idle -> { purchasingCategoryId = null }
            }
        }
    }

    // ✅ DÜZELTME: promoUnlocked dependency'e eklendi, artık Flow değişince güncellenir
    val filteredCategories = remember(categories, searchText, currentFilter, promoUnlocked) {
        var filtered = categories

        // Promo ile açılan kategorilerin kilidini kaldır
        filtered = filtered.map { category ->
            if (promoUnlocked.contains(category.id) && category.isLocked) {
                category.copy(isLocked = false)
            } else {
                category
            }
        }

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

    LaunchedEffect(Unit) { loadCategories() }

    DisposableEffect(Unit) { onDispose { billingManager.destroy() } }

    errorMessage?.let { error ->
        LaunchedEffect(error) {
            kotlinx.coroutines.delay(3000)
            errorMessage = null
        }
    }

    adLoadingMessage?.let { msg ->
        LaunchedEffect(msg) {
            kotlinx.coroutines.delay(5000)
            adLoadingMessage = null
        }
    }

    if (isLoading) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFFE91E63)),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(48.dp))
                Spacer(modifier = Modifier.height(16.dp))
                Text("Kategoriler yükleniyor...", color = Color.White, fontSize = 16.sp)
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
                    Icon(Icons.Default.ArrowBack, contentDescription = "Geri", tint = Color.White)
                }

                Spacer(modifier = Modifier.width(16.dp))

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Kategori Seç",
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Text(
                        text = if (selectedCategories.isEmpty())
                            "Açık kategorilerden istediklerinizi seçin"
                        else
                            "${selectedCategories.size} kategori seçildi",
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
                    Icon(Icons.Default.Search, contentDescription = "Ara", tint = Color.White)
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
                        Icon(Icons.Default.Refresh, contentDescription = "Yenile", tint = Color.White)
                    }
                }
            }

            // Error / Success Message
            errorMessage?.let { error ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                        .padding(bottom = 8.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = if (error.contains("başarıyla") || error.contains("🎉"))
                            Color.Green.copy(alpha = 0.9f)
                        else
                            Color.Red.copy(alpha = 0.9f)
                    )
                ) {
                    Text(error, color = Color.White, modifier = Modifier.padding(12.dp), fontSize = 14.sp)
                }
            }

            // Ad Loading Message
            adLoadingMessage?.let { msg ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                        .padding(bottom = 8.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = Color(0xFF2196F3).copy(alpha = 0.9f)
                    )
                ) {
                    Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(20.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                        Spacer(modifier = Modifier.width(12.dp))
                        Text(msg, color = Color.White, fontSize = 14.sp)
                    }
                }
            }

            // Search Bar & Filters
            if (isSearchActive) {
                OutlinedTextField(
                    value = searchText,
                    onValueChange = { searchText = it },
                    placeholder = { Text("Kategori ara...", color = Color.White.copy(alpha = 0.7f)) },
                    leadingIcon = {
                        Icon(Icons.Default.Search, null, tint = Color.White.copy(alpha = 0.7f))
                    },
                    trailingIcon = {
                        if (searchText.text.isNotEmpty()) {
                            IconButton(onClick = { searchText = TextFieldValue() }) {
                                Icon(Icons.Default.Close, "Temizle", tint = Color.White.copy(alpha = 0.7f))
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
                            Icon(Icons.Default.Star, null, modifier = Modifier.size(16.dp))
                        },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = Color.White.copy(alpha = 0.3f),
                            selectedLabelColor = Color.White,
                            containerColor = Color.White.copy(alpha = 0.1f),
                            labelColor = Color.White.copy(alpha = 0.8f)
                        )
                    )

                    // ✅ DÜZELTME: Açık sayısı artık promoUnlocked'ı da hesaba katıyor
                    val unlockedCount = filteredCategories.count { !it.isLocked }
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

            // Categories
            if (filteredCategories.isEmpty() && currentFilter == FilterType.FAVORITES) {
                EmptyFavoritesComponent(
                    onAddFavoriteClick = {
                        currentFilter = FilterType.ALL
                        isSearchActive = true
                    }
                )
            } else if (filteredCategories.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
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
                        val isSelected = selectedCategories.any { it.first.id == category.id }
                        val isExpanded = expandedCategoryId == category.id

                        CategoryCard(
                            category = category,
                            isSelected = isSelected,
                            isExpanded = isExpanded,
                            onClick = {
                                if (!category.isLocked) {
                                    if (category.hasSubcategories) {
                                        selectedCategoryForSubcategories = category
                                        showSubcategoryDialog = true
                                    } else {
                                        if (isSelected) {
                                            selectedCategories = selectedCategories
                                                .filter { it.first.id != category.id }
                                        } else {
                                            selectedCategories = selectedCategories + (category to null)
                                        }
                                        expandedCategoryId =
                                            if (expandedCategoryId == category.id) null
                                            else category.id
                                    }
                                }
                            },
                            onUnlockClick = {
                                if (activity != null && category.isLocked) {
                                    purchaseCategory(category.id)
                                }
                            },
                            onFavoriteClick = {
                                if (!category.isRandomCategory) toggleFavorite(category.id)
                            },
                            productPrice = productPrice,
                            isLoading = isLoadingPurchase
                        )
                    }
                }
            }
        }

        // Subcategory Unlock Dialog
        if (showSubcategoryUnlockDialog && subcategoryToUnlock != null && selectedCategoryForSubcategories != null) {
            SubcategoryUnlockDialog(
                subcategory = subcategoryToUnlock!!,
                categoryColor = selectedCategoryForSubcategories!!.color,
                onWatchAd = { watchAdForSubcategory(subcategoryToUnlock!!.id) },
                onPurchase = { purchaseCategory(subcategoryToUnlock!!.id) },
                onDismiss = {
                    showSubcategoryUnlockDialog = false
                    subcategoryToUnlock = null
                    isLoadingAdForUnlock = false
                },
                isLoadingAd = isLoadingAdForUnlock,
                subcategoryPrice = billingManager.getSubcategoryPrice(subcategoryToUnlock!!.id)
            )
        }

        // Subcategory Dialog
        if (showSubcategoryDialog && selectedCategoryForSubcategories != null) {
            val selectedSubIds = selectedCategories
                .filter { it.first.id == selectedCategoryForSubcategories!!.id }
                .mapNotNull { it.second?.id }

            SubcategorySelectionDialog(
                category = selectedCategoryForSubcategories!!,
                selectedSubcategories = selectedSubIds,
                onSubcategorySelected = { subcategory ->
                    val existing = selectedCategories.find {
                        it.first.id == selectedCategoryForSubcategories!!.id &&
                                it.second?.id == subcategory.id
                    }
                    selectedCategories = if (existing != null) {
                        selectedCategories.filter { it != existing }
                    } else {
                        selectedCategories + (selectedCategoryForSubcategories!! to subcategory)
                    }
                },
                onSubcategoryUnlockRequest = { subcategory ->
                    subcategoryToUnlock = subcategory
                    showSubcategoryUnlockDialog = true
                },
                onDismiss = {
                    showSubcategoryDialog = false
                    selectedCategoryForSubcategories = null
                }
            )
        }

        // Start Game Button
        if (selectedCategories.isNotEmpty()) {
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth()
                    .background(Color.Black.copy(alpha = 0.3f))
                    .padding(16.dp)
            ) {
                Button(
                    onClick = {
                        val randomSelection = selectedCategories.random()
                        val (category, subcategory) = randomSelection

                        val itemsToUse = if (category.hasSubcategories && subcategory != null)
                            subcategory.items else category.items
                        val hintsToUse = if (category.hasSubcategories && subcategory != null)
                            subcategory.hints else category.hints

                        if (itemsToUse.isEmpty()) {
                            errorMessage = "Kategoride öğe bulunamadı!"
                            return@Button
                        }

                        if (category.hasSubcategories && subcategory != null) {
                            categoryManager.consumeSingleUseAccess(subcategory.id)
                        }

                        val categoryWithSelectedItems = category.copy(
                            items = itemsToUse,
                            hints = hintsToUse
                        )
                        val gamePlayers = assignRoles(players, categoryWithSelectedItems)
                        onCategorySelected(categoryWithSelectedItems, gamePlayers)
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.White),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    val totalItems = selectedCategories.sumOf { (cat, sub) ->
                        if (sub != null) sub.items.size
                        else if (cat.hasSubcategories)
                            cat.subcategories.filter { it.isUnlocked }.sumOf { it.items.size }
                        else cat.items.size
                    }
                    Text(
                        text = "Oyunu Başlat (${selectedCategories.size} kategori, $totalItems öğe)",
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
fun SubcategorySelectionDialog(
    category: Category,
    selectedSubcategories: List<String> = emptyList(),
    onSubcategorySelected: (Subcategory) -> Unit,
    onSubcategoryUnlockRequest: (Subcategory) -> Unit,
    onDismiss: () -> Unit,
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = Color.White,
        title = {
            Column(
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(category.color.copy(alpha = 0.15f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = category.icon,
                            contentDescription = null,
                            tint = category.color,
                            modifier = Modifier.size(26.dp)
                        )
                    }

                    Column {
                        Text(
                            text = category.name,
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFF212121)
                        )
                        Text(
                            text = if (selectedSubcategories.isEmpty())
                                "İstediğiniz alt kategorileri seçin"
                            else
                                "${selectedSubcategories.size} kategori seçildi",
                            fontSize = 13.sp,
                            color = if (selectedSubcategories.isEmpty())
                                Color(0xFF757575)
                            else
                                category.color,
                            fontWeight = if (selectedSubcategories.isEmpty())
                                FontWeight.Normal
                            else
                                FontWeight.Medium
                        )
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                HorizontalDivider(
                    color = Color(0xFFE0E0E0),
                    thickness = 1.dp
                )
            }
        },
        text = {
            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(10.dp),
                modifier = Modifier.padding(top = 8.dp)
            ) {
                items(category.subcategories) { subcategory ->
                    val isSelected = selectedSubcategories.contains(subcategory.id)

                    SubcategoryItem(
                        subcategory = subcategory,
                        categoryColor = category.color,
                        categoryIcon = category.icon, // 🆕 Ana kategori ikonunu geçir
                        isSelected = isSelected,
                        onClick = {
                            if (subcategory.isUnlocked) {
                                onSubcategorySelected(subcategory)
                            } else {
                                onSubcategoryUnlockRequest(subcategory)
                            }
                        }
                    )
                }
            }
        },
        confirmButton = {},
        dismissButton = {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End
            ) {
                TextButton(
                    onClick = onDismiss,
                    colors = ButtonDefaults.textButtonColors(
                        contentColor = category.color
                    )
                ) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        "Kapat",
                        fontWeight = FontWeight.Medium,
                        fontSize = 15.sp
                    )
                }
            }
        }
    )
}

@Composable
fun SubcategoryItem(
    subcategory: Subcategory,
    categoryColor: Color,
    categoryIcon: ImageVector,
    isSelected: Boolean = false,
    onClick: () -> Unit,
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(85.dp),
        onClick = onClick, // 🆕 Her zaman tıklanabilir
        colors = CardDefaults.cardColors(
            containerColor = when {
                !subcategory.isUnlocked -> Color(0xFFF5F5F5)
                isSelected -> categoryColor // 🆕 Seçilince sadece kategorinin rengi
                else -> Color.White
            }
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = if (isSelected) 4.dp else 2.dp
        ),
        shape = RoundedCornerShape(16.dp),
        border = when {
            !subcategory.isUnlocked -> BorderStroke(1.dp, Color(0xFFE0E0E0))
            isSelected -> null
            else -> BorderStroke(1.dp, Color(0xFFF0F0F0))
        }
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            contentAlignment = Alignment.Center
        ) {
            if (isSelected) {
                // 🆕 SEÇİLİ HALİ - Sadece başlık ortada
                Text(
                    text = subcategory.name,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    textAlign = TextAlign.Center
                )
            } else {
                // 🆕 SEÇİLMEMİŞ HALİ - Tam detaylı görünüm
                Row(
                    modifier = Modifier.fillMaxSize(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Sol taraf - İçerik
                    Row(
                        modifier = Modifier.weight(1f),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        // İkon - Ana kategorinin ikonu
                        Box(
                            modifier = Modifier
                                .size(50.dp)
                                .clip(RoundedCornerShape(12.dp))
                                .background(
                                    if (!subcategory.isUnlocked)
                                        Color(0xFFE0E0E0)
                                    else
                                        categoryColor.copy(alpha = 0.1f)
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = if (!subcategory.isUnlocked) Icons.Default.Lock else categoryIcon,
                                contentDescription = null,
                                tint = if (!subcategory.isUnlocked)
                                    Color(0xFF9E9E9E)
                                else
                                    categoryColor,
                                modifier = Modifier.size(24.dp)
                            )
                        }

                        // Metin bilgileri
                        Column(
                            verticalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Text(
                                text = subcategory.name,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = if (subcategory.isUnlocked)
                                    Color(0xFF212121)
                                else
                                    Color(0xFF757575)
                            )

                            Row(
                                horizontalArrangement = Arrangement.spacedBy(8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                if (subcategory.isUnlocked) {// Kelime sayısı
                                    Row(
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                                    ) {
                                        Icon(
                                            imageVector = Icons.Default.Notes,
                                            contentDescription = null,
                                            modifier = Modifier.size(14.dp),
                                            tint =
                                                Color(0xFF757575)

                                        )
                                        Text(
                                            text = "${subcategory.items.size} kelime",
                                            fontSize = 12.sp,
                                            color =
                                                Color(0xFF757575)

                                        )
                                    }
                                }

                            }
                        }
                    }

                    // Sağ taraf - Durum göstergesi (sadece kilitliyse)
                    if (!subcategory.isUnlocked) {
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(8.dp))
                                .background(categoryColor.copy(alpha = 0.15f))
                                .padding(horizontal = 12.dp, vertical = 8.dp)
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Lock,
                                    contentDescription = "Kilitli",
                                    tint = categoryColor,
                                    modifier = Modifier.size(16.dp))
                            }
                        }
                    }
                }
            }
        }
    }
}


@Composable
fun SubcategoryUnlockDialog(
    subcategory: Subcategory,
    categoryColor: Color,
    onWatchAd: () -> Unit,
    onPurchase: () -> Unit,
    onDismiss: () -> Unit,
    isLoadingAd: Boolean = false,
    subcategoryPrice: String? = null
) {
    AlertDialog(
        onDismissRequest = { if (!isLoadingAd) onDismiss() },
        containerColor = Color.White,
        title = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(max = 400.dp) // maksimum yükseklik sınırı
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Lock,
                    contentDescription = null,
                    tint = categoryColor,
                    modifier = Modifier.size(48.dp)
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = subcategory.name,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black,
                    textAlign = TextAlign.Center
                )
                Text(
                    text = "Bu alt kategori kilitli",
                    fontSize = 14.sp,
                    color = Color.Gray,
                    textAlign = TextAlign.Center
                )
            }
        },
        text = {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    StatCard(
                        icon = Icons.Default.Category,
                        value = "${subcategory.items.size}",
                        label = "Kelime",
                        color = categoryColor
                    )
                    StatCard(
                        icon = Icons.Default.Lightbulb,
                        value = "${subcategory.hints.size}",
                        label = "İpucu",
                        color = categoryColor
                    )
                }

                Divider(modifier = Modifier.padding(vertical = 8.dp))

                Text(
                    text = "Kilidi nasıl açmak istersiniz?",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = Color.Black
                )

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = Color(0xFFFFF3E0)
                    ),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = Icons.Default.PlayArrow,
                                contentDescription = null,
                                tint = Color(0xFFFF9800),
                                modifier = Modifier.size(24.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = "Reklam İzle",
                                    fontSize = 16.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Color.Black
                                )
                                Text(
                                    text = "1 oyunluk ücretsiz erişim",
                                    fontSize = 12.sp,
                                    color = Color.Gray
                                )
                            }
                            Text(
                                text = "ÜCRETSİZ",
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFFFF9800)
                            )
                        }
                    }
                }

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = categoryColor.copy(alpha = 0.1f)
                    ),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = Icons.Default.Star,
                                contentDescription = null,
                                tint = categoryColor,
                                modifier = Modifier.size(24.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = "Kalıcı Erişim",
                                    fontSize = 16.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Color.Black
                                )
                                Text(
                                    text = "Sınırsız kullanım",
                                    fontSize = 12.sp,
                                    color = Color.Gray
                                )
                            }
                            Text(
                                text = subcategoryPrice ?: "₺9,99",
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                color = categoryColor
                            )
                        }
                    }
                }
            }
        },
        confirmButton = {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Button(
                    onClick = onWatchAd,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFFFF9800)
                    ),
                    shape = RoundedCornerShape(12.dp),
                    enabled = !isLoadingAd
                ) {
                    if (isLoadingAd) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(20.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Reklam Yükleniyor...", color = Color.White)
                    } else {
                        Icon(
                            imageVector = Icons.Default.PlayArrow,
                            contentDescription = null,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Reklam İzle", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                    }
                }

                OutlinedButton(
                    onClick = onPurchase,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp),
                    colors = ButtonDefaults.outlinedButtonColors(
                        contentColor = categoryColor
                    ),
                    border = BorderStroke(2.dp, categoryColor),
                    shape = RoundedCornerShape(12.dp),
                    enabled = !isLoadingAd
                ) {
                    Icon(
                        imageVector = Icons.Default.ShoppingCart,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Satın Al", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                }

                TextButton(
                    onClick = onDismiss,
                    modifier = Modifier.fillMaxWidth(),
                    enabled = !isLoadingAd
                ) {
                    Text(
                        "İptal",
                        color = Color.Gray,
                        fontSize = 14.sp
                    )
                }
            }
        },
        dismissButton = {}
    )
}

@Composable
fun StatCard(
    icon: ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Card(
        colors = CardDefaults.cardColors(
            containerColor = color.copy(alpha = 0.1f)
        ),
        shape = RoundedCornerShape(8.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = color,
                modifier = Modifier.size(24.dp)
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = value,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = Color.Black
            )
            Text(
                text = label,
                fontSize = 12.sp,
                color = Color.Gray
            )
        }
    }
}
