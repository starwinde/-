package com.starwinde.routinemon.usage

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.PackageManager

data class AppUsageData(val packageName: String, val totalTimeMs: Long)

class UsageStatsCollector(private val context: Context) {
    private val usageStatsManager =
        context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

    fun queryUsage(startTime: Long, endTime: Long): List<AppUsageData> {
        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)
        val lastResumed = mutableMapOf<String, Long>()
        val totalTime = mutableMapOf<String, Long>()

        val event = UsageEvents.Event()
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            val pkg = event.packageName
            when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED -> {
                    lastResumed[pkg] = event.timeStamp
                }
                UsageEvents.Event.ACTIVITY_PAUSED -> {
                    val resumed = lastResumed.remove(pkg) ?: continue
                    val duration = event.timeStamp - resumed
                    if (duration > 0) {
                        totalTime[pkg] = (totalTime[pkg] ?: 0L) + duration
                    }
                }
            }
        }
        return totalTime.map { (pkg, time) -> AppUsageData(pkg, time) }
    }

    fun getInstalledPackages(): List<String> {
        return context.packageManager
            .getInstalledApplications(PackageManager.GET_META_DATA)
            .map { it.packageName }
    }

    /// PackageManager.loadLabel 로 패키지명 → 사람 표시명 매핑.
    /// 미설치/조회 실패는 결과 Map 에서 제외 — 호출자가 fallback 처리.
    fun getAppLabels(packages: List<String>): Map<String, String> {
        val pm = context.packageManager
        val out = mutableMapOf<String, String>()
        for (pkg in packages) {
            try {
                val info = pm.getApplicationInfo(pkg, PackageManager.GET_META_DATA)
                val label = pm.getApplicationLabel(info).toString()
                if (label.isNotBlank()) out[pkg] = label
            } catch (_: PackageManager.NameNotFoundException) {
                // skip — fallback packageName at UI layer
            }
        }
        return out
    }
}
