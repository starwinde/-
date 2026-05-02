/// 블랙리스트 앱 실행 횟수에 따른 단계별 개입 수준.
/// domain layer — framework import 금지 (rules.md §3.3).
///
/// REQUIREMENTS_DRAFT §H / PRD §2.4:
/// - 1회: 부드러운 알림 (notification)
/// - 3회: 팝업 (popup)
/// - 5회: 전체화면 경고 (fullscreen)
enum InterventionLevel {
  /// 개입 없음.
  none,

  /// 부드러운 알림 (1~2회).
  notification,

  /// 팝업 경고 (3~4회).
  popup,

  /// 전체화면 경고 (5회 이상).
  fullscreen,
}

/// 블랙리스트 앱 열림 횟수를 추적하고 개입 수준을 결정하는 순수 Dart 로직.
class BlacklistIntervention {
  int _openCount = 0;

  /// 현재 열림 횟수.
  int get openCount => _openCount;

  /// 블랙리스트 앱이 열렸을 때 호출.
  /// 현재 횟수에 맞는 [InterventionLevel]을 반환한다.
  InterventionLevel onBlacklistAppOpened() {
    _openCount++;
    if (_openCount >= 5) return InterventionLevel.fullscreen;
    if (_openCount >= 3) return InterventionLevel.popup;
    return InterventionLevel.notification;
  }

  /// 세션 리셋. 집중 시간대 종료 시 호출.
  void resetSession() {
    _openCount = 0;
  }
}
