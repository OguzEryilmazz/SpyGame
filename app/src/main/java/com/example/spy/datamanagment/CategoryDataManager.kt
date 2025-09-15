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
    private val currentVersion = 3

    companion object {
        private val VERSION_KEY = intPreferencesKey("category_version")
        private val CATEGORIES_KEY = stringPreferencesKey("categories_json")
    }

    suspend fun getCategories(): List<Category> {
        return withContext(Dispatchers.IO) {
            val savedVersion = context.dataStore.data.map { preferences ->
                preferences[VERSION_KEY] ?: 0
            }.first()

            if (savedVersion < currentVersion) {
                val bundledCategories = loadBundledCategories()
                saveCategories(bundledCategories)
                bundledCategories
            } else {
                // Mevcut versiyon güncel, DataStore'dan yükle
                loadSavedCategories() ?: run {
                    // Eğer kayıtlı veri yoksa bundle'dan yükle
                    val bundledCategories = loadBundledCategories()
                    saveCategories(bundledCategories)
                    bundledCategories
                }
            }
        }
    }

    private fun loadBundledCategories(): List<Category> {
        return try {
            val jsonString = context.assets.open("categories/categories_v$currentVersion.json")
                .bufferedReader().use { it.readText() }

            val gson = Gson()
            val categoryData = gson.fromJson(jsonString, CategoryData::class.java)
            categoryData.categories.map { it.toCategory() }
        } catch (e: Exception) {
            e.printStackTrace()
            getDefaultCategories()
        }
    }

    private suspend fun loadSavedCategories(): List<Category>? {
        return try {
            val jsonString = context.dataStore.data.map { preferences ->
                preferences[CATEGORIES_KEY]
            }.first() ?: return null

            val gson = Gson()
            val categoryData = gson.fromJson(jsonString, CategoryData::class.java)
            categoryData.categories.map { it.toCategory() }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private suspend fun saveCategories(categories: List<Category>) {
        val categoryData = CategoryData(categories.map { CategoryDto.fromCategory(it) })
        val gson = Gson()
        val jsonString = gson.toJson(categoryData)

        context.dataStore.edit { preferences ->
            preferences[CATEGORIES_KEY] = jsonString
            preferences[VERSION_KEY] = currentVersion
        }
    }

    // Kullanıcının kilidi açtığı kategorileri kaydet
    suspend fun unlockCategory(categoryId: String) {
        withContext(Dispatchers.IO) {
            val categories = getCategories()

            // İlgili kategoriyi bul ve kilidini aç
            val updatedCategories = categories.map { category ->
                if (category.id == categoryId) {
                    category.copy(isLocked = false)
                } else {
                    category
                }
            }

            // Güncellenen kategorileri kaydet
            saveCategories(updatedCategories)
        }
    }

    // Kategoriyi güncelle
    suspend fun updateCategory(updatedCategory: Category) {
        withContext(Dispatchers.IO) {
            val categories = getCategories()
            val updatedCategories = categories.map { category ->
                if (category.id == updatedCategory.id) updatedCategory else category
            }
            saveCategories(updatedCategories)
        }
    }

    // Tüm kategorileri sıfırla (bundle'dan yeniden yükle)
    suspend fun resetCategories() {
        withContext(Dispatchers.IO) {
            context.dataStore.edit { preferences ->
                preferences.remove(CATEGORIES_KEY)
                preferences.remove(VERSION_KEY)
            }
            // Yeniden yükleme getCategories() çağrıldığında otomatik olacak
        }
    }
}

// JSON için Data Transfer Objects
data class CategoryData(
    val categories: List<CategoryDto>
)

data class CategoryDto(
    val id: String,
    val name: String,
    val iconName: String,
    val colorHex: String,
    val items: List<String>,
    val hints: List<String>,
    val isLocked: Boolean
) {
    fun toCategory(): Category {
        return Category(
            id = id,
            name = name,
            icon = getIconByName(iconName),
            color = Color(android.graphics.Color.parseColor(colorHex)),
            items = items,
            hints = hints,
            isLocked = isLocked
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
                isLocked = category.isLocked
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
        "car" -> Icons.Default.DirectionsCar
        "music" -> Icons.Default.MusicNote
        "game" -> Icons.Default.SportsEsports
        "travel" -> Icons.Default.Flight
        "book" -> Icons.Default.MenuBook
        "art" -> Icons.Default.Brush
        "tech" -> Icons.Default.Computer
        "nature" -> Icons.Default.Nature
        "shopping" -> Icons.Default.ShoppingCart
        "pets" -> Icons.Default.Pets
        "place" -> Icons.Default.Place
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
        Icons.Default.DirectionsCar -> "car"
        Icons.Default.MusicNote -> "music"
        Icons.Default.SportsEsports -> "game"
        Icons.Default.Flight -> "travel"
        Icons.Default.MenuBook -> "book"
        Icons.Default.Brush -> "art"
        Icons.Default.Computer -> "tech"
        Icons.Default.Nature -> "nature"
        Icons.Default.ShoppingCart -> "shopping"
        Icons.Default.Pets -> "pets"
        Icons.Default.Place -> "place"
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