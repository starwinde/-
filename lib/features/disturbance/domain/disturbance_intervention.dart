/// 일정별 방해 허용(T5.21) 강도. 1=L1, 2=L2, 3=L3.
enum DisturbanceLevel {
  /// L1: 짧은 진동 + 검은 풀스크린 오버레이.
  l1,

  /// L2: 진동 + 차단 다이얼로그 + 홈 강제 이동.
  l2,

  /// L3: 강한 진동 + 풀스크린 차단 + 주기적 화면 잠금 (DEVICE_ADMIN).
  l3;

  /// Drift int 컬럼 → enum 변환 (1/2/3, 그 외는 L1로 안전 디폴트).
  static DisturbanceLevel fromInt(int value) {
    switch (value) {
      case 2:
        return DisturbanceLevel.l2;
      case 3:
        return DisturbanceLevel.l3;
      default:
        return DisturbanceLevel.l1;
    }
  }
}

/// 강도별 권장 액션 (Pigeon 호출 매개변수 + UI 표시 힌트).
class DisturbanceAction {
  /// Const 생성자.
  const DisturbanceAction({
    required this.vibrateMs,
    this.blackOverlayMs = 0,
    this.blockDialog = false,
    this.launchHome = false,
    this.blockOverlay = false,
    this.periodicSec = 0,
    this.periodicVibrateMs = 0,
    this.periodicVibrateSec = 0,
    this.periodicLaunchHome = false,
    this.periodicLockDevice = false,
  });

  /// 진동 길이 (ms).
  final int vibrateMs;

  /// L1: 검은 오버레이 표시 시간 (ms). 0이면 표시 안 함.
  final int blackOverlayMs;

  /// L2: 차단 다이얼로그 + 홈 이동 카운트다운.
  final bool blockDialog;

  /// L2/L3: 홈으로 강제 이동.
  final bool launchHome;

  /// L3: 풀스크린 차단 오버레이.
  final bool blockOverlay;

  /// 반복 주기 (초). 0이면 반복 동작 없음.
  final int periodicSec;

  /// 반복 시 진동 길이 (ms). 0이면 진동 안 함.
  final int periodicVibrateMs;

  /// 진동 반복 주기 (초). 0이면 [periodicSec] 와 동일 주기로 동작.
  final int periodicVibrateSec;

  /// 반복 시 홈으로 강제 이동.
  final bool periodicLaunchHome;

  /// 반복 시 화면 잠금 (DEVICE_ADMIN.lockNow).
  final bool periodicLockDevice;
}

/// 일정 진행 중 적극적 기기 사용 감지 시 강도별 액션을 결정한다.
/// 동일 일정 내 30초 1회 쿨다운 (PRD §2.8 방해 허용).
class DisturbanceIntervention {
  /// 기본 쿨다운: 30초.
  static const Duration cooldown = Duration(seconds: 30);

  DateTime? _lastEventTime;

  /// 활성 사용 감지 시점 [now]에 [level] 강도로 호출. 쿨다운에 걸리면
  /// `null`을 반환한다. 그 외에는 강도별 액션을 반환하고 쿨다운 시작.
  DisturbanceAction? onActiveUsage(DateTime now, DisturbanceLevel level) {
    final last = _lastEventTime;
    if (last != null && now.difference(last) < cooldown) return null;
    _lastEventTime = now;
    switch (level) {
      case DisturbanceLevel.l1:
        return const DisturbanceAction(
          vibrateMs: 200,
          blackOverlayMs: 5000,
          periodicSec: 60,
          periodicVibrateMs: 200,
          periodicVibrateSec: 20,
        );
      case DisturbanceLevel.l2:
        return const DisturbanceAction(
          vibrateMs: 500,
          blockDialog: true,
          launchHome: true,
          periodicSec: 60,
          periodicVibrateMs: 500,
          periodicVibrateSec: 20,
          periodicLaunchHome: true,
        );
      case DisturbanceLevel.l3:
        return const DisturbanceAction(
          vibrateMs: 1000,
          blockOverlay: true,
          launchHome: true,
          periodicSec: 30,
          periodicVibrateMs: 800,
          periodicVibrateSec: 10,
          periodicLockDevice: true,
        );
    }
  }

  /// 새 일정 진입 시 쿨다운 초기화.
  void resetForNewSchedule() {
    _lastEventTime = null;
  }
}
