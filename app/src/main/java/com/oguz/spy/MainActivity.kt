package com.oguz.spy

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.lifecycleScope
import com.google.android.gms.ads.MobileAds
import com.oguz.spy.ads.RewardedAdManager
import com.oguz.spy.billing.BillingManager
import com.oguz.spy.datamanagment.CategoryDataManager
import com.oguz.spy.ui.theme.SpyTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private lateinit var rewardedAdManager: RewardedAdManager
    private lateinit var billingManager: BillingManager
    private lateinit var categoryDataManager: CategoryDataManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)


        rewardedAdManager = RewardedAdManager(this)


        MobileAds.initialize(this) { initializationStatus ->
            Log.d("AdMob", "AdMob initialized: $initializationStatus")
        }
        // İlk reklamı yükle
        rewardedAdManager.loadAd(
            onAdLoaded = { Log.d("AdMob", "Rewarded ad loaded") },
            onAdFailedToLoad = { error -> Log.e("AdMob", "Failed to load: $error") }
        )

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
                        // Satın alma başarılı - kategoriyi kilitsiz yap
                        categoryDataManager.markAsPurchased(state.categoryId)
                        // UI'ı güncelle (compose state ile)
                    }
                    else -> { /* Loading veya Idle */ }
                }
            }
        }
        enableEdgeToEdge()
        setContent {
            SpyTheme {
                PageTransition(rewardedAdManager =rewardedAdManager)
            }
        }
    }
}

