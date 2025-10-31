package com.oguz.spy.ux.components

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.oguz.spy.ads.BannerAdManager

@Composable
fun BannerAd(
    bannerAdManager: BannerAdManager,
    modifier: Modifier = Modifier
) {
    AndroidView(
        modifier = modifier.fillMaxWidth().height(50.dp),
        factory = { context ->
            bannerAdManager.createAdView(context)
        }
    )
}