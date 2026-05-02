import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/native/disturbance_api.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/com/starwinde/routinemon/DisturbanceApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.starwinde.routinemon',
      errorClassName: 'DisturbanceFlutterError',
    ),
  ),
)

/// Native disturbance API (T5.21 일정별 방해 허용).
@HostApi()
abstract class DisturbanceApi {
  /// Vibrate for [durationMs]. [amplitude] is 1..255 (-1 = default).
  void vibrate(int durationMs, int amplitude);

  /// Send the user to the home screen (Intent ACTION_MAIN/CATEGORY_HOME).
  void launchHome();

  /// Whether the routinemon DeviceAdminReceiver is currently active.
  bool isDeviceAdminActive();

  /// Launch the system intent to grant DEVICE_ADMIN to routinemon.
  void requestDeviceAdmin();

  /// Lock the screen via DevicePolicyManager.lockNow().
  /// No-op when DEVICE_ADMIN is not active.
  void lockDevice();

  /// Start a lightweight foreground service so the process is not killed
  /// while the disturbance schedule is active. Idempotent.
  void startDisturbanceService();

  /// Stop the disturbance foreground service. Idempotent.
  void stopDisturbanceService();

  /// SYSTEM_ALERT_WINDOW (다른 앱 위에 표시) 권한 부여 여부.
  /// L2/L3 launchHome BAL 우회에 필수.
  bool isOverlayPermissionGranted();

  /// "다른 앱 위에 표시" 시스템 설정 화면을 연다.
  void requestOverlayPermission();

  /// 배터리 최적화 제외 여부 (process 안정성 확보).
  bool isBatteryOptimizationIgnored();

  /// 배터리 최적화 제외 요청 시스템 설정을 연다.
  void requestBatteryOptimizationExemption();

  /// POST_NOTIFICATIONS 권한 부여 여부 (Android 13+).
  bool isNotificationPermissionGranted();

  /// 앱 알림 설정 화면을 연다.
  void openNotificationSettings();

  /// L1 검은 풀스크린 오버레이 표시. SYSTEM_ALERT_WINDOW 권한 필수.
  /// [durationMs] 후 자동 해제.
  void showBlackOverlay(int durationMs);

  /// L2 차단 다이얼로그 (반투명 중앙). [countdownSec] 후 자동 해제.
  void showBlockDialog(int countdownSec);

  /// L3 풀스크린 차단 오버레이. dismissOverlay 호출 전까지 유지.
  void showBlockFullscreen();

  /// 현재 표시된 disturbance 오버레이를 즉시 해제.
  void dismissOverlay();
}
