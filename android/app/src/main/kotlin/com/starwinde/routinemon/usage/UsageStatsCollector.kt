package com.starwinde.routinemon.usage

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
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

    /// 현재 디폴트로 설정된 런처 패키지 (1개) + 사용자가 설치한 다른 런처들.
    ///
    /// Samsung 일부 펌웨어는 `com.android.settings` 가 `CATEGORY_HOME` fallback
    /// 으로 등록되어 있고 `ACTIVITY_HAS_DEFAULT` 까지 갖고 있어
    /// `queryIntentActivities + MATCH_DEFAULT_ONLY` 만으로는 못 거름.
    /// `resolveActivity` 가 OS 에게 "현재 사용자가 쓰는 launcher 한 개" 를
    /// 물어보는 정공법 — fallback 자동 제외됨.
    ///
    /// 추가로 사용자가 깔아둔 다른 launcher 후보는 queryIntentActivities 로
    /// 가져와서 합집합. (사용자가 Nova/Niagara 등을 설치하고 가끔 쓸 수 있음)
    /// Samsung 의 settings fallback 만 명시 제외.
    fun getLauncherPackages(): List<String> {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }
        val pm = context.packageManager
        val result = mutableSetOf<String>()

        pm.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
            ?.activityInfo
            ?.packageName
            ?.let(result::add)

        pm.queryIntentActivities(intent, 0)
            .map { it.activityInfo.packageName }
            .filter { it != "com.android.settings" }
            .forEach(result::add)

        return result.toList()
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
