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
}
