package com.oguz.spy.domain

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class TimerManager {

    fun startCountdown(durationInSeconds: Int): Flow<TimerState> = flow {
        var timeLeft = durationInSeconds

        while (timeLeft > 0) {
            val progress = timeLeft.toFloat() / durationInSeconds
            val minutes = timeLeft / 60
            val seconds = timeLeft % 60
            val formattedTime = String.format("%02d:%02d", minutes, seconds)

            val warningLevel = when {
                timeLeft <= 10 -> WarningLevel.CRITICAL
                timeLeft <= 30 -> WarningLevel.WARNING
                else -> WarningLevel.NORMAL
            }

            emit(
                TimerState(
                    timeLeft = timeLeft,
                    formattedTime = formattedTime,
                    progress = progress,
                    isFinished = false,
                    warningLevel = warningLevel
                )
            )

            delay(1000L)
            timeLeft--
        }

        emit(
            TimerState(
                timeLeft = 0,
                formattedTime = "00:00",
                progress = 0f,
                isFinished = true,
                warningLevel = WarningLevel.FINISHED
            )
        )
    }

    fun formatTime(totalSeconds: Int): String {
        val minutes = totalSeconds / 60
        val seconds = totalSeconds % 60
        return String.format("%02d:%02d", minutes, seconds)
    }

    fun getTimeWarningLevel(timeLeft: Int): WarningLevel {
        return when {
            timeLeft <= 0 -> WarningLevel.FINISHED
            timeLeft <= 10 -> WarningLevel.CRITICAL
            timeLeft <= 30 -> WarningLevel.WARNING
            else -> WarningLevel.NORMAL
        }
    }

    data class TimerState(
        val timeLeft: Int,
        val formattedTime: String,
        val progress: Float,
        val isFinished: Boolean,
        val warningLevel: WarningLevel
    )

    enum class WarningLevel {
        NORMAL,
        WARNING,
        CRITICAL,
        FINISHED
    }
}
