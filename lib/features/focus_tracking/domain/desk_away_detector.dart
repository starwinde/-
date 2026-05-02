/// 책상 이탈 감지 시 HP 패널티를 계산하는 순수 Dart 로직.
/// domain layer — framework import 금지 (rules.md §3.3).
///
/// Codex 확정 수치:
/// - HP -3/회
/// - 30분 쿨다운
/// - 일일 max -9
class DeskAwayDetector {
  static const int _penaltyPerEvent = 3;
  static const int _maxDailyLoss = 9;
  static const Duration _cooldown = Duration(minutes: 30);

  DateTime? _lastEventTime;
  int _dailyHpLoss = 0;

  /// 누적 일일 HP 손실량 (양수).
  int get dailyHpLoss => _dailyHpLoss;

  /// 이탈 감지 이벤트 발생 시 호출.
  /// HP 패널티를 반환한다 (0 또는 음수).
  int onDeskAway(DateTime now) {
    // 일일 max 체크
    if (_dailyHpLoss >= _maxDailyLoss) return 0;

    // 쿨다운 체크
    if (_lastEventTime != null &&
        now.difference(_lastEventTime!) < _cooldown) {
      return 0;
    }

    _lastEventTime = now;
    _dailyHpLoss += _penaltyPerEvent;
    return -_penaltyPerEvent;
  }

  /// 일일 리셋. 자정 또는 일일 정산 시 호출.
  void resetDaily() {
    _dailyHpLoss = 0;
    _lastEventTime = null;
  }
}
