package com.oguz.spy.ads

import android.app.Activity
import android.content.Context
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import com.oguz.spy.ads.AdIds.REWARDED_TEST

class RewardedAdManager(
    private val context: Context,
    private val adUnitId: String = REWARDED_TEST // Test ID
) {
    private var rewardedAd: RewardedAd? = null
    private var isLoading = false

    fun loadAd(onAdLoaded: () -> Unit = {}, onAdFailedToLoad: (String) -> Unit = {}) {
        if (isLoading) return

        isLoading = true
        val adRequest = AdRequest.Builder().build()

        RewardedAd.load(
            context,
            adUnitId,
            adRequest,
            object : RewardedAdLoadCallback() {
                override fun onAdLoaded(ad: RewardedAd) {
                    rewardedAd = ad
                    isLoading = false
                    onAdLoaded()
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    rewardedAd = null
                    isLoading = false
                    onAdFailedToLoad(error.message)
                }
            }
        )
    }

    fun showAd(
        activity: Activity,
        onUserEarnedReward: (Int, String) -> Unit,
        onAdDismissed: () -> Unit = {},
        onAdShowFailed: (String) -> Unit = {}
    ) {
        if (rewardedAd != null) {
            rewardedAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
                override fun onAdDismissedFullScreenContent() {
                    rewardedAd = null
                    onAdDismissed()
                    // Yeni reklam yükle
                    loadAd()
                }

                override fun onAdFailedToShowFullScreenContent(error: AdError) {
                    rewardedAd = null
                    onAdShowFailed(error.message)
                }

                override fun onAdShowedFullScreenContent() {
                    // Reklam gösterildi
                }
            }

            rewardedAd?.show(activity) { reward ->
                // Kullanıcı ödülü kazandı
                onUserEarnedReward(reward.amount, reward.type)
            }
        } else {
            onAdShowFailed("Reklam henüz yüklenmedi")
            loadAd()
        }
    }

    fun isAdReady(): Boolean = rewardedAd != null
}