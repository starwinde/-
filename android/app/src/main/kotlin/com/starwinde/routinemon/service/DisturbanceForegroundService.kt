package com.starwinde.routinemon.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * Lightweight foreground service that keeps the routinemon process alive while
 * a schedule with disruption allowance is running, and acts as a BAL-safe
 * launcher for `Intent.ACTION_MAIN/CATEGORY_HOME` redirects (T5.21).
 *
 * Android 12+ blocks background `startActivity` calls from a paused activity
 * (BAL policy). A foreground service is exempt from BAL while it is in the
 * STARTED state, so we route `launchHome` requests through this service.
 */
class DisturbanceForegroundService : Service() {

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, buildNotification())
        if (intent?.getBooleanExtra(EXTRA_LAUNCH_HOME, false) == true) {
            launchHomeFromService()
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun launchHomeFromService() {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "방해 허용",
            NotificationManager.IMPORTANCE_LOW
        ).apply { description = "일정 진행 중 방해 허용 동작 유지" }
        getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("루틴몬")
            .setContentText("일정 진행 중 — 방해 허용 활성")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setOngoing(true)
            .build()
    }

    companion object {
        const val NOTIFICATION_ID = 1002
        const val CHANNEL_ID = "disturbance_session"
        const val EXTRA_LAUNCH_HOME = "launchHome"

        fun start(context: Context) {
            val intent = Intent(context, DisturbanceForegroundService::class.java)
            context.startForegroundService(intent)
        }

        fun launchHome(context: Context) {
            val intent = Intent(context, DisturbanceForegroundService::class.java)
                .putExtra(EXTRA_LAUNCH_HOME, true)
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, DisturbanceForegroundService::class.java)
            context.stopService(intent)
        }
    }
}
