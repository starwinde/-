# 02 — RuleBasedPlanner (Path A)

Status: done
의존성: 01
관련 ADR: 0001
완료: 2026-05-03 — 결정론 38/38 PASS, items ∈ [10,18] (모든 status×workDays×goal 매트릭스), no overlap, fixedSchedules 한국어/영어 정규식 + warnings, pastWeek 보정.

## 목적

Path A 의 핵심: WizardAnswers → 결정론 알고리즘 → `List<GeneratedScheduleItem>`. LLM 호출 0건. 동기 ≤ 50ms. 동일 입력 → 동일 출력.

## 변경/신규 파일

- `lib/features/schedule/domain/rule_based_planner.dart` (신규)
- `test/features/schedule/domain/rule_based_planner_test.dart` (신규)

## 설계 메모

```dart
class RuleBasedPlanner {
  const RuleBasedPlanner();
  
  RuleBasedPlanResult plan({
    required WizardAnswers answers,
    required DateTime weekStart,  // 월요일
  });
}

class RuleBasedPlanResult {
  final List<GeneratedScheduleItem> items;  // source = WizardSource.rule
  final List<String> warnings;  // fixedSchedules 파싱 실패 등
}
```

### 알고리즘 단계

1. `awake_window.resolve(wakeTime, sleepTime, chronotype)`
2. `_resolveWorkdaySet(workDays)` → Set<int> (0=월, 6=일)
3. `_resolveWorkWindow(workHours, focusTime)` → (startMin, endMin)
4. `_placeMeals(mealPattern, awake)` → List<Slot>
5. `_placeWork(workdays, workWindow, status)` — homemaker/retired skip
6. `_placeCommute(commuteTime, workWindow)` — noCommute/null skip
7. `_placeFocusBlocks(focusTime, goalFocus, awake, workWindow)` — work_study 가중치
8. `_placeExercise(exercise, exercisePreferredTime, awake, workWindow)` — none skip
9. `_placeHobby(hobby, freeTime, awake, workWindow)` — none skip
10. `_labelCategory(slots, goalFocus)` → ScheduleCategory 매핑
11. `_resolveOverlap(slots)` 인라인 (작은 우선순위 슬롯을 ±15분 이동, 실패 시 drop)
12. `_parseFixedSchedules(answers.fixedSchedules)` 정규식 best-effort
13. `_applyPastWeekContext(slots, pastWeekContext)` — completion < 0.5 면 30% drop (low priority 부터)
14. `_sortByDayThenStart(slots)` → `GeneratedScheduleItem[]` 변환

### fixedSchedules 정규식 (한국어/영어 best-effort)

- `(월|화|수|목|금|토|일|Mon|Tue|...)\s*(\d{1,2}):?(\d{0,2})\s*(시|시간|h|hr)?`
- 매칭 실패 시 `warnings` 에 `"파싱 실패: <원문>"` append, 무시하고 진행

## DoD

- [ ] `RuleBasedPlanner.plan()` 결정론 (동일 입력 → 동일 items list, ordering 포함)
- [ ] LifestyleStatus × WorkDays × GoalFocus 매트릭스 샘플 (≥ 10) 모두 items.length ∈ [10, 18]
- [ ] 자기 자신 시간 겹침 0건 (모든 테스트 케이스에서 검증)
- [ ] `fixedSchedules = "월/수 18시 PT 1시간"` 파싱 → 해당 슬롯 superimpose 성공
- [ ] `fixedSchedules` 파싱 실패 입력 → warnings 에 메시지, 다른 일정은 정상
- [ ] `pastWeekContext.weeklyCompletionRate = 0.3` → items 30% 감소 + low priority 우선 drop
- [ ] 단위 테스트 ≥ 20 (상태별/요일별/목표별 분포 + fixedSchedules 양/음성 + pastWeek 보정 + 결정론)
- [ ] `flutter analyze` 0 warning
- [ ] 50ms 이내 실행 (`Stopwatch` 측정 1 케이스)

## 검증

- TDD red-green-refactor
- 회귀 0건 (`flutter test`)
