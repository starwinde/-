package com.starwinde.routinemon.bridge

import android.annotation.SuppressLint
import android.app.NotificationManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import com.starwinde.routinemon.DisturbanceApi
import com.starwinde.routinemon.admin.RoutinemonDeviceAdminReceiver
import com.starwinde.routinemon.overlay.DisturbanceOverlayController
import com.starwinde.routinemon.service.DisturbanceForegroundService

/**
 * Native implementation of [DisturbanceApi] for T5.21 (일정별 방해 허용).
 *
 * - vibrate: VibrationEffect (Android 8+)
 * - launchHome: Intent ACTION_MAIN/CATEGORY_HOME
 * - lockDevice/requestDeviceAdmin/isDeviceAdminActive: DevicePolicyManager
 *
 * On Android, regular apps cannot force the screen off (`PowerManager.goToSleep`
 * is system-only) nor force-stop other apps (`forceStopPackage` is system-only).
 * The plan compensates with a black overlay (L1) and lock-now + home redirect
 * (L3); see plan file at ~/.claude/plans/concurrent-dancing-badger.md.
 */
class DisturbanceApiImpl(private val context: Context) : DisturbanceApi {

    private val overlay = DisturbanceOverlayController(context)

    private val dpm: DevicePolicyManager
        get() = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager

    private val adminComponent: ComponentName
        get() = ComponentName(context, RoutinemonDeviceAdminReceiver::class.java)

    @Suppress("DEPRECATION")
    private val vibrator: Vibrator
        get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager)
                .defaultVibrator
        } else {
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

    override fun vibrate(durationMs: Long, amplitude: Long) {
        if (durationMs <= 0) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val amp = if (amplitude in 1..255) amplitude.toInt() else VibrationEffect.DEFAULT_AMPLITUDE
            vibrator.vibrate(VibrationEffect.createOneShot(durationMs, amp))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(durationMs)
        }
    }

    override fun launchHome() {
        // BAL exempt path: foreground service performs startActivity on our
        // behalf so Android 12+ does not block the redirect when routinemon
        // itself is paused.
        DisturbanceForegroundService.launchHome(context)
    }

    override fun isDeviceAdminActive(): Boolean = dpm.isAdminActive(adminComponent)

    override fun requestDeviceAdmin() {
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
            putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
            putExtra(
                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "루틴몬이 일정 중 방해 강도 L3에서 화면을 잠가 집중을 보호합니다."
            )
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }

    override fun lockDevice() {
        if (!dpm.isAdminActive(adminComponent)) return
        try {
            dpm.lockNow()
        } catch (e: SecurityException) {
            // Admin was revoked between check and call — fail soft.
        }
    }

    override fun startDisturbanceService() {
        DisturbanceForegroundService.start(context)
    }

    override fun stopDisturbanceService() {
        DisturbanceForegroundService.stop(context)
    }

    override fun isOverlayPermissionGranted(): Boolean = Settings.canDrawOverlays(context)

    override fun requestOverlayPermission() {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${context.packageName}")
        ).apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK }
        context.startActivity(intent)
    }

    override fun isBatteryOptimizationIgnored(): Boolean {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(context.packageName)
    }

    @SuppressLint("BatteryLife")
    override fun requestBatteryOptimizationExemption() {
        val intent = Intent(
            Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
            Uri.parse("package:${context.packageName}")
        ).apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK }
        context.startActivity(intent)
    }

    override fun isNotificationPermissionGranted(): Boolean {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return nm.areNotificationsEnabled()
    }

    override fun openNotificationSettings() {
        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
            putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }

    override fun showBlackOverlay(durationMs: Long) {
        overlay.showBlack(durationMs)
    }

    override fun showBlockDialog(countdownSec: Long) {
        overlay.showBlockDialog(countdownSec.toInt())
    }

    override fun showBlockFullscreen() {
        overlay.showBlockFullscreen()
    }

    override fun dismissOverlay() {
        overlay.dismiss()
    }
}
