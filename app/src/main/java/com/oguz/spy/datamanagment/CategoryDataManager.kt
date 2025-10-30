package com.oguz.spy.datamanagment

import android.content.Context
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.ui.graphics.Color
import com.oguz.spy.ux.Category
import com.oguz.spy.ux.Subcategory
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

data class CategoryJson(
    @SerializedName("id") val id: String,
    @SerializedName("name") val name: String,
    @SerializedName("iconName") val iconName: String,
    @SerializedName("colorHex") val colorHex: String,
    @SerializedName("items") val items: List<String>? = null,
    @SerializedName("hints") val hints: List<String>? = null,
    @SerializedName("isLocked") val isLocked: Boolean,
    @SerializedName("priceTL") val priceTL: Double,
    @SerializedName("hasSubcategories") val hasSubcategories: Boolean = false,
    @SerializedName("subcategories") val subcategories: List<SubcategoryJson>? = null,
    @SerializedName("isRandomCategory") val isRandomCategory: Boolean = false
)

data class SubcategoryJson(
    @SerializedName("id") val id: String,
    @SerializedName("name") val name: String,
    @SerializedName("unlockedByAd") val unlockedByAd: Boolean,
    @SerializedName("isUnlocked") val isUnlocked: Boolean,
    @SerializedName("items") val items: List<String>,
    @SerializedName("hints") val hints: List<String>
)

data class CategoriesData(
    @SerializedName("version") val version: Int,
    @SerializedName("categories") val categories: List<CategoryJson>
)

class CategoryDataManager(private val context: Context) {

    private val prefs = context.getSharedPreferences("spy_prefs", Context.MODE_PRIVATE)
    private val FAVORITES_KEY = "favorite_categories"
    private val PURCHASED_KEY = "purchased_categories"
    private val UNLOCKED_SUBCATEGORIES_KEY = "unlocked_subcategories"

    suspend fun getCategories(): List<Category> = withContext(Dispatchers.IO) {
        try {
            val jsonString = context.assets.open("categories/categories.json")
                .bufferedReader()
                .use { it.readText() }

            val gson = Gson()
            val data = gson.fromJson(jsonString, CategoriesData::class.java)

            val favorites = getFavoriteIds()
            val purchased = getPurchasedIds()
            val unlockedSubs = getUnlockedSubcategoryIds()

            data.categories.map { json ->
                val subcategories = json.subcategories?.map { subJson ->
                    Subcategory(
                        id = subJson.id,
                        name = subJson.name,
                        items = subJson.items,
                        hints = subJson.hints,
                        unlockedByAd = subJson.unlockedByAd,
                        isUnlocked = unlockedSubs.contains(subJson.id)
                    )
                } ?: emptyList()

                Category(
                    id = json.id,
                    name = json.name,
                    icon = getIconByName(json.iconName),
                    color = Color(android.graphics.Color.parseColor(json.colorHex)),
                    items = json.items ?: emptyList(),
                    hints = json.hints ?: emptyList(),
                    isLocked = json.isLocked && !purchased.contains(json.id),
                    priceTL = json.priceTL,
                    isFavorite = favorites.contains(json.id),
                    hasSubcategories = json.hasSubcategories,
                    subcategories = subcategories,
                    isRandomCategory = json.isRandomCategory
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

    private fun getUnlockedSubcategoryIds(): Set<String> {
        return prefs.getStringSet(UNLOCKED_SUBCATEGORIES_KEY, emptySet()) ?: emptySet()
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

    fun markAsPurchased(categoryId: String) {
        val purchased = getPurchasedIds().toMutableSet()
        purchased.add(categoryId)
        prefs.edit().putStringSet(PURCHASED_KEY, purchased).apply()
    }

    fun isPurchased(categoryId: String): Boolean {
        return getPurchasedIds().contains(categoryId)
    }

    fun unlockSubcategoryWithAd(subcategoryId: String) {
        val unlocked = getUnlockedSubcategoryIds().toMutableSet()
        unlocked.add(subcategoryId)
        prefs.edit().putStringSet(UNLOCKED_SUBCATEGORIES_KEY, unlocked).apply()
    }

    fun isSubcategoryUnlocked(subcategoryId: String): Boolean {
        return getUnlockedSubcategoryIds().contains(subcategoryId)
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
        "shuffle" -> Icons.Default.Shuffle
        else -> Icons.Default.Category
    }
}