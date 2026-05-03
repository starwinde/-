# 06 — LLM Enhance (Path B) + 3-retry backoff

Status: in-progress
의존성: 04
관련 ADR: 0001
진행: 2026-05-03 — service.enhance() + 3-retry backoff(500/1500/3500ms ±20% jitter), 4xx 즉시 폴백, 5xx/timeout/parse-fail/empty items 재시도, EnhanceObjective enum 추가. 단위 8개 PASS. **Deferred**: (a) UI "AI 향상 (Pro)" 토글/Paywall — entitlementProvider 미구현(billing wiring 별도 이슈). (b) n8n 워크플로우 mode 분기 — JSON 수동 편집 필요. 코드 부분 DoD 만 충족 상태로 Issue 07 으로 이동.

## 목적

LLM 경로를 "AI 향상 (Pro)" 옵트인으로 분리. Path A seed 를 입력으로 받아 향상된 items + diff_summary 를 반환. rules.md §9.3 의 3-retry 정책을 정확히 이행.

## 변경/신규 파일

### 수정
- `lib/features/schedule/data/weekly_wizard_service.dart`
- `lib/features/schedule/data/wizard_models.dart` (EnhanceObjective enum 추가)
- `lib/features/schedule/presentation/wizard_preview_page.dart` (toggle + 호출)
- `n8n/workflows/routinemon-weekly-schedule-wizard.json` (mode 분기)
- `test/features/schedule/data/weekly_wizard_service_test.dart`

## 설계 메모

### EnhanceObjective enum

```dart
enum EnhanceObjective {
  @JsonValue('diversify_titles') diversifyTitles,
  @JsonValue('rebalance_load') rebalanceLoad,
  @JsonValue('add_recovery') addRecovery,
  @JsonValue('refine_categories') refineCategories,
}
```

### Service.enhance()

```dart
Future<WeeklyWizardResponse> enhance({
  required WizardAnswers answers,
  required DateTime weekStart,
  required List<GeneratedScheduleItem> seed,
  required EnhanceObjective objective,
  String? conversationId,
  int turn = 1,
  String? userId,
}) async {
  // Pro 게이트: 호출자 (UI) 가 entitlementProvider 검사 후 호출. service 는 신뢰.
  final enriched = await _withPastContext(answers, userId);
  final body = {
    'mode': 'enhance',
    'answers': enriched.toJson(),
    'week_start': _ymd(weekStart),
    'rule_based_seed': seed.map((i) => i.toJson()).toList(),
    'enhance_objective': _objToJson(objective),
    'conversation_id': conversationId ?? _newConversationId(),
    'turn': turn,
  };
  return _postWithRetry(body, fallback: () => _seedResponse(seed, conversationId, turn));
}
```

### Retry 정책 (`_postWithRetry`)

```dart
Future<WeeklyWizardResponse> _postWithRetry(
  Map<String, dynamic> body, {
  required WeeklyWizardResponse Function() fallback,
}) async {
  final delays = [Duration(milliseconds: 500), Duration(milliseconds: 1500), Duration(milliseconds: 3500)];
  for (var attempt = 0; attempt < 3; attempt++) {
    try {
      final response = await _client.post(_path, body: body);
      if (response.statusCode >= 400 && response.statusCode < 500) {
        // 4xx 즉시 폴백
        return fallback();
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await _backoff(delays[attempt]);
        continue;
      }
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = WeeklyWizardResponse.fromJson(json);
        if (parsed.items.isEmpty) {
          await _backoff(delays[attempt]);
          continue;
        }
        return parsed;
      } on FormatException {
        await _backoff(delays[attempt]);
        continue;
      }
    } on TimeoutException {
      await _backoff(delays[attempt]);
      continue;
    } on Exception {
      await _backoff(delays[attempt]);
      continue;
    }
  }
  return fallback();
}

Future<void> _backoff(Duration base) async {
  final jitter = (base.inMilliseconds * 0.2 * (Random().nextDouble() * 2 - 1)).round();
  await Future.delayed(Duration(milliseconds: base.inMilliseconds + jitter));
}
```

### n8n 워크플로우 변경

webhook 노드 직후 Switch:
- `body.mode == 'initial'` → 기존 initial 프롬프트 (v2 에서는 이 경로 미사용, 호환 유지)
- `body.mode == 'refine'` → 기존 refine 프롬프트 (Issue 07 에서 history 추가)
- `body.mode == 'enhance'` → 신규 enhance 프롬프트 (rule_based_seed + objective)

### Pro 게이트 (UI 측)

`wizard_preview_page` 에서:
```dart
final isPro = ref.watch(entitlementProvider).hasProAccess;
if (toggleOn && !isPro) {
  showPaywall(context);
  return;
}
```

토글 자체는 활성 (탭 가능), 클릭 시 Paywall (Open Decision §6 — 1차는 Paywall 가닥, billing 정렬 후 ADR 가능).

## DoD

- [ ] `EnhanceObjective` enum freezed/json 통과
- [ ] `WeeklyWizardService.enhance()` 3-retry (500/1500/3500ms ± jitter)
- [ ] 4xx 즉시 폴백 (재시도 0)
- [ ] 5xx / timeout / parse 실패 / items.isEmpty 재시도
- [ ] 3회 모두 실패 시 seed 그대로 반환 (source 는 호출자가 판단)
- [ ] n8n 워크플로우 mode=enhance 분기 추가, manual `curl` 호출 정상
- [ ] `wizard_preview_page` "AI 향상 (Pro)" 토글 + Pro 게이트 + Paywall 호출
- [ ] 단위 테스트 ≥ 8 (재시도 카운트 / 4xx 즉시 / 5xx 폴백 / parse 실패 / timeout / items=0 / Pro 게이트 / 정상 enhance)
- [ ] `flutter analyze` 0 warning
- [ ] `flutter test` 회귀 0건

## 검증

- 단위 테스트 + n8n curl 4 case (정상 / 5xx mock / 4xx mock / timeout)
- 실기기 1 case: LM Studio 종료 후 enhance 토글 → 3회 진행 표시 → seed 결과
