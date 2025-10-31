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

        // Banner Ad Manager - AdView'ı burada oluştur
        bannerAdManager = BannerAdManager()
        bannerAdManager.createAdView(
            context = this,
            onAdLoaded = { Log.d("AdMob", "Banner ad loaded") },
            onAdFailedToLoad = { error -> Log.e("AdMob", "Failed to load banner: $error") }
        )
        bannerAdManager.loadAd()

        // Billing Manager'ı başlat
        billingManager = BillingManager(
            context = applicationContext,
            coroutineScope = lifecycleScope
        )

        categoryDataManager = CategoryDataManager(this)

        // Satın alma durumunu dinle
        lifecycleScope.launch {
            billingManager.purchaseState.collect { state ->
                when (state) {
                    is BillingManager.PurchaseState.Success -> {
                        categoryDataManager.markAsPurchased(state.categoryId)
                    }
                    else -> { /* Loading veya Idle */ }
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
    }
}