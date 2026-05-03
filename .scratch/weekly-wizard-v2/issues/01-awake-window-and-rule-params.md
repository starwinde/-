# 01 — Awake window + rule params 도메인 모듈

Status: done
의존성: 없음
관련 ADR: 0001 (Issue 04 직전 작성)
완료: 2026-05-03 — awake_window/lifestyle_enums/wizard_rule_params 신설, 단위 15 PASS, 회귀 0 (schedule 77/77).

## 목적

Path A 결정론 알고리즘의 기반 모듈. 깨어있는 시간 윈도우 해석과 튜닝 파라미터 단일 출처를 분리한다. 순수 Dart, framework import 0 (rules.md §3.3).

## 변경/신규 파일

- `lib/features/schedule/domain/awake_window.dart` (신규)
- `lib/features/schedule/domain/wizard_rule_params.dart` (신규)
- `test/features/schedule/domain/awake_window_test.dart` (신규)

## 설계 메모

### awake_window.dart

```dart
class AwakeWindow {
  final int startMinute;  // 0~1439 (24*60)
  final int endMinute;    // start 보다 클 수도, 다음날(>1440) 이어도 됨 (자정 넘김)
  AwakeWindow resolve(WakeTime, SleepTime, Chronotype);
  bool contains(int minuteOfDay);
  Duration get duration;
}
```

매핑 테이블 (예시):
- WakeTime.early57 + Chronotype.morning → startMinute = 6:00 (360)
- WakeTime.morning79 + Chronotype.middle → 7:30 (450)
- WakeTime.late911 + Chronotype.evening → 9:30 (570)
- WakeTime.variable → Chronotype 기준값 (morning=7, middle=8, evening=10)
- SleepTime.early2123 → endMinute = 22:30 (1350)
- SleepTime.midnight231 → 24:00 (1440)
- SleepTime.late13 → 25:30 (1530, 다음날 1:30)
- SleepTime.variable → Chronotype 기준값 (morning=23, middle=24, evening=25)

### wizard_rule_params.dart

`const` 상수 단일 출처:
- `kFocusBlockMinDeep = 90`, `kFocusBlockMinShallow = 45`
- `kMealDurationBreakfast = 30`, `kMealDurationLunch = 45`, `kMealDurationDinner = 60`
- `kExerciseDurationLight = 30`, `kExerciseDurationModerate = 45`, `kExerciseDurationDaily = 60`
- `kHobbyDurationWeekday = 90`, `kHobbyDurationWeekend = 120`
- `kMinBreakMin = 15`, `kMinBreakWorkToWork = 30`
- `kCategoryMonotonyN = 3`
- `kPastWeekLowThreshold = 0.5`, `kPastWeekReductionRatio = 0.7`

각 상수 위에 ADR 0001/0002 참조 주석.

## DoD

- [ ] `awake_window.dart` 가 (WakeTime, SleepTime, Chronotype) 9 종 조합 모두 deterministic 매핑
- [ ] `contains()` 가 자정 넘김 (endMinute > 1440) 정상 처리
- [ ] `wizard_rule_params.dart` 모든 const 정의 + ADR 0001/0002 참조 주석
- [ ] 단위 테스트 ≥ 12 (각 WakeTime × SleepTime 조합 + Chronotype variable + 경계 + duration 양수 검증 + contains 자정 넘김)
- [ ] `flutter analyze` 0 warning
- [ ] `flutter test test/features/schedule/domain/awake_window_test.dart` 100%

## 검증

- TDD red-green-refactor (테스트 먼저 → 최소 구현 → 리팩터)
- 다른 기존 테스트 회귀 0건 (`flutter test` 전체)
