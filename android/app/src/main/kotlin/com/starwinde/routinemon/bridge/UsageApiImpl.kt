package com.starwinde.routinemon.bridge

import android.content.Context
import com.starwinde.routinemon.AppUsageInfo
import com.starwinde.routinemon.UsageApi
import com.starwinde.routinemon.permissions.UsageAccessPermission
import com.starwinde.routinemon.usage.UsageStatsCollector

class UsageApiImpl(private val context: Context) : UsageApi {
    private val permission = UsageAccessPermission(context)
    private val collector = UsageStatsCollector(context)

    override fun hasUsagePermission(): Boolean = permission.hasPermission()

    override fun openUsageSettings() = permission.openSettings()

    override fun queryUsageStats(startTime: Long, endTime: Long): List<AppUsageInfo> {
        return collector.queryUsage(startTime, endTime).map { data ->
            AppUsageInfo(
                packageName = data.packageName,
                totalTimeInForeground = data.totalTimeMs,
            )
        }
    }

    override fun getInstalledPackages(): List<String> = collector.getInstalledPackages()
}
