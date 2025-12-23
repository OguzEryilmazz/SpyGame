package com.oguz.spy.ads

import android.app.Activity
import android.util.Log
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback

class InterstitialAdManager(
    private val adUnitId: String = AdIds.INTERSTITIAL_PROD
) {
    private var interstitialAd: InterstitialAd? = null
    private var isLoading = false
    private var adShowCount = 0 // Reklam gösterim sayacı

    // ✅ Her 2 tetiklemede bir reklam göster (spam önleme)
    private val showAdEveryNthTime = 2

    companion object {
        private const val TAG = "InterstitialAdManager"
    }

    fun loadAd(
        context: Activity,
        onAdLoaded: () -> Unit = {},
        onAdFailedToLoad: (String) -> Unit = {}
    ) {
        if (isLoading || interstitialAd != null) {
            Log.d(TAG, "Reklam zaten yükleniyor veya yüklenmiş")
            return
        }

        isLoading = true
        val adRequest = AdRequest.Builder().build()

        InterstitialAd.load(
            context,
            adUnitId,
            adRequest,
            object : InterstitialAdLoadCallback() {
                override fun onAdLoaded(ad: InterstitialAd) {
                    Log.d(TAG, "Interstitial reklam yüklendi")
                    interstitialAd = ad
                    isLoading = false
                    onAdLoaded()
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    Log.e(TAG, "Interstitial reklam yüklenemedi: ${error.message}")
                    interstitialAd = null
                    isLoading = false
                    onAdFailedToLoad(error.message)
                }
            }
        )
    }

    // ✅ Spam önlemeli gösterim
    fun showAdWithFrequencyControl(
        activity: Activity,
        onAdDismissed: () -> Unit = {},
        onAdShowFailed: (String) -> Unit = {}
    ) {
        adShowCount++

        // Her N tetiklemede bir göster
        if (adShowCount % showAdEveryNthTime != 0) {
            Log.d(TAG, "Reklam sıklık kontrolü: ${adShowCount % showAdEveryNthTime}/$showAdEveryNthTime")
            onAdDismissed()
            return
        }

        showAd(activity, onAdDismissed, onAdShowFailed)
    }

    fun showAd(
        activity: Activity,
        onAdDismissed: () -> Unit = {},
        onAdShowFailed: (String) -> Unit = {}
    ) {
        if (interstitialAd == null) {
            Log.d(TAG, "Interstitial reklam hazır değil")
            onAdShowFailed("Reklam henüz yüklenmedi")
            loadAd(activity) // Bir sonraki için yükle
            onAdDismissed() // Akışı devam ettir
            return
        }

        interstitialAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                Log.d(TAG, "Interstitial reklam kapatıldı")
                interstitialAd = null
                onAdDismissed()
                loadAd(activity) // Yeni reklam yükle
            }

            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                Log.e(TAG, "Interstitial reklam gösterilemedi: ${error.message}")
                interstitialAd = null
                onAdShowFailed(error.message)
                onAdDismissed() // Akışı devam ettir
                loadAd(activity) // Yeni reklam yükle
            }

            override fun onAdShowedFullScreenContent() {
                Log.d(TAG, "Interstitial reklam gösterildi")
            }

            override fun onAdClicked() {
                Log.d(TAG, "Interstitial reklama tıklandı")
            }

            override fun onAdImpression() {
                Log.d(TAG, "Interstitial reklam impression kaydedildi")
            }
        }

        interstitialAd?.show(activity)
    }

    fun isAdReady(): Boolean = interstitialAd != null

    fun resetCounter() {
        adShowCount = 0
    }

    fun destroy() {
        interstitialAd = null
    }
}