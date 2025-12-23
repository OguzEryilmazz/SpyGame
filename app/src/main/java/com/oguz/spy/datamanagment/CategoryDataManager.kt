package com.oguz.spy.datamanagment

import com.oguz.spy.R
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


private const val SINGLE_USE_UNLOCKED_SUBCATEGORIES_KEY = "single_use_unlocked_subcategories"

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
    private val PURCHASED_SUBCATEGORIES_KEY = "purchased_subcategories"

    suspend fun getCategories(): List<Category> = withContext(Dispatchers.IO) {
        android.util.Log.d("CategoryDebug", "========== getCategories BAŞLADI ==========")

        try {
            // ✅ ASSETS yerine RAW RESOURCES kullan
            val jsonString = context.resources
                .openRawResource(R.raw.categories)
                .bufferedReader()
                .use { it.readText() }

            android.util.Log.d("CategoryDebug", "✅ JSON OKUNDU! Boyut: ${jsonString.length}")

            val gson = Gson()
            val data = gson.fromJson(jsonString, CategoriesData::class.java)

            android.util.Log.d("CategoryDebug", "✅ Kategori sayısı: ${data.categories.size}")

            val favorites = getFavoriteIds()
            val purchased = getPurchasedIds()
            val unlockedSubs = getUnlockedSubcategoryIds()

            val result = data.categories.map { json ->
                val isMainCategoryPurchased = purchased.contains(json.id)

                val subcategories = json.subcategories?.map { subJson ->
                    Subcategory(
                        id = subJson.id,
                        name = subJson.name,
                        items = subJson.items,
                        hints = subJson.hints,
                        unlockedByAd = subJson.unlockedByAd,
                        isUnlocked = isMainCategoryPurchased ||
                                unlockedSubs.contains(subJson.id) ||
                                subJson.isUnlocked
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

            android.util.Log.d("CategoryDebug", "🎯 DÖNDÜRÜLEN: ${result.size} kategori")
            result

        } catch (e: Exception) {
            android.util.Log.e("CategoryDebug", "❌ HATA!", e)
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

    fun markAsPurchased(categoryId: String) {
        val purchased = getPurchasedIds().toMutableSet()
        purchased.add(categoryId)
        prefs.edit().putStringSet(PURCHASED_KEY, purchased).apply()
    }

    fun isPurchased(categoryId: String): Boolean {
        return getPurchasedIds().contains(categoryId)
    }

    fun markSubcategoryAsPurchased(subcategoryId: String) {
        val purchased = getPurchasedSubcategoryIds().toMutableSet()
        purchased.add(subcategoryId)
        prefs.edit().putStringSet(PURCHASED_SUBCATEGORIES_KEY, purchased).apply()
    }

    fun getPurchasedSubcategoryIds(): Set<String> {
        return prefs.getStringSet(PURCHASED_SUBCATEGORIES_KEY, emptySet()) ?: emptySet()
    }

    fun isPermanentlyUnlocked(subcategoryId: String): Boolean {
        val permanentUnlocked = prefs.getStringSet(UNLOCKED_SUBCATEGORIES_KEY, emptySet()) ?: emptySet()
        val purchased = getPurchasedSubcategoryIds()
        return permanentUnlocked.contains(subcategoryId) || purchased.contains(subcategoryId)
    }

    fun unlockSubcategoryWithAd(subcategoryId: String) {
        val unlocked = getUnlockedSubcategoryIds().toMutableSet()
        unlocked.add(subcategoryId)
        prefs.edit().putStringSet(UNLOCKED_SUBCATEGORIES_KEY, unlocked).apply()
    }

    fun grantSingleUseAccess(subcategoryId: String) {
        val singleUseAccessIds =
            prefs.getStringSet(SINGLE_USE_UNLOCKED_SUBCATEGORIES_KEY, emptySet())
                ?.toMutableSet()
                ?: mutableSetOf()

        singleUseAccessIds.add(subcategoryId)

        prefs.edit().putStringSet(SINGLE_USE_UNLOCKED_SUBCATEGORIES_KEY, singleUseAccessIds).apply()
    }

    fun getUnlockedSubcategoryIds(): Set<String> {
        val permanentUnlocked = prefs.getStringSet(UNLOCKED_SUBCATEGORIES_KEY, emptySet()) ?: emptySet()
        val purchased = getPurchasedSubcategoryIds()
        val singleUseUnlocked = prefs.getStringSet(SINGLE_USE_UNLOCKED_SUBCATEGORIES_KEY, emptySet()) ?: emptySet()

        return permanentUnlocked + purchased + singleUseUnlocked
    }

    fun consumeSingleUseAccess(subcategoryId: String) {
        val singleUseAccessIds = prefs.getStringSet(SINGLE_USE_UNLOCKED_SUBCATEGORIES_KEY, emptySet())
            ?.toMutableSet()
            ?: mutableSetOf()

        if (singleUseAccessIds.remove(subcategoryId)) {
            prefs.edit().putStringSet(SINGLE_USE_UNLOCKED_SUBCATEGORIES_KEY, singleUseAccessIds).apply()
        }
    }

    private fun getIconByName(iconName: String) = when (iconName) {
        "work" -> Icons.Default.Work
        "restaurant" -> Icons.Default.Restaurant
        "apple" -> Icons.Default.FoodBank
        "palette" -> Icons.Default.Palette
        "sports" -> Icons.Default.Sports
        "music" -> Icons.Default.MusicNote
        "place" -> Icons.Default.Place
        "pets" -> Icons.Default.Pets
        "directions_car" -> Icons.Default.DirectionsCar
        "sports_esports" -> Icons.Default.SportsBasketball
        "computer" -> Icons.Default.Computer
        "checkroom" -> Icons.Default.Checkroom
        "school" -> Icons.Default.School
        "book" -> Icons.Default.Book
        "wb_sunny" -> Icons.Default.WbSunny
        "mood" -> Icons.Default.Mood
        "home" -> Icons.Default.Home
        "public" -> Icons.Default.Public
        "shuffle" -> Icons.Default.Shuffle
        "cake"-> Icons.Default.Cake
        "local_cafe"-> Icons.Default.LocalCafe
        "store"->Icons.Default.Store
        "movie" -> Icons.Default.Movie
        "live_tv" -> Icons.Default.LiveTv
        "play_circle" -> Icons.Default.PlayCircle
        else -> Icons.Default.Category
    }
}