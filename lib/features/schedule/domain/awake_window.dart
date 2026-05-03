// Pure Dart. Framework imports 금지 (rules.md §3.3).
// (WakeTime × SleepTime × Chronotype) → 깨어있는 시간 윈도우 결정론 매핑.
// ADR 0001 (rule-based default) 의 핵심 입력 모듈.
import 'package:routinemon/features/schedule/domain/lifestyle_enums.dart';

class AwakeWindow {
  const AwakeWindow({required this.startMinute, required this.endMinute});

  factory AwakeWindow.resolve(
    WakeTime wake,
    SleepTime sleep,
    Chronotype chrono,
  ) {
    return AwakeWindow(
      startMinute: _resolveStart(wake, chrono),
      endMinute: _resolveEnd(sleep, chrono),
    );
  }

  /// 0~1439 (자정 0:00 = 0)
  final int startMinute;

  /// startMinute 보다 큼. 자정 넘김 시 > 1440 (e.g., 01:30 다음날 = 1530).
  final int endMinute;

  /// [minuteOfDay] 가 윈도우 안에 있는지.
  /// 자정 넘김 윈도우에서 다음날 시각을 검사할 때 [treatAsNextDay] = true.
  bool contains(int minuteOfDay, {bool treatAsNextDay = false}) {
    final m = treatAsNextDay ? minuteOfDay + 24 * 60 : minuteOfDay;
    return m >= startMinute && m < endMinute;
  }

  int get durationMinutes => endMinute - startMinute;
}

int _resolveStart(WakeTime wake, Chronotype chrono) {
  switch (wake) {
    case WakeTime.early57:
      return _byChrono(
        chrono,
        morning: 6 * 60,
        middle: 6 * 60 + 30,
        evening: 7 * 60,
      );
    case WakeTime.morning79:
      return _byChrono(
        chrono,
        morning: 7 * 60,
        middle: 7 * 60 + 30,
        evening: 8 * 60 + 30,
      );
    case WakeTime.late911:
      return _byChrono(
        chrono,
        morning: 9 * 60,
        middle: 10 * 60,
        evening: 10 * 60 + 30,
      );
    case WakeTime.variable:
      return _byChrono(
        chrono,
        morning: 7 * 60,
        middle: 8 * 60,
        evening: 10 * 60,
      );
  }
}

int _resolveEnd(SleepTime sleep, Chronotype chrono) {
  switch (sleep) {
    case SleepTime.early2123:
      return _byChrono(
        chrono,
        morning: 22 * 60,
        middle: 22 * 60 + 30,
        evening: 23 * 60,
      );
    case SleepTime.midnight231:
      return _byChrono(
        chrono,
        morning: 23 * 60 + 30,
        middle: 24 * 60,
        evening: 24 * 60 + 30,
      );
    case SleepTime.late13:
      return _byChrono(
        chrono,
        morning: 25 * 60,
        middle: 25 * 60 + 30,
        evening: 26 * 60 + 30,
      );
    case SleepTime.variable:
      return _byChrono(
        chrono,
        morning: 23 * 60,
        middle: 24 * 60,
        evening: 25 * 60,
      );
  }
}

int _byChrono(
  Chronotype chrono, {
  required int morning,
  required int middle,
  required int evening,
}) {
  switch (chrono) {
    case Chronotype.morning:
      return morning;
    case Chronotype.middle:
      return middle;
    case Chronotype.evening:
      return evening;
  }
}
