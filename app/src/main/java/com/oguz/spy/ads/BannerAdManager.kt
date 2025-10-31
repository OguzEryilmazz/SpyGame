package com.oguz.spy.ads

import android.content.Context
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.LoadAdError

class BannerAdManager(
    private val adUnitId: String = AdIds.BANNER_TEST
) {
    private var adView: AdView? = null
    private var isLoading = false

    fun createAdView(
        context: Context,
        onAdLoaded: () -> Unit = {},
        onAdFailedToLoad: (String) -> Unit = {},
        onAdOpened: () -> Unit = {},
        onAdClosed: () -> Unit = {}
    ): AdView {
        adView?.let { return it }

        // Yeni adView oluştur VE AYARLARI YAP
        val newAdView = AdView(context).apply {
            setAdSize(AdSize.BANNER)
            adUnitId = this@BannerAdManager.adUnitId

            adListener = object : AdListener() {
                override fun onAdLoaded() {
                    this@BannerAdManager.isLoading = false
                    onAdLoaded()
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    this@BannerAdManager.isLoading = false
                    onAdFailedToLoad(error.message)
                }

                override fun onAdOpened() {
                    onAdOpened()
                }

                override fun onAdClosed() {
                    onAdClosed()
                }

                override fun onAdClicked() {
                    // Reklama tıklandı
                }

                override fun onAdImpression() {
                    // Reklam görüntülendi
                }
            }
        }

        adView = newAdView
        return newAdView
    }

    fun loadAd() {
        val currentAdView = adView
        if (isLoading || currentAdView == null) return

        isLoading = true
        val adRequest = AdRequest.Builder().build()
        currentAdView.loadAd(adRequest)
    }

    fun pause() {
        adView?.pause()
    }

    fun resume() {
        adView?.resume()
    }

    fun destroy() {
        adView?.destroy()
        adView = null
    }

    fun isAdLoaded(): Boolean = adView != null
}