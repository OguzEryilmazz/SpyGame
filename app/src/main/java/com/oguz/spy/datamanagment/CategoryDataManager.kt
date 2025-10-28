package com.oguz.spy.datamanagment

import android.content.Context
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.ui.graphics.Color
import com.oguz.spy.ux.Category
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

data class CategoryJson(
    @SerializedName("id") val id: String,
    @SerializedName("name") val name: String,
    @SerializedName("iconName") val iconName: String,
    @SerializedName("colorHex") val colorHex: String,
    @SerializedName("items") val items: List<String>,
    @SerializedName("hints") val hints: List<String>,
    @SerializedName("isLocked") val isLocked: Boolean,
    @SerializedName("priceTL") val priceTL: Double
)

data class CategoriesData(
    @SerializedName("version") val version: Int,
    @SerializedName("categories") val categories: List<CategoryJson>
)

class CategoryDataManager(private val context: Context) {

    private val prefs = context.getSharedPreferences("spy_prefs", Context.MODE_PRIVATE)
    private val FAVORITES_KEY = "favorite_categories"
    private val PURCHASED_KEY = "purchased_categories"

    suspend fun getCategories(): List<Category> = withContext(Dispatchers.IO) {
        try {
            val jsonString = context.assets.open("categories/categories.json")
                .bufferedReader()
                .use { it.readText() }

            val gson = Gson()
            val data = gson.fromJson(jsonString, CategoriesData::class.java)

            val favorites = getFavoriteIds()
            val purchased = getPurchasedIds()

            data.categories.map { json ->
                Category(
                    id = json.id,
                    name = json.name,
                    icon = getIconByName(json.iconName),
                    color = Color(android.graphics.Color.parseColor(json.colorHex)),
                    items = json.items,
                    hints = json.hints,
                    isLocked = json.isLocked && !purchased.contains(json.id), // Satın alındıysa kilidi aç
                    priceTL = json.priceTL,
                    isFavorite = favorites.contains(json.id)
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
            emptyList()
        }
    }

    private fun getFavoriteIds(): Set<String> {
        return prefs.getStringSet(FAVORITES_KEY, emptySet()) ?: emptySet()
    }

    private fun getPurchasedIds(): Set<String> {
        return prefs.getStringSet(PURCHASED_KEY, emptySet()) ?: emptySet()
    }

    fun toggleFavorite(categoryId: String) {
        val favorites = getFavoriteIds().toMutableSet()
        if (favorites.contains(categoryId)) {
            favorites.remove(categoryId)
        } else {
            favorites.add(categoryId)
        }
        prefs.edit().putStringSet(FAVORITES_KEY, favorites).apply()
    }

    // Satın alınan kategoriyi kaydet
    fun markAsPurchased(categoryId: String) {
        val purchased = getPurchasedIds().toMutableSet()
        purchased.add(categoryId)
        prefs.edit().putStringSet(PURCHASED_KEY, purchased).apply()
    }

    // Kategori satın alınmış mı kontrol et
    fun isPurchased(categoryId: String): Boolean {
        return getPurchasedIds().contains(categoryId)
    }

    private fun getIconByName(iconName: String) = when (iconName) {
        "work" -> Icons.Default.Work
        "restaurant" -> Icons.Default.Restaurant
        "apple" -> Icons.Default.EmojiFoodBeverage
        "palette" -> Icons.Default.Palette
        "sports" -> Icons.Default.Sports
        "music" -> Icons.Default.MusicNote
        "place" -> Icons.Default.Place
        "pets" -> Icons.Default.Pets
        "directions_car" -> Icons.Default.DirectionsCar
        "sports_esports" -> Icons.Default.SportsEsports
        "computer" -> Icons.Default.Computer
        "checkroom" -> Icons.Default.Checkroom
        "school" -> Icons.Default.School
        "book" -> Icons.Default.Book
        "wb_sunny" -> Icons.Default.WbSunny
        "mood" -> Icons.Default.Mood
        "home" -> Icons.Default.Home
        "public" -> Icons.Default.Public
        else -> Icons.Default.Category
    }
}