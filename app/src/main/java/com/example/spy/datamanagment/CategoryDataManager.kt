package com.example.spy.datamanagment

import android.content.Context
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.runtime.Stable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.example.spy.ux.Category
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext

// DataStore extension
val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "category_data")

@Stable
class CategoryDataManager(private val context: Context) {
    private val gson = Gson()

    companion object {
        private val VERSION_KEY = intPreferencesKey("category_version")
        private val CATEGORIES_KEY = stringPreferencesKey("categories_json")
        private val USER_PREFERENCES_KEY = stringPreferencesKey("user_preferences")
    }

    suspend fun getCategories(): List<Category> {
        return withContext(Dispatchers.IO) {
            val bundledData = loadBundledCategoryData()
            val savedVersion = getSavedVersion()
            val bundledVersion = bundledData.version

            // Version kontrolü
            if (savedVersion < bundledVersion) {
                // Yeni versiyon varsa bundle'dan yükle ve kaydet
                val updatedCategories = mergeCategoriesWithUserPreferences(
                    bundledCategories = bundledData.categories,
                    userPreferences = getUserPreferences()
                )
                saveCategories(updatedCategories, bundledVersion)
                updatedCategories
            } else {
                // Mevcut versiyon güncel, DataStore'dan yükle
                loadSavedCategories() ?: run {
                    // Eğer kayıtlı veri yoksa bundle'dan yükle
                    val updatedCategories = mergeCategoriesWithUserPreferences(
                        bundledCategories = bundledData.categories,
                        userPreferences = getUserPreferences()
                    )
                    saveCategories(updatedCategories, bundledVersion)
                    updatedCategories
                }
            }
        }
    }

    private suspend fun getSavedVersion(): Int {
        return context.dataStore.data.map { preferences ->
            preferences[VERSION_KEY] ?: 0
        }.first()
    }

    private fun loadBundledCategoryData(): BundledCategoryData {
        return try {
            val jsonString = context.assets.open("categories/categories.json")
                .bufferedReader().use { it.readText() }

            gson.fromJson(jsonString, BundledCategoryData::class.java)
        } catch (e: Exception) {
            e.printStackTrace()
            // Fallback data
            BundledCategoryData(
                version = 1,
                categories = getDefaultCategories().map { CategoryDto.fromCategory(it) }
            )
        }
    }

    private suspend fun loadSavedCategories(): List<Category>? {
        return try {
            val jsonString = context.dataStore.data.map { preferences ->
                preferences[CATEGORIES_KEY]
            }.first() ?: return null

            val categoryData = gson.fromJson(jsonString, CategoryData::class.java)
            categoryData.categories.map { it.toCategory() }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private suspend fun saveCategories(categories: List<Category>, version: Int) {
        val categoryData = CategoryData(categories.map { CategoryDto.fromCategory(it) })
        val jsonString = gson.toJson(categoryData)

        context.dataStore.edit { preferences ->
            preferences[CATEGORIES_KEY] = jsonString
            preferences[VERSION_KEY] = version
        }
    }

    // Kullanıcı tercihlerini yükle
    suspend fun getUserPreferences(): UserPreferences {
        return try {
            val jsonString = context.dataStore.data.map { preferences ->
                preferences[USER_PREFERENCES_KEY]
            }.first()

            if (jsonString != null) {
                gson.fromJson(jsonString, UserPreferences::class.java)
            } else {
                // Bundle'dan default user preferences yükle
                loadBundledUserPreferences()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            UserPreferences()
        }
    }

    private fun loadBundledUserPreferences(): UserPreferences {
        return try {
            val jsonString = context.assets.open("preferences/user_preferences.json")
                .bufferedReader().use { it.readText() }

            gson.fromJson(jsonString, UserPreferences::class.java)
        } catch (e: Exception) {
            e.printStackTrace()
            UserPreferences()
        }
    }

    // Kullanıcı tercihlerini kaydet
    private suspend fun saveUserPreferences(userPreferences: UserPreferences) {
        val jsonString = gson.toJson(userPreferences)
        context.dataStore.edit { preferences ->
            preferences[USER_PREFERENCES_KEY] = jsonString
        }
    }

    // Bundle kategorileri ile kullanıcı tercihlerini birleştir
    private suspend fun mergeCategoriesWithUserPreferences(
        bundledCategories: List<CategoryDto>,
        userPreferences: UserPreferences
    ): List<Category> {
        return bundledCategories.map { bundledCategory ->
            val category = bundledCategory.toCategory()

            // Kullanıcı tercihlerine göre isLocked durumunu güncelle
            val isLocked = if (userPreferences.unlockedCategories.contains(bundledCategory.id)) {
                false // Kullanıcı kilidi açmış
            } else {
                bundledCategory.isLocked // Bundle'daki orijinal durum
            }

            category.copy(isLocked = isLocked)
        }
    }

    // Kategori satın al / kilidi aç
    suspend fun purchaseCategory(categoryId: String) {
        withContext(Dispatchers.IO) {
            val userPreferences = getUserPreferences()

            if (!userPreferences.unlockedCategories.contains(categoryId)) {
                val updatedPreferences = userPreferences.copy(
                    unlockedCategories = userPreferences.unlockedCategories + categoryId
                )
                saveUserPreferences(updatedPreferences)
            }

            // Kategorileri yeniden yükle ve kaydet
            val categories = getCategories()
            val updatedCategories = categories.map { category ->
                if (category.id == categoryId) {
                    category.copy(isLocked = false)
                } else {
                    category
                }
            }
            saveCategories(updatedCategories, getSavedVersion())
        }
    }

    // Favorilere ekle/çıkar
    suspend fun toggleFavorite(categoryId: String) {
        withContext(Dispatchers.IO) {
            val userPreferences = getUserPreferences()
            val updatedFavorites = if (userPreferences.favorites.contains(categoryId)) {
                userPreferences.favorites - categoryId
            } else {
                userPreferences.favorites + categoryId
            }

            val updatedPreferences = userPreferences.copy(favorites = updatedFavorites)
            saveUserPreferences(updatedPreferences)
        }
    }

    // Son kullanılan kategoriyi güncelle
    suspend fun updateLastUsed(categoryId: String) {
        withContext(Dispatchers.IO) {
            val userPreferences = getUserPreferences()
            val updatedLastUsed = listOf(categoryId) +
                    (userPreferences.lastUsed - categoryId).take(4) // Son 5 kategoriyi tut

            val updatedPreferences = userPreferences.copy(lastUsed = updatedLastUsed)
            saveUserPreferences(updatedPreferences)
        }
    }

    // Filtrelenmiş kategorileri getir
    suspend fun getCategoriesFiltered(
        showOnlyFavorites: Boolean = false,
        showOnlyUnlocked: Boolean = false
    ): List<Category> {
        val allCategories = getCategories()
        val userPreferences = getUserPreferences()

        return allCategories.filter { category ->
            val passesLockedFilter = if (showOnlyUnlocked) !category.isLocked else true
            val passesFavoriteFilter = if (showOnlyFavorites) {
                userPreferences.favorites.contains(category.id)
            } else true

            passesLockedFilter && passesFavoriteFilter
        }
    }

    // Son kullanılan kategorileri getir
    suspend fun getRecentCategories(): List<Category> {
        val userPreferences = getUserPreferences()
        val allCategories = getCategories()

        return userPreferences.lastUsed.mapNotNull { categoryId ->
            allCategories.find { it.id == categoryId }
        }
    }

    // Favori kategorileri getir
    suspend fun getFavoriteCategories(): List<Category> {
        val userPreferences = getUserPreferences()
        val allCategories = getCategories()

        return userPreferences.favorites.mapNotNull { categoryId ->
            allCategories.find { it.id == categoryId }
        }
    }

    // Kategoriyi güncelle
    suspend fun updateCategory(updatedCategory: Category) {
        withContext(Dispatchers.IO) {
            val categories = getCategories()
            val updatedCategories = categories.map { category ->
                if (category.id == updatedCategory.id) updatedCategory else category
            }
            saveCategories(updatedCategories, getSavedVersion())
        }
    }

    // Tüm kategorileri sıfırla (bundle'dan yeniden yükle)
    suspend fun resetCategories() {
        withContext(Dispatchers.IO) {
            context.dataStore.edit { preferences ->
                preferences.remove(CATEGORIES_KEY)
                preferences.remove(VERSION_KEY)
            }
        }
    }

    // Kullanıcı tercihlerini sıfırla
    suspend fun resetUserPreferences() {
        withContext(Dispatchers.IO) {
            context.dataStore.edit { preferences ->
                preferences.remove(USER_PREFERENCES_KEY)
            }
        }
    }

    // Her şeyi sıfırla
    suspend fun resetAll() {
        withContext(Dispatchers.IO) {
            context.dataStore.edit { preferences ->
                preferences.remove(CATEGORIES_KEY)
                preferences.remove(VERSION_KEY)
                preferences.remove(USER_PREFERENCES_KEY)
            }
        }
    }
}

// JSON için Data Transfer Objects
data class BundledCategoryData(
    val version: Int,
    val categories: List<CategoryDto>
)

data class CategoryData(
    val categories: List<CategoryDto>
)

data class UserPreferences(
    val favorites: List<String> = emptyList(),
    val lastUsed: List<String> = emptyList(),
    val unlockedCategories: List<String> = emptyList()
)

data class CategoryDto(
    val id: String,
    val name: String,
    val iconName: String,
    val colorHex: String,
    val items: List<String>,
    val hints: List<String>,
    val isLocked: Boolean,
    val price: Int = 0 // Kategori fiyatı (0 = ücretsiz)
) {
    fun toCategory(): Category {
        return Category(
            id = id,
            name = name,
            icon = getIconByName(iconName),
            color = Color(android.graphics.Color.parseColor(colorHex)),
            items = items,
            hints = hints,
            isLocked = isLocked,
            price = price
        )
    }

    companion object {
        fun fromCategory(category: Category): CategoryDto {
            return CategoryDto(
                id = category.id,
                name = category.name,
                iconName = getIconName(category.icon),
                colorHex = "#${Integer.toHexString(category.color.toArgb()).substring(2).uppercase()}",
                items = category.items,
                hints = category.hints,
                isLocked = category.isLocked,
                price = category.price
            )
        }
    }
}

// Icon mapping functions
private fun getIconByName(iconName: String): ImageVector {
    return when (iconName) {
        "work" -> Icons.Default.Work
        "home" -> Icons.Default.Home
        "restaurant" -> Icons.Default.Restaurant
        "sports" -> Icons.Default.Sports
        "movie" -> Icons.Default.Movie
        "school" -> Icons.Default.School
        "directions_car" -> Icons.Default.DirectionsCar
        "music" -> Icons.Default.MusicNote
        "sports_esports" -> Icons.Default.SportsEsports
        "flight" -> Icons.Default.Flight
        "book" -> Icons.Default.MenuBook
        "brush" -> Icons.Default.Brush
        "computer" -> Icons.Default.Computer
        "nature" -> Icons.Default.Nature
        "shopping_cart" -> Icons.Default.ShoppingCart
        "pets" -> Icons.Default.Pets
        "place" -> Icons.Default.Place
        "palette" -> Icons.Default.Palette
        else -> Icons.Default.Category
    }
}

private fun getIconName(icon: ImageVector): String {
    return when (icon) {
        Icons.Default.Work -> "work"
        Icons.Default.Home -> "home"
        Icons.Default.Restaurant -> "restaurant"
        Icons.Default.Sports -> "sports"
        Icons.Default.Movie -> "movie"
        Icons.Default.School -> "school"
        Icons.Default.DirectionsCar -> "directions_car"
        Icons.Default.MusicNote -> "music"
        Icons.Default.SportsEsports -> "sports_esports"
        Icons.Default.Flight -> "flight"
        Icons.Default.MenuBook -> "book"
        Icons.Default.Brush -> "brush"
        Icons.Default.Computer -> "computer"
        Icons.Default.Nature -> "nature"
        Icons.Default.ShoppingCart -> "shopping_cart"
        Icons.Default.Pets -> "pets"
        Icons.Default.Place -> "place"
        Icons.Default.Palette -> "palette"
        else -> "category"
    }
}

// Default Categories (fallback)
private fun getDefaultCategories(): List<Category> {
    return listOf(
        Category(
            id = "professions",
            name = "Meslekler",
            icon = Icons.Default.Work,
            color = Color(0xFF2196F3),
            items = listOf(
                "Doktor", "Öğretmen", "Mühendis", "Avukat", "Hemşire",
                "Polis", "İtfaiyeci", "Pilot", "Şoför", "Aşçı"
            ),
            hints = listOf("İnsanlara yardım eder", "Eğitim verir"),
            isLocked = false,
            price = 0
        ),
        Category(
            id = "foods",
            name = "Yiyecekler",
            icon = Icons.Default.Restaurant,
            color = Color(0xFFE91E63),
            items = listOf(
                "Pizza", "Hamburger", "Makarna", "Pilav", "Çorba"
            ),
            hints = listOf("Beslenme için tüketilir", "Lezzetli"),
            isLocked = false,
            price = 0
        )
    )
}