package com.starwinde.routinemon.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * 활성 일정 동안 시스템 알림 영역에 sticky 알림을 띄우는 foreground service.
 *
 * USB 연결 알림과 동일 패턴 — `setOngoing(true)` 로 사용자가 swipe 로 못
 * 지우게 하고, foreground service 가 살아있는 동안 notification 도 유지.
 *
 * 호출 흐름:
 * - [start] / [update] — Dart 측 ScheduleSessionTrigger 가 활성 일정 감지/
 *   갱신 시. extras 로 title/subtitle 전달 → onStartCommand 가 NotificationManager.notify()
 *   재호출하여 콘텐츠만 새로 그림 (서비스 재기동 없음).
 * - [stop] — 일정 종료 시.
 *
 * 채널 IMPORTANCE_LOW — 소리/진동 없이 sticky 표시판 성격 (USB 알림과 동일).
 */
class ScheduleForegroundService : Service() {

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val title = intent?.getStringExtra(EXTRA_TITLE) ?: "일정 진행 중"
        val subtitle = intent?.getStringExtra(EXTRA_SUBTITLE) ?: ""
        val notification = buildNotification(title, subtitle)
        startForeground(NOTIFICATION_ID, notification)
        // 같은 ID 로 다시 notify 하면 콘텐츠만 갱신 (사용자가 보는 알림 자체는 그대로 유지).
        getSystemService(NotificationManager::class.java)
            .notify(NOTIFICATION_ID, notification)
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "일정 진행",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "현재 진행 중인 일정을 표시합니다 (지울 수 없는 알림)"
            setShowBadge(false)
        }
        getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }

    private fun buildNotification(title: String, subtitle: String): Notification {
        // 알림 탭 시 앱 launch.
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?.apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK }
        val pendingIntent = launchIntent?.let {
            PendingIntent.getActivity(
                this,
                0,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(subtitle)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setOngoing(true) // swipe 로 못 지움 (USB 알림과 동일).
            .setShowWhen(false)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .build()
    }

    companion object {
        const val NOTIFICATION_ID = 1003
        const val CHANNEL_ID = "schedule_active"
        const val EXTRA_TITLE = "title"
        const val EXTRA_SUBTITLE = "subtitle"

        fun start(context: Context, title: String, subtitle: String) {
            val intent = Intent(context, ScheduleForegroundService::class.java)
                .putExtra(EXTRA_TITLE, title)
                .putExtra(EXTRA_SUBTITLE, subtitle)
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, ScheduleForegroundService::class.java)
            context.stopService(intent)
        }
    }
}
