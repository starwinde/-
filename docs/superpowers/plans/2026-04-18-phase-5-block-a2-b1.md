# Phase 5 Block A2 + B1 Implementation Plan

> **Scope:** T5.2 content_filter 정식 이식 + T5.1 AI 주간/월간 리포트 + T5.16 다크모드. 사용자 지시 "다크모드까지"에 따라 3 태스크를 본 plan 하나로 묶음.

**Goal:** (a) n8n content_filter 로직을 server.archived에서 정식 이식 + 공통화, (b) 로컬 LLM 기반 AI 주간/월간 리포트 n8n 워크플로우 + Flutter 클라이언트, (c) 다크모드(system/light/dark 3 모드 + SharedPreferences 지속).

**Architecture:**
- T5.2: `n8n/shared/content_filter.js` 파일을 source of truth로 확립. 기존 `routinemon-auto-schedule` 워크플로우의 필터 Code node를 확장(self_harm + profanity ko/en). Dart `ContentFilterReason` enum 추가.
- T5.1: 2 n8n workflows (`routinemon-ai-weekly-report`, `routinemon-ai-monthly-report`). Input JSON(focus_sessions 집계 + tasks_completed + pet_status) → content_filter → local LLM → 구조화 JSON 응답. 실패 시 수치 기반 preset fallback.
- T5.16: `lib/core/theme/` 모듈(light/dark ThemeData + `@riverpod` ThemeMode provider + SharedPreferences 지속). app.dart에 darkTheme + themeMode 연결. `/settings` 라우트 + SettingsPage UI.

**Tech Stack:**
- Flutter: freezed / mocktail / shared_preferences (기존 사용 중) / riverpod 3.x
- n8n: Code 노드 + HTTP Request + Code 노드 (JSON parse)
- llama-server-8600-v2 (기존)

**Non-goals:**
- T5.1의 실 DB 쿼리(`drift` aggregation)는 Service 레이어에서 stub 처리. 실 데이터 wiring은 Block C/D에서.
- T5.16 Settings UI는 다크모드 토글만. 다른 설정 항목은 Block B 후반(B2).
- T5.2에서 n8n "Execute Sub-workflow" 노드 사용은 과한 복잡성 → `n8n/shared/content_filter.js` 파일을 공유 source로 두고 각 워크플로우의 Code 노드에서 동일 로직 복사 유지 (Option A).

**Non-git note:** git repo 아님. TDD 체크포인트는 test pass + analyze 0 warning.

---

## 의존성 맵

```
Task 0: 베이스라인 기록 (main)
  ↓
Task A2-1: n8n/shared/content_filter.js + 기존 워크플로우 필터 강화 (agent-filter)
Task A2-2: AiReport 모델 + AiReportService + tests (agent-ai-report)
Task B1-1: 다크모드 theme provider + tests + settings page + app.dart 통합 (agent-theme)
  ↓ (병렬, 파일 충돌 없음)
  
Task M-1: 강화된 auto-schedule 워크플로우 재업로드 + 신규 2 AI 워크플로우 import + activate (main)
  ↓
Task M-2: smoke test (기존 auto-schedule 회귀 3케이스 + 신규 AI 리포트 2케이스) (main)
  ↓
Task A2-I: AI Report 통합 테스트 (test/integration) (agent-integration)
  ↓
Task G: Tasks.md T5.1 [-], T5.2 [x], T5.16 [x] + Meta rev 11 + Retrospectives + memory (main)
```

---

## Task 0 — 베이스라인

```bash
export PATH="/home/str_dgx_spark/flutter/bin:$PATH"
cd /home/str_dgx_spark/Desktop/Reward-Based-Self-Management-AppReward-Based-Self-Management-App
flutter analyze 2>&1 | grep -E "error •|warning •" | head -3
flutter test --reporter compact 2>&1 | grep -oE "\+[0-9]+( ~[0-9]+)?( -[0-9]+)?" | tail -1
```

기대: 0 error/warning, `+116 ~4` (Block A1 종료 시점).

---

## Task A2-1 (agent-filter) — content_filter 이식

**파일 스코프**:
- Create: `n8n/shared/content_filter.js`
- Create: `lib/core/content/content_filter_types.dart` (ContentFilterReason enum)
- Create: `test/core/content/content_filter_types_test.dart`
- Modify: `n8n/workflows/routinemon-auto-schedule.json` (Validate + Filter node jsCode만)

### Step A2-1.1 — `n8n/shared/content_filter.js` (source of truth)

```javascript
// Content filter — n8n workflows 공용 로직.
// server.archived/src/middleware/content_filter.ts 이식 (rev 10, 2026-04-18).
// 각 워크플로우의 Code 노드에서 동일 상수·함수 복사 사용.
const PROFANITY_KO = ['바보', '멍청', '씨발', '개새끼', '지랄'];
const PROFANITY_EN = ['fuck', 'shit', 'asshole', 'idiot', 'bitch'];
const SELF_HARM = ['자해', '자살', '죽고 싶', 'kill myself', 'self harm', 'suicide'];

function filterContent(text) {
  const lower = (text || '').toLowerCase();
  for (const word of SELF_HARM) {
    if (lower.includes(word)) return { blocked: true, reason: 'self_harm' };
  }
  for (const word of [...PROFANITY_KO, ...PROFANITY_EN]) {
    if (lower.includes(word)) return { blocked: true, reason: 'profanity' };
  }
  return { blocked: false };
}

module.exports = { filterContent, PROFANITY_KO, PROFANITY_EN, SELF_HARM };
```

### Step A2-1.2 — Dart enum

`lib/core/content/content_filter_types.dart`:

```dart
/// Reason why content was blocked by the n8n content filter.
///
/// Mirrors `n8n/shared/content_filter.js` — any new reason must be added
/// in both places.
enum ContentFilterReason {
  /// Self-harm or suicidal ideation keyword detected.
  selfHarm('self_harm'),

  /// Profanity keyword (ko or en) detected.
  profanity('profanity'),

  /// Empty or malformed input.
  emptyText('empty_text');

  const ContentFilterReason(this.wireValue);

  /// Wire value used by n8n workflows.
  final String wireValue;

  /// Parse from wire value, falling back to [profanity] for unknown values.
  static ContentFilterReason fromWire(String value) {
    return ContentFilterReason.values.firstWhere(
      (r) => r.wireValue == value,
      orElse: () => ContentFilterReason.profanity,
    );
  }
}
```

### Step A2-1.3 — 단위 테스트

`test/core/content/content_filter_types_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/content/content_filter_types.dart';

void main() {
  group('ContentFilterReason', () {
    test('wire values match n8n shared module', () {
      expect(ContentFilterReason.selfHarm.wireValue, 'self_harm');
      expect(ContentFilterReason.profanity.wireValue, 'profanity');
      expect(ContentFilterReason.emptyText.wireValue, 'empty_text');
    });

    test('fromWire parses known values', () {
      expect(ContentFilterReason.fromWire('self_harm'),
          ContentFilterReason.selfHarm);
      expect(ContentFilterReason.fromWire('profanity'),
          ContentFilterReason.profanity);
      expect(ContentFilterReason.fromWire('empty_text'),
          ContentFilterReason.emptyText);
    });

    test('fromWire falls back to profanity for unknown', () {
      expect(ContentFilterReason.fromWire('xxx'),
          ContentFilterReason.profanity);
    });
  });
}
```

### Step A2-1.4 — auto-schedule 워크플로우의 Validate+Filter 노드 업데이트

`n8n/workflows/routinemon-auto-schedule.json`의 "Validate + Filter" 노드 `jsCode`를 아래로 교체:

```javascript
// content_filter (source: n8n/shared/content_filter.js)
const PROFANITY_KO = ['바보', '멍청', '씨발', '개새끼', '지랄'];
const PROFANITY_EN = ['fuck', 'shit', 'asshole', 'idiot', 'bitch'];
const SELF_HARM = ['자해', '자살', '죽고 싶', 'kill myself', 'self harm', 'suicide'];

const body = $input.first().json.body || {};
const text = (body.text || '').trim();
const userLocale = body.user_locale || 'ko';
if (!text) {
  return [{ json: { valid: false, reason: 'empty_text' } }];
}
const lower = text.toLowerCase();
for (const word of SELF_HARM) {
  if (lower.includes(word)) return [{ json: { valid: false, reason: 'self_harm' } }];
}
for (const word of [...PROFANITY_KO, ...PROFANITY_EN]) {
  if (lower.includes(word)) return [{ json: { valid: false, reason: 'profanity' } }];
}
return [{ json: { valid: true, text, userLocale } }];
```

JSON 유효성 검증, 스택오버플로우 방지용 escape 주의 (개행 `\n`, 백슬래시 `\\`).

### Step A2-1.5 — 테스트 실행 + 회귀

```bash
flutter test test/core/content/content_filter_types_test.dart 2>&1 | tail -5  # +3 expected
flutter analyze lib/core/content/ test/core/content/ 2>&1 | grep -E "error •|warning •" || echo ok
python3 -m json.tool n8n/workflows/routinemon-auto-schedule.json > /dev/null && echo ok
```

### Step A2-1.6 — TaskUpdate + 보고

---

## Task A2-2 (agent-ai-report) — AI 리포트 모델·서비스 + n8n 워크플로우

**파일 스코프**:
- Create: `lib/features/ai/data/ai_report_models.dart` (freezed)
- Create: `lib/features/ai/data/ai_report_service.dart`
- Create: `test/features/ai/data/ai_report_models_test.dart`
- Create: `test/features/ai/data/ai_report_service_test.dart`
- Create: `n8n/workflows/routinemon-ai-weekly-report.json`
- Create: `n8n/workflows/routinemon-ai-monthly-report.json`

### Step A2-2.1 — 모델 (TDD)

테스트 (`ai_report_models_test.dart`):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';

void main() {
  group('AiReportRequest', () {
    test('toJson has snake_case keys', () {
      final req = AiReportRequest(
        userId: 'u1',
        period: ReportPeriod.weekly,
        periodStart: DateTime.utc(2026, 4, 11),
        periodEnd: DateTime.utc(2026, 4, 18),
        data: const AiReportInputData(
          focusSessions: 10,
          avgFocusRatio: 0.75,
          tasksCompleted: 15,
          tasksTotal: 20,
          streakDays: 5,
        ),
        userLocale: 'ko',
      );
      final json = req.toJson();
      expect(json['period'], 'weekly');
      expect(json['user_id'], 'u1');
      expect(json['user_locale'], 'ko');
      expect(json['data']['focus_sessions'], 10);
      expect(json['data']['avg_focus_ratio'], 0.75);
    });
  });

  group('AiReportResponse', () {
    test('fromJson parses llm source', () {
      final json = {
        'summary': '이번 주 집중도 우수',
        'insights': ['a', 'b'],
        'suggestions': ['c'],
        'encouragement': '잘하고 있어요!',
        'source': 'llm',
      };
      final res = AiReportResponse.fromJson(json);
      expect(res.source, AiReportSource.llm);
      expect(res.insights, ['a', 'b']);
    });

    test('fromJson parses preset fallback', () {
      final json = {
        'summary': '',
        'insights': <String>[],
        'suggestions': <String>[],
        'encouragement': '',
        'source': 'preset',
      };
      final res = AiReportResponse.fromJson(json);
      expect(res.source, AiReportSource.preset);
    });
  });
}
```

구현 (`ai_report_models.dart`):

```dart
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_report_models.freezed.dart';
part 'ai_report_models.g.dart';

enum ReportPeriod {
  @JsonValue('weekly') weekly,
  @JsonValue('monthly') monthly,
}

enum AiReportSource {
  @JsonValue('llm') llm,
  @JsonValue('preset') preset,
}

@freezed
sealed class AiReportInputData with _$AiReportInputData {
  const factory AiReportInputData({
    @JsonKey(name: 'focus_sessions') required int focusSessions,
    @JsonKey(name: 'avg_focus_ratio') required double avgFocusRatio,
    @JsonKey(name: 'tasks_completed') required int tasksCompleted,
    @JsonKey(name: 'tasks_total') required int tasksTotal,
    @JsonKey(name: 'streak_days') required int streakDays,
  }) = _AiReportInputData;

  factory AiReportInputData.fromJson(Map<String, dynamic> json) =>
      _$AiReportInputDataFromJson(json);
}

@freezed
sealed class AiReportRequest with _$AiReportRequest {
  const factory AiReportRequest({
    @JsonKey(name: 'user_id') required String userId,
    required ReportPeriod period,
    @JsonKey(name: 'period_start') required DateTime periodStart,
    @JsonKey(name: 'period_end') required DateTime periodEnd,
    required AiReportInputData data,
    @JsonKey(name: 'user_locale') required String userLocale,
  }) = _AiReportRequest;

  factory AiReportRequest.fromJson(Map<String, dynamic> json) =>
      _$AiReportRequestFromJson(json);
}

@freezed
sealed class AiReportResponse with _$AiReportResponse {
  const factory AiReportResponse({
    required String summary,
    required List<String> insights,
    required List<String> suggestions,
    required String encouragement,
    required AiReportSource source,
  }) = _AiReportResponse;

  factory AiReportResponse.fromJson(Map<String, dynamic> json) =>
      _$AiReportResponseFromJson(json);
}
```

build_runner 실행 후 테스트 통과 확인.

### Step A2-2.2 — Service (TDD, mocktail)

테스트 (`ai_report_service_test.dart`):

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';
import 'package:routinemon/features/ai/data/ai_report_service.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  late _MockApiClient client;
  late AiReportService service;

  final baseReq = AiReportRequest(
    userId: 'u1',
    period: ReportPeriod.weekly,
    periodStart: DateTime.utc(2026, 4, 11),
    periodEnd: DateTime.utc(2026, 4, 18),
    data: const AiReportInputData(
      focusSessions: 10,
      avgFocusRatio: 0.75,
      tasksCompleted: 15,
      tasksTotal: 20,
      streakDays: 5,
    ),
    userLocale: 'ko',
  );

  setUp(() {
    client = _MockApiClient();
    service = AiReportService(client);
  });

  test('weekly posts to /ai/weekly-report and parses llm response', () async {
    final body = jsonEncode({
      'summary': 's',
      'insights': ['i1'],
      'suggestions': ['sg1'],
      'encouragement': 'e',
      'source': 'llm',
    });
    when(() => client.post(any(),
            body: any(named: 'body'),
            headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(body, 200,
            headers: {'content-type': 'application/json; charset=utf-8'}));

    final res = await service.generate(baseReq);

    expect(res.source, AiReportSource.llm);
    verify(() => client.post(
          '/webhook/routinemon/ai/weekly-report',
          body: any(named: 'body'),
        )).called(1);
  });

  test('monthly posts to /ai/monthly-report path', () async {
    final monthlyReq = baseReq.copyWith(period: ReportPeriod.monthly);
    final body = jsonEncode({
      'summary': 's', 'insights': <String>[], 'suggestions': <String>[],
      'encouragement': '', 'source': 'preset',
    });
    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response(body, 200,
            headers: {'content-type': 'application/json; charset=utf-8'}));

    await service.generate(monthlyReq);

    verify(() => client.post('/webhook/routinemon/ai/monthly-report',
        body: any(named: 'body'))).called(1);
  });

  test('non-2xx returns preset fallback', () async {
    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('err', 500));
    final res = await service.generate(baseReq);
    expect(res.source, AiReportSource.preset);
    expect(res.summary, isNotEmpty); // preset 수치 기반 요약
  });

  test('exception returns preset fallback', () async {
    when(() => client.post(any(), body: any(named: 'body')))
        .thenThrow(Exception('x'));
    final res = await service.generate(baseReq);
    expect(res.source, AiReportSource.preset);
  });
}
```

구현 (`ai_report_service.dart`):

```dart
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';

part 'ai_report_service.g.dart';

/// Generates weekly/monthly Pro reports via local LLM (llama-server-8600-v2)
/// routed through n8n webhooks. On any failure returns a numeric preset
/// summary so the UI still has something to show.
class AiReportService {
  AiReportService(this._client);

  final ApiClient _client;

  static const _weeklyPath = '/webhook/routinemon/ai/weekly-report';
  static const _monthlyPath = '/webhook/routinemon/ai/monthly-report';

  Future<AiReportResponse> generate(AiReportRequest req) async {
    final path =
        req.period == ReportPeriod.weekly ? _weeklyPath : _monthlyPath;
    try {
      final response = await _client.post(path, body: req.toJson());
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _preset(req);
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AiReportResponse.fromJson(json);
    } on Exception {
      return _preset(req);
    }
  }

  AiReportResponse _preset(AiReportRequest req) {
    final d = req.data;
    final ratioPct = (d.avgFocusRatio * 100).round();
    final taskPct = d.tasksTotal == 0
        ? 0
        : ((d.tasksCompleted / d.tasksTotal) * 100).round();
    final summary =
        '집중 세션 ${d.focusSessions}회, 평균 집중도 $ratioPct%, 할일 $taskPct% 완료 (연속 ${d.streakDays}일).';
    return AiReportResponse(
      summary: summary,
      insights: const [],
      suggestions: const [],
      encouragement: '이번 주기의 수치를 확인해 보세요.',
      source: AiReportSource.preset,
    );
  }
}

@riverpod
AiReportService aiReportService(Ref ref) =>
    AiReportService(ref.watch(apiClientProvider));
```

### Step A2-2.3 — n8n 워크플로우 2종

공통 구조 (routinemon-ai-weekly-report):
1. Webhook (POST routinemon/ai/weekly-report, responseMode=responseNode)
2. Content Filter (Code 노드 — user-supplied notes가 없으므로 간단한 sanity check만)
3. Call llama-server (HTTP Request — data 요약 + 격려 요청 프롬프트)
4. Parse LLM JSON (Code — markdown fence strip + whitelist)
5. Preset Fallback (Code — 수치 템플릿)
6. Respond

LLM 프롬프트 예 (시스템):
```
You are a JSON wellness report generator. Output ONLY a single JSON object, no reasoning, no markdown.
Keys: summary (string, <=160 chars), insights (3-5 short korean/english strings), suggestions (2-3 short strings), encouragement (single positive sentence), source (ignore, always set to 'llm').
Locale: {{ $json.body.user_locale }}. Period: {{ $json.body.period }}.
Focus sessions: {{ $json.body.data.focus_sessions }}, avg focus ratio: {{ $json.body.data.avg_focus_ratio }}, tasks completed: {{ $json.body.data.tasks_completed }}/{{ $json.body.data.tasks_total }}, streak: {{ $json.body.data.streak_days }} days.
```

max_tokens: 2048 (Block A1과 동일 교훈), temperature: 0.4, response_format: json_object.

파일 저장 후 JSON 유효성 확인. Monthly는 weekly와 path만 다름 (프롬프트에 "month"로 변경).

### Step A2-2.4 — build_runner + 테스트

```bash
flutter pub run build_runner build --delete-conflicting-outputs 2>&1 | tail -5
flutter test test/features/ai/ 2>&1 | tail -5  # +6 expected (models 3 + service 4 = 7, plan 중 1 여유 허용)
```

### Step A2-2.5 — TaskUpdate + 보고

---

## Task B1-1 (agent-theme) — 다크모드

**파일 스코프**:
- Create: `lib/core/theme/app_theme.dart`
- Create: `lib/core/theme/theme_mode_provider.dart`
- Create: `lib/features/settings/presentation/settings_page.dart`
- Create: `test/core/theme/theme_mode_provider_test.dart`
- Modify: `lib/app.dart` (MaterialApp.router: darkTheme + themeMode 추가 + /settings 라우트 + home AppBar에 설정 아이콘)

### Step B1-1.1 — AppTheme (light/dark)

`lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

/// 루틴몬 light/dark 테마 정의 (PRD §2.20: 파스텔 그린 메인 + 다크모드 지원).
class AppTheme {
  const AppTheme._();

  static const _seed = Color(0xFFA8D8B9);

  static ThemeData light() => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      );

  static ThemeData dark() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
```

### Step B1-1.2 — ThemeMode provider (TDD)

테스트 (`theme_mode_provider_test.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routinemon/core/theme/theme_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('default ThemeMode is system when nothing saved', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final mode = await container.read(themeModeProvider.future);
    expect(mode, ThemeMode.system);
  });

  test('loads previously saved "dark" value', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final mode = await container.read(themeModeProvider.future);
    expect(mode, ThemeMode.dark);
  });

  test('setThemeMode persists and updates', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Initialize
    await container.read(themeModeProvider.future);
    // Update
    await container.read(themeModeProvider.notifier).setMode(ThemeMode.light);
    final updated = await container.read(themeModeProvider.future);
    expect(updated, ThemeMode.light);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'light');
  });
}
```

구현 (`theme_mode_provider.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_mode_provider.g.dart';

const _prefKey = 'theme_mode';

/// Persisted app theme mode (system / light / dark).
///
/// rules.md §3.5 허용: SharedPreferences는 UI 설정만 — ThemeMode 해당.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    return _parse(prefs.getString(_prefKey));
  }

  /// Updates and persists the theme mode.
  Future<void> setMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _encode(mode));
    state = AsyncData(mode);
  }

  static ThemeMode _parse(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
```

### Step B1-1.3 — SettingsPage

`lib/features/settings/presentation/settings_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routinemon/core/theme/theme_mode_provider.dart';

/// 설정 페이지. 현재는 다크모드 토글만 (Block B1, T5.16).
class SettingsPage extends ConsumerWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modeAsync = ref.watch(themeModeNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: modeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (current) => ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('테마', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('시스템 설정 따르기'),
              value: ThemeMode.system,
              groupValue: current,
              onChanged: (v) async {
                if (v != null) {
                  await ref
                      .read(themeModeNotifierProvider.notifier)
                      .setMode(v);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('라이트 모드'),
              value: ThemeMode.light,
              groupValue: current,
              onChanged: (v) async {
                if (v != null) {
                  await ref
                      .read(themeModeNotifierProvider.notifier)
                      .setMode(v);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('다크 모드'),
              value: ThemeMode.dark,
              groupValue: current,
              onChanged: (v) async {
                if (v != null) {
                  await ref
                      .read(themeModeNotifierProvider.notifier)
                      .setMode(v);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step B1-1.4 — app.dart 통합

`lib/app.dart` 변경:
1. Import 추가: `app_theme.dart`, `theme_mode_provider.dart`, `settings_page.dart`
2. GoRouter routes에 `/settings` 추가
3. `_HomePage` AppBar에 설정 아이콘 버튼 (`IconButton(Icons.settings, onPressed: () => context.push('/settings'))`)
4. `MaterialApp.router`:
   ```dart
   final themeModeAsync = ref.watch(themeModeNotifierProvider);
   final themeMode = themeModeAsync.value ?? ThemeMode.system;
   return MaterialApp.router(
     title: '루틴몬',
     theme: AppTheme.light(),
     darkTheme: AppTheme.dark(),
     themeMode: themeMode,
     routerConfig: goRouter,
   );
   ```

### Step B1-1.5 — build_runner + 테스트

```bash
flutter pub run build_runner build --delete-conflicting-outputs 2>&1 | tail -3
flutter test test/core/theme/ 2>&1 | tail -5  # +3 expected
flutter analyze lib/core/theme/ lib/features/settings/ lib/app.dart test/core/theme/ 2>&1 | grep -E "error •|warning •" || echo ok
```

### Step B1-1.6 — TaskUpdate + 보고

---

## Task M-1 (main) — n8n import + activate

Stage 1 완료 후 main 실행:

```bash
# 1) 기존 auto-schedule 워크플로우는 PUT으로 필터 강화만 갱신
curl -sk -X PUT https://localhost:5678/api/v1/workflows/NrqMGblcgsOTX0f4 \
  -H "X-N8N-API-KEY: $N8N_API_KEY" -H "Content-Type: application/json" \
  --data-binary @n8n/workflows/routinemon-auto-schedule.json

# 2) 신규 weekly-report
curl -sk -X POST https://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: $N8N_API_KEY" -H "Content-Type: application/json" \
  --data-binary @n8n/workflows/routinemon-ai-weekly-report.json
# → id 추출 후 activate

# 3) 신규 monthly-report
curl -sk -X POST https://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: $N8N_API_KEY" -H "Content-Type: application/json" \
  --data-binary @n8n/workflows/routinemon-ai-monthly-report.json
# → id 추출 후 activate
```

각 id 기록.

---

## Task M-2 (main) — 통합 smoke

```bash
# A1 회귀: auto-schedule 3 케이스 재실행
bash n8n/workflows/__smoke__/auto_schedule_smoke.sh | grep '"source"'
# 기대: llm, preset, preset

# 추가: profanity 차단 케이스
curl -sk -X POST https://localhost:5678/webhook/routinemon/auto-schedule \
  -H "Content-Type: application/json" \
  -d '{"text":"씨발 내일 회의","user_locale":"ko"}' | python3 -m json.tool
# 기대: source=preset (profanity blocked)

# 신규 AI report smoke
curl -sk -X POST https://localhost:5678/webhook/routinemon/ai/weekly-report \
  -H "Content-Type: application/json" \
  -d '{"user_id":"u1","period":"weekly","period_start":"2026-04-11","period_end":"2026-04-18","data":{"focus_sessions":10,"avg_focus_ratio":0.75,"tasks_completed":15,"tasks_total":20,"streak_days":5},"user_locale":"ko"}' | python3 -m json.tool
# 기대: source=llm 또는 preset, 구조화된 응답
```

실패 시 execution 로그 확인 + 교정.

---

## Task A2-I (agent-integration) — AI report 통합 테스트

`test/integration/ai_report_integration_test.dart`:

- 3 tests: weekly LLM, monthly LLM, non-2xx fallback (어려우면 2 tests만: weekly/monthly 둘 다 valid response 반환 확인)
- `dart:io` HttpClient with `badCertificateCallback`
- Timeout 90 seconds (LLM report는 auto-schedule보다 느릴 수 있음)

---

## Task G (main) — 거버넌스 갱신

- Tasks.md T5.1 `[-]` (코드/n8n 완료, 실 DB wiring은 Block C/D) → 완료 노트 추가
- Tasks.md T5.2 `[x]` (DoD 전부 충족: 이식 완료 + Dart enum + tests + 기존 워크플로우 통합)
- Tasks.md T5.16 `[x]` (다크모드 완료)
- Tasks.md Meta rev 11
- Tasks.md Retrospectives 1줄
- memory `project_status.md` 상태 갱신

---

## DoD

- [ ] analyze 0 error/warning
- [ ] flutter test 회귀 없이 +N 증가 (A2-1 +3, A2-2 +6, B1 +3 = +12 기대; 총 +128 ~4)
- [ ] 3 n8n 워크플로우 active (auto-schedule 갱신 + weekly + monthly)
- [ ] smoke test 회귀 없음 + profanity 차단 케이스 추가 통과
- [ ] 통합 테스트 통과
- [ ] Tasks.md + memory 갱신

---

## 멀티에이전트 실행 규칙 (Block A1과 동일)

- Codex 플러그인 off 유지
- 서브에이전트 프롬프트: `Do not invoke codex:* skills`
- 파일 스코프 배타적, write 충돌 0
- Stage 1 병렬 3 agents (agent-filter / agent-ai-report / agent-theme)
- Stage 2/3 main thread (n8n API + smoke)
- Stage 4 단일 agent (통합 테스트)
- Stage 5 main thread (거버넌스)
- 완료 시 SendMessage shutdown + TeamDelete
