package com.oguz.spy

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.lifecycleScope
import com.google.android.gms.ads.MobileAds
import com.oguz.spy.ads.BannerAdManager
import com.oguz.spy.ads.RewardedAdManager
import com.oguz.spy.billing.BillingManager
import com.oguz.spy.datamanagment.CategoryDataManager
import com.oguz.spy.ui.theme.SpyTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private lateinit var rewardedAdManager: RewardedAdManager
    private lateinit var billingManager: BillingManager
    private lateinit var categoryDataManager: CategoryDataManager
    private lateinit var bannerAdManager: BannerAdManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // AdMob'u başlat
        MobileAds.initialize(this) { initializationStatus ->
            Log.d("AdMob", "AdMob initialized: $initializationStatus")
        }

        // Rewarded Ad Manager
        rewardedAdManager = RewardedAdManager(this)
        rewardedAdManager.loadAd(
            onAdLoaded = { Log.d("AdMob", "Rewarded ad loaded") },
            onAdFailedToLoad = { error -> Log.e("AdMob", "Failed to load rewarded: $error") }
        )

        // Banner Ad Manager
        bannerAdManager = BannerAdManager()
        bannerAdManager.createAdView(
            context = this,
            onAdLoaded = { Log.d("AdMob", "Banner ad loaded") },
            onAdFailedToLoad = { error -> Log.e("AdMob", "Failed to load banner: $error") }
        )
        bannerAdManager.loadAd()

        // CategoryDataManager'ı önce oluştur
        categoryDataManager = CategoryDataManager(this)

        // Billing Manager'ı başlat
        billingManager = BillingManager(
            context = applicationContext,
            coroutineScope = lifecycleScope
        )

        // ✅ Satın alma durumunu dinle
        lifecycleScope.launch {
            billingManager.purchaseState.collect { state ->
                when (state) {
                    is BillingManager.PurchaseState.Success -> {
                        val categoryId = state.categoryId
                        Log.d("MainActivity", "Satın alma başarılı: $categoryId")

                        // Subcategory mi ana kategori mi kontrol et
                        if (isSubcategory(categoryId)) {
                            categoryDataManager.markSubcategoryAsPurchased(categoryId)
                            Log.d("MainActivity", "Subcategory satın alındı olarak işaretlendi: $categoryId")
                        } else {
                            categoryDataManager.markAsPurchased(categoryId)
                            Log.d("MainActivity", "Ana kategori satın alındı olarak işaretlendi: $categoryId")
                        }
                    }
                    is BillingManager.PurchaseState.Error -> {
                        Log.e("MainActivity", "Satın alma hatası: ${state.message}")
                    }
                    else -> { /* Loading veya Idle */ }
                }
            }
        }

        // ✅ Uygulama başladığında mevcut satın almaları yükle
        lifecycleScope.launch {
            // Billing client hazır olana kadar bekle
            kotlinx.coroutines.delay(2000)

            // Tüm satın alınmış ürünleri al
            val purchasedProducts = billingManager.getAllPurchasedProducts()

            Log.d("MainActivity", "Toplam ${purchasedProducts.size} satın alınmış ürün bulundu")

            purchasedProducts.forEach { productId ->
                if (isSubcategory(productId)) {
                    categoryDataManager.markSubcategoryAsPurchased(productId)
                    Log.d("MainActivity", "Subcategory yüklendi: $productId")
                } else {
                    categoryDataManager.markAsPurchased(productId)
                    Log.d("MainActivity", "Ana kategori yüklendi: $productId")
                }
            }
        }

        enableEdgeToEdge()
        setContent {
            SpyTheme {
                PageTransition(
                    rewardedAdManager = rewardedAdManager,
                    bannerAdManager = bannerAdManager
                )
            }
        }
    }

    // Subcategory mi kontrol et (ID'de underscore varsa subcategory'dir)
    private fun isSubcategory(productId: String): Boolean {
        val subcategoryPrefixes = listOf(
            "athletes_", "singers_", "actors_", "youtubers_"
        )
        return subcategoryPrefixes.any { productId.startsWith(it) }
    }

    override fun onPause() {
        super.onPause()
        bannerAdManager.pause()
    }

    override fun onResume() {
        super.onResume()
        bannerAdManager.resume()
    }

    override fun onDestroy() {
        super.onDestroy()
        bannerAdManager.destroy()
        billingManager.destroy()
    }
}