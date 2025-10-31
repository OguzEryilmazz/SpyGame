package com.oguz.spy.app

import android.app.Application
import com.google.android.gms.ads.MobileAds

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // AdMob'u başlat
        MobileAds.initialize(this) {}
    }
}