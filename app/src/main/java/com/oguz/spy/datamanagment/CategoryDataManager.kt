package com.oguz.spy.datamanagment

import com.oguz.spy.R
import android.content.Context
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.ui.graphics.Color
import com.oguz.spy.ux.Category
import com.oguz.spy.ux.Subcategory
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName
import kotlinx.serialization.json.Json // ✅ EKLE

private const val SINGLE_USE_UNLOCKED_SUBCATEGORIES_KEY = "single_use_unlocked_subcategories"

@Serializable
data class CategoryJson(
    @SerialName("id") val id: String,
    @SerialName("name") val name: String,
    @SerialName("iconName") val iconName: String,
    @SerialName("colorHex") val colorHex: String,
    @SerialName("items") val items: List<String>? = null,
    @SerialName("hints") val hints: List<String>? = null,
    @SerialName("isLocked") val isLocked: Boolean,
    @SerialName("priceTL") val priceTL: Double,
    @SerialName("hasSubcategories") val hasSubcategories: Boolean = false,
    @SerialName("subcategories") val subcategories: List<SubcategoryJson>? = null,
    @SerialName("isRandomCategory") val isRandomCategory: Boolean = false
)

@Serializable
data class SubcategoryJson(
    @SerialName("id") val id: String,
    @SerialName("name") val name: String,
    @SerialName("unlockedByAd") val unlockedByAd: Boolean,
    @SerialName("isUnlocked") val isUnlocked: Boolean,
    @SerialName("items") val items: List<String>,
    @SerialName("hints") val hints: List<String>
)

@Serializable
data class CategoriesData(
    @SerialName("version") val version: Int,
    @SerialName("categories") val categories: List<CategoryJson>
)

class CategoryDataManager(private val context: Context) {

    private val prefs = context.getSharedPreferences("spy_prefs", Context.MODE_PRIVATE)
    private val FAVORITES_KEY = "favorite_categories"
    private val PURCHASED_KEY = "purchased_categories"
    private val UNLOCKED_SUBCATEGORIES_KEY = "unlocked_subcategories"
    private val PURCHASED_SUBCATEGORIES_KEY = "purchased_subcategories"

    // ✅ JSON Parser'ı oluştur
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
        coerceInputValues = true
        encodeDefaults = true
    }

    suspend fun getCategories(): List<Category> = withContext(Dispatchers.IO) {
        android.util.Log.d("CategoryDebug", "========== getCategories BAŞLADI ==========")

        try {
            val jsonString = context.resources
                .openRawResource(R.raw.categories)
                .bufferedReader()
                .use { it.readText() }

            android.util.Log.d("CategoryDebug", "✅ JSON OKUNDU! Boyut: ${jsonString.length}")

            val data = json.decodeFromString<CategoriesData>(jsonString)

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
            android.util.Log.e("CategoryDebug", "❌ HATA TİPİ: ${e.javaClass.simpleName}", e)
            android.util.Log.e("CategoryDebug", "❌ HATA MESAJI: ${e.message}", e)
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