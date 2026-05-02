package com.starwinde.routinemon.admin

import android.app.admin.DeviceAdminReceiver

/**
 * DeviceAdminReceiver for T5.21 (일정별 방해 허용 L3 화면 잠금).
 *
 * Required by [android.app.admin.DevicePolicyManager.lockNow]. The user
 * must grant device-admin in system settings; the app prompts via
 * `DisturbanceApi.requestDeviceAdmin()`.
 *
 * The only policy declared in `res/xml/device_admin.xml` is `force-lock`,
 * which permits `lockNow()` only — the app cannot wipe data, change
 * passwords, or take any other admin action.
 */
class RoutinemonDeviceAdminReceiver : DeviceAdminReceiver()
