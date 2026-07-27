package com.oguz.spy

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.lifecycleScope
import com.google.android.gms.ads.MobileAds
import com.oguz.spy.ads.BannerAdManager
import com.oguz.spy.ads.SpyInterstitialAdManager
import com.oguz.spy.ads.RewardedAdManager
import com.oguz.spy.billing.BillingManager
import com.oguz.spy.billing.PurchaseState
import com.oguz.spy.datamanagment.CategoryDataManager
import com.oguz.spy.ui.theme.SpyTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private var rewardedAdManager: RewardedAdManager? = null
    private var billingManager: BillingManager? = null
    private var categoryDataManager: CategoryDataManager? = null
    private var bannerAdManager: BannerAdManager? = null
    private var interstitialAdManager: SpyInterstitialAdManager? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        enableEdgeToEdge()
        
        initializeManagers()
        setupPurchaseObserver()
        loadInitialPurchases()

        setContent {
            val rewarded = rewardedAdManager
            val banner = bannerAdManager
            val interstitial = interstitialAdManager
            
            if (rewarded != null && banner != null && interstitial != null) {
                SpyTheme {
                    PageTransition(
                        rewardedAdManager = rewarded,
                        bannerAdManager = banner,
                        interstitialAdManager = interstitial
                    )
                }
            }
        }
    }

    private fun initializeManagers() {
        MobileAds.initialize(this) { initializationStatus ->
            Log.d("AdMob", "AdMob initialized: $initializationStatus")
        }

        rewardedAdManager = RewardedAdManager(this).apply {
            loadAd(
                onAdLoaded = { Log.d("AdMob", "Rewarded ad loaded") },
                onAdFailedToLoad = { error -> Log.e("AdMob", "Failed to load rewarded: $error") }
            )
        }

        interstitialAdManager = SpyInterstitialAdManager().apply {
            loadAd(
                context = this@MainActivity,
                onAdLoaded = { Log.d("AdMob", "Interstitial ad loaded") },
                onAdFailedToLoad = { error -> Log.e("AdMob", "Failed to load interstitial: $error") }
            )
        }

        bannerAdManager = BannerAdManager().apply {
            createAdView(
                context = this@MainActivity,
                onAdLoaded = { Log.d("AdMob", "Banner ad loaded") },
                onAdFailedToLoad = { error -> Log.e("AdMob", "Failed to load banner: $error") }
            )
            loadAd()
        }

        categoryDataManager = CategoryDataManager(this)

        billingManager = BillingManager(
            context = applicationContext,
            coroutineScope = lifecycleScope
        )
    }

    private fun setupPurchaseObserver() {
        val billing = billingManager ?: return
        lifecycleScope.launch {
            billing.purchaseState.collect { state ->
                when (state) {
                    is PurchaseState.Success -> {
                        val categoryId = state.categoryId
                        Log.d("MainActivity", "Satın alma başarılı: $categoryId")

                        if (isSubcategory(categoryId)) {
                            categoryDataManager?.markSubcategoryAsPurchased(categoryId)
                        } else {
                            categoryDataManager?.markAsPurchased(categoryId)
                        }
                    }
                    is PurchaseState.Error -> {
                        Log.e("MainActivity", "Satın alma hatası: ${state.message}")
                    }
                    PurchaseState.Idle -> {}
                    PurchaseState.Loading -> {}
                }
            }
        }
    }

    private fun loadInitialPurchases() {
        val billing = billingManager ?: return
        lifecycleScope.launch {
            delay(2000)
            val purchasedProducts = billing.getAllPurchasedProducts()
            Log.d("MainActivity", "Toplam ${purchasedProducts.size} satın alınmış ürün bulundu")

            purchasedProducts.forEach { productId ->
                if (isSubcategory(productId)) {
                    categoryDataManager?.markSubcategoryAsPurchased(productId)
                } else {
                    categoryDataManager?.markAsPurchased(productId)
                }
            }
        }
    }

    private fun isSubcategory(productId: String): Boolean {
        val subcategoryPrefixes = listOf("athletes_", "singers_", "actors_", "youtubers_")
        return subcategoryPrefixes.any { productId.startsWith(it) }
    }

    override fun onPause() {
        super.onPause()
        bannerAdManager?.pause()
    }

    override fun onResume() {
        super.onResume()
        bannerAdManager?.resume()
    }

    override fun onDestroy() {
        super.onDestroy()
        interstitialAdManager?.destroy()
        bannerAdManager?.destroy()
        billingManager?.destroy()
    }
}
