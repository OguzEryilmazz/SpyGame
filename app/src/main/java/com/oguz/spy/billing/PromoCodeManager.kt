package com.oguz.spy.billing

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.promoDataStore by preferencesDataStore(name = "promo_prefs")

object PromoCodeManager {

    private const val VALID_CODE = "OGUZ2026"
    private val CODE_USED_KEY = stringPreferencesKey("promo_code_used")
    private val PROMO_UNLOCKED_KEY = stringPreferencesKey("promo_unlocked_categories")

    fun isValidCode(code: String): Boolean =
        code.trim().uppercase() == VALID_CODE

    suspend fun savePromoUnlocks(context: Context, categoryIds: List<String>) {
        context.promoDataStore.edit { prefs ->
            prefs[CODE_USED_KEY] = VALID_CODE
            prefs[PROMO_UNLOCKED_KEY] = categoryIds.joinToString(",")
        }
    }

    fun getPromoUnlockedCategories(context: Context): Flow<Set<String>> =
        context.promoDataStore.data.map { prefs ->
            val raw = prefs[PROMO_UNLOCKED_KEY] ?: ""
            if (raw.isEmpty()) emptySet() else raw.split(",").toSet()
        }

    fun isCodeAlreadyUsed(context: Context): Flow<Boolean> =
        context.promoDataStore.data.map { prefs ->
            prefs[CODE_USED_KEY] != null
        }
}