# 07 — Multi-turn refinement

Status: done
의존성: 06
관련 ADR: 0003 (선택, 토큰 측정 후)
완료: 2026-05-03 — RefinementSession/Turn freezed, RefinementSessionNotifier (Riverpod), service.refine() session/window 기반, 마지막 2턴 윈도잉, maxTurns=5 가드, UI 카운터 + diffSummary 카드. 단위 11 + widget 9 PASS, 162/162 schedule. **Deferred**: n8n mode=refine 토큰 ≤ 8KB 실측 (수동 n8n test execution 후 ADR 0003 결정).

## 목적

기존 single-round refinement 를 multi-turn 으로 확장. 마지막 2턴 history 를 윈도잉해 토큰 예산을 지키며, 5턴 상한으로 무한 재생성을 방지.

## 변경/신규 파일

### 수정
- `lib/features/schedule/data/wizard_models.dart` (RefinementSession, RefinementTurn 추가)
- `lib/features/schedule/data/weekly_wizard_service.dart` (refine() history 윈도잉)
- `lib/features/schedule/application/wizard_state.dart` (RefinementSession 보존)
- `lib/features/schedule/presentation/wizard_preview_page.dart` (카운터 + diff_summary 카드)
- `n8n/workflows/routinemon-weekly-schedule-wizard.json` (mode=refine history 처리)
- `test/features/schedule/application/wizard_state_test.dart` (신규)
- `test/features/schedule/data/weekly_wizard_service_test.dart` (확장)

## 설계 메모

### Models

```dart
@freezed
sealed class RefinementTurn with _$RefinementTurn {
  const factory RefinementTurn({
    required int turn,
    required List<GeneratedScheduleItem> items,
    @JsonKey(name: 'followup_answers')
    @Default(<String, String>{}) Map<String, String> followupAnswers,
    @JsonKey(name: 'diff_summary') String? diffSummary,
    required DateTime timestamp,
  }) = _RefinementTurn;

  factory RefinementTurn.fromJson(Map<String, dynamic> json) =>
      _$RefinementTurnFromJson(json);
}

@freezed
sealed class RefinementSession with _$RefinementSession {
  const factory RefinementSession({
    @JsonKey(name: 'conversation_id') required String conversationId,
    @Default(<RefinementTurn>[]) List<RefinementTurn> history,
  }) = _RefinementSession;

  static const int maxTurns = 5;

  factory RefinementSession.fromJson(Map<String, dynamic> json) =>
      _$RefinementSessionFromJson(json);
}

extension RefinementSessionX on RefinementSession {
  int get turnCount => history.length;
  bool get isFull => turnCount >= RefinementSession.maxTurns;
  List<RefinementTurn> get window => history.length <= 2
      ? history
      : history.sublist(history.length - 2);
}
```

### wizard_state.dart

```dart
@riverpod
class RefinementSessionNotifier extends _$RefinementSessionNotifier {
  @override
  RefinementSession? build() => null;

  void start(String conversationId) {
    state = RefinementSession(conversationId: conversationId);
  }

  bool tryAppend(RefinementTurn turn) {
    final cur = state;
    if (cur == null) return false;
    if (cur.isFull) return false;
    state = cur.copyWith(history: [...cur.history, turn]);
    return true;
  }

  void reset() => state = null;
}
```

### Service.refine()

```dart
Future<WeeklyWizardResponse> refine({
  required WizardAnswers answers,
  required DateTime weekStart,
  required RefinementSession session,           // 변경: 단일 객체 전달
  required Map<String, String> followupAnswers,
  String? userId,
}) async {
  final enriched = await _withPastContext(answers, userId);
  final body = {
    'mode': 'refine',
    'answers': enriched.toJson(),
    'week_start': _ymd(weekStart),
    'conversation_id': session.conversationId,
    'turn': session.turnCount + 1,
    'previous_turns': session.window.map((t) => t.toJson()).toList(),
    'followup_answers': followupAnswers,
  };
  return _postWithRetry(body, fallback: () => _seedFromLastTurn(session));
}
```

### Preview UI

- "재생성 N/5" 카운터 (top right)
- session.isFull 이면 "재생성 버튼 비활성 + tooltip 안내"
- 마지막 turn 의 `diffSummary` 가 있으면 카드로 표시 (보라 배경, 한국어 1-2문장)

### n8n 프롬프트 변경

mode=refine 분기에서 `previous_turns` 배열을 system prompt 마지막 부분에 직렬화. 토큰 예산 측정 (n8n execution detail) — 8KB 초과 시 turn 1개로 줄이는 방어 로직.

## DoD

- [ ] `RefinementSession`, `RefinementTurn` freezed/json 통과
- [ ] `RefinementSessionNotifier` 가 history append + maxTurns 가드 + reset
- [ ] `refine()` 가 마지막 2턴만 직렬화 (window 검증)
- [ ] preview UI 카운터 N/5 + 5턴 도달 시 비활성
- [ ] preview UI diff_summary 카드 (turn ≥ 1 일 때)
- [ ] n8n mode=refine 가 previous_turns 처리, 토큰 ≤ 8KB (수동 측정 후 보고서에 기록)
- [ ] 단위 테스트 ≥ 6 (turn 누적, 5턴 가드, conversation_id 유지, window 2턴, full 시 append 실패, reset)
- [ ] widget 테스트 ≥ 2 (카운터 표시, 비활성 상태)
- [ ] `flutter analyze` 0 warning
- [ ] `flutter test` 회귀 0건

## 검증

- 단위 + widget + n8n manual 5턴 시나리오 토큰 측정 → ADR 0003 가닥
