package com.starwinde.routinemon.service

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.starwinde.routinemon.usage.UsageStatsCollector
import org.json.JSONArray
import org.json.JSONObject

class FocusForegroundService : Service() {
    private lateinit var collector: UsageStatsCollector
    private var isRunning = false

    override fun onCreate() {
        super.onCreate()
        collector = UsageStatsCollector(this)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = buildNotification()
        startForeground(NOTIFICATION_ID, notification)
        isRunning = true
        startPolling()
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        isRunning = false
        super.onDestroy()
    }

    private fun startPolling() {
        val handler = android.os.Handler(mainLooper)
        val runnable = object : Runnable {
            override fun run() {
                if (!isRunning) return
                pollUsageStats()
                handler.postDelayed(this, POLL_INTERVAL_MS)
            }
        }
        handler.post(runnable)
    }

    private fun pollUsageStats() {
        val now = System.currentTimeMillis()
        val oneMinuteAgo = now - POLL_INTERVAL_MS
        val usage = collector.queryUsage(oneMinuteAgo, now)

        // Background cache: accumulate usage into SharedPreferences as JSON.
        // Dart side merges this into Drift when app returns to foreground.
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val existing = prefs.getString(KEY_CACHED_USAGE, "[]") ?: "[]"
        val array = JSONArray(existing)
        for (data in usage) {
            val obj = JSONObject()
            obj.put("packageName", data.packageName)
            obj.put("totalTimeMs", data.totalTimeMs)
            obj.put("timestamp", now)
            array.put(obj)
        }
        prefs.edit().putString(KEY_CACHED_USAGE, array.toString()).apply()
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID, "Focus Session", NotificationManager.IMPORTANCE_LOW
        ).apply { description = "Tracking focus session" }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Routinemon")
            .setContentText("Focus session in progress...")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setOngoing(true)
            .build()
    }

    companion object {
        const val NOTIFICATION_ID = 1001
        const val CHANNEL_ID = "focus_session"
        const val POLL_INTERVAL_MS = 60_000L
        const val PREFS_NAME = "focus_bg_cache"
        const val KEY_CACHED_USAGE = "cached_usage"
    }
}
