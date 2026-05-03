# 04 — 모델 + 서비스 Path A 통합

Status: done
의존성: 02, 03
관련 ADR: 0001 (이 이슈 진행 직전 머지 권장, `/grill-with-docs`)
완료: 2026-05-03 — WizardSource.rule + EnhanceObjective + 모든 신규 필드 추가, generate() Path A 통합 (LLM 호출 0건), conflict detect 자동, refine() 기존 동작 유지. 134/134 schedule PASS, 0 warning.

## 목적

도메인 모듈 (Issue 02/03) 을 데이터 계층에 통합. `WeeklyWizardService.generate()` 가 LLM 호출 전 Path A 를 실행하고 conflict 를 자동 첨부. 기존 preview UI 는 깨지지 않게 (회귀 0).

## 변경/신규 파일

### 수정
- `lib/features/schedule/data/wizard_models.dart`
- `lib/features/schedule/data/weekly_wizard_service.dart`
- `test/features/schedule/data/weekly_wizard_service_test.dart`

### 신규
- (없음 — 기존 파일 확장)

### 자동 생성 (build_runner)
- `lib/features/schedule/data/wizard_models.freezed.dart`
- `lib/features/schedule/data/wizard_models.g.dart`

## 설계 메모

### wizard_models.dart 변경

```dart
enum WizardSource {
  @JsonValue('rule') rule,           // 신규
  @JsonValue('llm') llm,
  @JsonValue('preset') preset,
}

@freezed
sealed class GeneratedScheduleItem with _$GeneratedScheduleItem {
  const factory GeneratedScheduleItem({
    required String title,
    @JsonKey(name: 'day_of_week') required int dayOfWeek,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    @JsonKey(fromJson: _catFromJson, toJson: _catToJson)
    required ScheduleCategory category,
    @Default([]) List<String> tags,
    @Default(WizardSource.rule) WizardSource source,    // 신규
    double? confidence,                                   // 신규 (선택)
  }) = _GeneratedScheduleItem;
  // ...
}

@freezed
sealed class WeeklyWizardResponse with _$WeeklyWizardResponse {
  const factory WeeklyWizardResponse({
    required List<GeneratedScheduleItem> items,
    required WizardSource source,
    @JsonKey(name: 'followup_questions')
    @Default(<FollowupQuestion>[]) List<FollowupQuestion> followupQuestions,
    @Default(<ConflictReport>[]) List<ConflictReport> conflicts,   // 신규
    @JsonKey(name: 'diff_summary') String? diffSummary,           // 신규
    @JsonKey(name: 'conversation_id') String? conversationId,     // 신규
    @Default(0) int turn,                                          // 신규
    @Default(<String>[]) List<String> warnings,                    // 신규 (Path A fixedSchedules 파싱 실패 등)
  }) = _WeeklyWizardResponse;
  // ...
}
```

### weekly_wizard_service.dart 변경

```dart
class WeeklyWizardService {
  WeeklyWizardService(
    this._client,
    this._aggregator,
    this._planner,           // 신규: RuleBasedPlanner
    this._conflictDetector,  // 신규: ScheduleConflictDetector
    this._existingFetcher,   // 신규: 기존 schedules 페치 (Issue 05 에서 wired)
  );

  // generate(): Path A 만 실행 (LLM 비활성, mode=initial 분기는 Issue 06 에서 추가)
  Future<WeeklyWizardResponse> generate({
    required WizardAnswers answers,
    required DateTime weekStart,
    String? userId,
  }) async {
    final enriched = await _withPastContext(answers, userId);
    final planResult = _planner.plan(answers: enriched, weekStart: weekStart);
    final existing = await _existingFetcher(userId, weekStart);  // 같은 주 schedules
    final awake = AwakeWindow.resolve(
      enriched.wakeTime, enriched.sleepTime, enriched.chronotype,
    );
    final conflicts = _conflictDetector.detect(
      proposed: planResult.items,
      existingThisWeek: existing,
      awake: awake,
      weekStart: weekStart,
    );
    return WeeklyWizardResponse(
      items: planResult.items,
      source: WizardSource.rule,
      conflicts: conflicts,
      warnings: planResult.warnings,
    );
  }

  // refine() 은 기존 방식 유지 (Issue 06 에서 enhance 와 통합 재설계)
  // _post() / _preset() 은 그대로 (Issue 06 에서 retry 추가)
}
```

`_existingFetcher` 는 `ScheduleRepository.snapshotForWeek(userId, weekStart)` 같은 새 메서드 또는 inline closure. Issue 05 에서 UI 와 wire.

## DoD

- [ ] wizard_models.dart 신규 필드 추가 + freezed/json_serializable 빌드 통과
- [ ] `WizardSource.rule` enum 값 추가
- [ ] `WeeklyWizardService.generate()` 가 Path A → conflict detect → response 반환 (LLM 미호출)
- [ ] 기존 wizard preview 가 동작 (manual smoke 또는 widget 테스트)
- [ ] `weekly_wizard_service_test.dart` "Path A only" 케이스 ≥ 5 (정상 / fixedSchedules 파싱 실패 / pastWeek 보정 / EXISTING_OVERLAP 1건 / 빈 existing)
- [ ] `flutter test` 회귀 0건 (기존 12+ 테스트 유지)
- [ ] `flutter analyze` 0 warning
- [ ] `dart run build_runner build --delete-conflicting-outputs` 결과물 커밋

## 검증

- 빌드 후 회귀 테스트 우선 (`flutter test test/features/schedule/`)
- 신규 케이스 추가 후 다시 통과
