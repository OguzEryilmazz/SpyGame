package com.oguz.spy.platform

import android.view.WindowManager
import androidx.activity.ComponentActivity

object ScreenHelper {

    fun keepScreenOn(activity: ComponentActivity) {
        activity.window?.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    fun allowScreenOff(activity: ComponentActivity) {
        activity.window?.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
}
