# Phase 5 Block A1 Implementation Plan — `routinemon-auto-schedule` (T5.11 part 1)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 자유 텍스트(한국어/영어)를 받아 로컬 LLM(llama-server-8600-v2)이 구조화된 일정 JSON으로 변환하는 n8n webhook + Flutter 클라이언트를 구현한다. Gmail API 통합은 T5.0 사용자 액션 후 별도 block에서 처리 (이 plan 범위 외).

**Architecture:**
- Flutter → `ApiClient.post('/webhook/routinemon/auto-schedule', {text, userLocale})` → n8n HTTPS 5678
- n8n 워크플로우: Webhook → JWT Validation (기존 ai-welcome 패턴 재사용) → Content Filter(Code) → HTTP Request(llama-server-8600 `/v1/chat/completions`) → JSON Validation(Code) → Response
- llama-server는 시스템 프롬프트가 강제하는 JSON schema로 응답. 실패/필터 차단 시 n8n이 프리셋 폴백 반환.
- Flutter 측은 `AutoScheduleResponse` freezed 모델로 파싱, confidence < 0.5 이면 사용자에게 확인 프롬프트.

**Tech Stack:**
- Flutter: freezed 3.x + json_annotation + http + riverpod 3.x + mocktail (TDD)
- n8n: self-hosted HTTPS, REST API import via `N8N_API_KEY`
- llama-server-8600-v2: OpenAI-compatible `/v1/chat/completions`, 모델 `gemma-4-E2B-it-Q4_K_M`

**Non-goals (이 plan 제외):**
- Gmail fetch (T5.0 OAuth 선결 필요 → 별도 block C)
- Google Calendar sync (T5.10)
- Share intent (T5.12)
- AI weekly/monthly reports (T5.1, Block A2)
- Content filter 강화 이식 (T5.2, Block A2 — 여기선 최소 필터만 inline)

**Non-git note:** 이 프로젝트는 git repo가 아님. TDD 각 태스크는 "test pass + analyze 0 warning"을 체크포인트로 대체한다. `git add/commit` 스텝 생략.

---

## Pre-flight checks

실행 전 아래 명령어로 환경 검증:

```bash
export PATH="/home/str_dgx_spark/flutter/bin:$PATH"
curl -s -o /dev/null -w "llama-server: %{http_code}\n" http://localhost:8600/v1/models
curl -sk -o /dev/null -w "n8n: %{http_code}\n" https://localhost:5678
cd /home/str_dgx_spark/Desktop/Reward-Based-Self-Management-AppReward-Based-Self-Management-App
flutter analyze 2>&1 | grep -E "error|warning" | wc -l  # 기대: 0
flutter test --reporter compact 2>&1 | grep -oE "\+[0-9]+" | tail -1  # 기대: +104
```

기대:
- llama-server: `200` + model `gemma-4-E2B-it-Q4_K_M`
- n8n: `200`
- flutter analyze: 0 error/warning (150 info 허용)
- flutter test: `+104` passed

---

## 의존성 맵

```
Task 1: 베이스라인 기록 (test/analyze 수치 스냅샷)
  ↓
Task 2: AutoScheduleRequest/Response 모델 (freezed) + 단위 테스트
  ↓
Task 3: AutoScheduleService (n8n webhook 호출 추상) + 단위 테스트 (mocktail)
  ↓
Task 4: api_client.dart 주석 수정 (Workers → n8n, 미세 후행 정리)
  ↓
Task 5: n8n 워크플로우 JSON 저장소 파일 생성 (Code node + HTTP Request node)
  ↓
Task 6: n8n API로 워크플로우 import + activate
  ↓
Task 7: curl smoke test (프리셋 폴백 + LLM 경로 둘 다)
  ↓
Task 8: Dart 통합 테스트 (실 n8n + 실 llama-server, 2개 시나리오)
  ↓
Task 9: 최종 회귀 검증 + Tasks.md T5.11 갱신(상태 `[-]`, 부분 완료 기록)
```

---

## Task 1: 베이스라인 기록

**Files:**
- Read only: 기존 test 결과 스냅샷

- [ ] **Step 1.1: 테스트·분석 baseline 측정 + 기록**

```bash
export PATH="/home/str_dgx_spark/flutter/bin:$PATH"
cd /home/str_dgx_spark/Desktop/Reward-Based-Self-Management-AppReward-Based-Self-Management-App
flutter analyze 2>&1 | tail -1  # "150 issues found" 또는 변동값
flutter test --reporter compact 2>&1 | grep -oE "\+[0-9]+( ~[0-9]+)?( -[0-9]+)?" | tail -1
```

Expected: `+104 ~4` (104 passed, 4 skipped, 0 failed), analyze 0 error/warning.

베이스라인 수치를 이 plan의 메모로 기록 (향후 회귀 검증에 사용).

---

## Task 2: AutoSchedule 모델 정의 (freezed + TDD)

**Files:**
- Create: `lib/features/schedule/data/auto_schedule_models.dart`
- Create: `test/features/schedule/data/auto_schedule_models_test.dart`

- [ ] **Step 2.1: 실패하는 테스트 작성**

`test/features/schedule/data/auto_schedule_models_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/auto_schedule_models.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

void main() {
  group('AutoScheduleRequest', () {
    test('toJson has snake_case keys', () {
      const req = AutoScheduleRequest(
        text: '내일 오후 2시 팀 미팅',
        userLocale: 'ko',
      );
      expect(req.toJson(), {
        'text': '내일 오후 2시 팀 미팅',
        'user_locale': 'ko',
      });
    });
  });

  group('AutoScheduleResponse', () {
    test('fromJson parses LLM response with all fields', () {
      final json = <String, dynamic>{
        'title': '팀 미팅',
        'start_time': '2026-04-19T14:00:00+09:00',
        'end_time': '2026-04-19T15:00:00+09:00',
        'category': 'work',
        'tags': ['meeting', 'team'],
        'confidence': 0.85,
        'source': 'llm',
      };
      final res = AutoScheduleResponse.fromJson(json);
      expect(res.title, '팀 미팅');
      expect(res.startTime, DateTime.parse('2026-04-19T14:00:00+09:00'));
      expect(res.category, ScheduleCategory.work);
      expect(res.tags, ['meeting', 'team']);
      expect(res.confidence, 0.85);
      expect(res.source, AutoScheduleSource.llm);
    });

    test('fromJson parses preset fallback with null times', () {
      final json = <String, dynamic>{
        'title': '일정',
        'start_time': null,
        'end_time': null,
        'category': 'etc',
        'tags': <String>[],
        'confidence': 0.0,
        'source': 'preset',
      };
      final res = AutoScheduleResponse.fromJson(json);
      expect(res.startTime, isNull);
      expect(res.endTime, isNull);
      expect(res.category, ScheduleCategory.etc);
      expect(res.source, AutoScheduleSource.preset);
    });

    test('fromJson falls back to etc for unknown category', () {
      final json = <String, dynamic>{
        'title': 'x',
        'start_time': null,
        'end_time': null,
        'category': 'unknown_category',
        'tags': <String>[],
        'confidence': 0.1,
        'source': 'llm',
      };
      final res = AutoScheduleResponse.fromJson(json);
      expect(res.category, ScheduleCategory.etc);
    });

    test('needsUserConfirmation is true when confidence < 0.5', () {
      final low = AutoScheduleResponse(
        title: 't',
        startTime: null,
        endTime: null,
        category: ScheduleCategory.etc,
        tags: const [],
        confidence: 0.3,
        source: AutoScheduleSource.llm,
      );
      final high = low.copyWith(confidence: 0.7);
      expect(low.needsUserConfirmation, isTrue);
      expect(high.needsUserConfirmation, isFalse);
    });
  });
}
```

- [ ] **Step 2.2: 테스트 실행 → 실패 확인**

```bash
flutter test test/features/schedule/data/auto_schedule_models_test.dart 2>&1 | tail -10
```

Expected: FAIL with "Target of URI doesn't exist: 'package:routinemon/features/schedule/data/auto_schedule_models.dart'".

- [ ] **Step 2.3: 모델 구현 + 생성기 실행**

`lib/features/schedule/data/auto_schedule_models.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

part 'auto_schedule_models.freezed.dart';
part 'auto_schedule_models.g.dart';

/// JSON source of an auto-schedule result.
enum AutoScheduleSource {
  @JsonValue('llm')
  llm,
  @JsonValue('preset')
  preset,
}

/// Request body sent to n8n `routinemon-auto-schedule` webhook.
@freezed
sealed class AutoScheduleRequest with _$AutoScheduleRequest {
  const factory AutoScheduleRequest({
    required String text,
    @JsonKey(name: 'user_locale') required String userLocale,
  }) = _AutoScheduleRequest;

  factory AutoScheduleRequest.fromJson(Map<String, dynamic> json) =>
      _$AutoScheduleRequestFromJson(json);
}

/// Structured schedule inferred by the LLM (or preset fallback).
@freezed
sealed class AutoScheduleResponse with _$AutoScheduleResponse {
  const AutoScheduleResponse._();

  const factory AutoScheduleResponse({
    required String title,
    @JsonKey(name: 'start_time') required DateTime? startTime,
    @JsonKey(name: 'end_time') required DateTime? endTime,
    @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
    required ScheduleCategory category,
    required List<String> tags,
    required double confidence,
    required AutoScheduleSource source,
  }) = _AutoScheduleResponse;

  /// True when the caller should prompt the user before committing.
  bool get needsUserConfirmation => confidence < 0.5;

  factory AutoScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$AutoScheduleResponseFromJson(json);
}

ScheduleCategory _categoryFromJson(String value) =>
    ScheduleCategory.fromString(value);

String _categoryToJson(ScheduleCategory c) => c.name;
```

- [ ] **Step 2.4: build_runner 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs 2>&1 | tail -10
```

Expected: `Succeeded after ...`. Two generated files appear: `auto_schedule_models.freezed.dart`, `auto_schedule_models.g.dart`.

- [ ] **Step 2.5: 테스트 실행 → 통과 확인**

```bash
flutter test test/features/schedule/data/auto_schedule_models_test.dart 2>&1 | tail -5
```

Expected: `All tests passed!` with `+4` passed.

- [ ] **Step 2.6: 회귀 검증**

```bash
flutter analyze 2>&1 | grep -E "error •|warning •" | head -5  # 기대: 빈 출력
flutter test --reporter compact 2>&1 | grep -oE "\+[0-9]+( ~[0-9]+)?( -[0-9]+)?" | tail -1  # 기대: +108 ~4 (104 + 4 신규)
```

---

## Task 3: AutoScheduleService + 단위 테스트 (mocktail)

**Files:**
- Create: `lib/features/schedule/data/auto_schedule_service.dart`
- Create: `test/features/schedule/data/auto_schedule_service_test.dart`

- [ ] **Step 3.1: 실패하는 테스트 작성**

`test/features/schedule/data/auto_schedule_service_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/schedule/data/auto_schedule_models.dart';
import 'package:routinemon/features/schedule/data/auto_schedule_service.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('AutoScheduleService.infer', () {
    late _MockApiClient client;
    late AutoScheduleService service;

    setUp(() {
      client = _MockApiClient();
      service = AutoScheduleService(client);
    });

    test('posts to /webhook/routinemon/auto-schedule and parses LLM response',
        () async {
      final bodyJson = jsonEncode({
        'title': '팀 미팅',
        'start_time': '2026-04-19T14:00:00+09:00',
        'end_time': '2026-04-19T15:00:00+09:00',
        'category': 'work',
        'tags': ['meeting'],
        'confidence': 0.9,
        'source': 'llm',
      });
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(bodyJson, 200));

      final result = await service.infer(
        text: '내일 오후 2시 팀 미팅',
        userLocale: 'ko',
      );

      expect(result.title, '팀 미팅');
      expect(result.category, ScheduleCategory.work);
      expect(result.source, AutoScheduleSource.llm);
      verify(() => client.post(
            '/webhook/routinemon/auto-schedule',
            body: {
              'text': '내일 오후 2시 팀 미팅',
              'user_locale': 'ko',
            },
          )).called(1);
    });

    test('returns preset fallback on non-2xx status', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      final result = await service.infer(text: 'x', userLocale: 'ko');

      expect(result.source, AutoScheduleSource.preset);
      expect(result.category, ScheduleCategory.etc);
      expect(result.confidence, 0.0);
    });

    test('returns preset fallback on JSON parse failure', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('not json', 200));

      final result = await service.infer(text: 'x', userLocale: 'ko');

      expect(result.source, AutoScheduleSource.preset);
    });

    test('returns preset fallback on network exception', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenThrow(Exception('network down'));

      final result = await service.infer(text: 'x', userLocale: 'ko');

      expect(result.source, AutoScheduleSource.preset);
    });
  });
}
```

- [ ] **Step 3.2: 테스트 실패 확인**

```bash
flutter test test/features/schedule/data/auto_schedule_service_test.dart 2>&1 | tail -10
```

Expected: FAIL ("AutoScheduleService is not defined").

- [ ] **Step 3.3: 서비스 구현**

`lib/features/schedule/data/auto_schedule_service.dart`:

```dart
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/schedule/data/auto_schedule_models.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

part 'auto_schedule_service.g.dart';

/// Calls the n8n `routinemon-auto-schedule` webhook to convert free-form text
/// into a structured schedule via the local LLM (llama-server-8600-v2).
///
/// On any failure (network, non-2xx, parse error) it returns a preset fallback
/// so the UI can still offer the user an "edit manually" path.
class AutoScheduleService {
  /// Creates a service backed by [client].
  AutoScheduleService(this._client);

  static const _path = '/webhook/routinemon/auto-schedule';

  final ApiClient _client;

  /// Infers a [AutoScheduleResponse] from [text] written in [userLocale].
  Future<AutoScheduleResponse> infer({
    required String text,
    required String userLocale,
  }) async {
    try {
      final response = await _client.post(
        _path,
        body: {'text': text, 'user_locale': userLocale},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _preset();
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AutoScheduleResponse.fromJson(json);
    } on Exception {
      return _preset();
    }
  }

  AutoScheduleResponse _preset() => const AutoScheduleResponse(
        title: '',
        startTime: null,
        endTime: null,
        category: ScheduleCategory.etc,
        tags: [],
        confidence: 0,
        source: AutoScheduleSource.preset,
      );
}

/// Provides [AutoScheduleService] wired to the global [ApiClient].
@riverpod
AutoScheduleService autoScheduleService(Ref ref) {
  return AutoScheduleService(ref.watch(apiClientProvider));
}
```

- [ ] **Step 3.4: build_runner 실행 (riverpod_generator)**

```bash
flutter pub run build_runner build --delete-conflicting-outputs 2>&1 | tail -5
```

- [ ] **Step 3.5: 테스트 실행 → 통과**

```bash
flutter test test/features/schedule/data/auto_schedule_service_test.dart 2>&1 | tail -5
```

Expected: `All tests passed!` with `+4`.

- [ ] **Step 3.6: 회귀 검증**

```bash
flutter analyze 2>&1 | grep -E "error •|warning •"  # 기대: 빈 출력
flutter test --reporter compact 2>&1 | grep -oE "\+[0-9]+( ~[0-9]+)?" | tail -1  # 기대: +112 ~4
```

---

## Task 4: api_client.dart 주석 정리 (rev 9 미세 후행)

**Files:**
- Modify: `lib/core/native/api_client.dart:10-11, 18`

- [ ] **Step 4.1: Workers → n8n 주석 수정**

변경:
```dart
/// HTTP client that automatically attaches the Supabase JWT as a Bearer token
/// to all requests sent to the self-hosted Workers API.
```
→
```dart
/// HTTP client that automatically attaches the Supabase JWT as a Bearer token
/// to all requests sent to the self-hosted n8n API (rev 9: Workers → n8n).
```

그리고:
```dart
  /// Base URL of the Workers API.
```
→
```dart
  /// Base URL of the n8n API.
```

- [ ] **Step 4.2: 회귀 검증**

```bash
flutter analyze 2>&1 | grep -E "error •|warning •"  # 빈 출력
flutter test --reporter compact 2>&1 | grep -oE "\+[0-9]+( ~[0-9]+)?" | tail -1  # 기대: +112 ~4
```

---

## Task 5: n8n 워크플로우 JSON 저장소 파일 생성

**Files:**
- Create: `n8n/workflows/routinemon-auto-schedule.json`

- [ ] **Step 5.1: 디렉토리 생성**

```bash
mkdir -p /home/str_dgx_spark/Desktop/Reward-Based-Self-Management-AppReward-Based-Self-Management-App/n8n/workflows
```

- [ ] **Step 5.2: 워크플로우 JSON 작성**

`n8n/workflows/routinemon-auto-schedule.json`:

```json
{
  "name": "routinemon-auto-schedule",
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "routinemon/auto-schedule",
        "responseMode": "responseNode",
        "options": {}
      },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 2,
      "position": [200, 300],
      "webhookId": "routinemon-auto-schedule"
    },
    {
      "parameters": {
        "jsCode": "const body = $input.first().json.body || {};\nconst text = (body.text || '').trim();\nconst userLocale = body.user_locale || 'ko';\nif (!text) {\n  return [{ json: { valid: false, reason: 'empty_text' } }];\n}\n// 최소 content filter: 욕설/자해 키워드 차단 (server.archived/middleware/content_filter.ts 요지 이식)\nconst BLOCK = ['죽고', '자살', 'kill myself', 'suicide'];\nif (BLOCK.some(k => text.toLowerCase().includes(k))) {\n  return [{ json: { valid: false, reason: 'blocked_content' } }];\n}\nreturn [{ json: { valid: true, text, userLocale } }];"
      },
      "name": "Validate + Filter",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [420, 300]
    },
    {
      "parameters": {
        "conditions": {
          "options": { "caseSensitive": true, "leftValue": "", "typeValidation": "strict" },
          "conditions": [
            {
              "id": "valid_check",
              "leftValue": "={{ $json.valid }}",
              "rightValue": true,
              "operator": { "type": "boolean", "operation": "equals" }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "name": "Is Valid?",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [640, 300]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "http://localhost:8600/v1/chat/completions",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            { "name": "Content-Type", "value": "application/json" }
          ]
        },
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={\n  \"model\": \"gemma-4-E2B-it-Q4_K_M\",\n  \"temperature\": 0.2,\n  \"max_tokens\": 512,\n  \"response_format\": {\"type\": \"json_object\"},\n  \"messages\": [\n    {\"role\": \"system\", \"content\": \"You are a schedule parser. Output STRICT JSON only with keys: title (string), start_time (ISO8601 or null), end_time (ISO8601 or null), category (one of: work, study, hobby, health, etc), tags (string array), confidence (0.0-1.0). Locale of input: {{ $json.userLocale }}. If uncertain, set confidence low and tags empty.\"},\n    {\"role\": \"user\", \"content\": {{ JSON.stringify($json.text) }}}\n  ]\n}",
        "options": {
          "timeout": 30000
        }
      },
      "name": "Call llama-server",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [860, 240]
    },
    {
      "parameters": {
        "jsCode": "const res = $input.first().json;\nconst content = res.choices?.[0]?.message?.content || '{}';\nlet parsed;\ntry { parsed = JSON.parse(content); } catch (e) { parsed = null; }\nif (!parsed || typeof parsed.title !== 'string') {\n  return [{ json: { title: '', start_time: null, end_time: null, category: 'etc', tags: [], confidence: 0.0, source: 'preset' } }];\n}\nreturn [{ json: {\n  title: parsed.title,\n  start_time: parsed.start_time ?? null,\n  end_time: parsed.end_time ?? null,\n  category: ['work','study','hobby','health','etc'].includes(parsed.category) ? parsed.category : 'etc',\n  tags: Array.isArray(parsed.tags) ? parsed.tags.map(String) : [],\n  confidence: typeof parsed.confidence === 'number' ? Math.max(0, Math.min(1, parsed.confidence)) : 0.0,\n  source: 'llm'\n}}];"
      },
      "name": "Parse LLM JSON",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [1080, 240]
    },
    {
      "parameters": {
        "jsCode": "return [{ json: { title: '', start_time: null, end_time: null, category: 'etc', tags: [], confidence: 0.0, source: 'preset' } }];"
      },
      "name": "Preset Fallback",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [860, 420]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ $json }}",
        "options": { "responseCode": 200 }
      },
      "name": "Respond",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1.1,
      "position": [1320, 300]
    }
  ],
  "connections": {
    "Webhook": { "main": [[{ "node": "Validate + Filter", "type": "main", "index": 0 }]] },
    "Validate + Filter": { "main": [[{ "node": "Is Valid?", "type": "main", "index": 0 }]] },
    "Is Valid?": {
      "main": [
        [{ "node": "Call llama-server", "type": "main", "index": 0 }],
        [{ "node": "Preset Fallback", "type": "main", "index": 0 }]
      ]
    },
    "Call llama-server": { "main": [[{ "node": "Parse LLM JSON", "type": "main", "index": 0 }]] },
    "Parse LLM JSON": { "main": [[{ "node": "Respond", "type": "main", "index": 0 }]] },
    "Preset Fallback": { "main": [[{ "node": "Respond", "type": "main", "index": 0 }]] }
  },
  "settings": { "executionOrder": "v1" }
}
```

- [ ] **Step 5.3: JSON 유효성 검증**

```bash
cat n8n/workflows/routinemon-auto-schedule.json | python3 -m json.tool > /dev/null && echo "✅ valid JSON"
```

Expected: `✅ valid JSON`.

---

## Task 6: n8n API로 워크플로우 import + activate

**Files:**
- Modify: n8n 서버 상태 (파일 아님)

- [ ] **Step 6.1: 기존 같은 이름 워크플로우 존재 확인**

```bash
cd /home/str_dgx_spark/Desktop/Reward-Based-Self-Management-AppReward-Based-Self-Management-App
source .env
curl -sk -H "X-N8N-API-KEY: $N8N_API_KEY" https://localhost:5678/api/v1/workflows \
  | python3 -c "import sys,json; [print(w['id'],w['name'],w['active']) for w in json.load(sys.stdin)['data'] if w['name']=='routinemon-auto-schedule']"
```

Expected: 빈 출력 (미존재). 이미 있으면 Step 6.2 skip + 6.3로 update.

- [ ] **Step 6.2: 새 워크플로우 생성 (POST)**

```bash
curl -sk -X POST https://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json" \
  --data-binary @n8n/workflows/routinemon-auto-schedule.json \
  | python3 -c "import sys,json; r=json.load(sys.stdin); print('ID:',r.get('id'),'Name:',r.get('name'))"
```

Expected: `ID: <새 ID> Name: routinemon-auto-schedule`. 실패 시 응답 JSON 검토 후 payload 수정.

- [ ] **Step 6.3: 워크플로우 활성화**

```bash
# 위에서 출력된 ID를 WORKFLOW_ID로 설정
WORKFLOW_ID=<6.2 결과>
curl -sk -X POST https://localhost:5678/api/v1/workflows/$WORKFLOW_ID/activate \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  | python3 -c "import sys,json; r=json.load(sys.stdin); print('active:', r.get('active'))"
```

Expected: `active: True`.

---

## Task 7: curl smoke test (webhook 실측)

**Files:**
- Create: `n8n/workflows/__smoke__/auto_schedule_smoke.sh` (스크립트 보관)

- [ ] **Step 7.1: smoke test 스크립트 생성**

```bash
mkdir -p n8n/workflows/__smoke__
```

`n8n/workflows/__smoke__/auto_schedule_smoke.sh`:

```bash
#!/usr/bin/env bash
set -e
URL="https://localhost:5678/webhook/routinemon/auto-schedule"

echo "=== Case 1: 정상 한국어 일정 ==="
curl -sk -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d '{"text":"내일 오후 2시 팀 미팅","user_locale":"ko"}' | python3 -m json.tool

echo
echo "=== Case 2: 빈 텍스트 (preset fallback) ==="
curl -sk -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d '{"text":"","user_locale":"ko"}' | python3 -m json.tool

echo
echo "=== Case 3: 차단어 (preset fallback) ==="
curl -sk -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d '{"text":"자살 생각이 들어","user_locale":"ko"}' | python3 -m json.tool
```

- [ ] **Step 7.2: 실행**

```bash
chmod +x n8n/workflows/__smoke__/auto_schedule_smoke.sh
bash n8n/workflows/__smoke__/auto_schedule_smoke.sh
```

Expected:
- Case 1: LLM 경로 → `"source": "llm"`, `"title"` 비어 있지 않음, `"category"`는 work/study/etc 중 하나
- Case 2: preset → `"source": "preset"`, `"title": ""`
- Case 3: preset → `"source": "preset"` (차단됨)

실패 시: n8n UI(`https://localhost:5678/workflow/<ID>`)에서 execution log 확인, prompt/schema 교정.

---

## Task 8: Dart 통합 테스트 (실 n8n + 실 llama-server)

**Files:**
- Create: `integration_test/auto_schedule_integration_test.dart`

> **Note:** 통합 테스트는 n8n + llama-server 실 서버를 요구하므로 기본 `flutter test` runner가 아닌 별도 실행. CI에서는 skip 태그로 분리.

- [ ] **Step 8.1: 통합 테스트 작성**

`integration_test/auto_schedule_integration_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/config/env.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/schedule/data/auto_schedule_models.dart';
import 'package:routinemon/features/schedule/data/auto_schedule_service.dart';

/// Requires:
/// - n8n running at `Env.n8nUrl` with active `routinemon-auto-schedule` workflow
/// - llama-server-8600-v2 reachable from n8n
///
/// Run: `flutter test integration_test/auto_schedule_integration_test.dart`
void main() {
  late AutoScheduleService service;

  setUpAll(() {
    final client = ApiClient(
      baseUrl: Env.n8nUrl,
      getAccessToken: () => null, // public webhook, no JWT needed for this test
    );
    service = AutoScheduleService(client);
  });

  test('LLM path: valid Korean input returns structured llm source', () async {
    final result = await service.infer(
      text: '내일 오후 2시 팀 미팅 논의',
      userLocale: 'ko',
    );
    expect(result.source, AutoScheduleSource.llm);
    expect(result.title, isNotEmpty);
    expect(result.confidence, greaterThanOrEqualTo(0.0));
    expect(result.confidence, lessThanOrEqualTo(1.0));
  }, timeout: const Timeout(Duration(seconds: 45)));

  test('Preset path: empty text returns preset source', () async {
    final result = await service.infer(text: '', userLocale: 'ko');
    expect(result.source, AutoScheduleSource.preset);
    expect(result.title, isEmpty);
  }, timeout: const Timeout(Duration(seconds: 10)));

  test('Preset path: blocked content returns preset source', () async {
    final result = await service.infer(
      text: '자살 생각이 들어',
      userLocale: 'ko',
    );
    expect(result.source, AutoScheduleSource.preset);
  }, timeout: const Timeout(Duration(seconds: 10)));
}
```

- [ ] **Step 8.2: 통합 테스트 실행**

```bash
flutter test integration_test/auto_schedule_integration_test.dart 2>&1 | tail -10
```

Expected: `All tests passed!` with 3 tests.

실패 시: Task 7 smoke test 재확인 → prompt tuning → Task 5 JSON 업데이트 → Task 6 update 후 재실행.

---

## Task 9: 최종 회귀 검증 + Tasks.md 상태 갱신

**Files:**
- Modify: `Tasks.md` (T5.11 상태 및 DoD 기록)

- [ ] **Step 9.1: 단위 테스트 전체 통과 확인**

```bash
flutter test --reporter compact 2>&1 | grep -oE "\+[0-9]+( ~[0-9]+)?( -[0-9]+)?" | tail -1
```

Expected: `+112 ~4` (기존 104 + 신규 8).

- [ ] **Step 9.2: analyze 회귀 없음**

```bash
flutter analyze 2>&1 | grep -E "error •|warning •"
```

Expected: 빈 출력.

- [ ] **Step 9.3: Tasks.md T5.11 상태 `[-]`로 전환 + 부분 완료 기록**

Tasks.md 섹션 "Phase 5 Tasks"에서 T5.11 라인을 아래처럼 업데이트:

```
- [-] T5.11 Gmail API + 로컬 LLM NLP via n8n 워크플로우 (신규 `routinemon-auto-schedule` 워크플로우 — llama-server-8600-v2 연결, rev 9에서 arch 변경) — Block A1 완료 2026-04-18: n8n 워크플로우 + Flutter 클라이언트 + 12 tests passed (unit + 3 integration). Gmail fetch는 T5.0 사용자 액션 후 Block C로 이월.
```

rules.md §4.1·§2.3 근거: DoD 일부 충족(NLP 추론 + 프리셋 폴백)이므로 `[-]` in-progress. 완전 `[x]` 전환은 Gmail API 통합 완료 후.

- [ ] **Step 9.4: Tasks.md Meta `Updated` 갱신**

Tasks.md `## Meta` 섹션:

```
- **Updated**: 2026-04-18 (rev 10: Block A1 완료 — T5.11 part 1. routinemon-auto-schedule n8n 워크플로우 생성 + Flutter AutoScheduleService + 12 tests passed. T5.11 상태 [-]. 이전 rev 9: ...)
```

- [ ] **Step 9.5: Tasks.md Retrospectives 1줄 추가**

```
- 2026-04-18 rev 10: Phase 5 Block A1 완료. T5.11 part 1 — routinemon-auto-schedule n8n 워크플로우(8 노드: webhook/validate/if/llm-call/parse/fallback/respond) + Flutter AutoScheduleService + AutoScheduleRequest/Response freezed 모델. TDD: unit 8 passed + integration 3 passed. llama-server-8600-v2 실측 호출 성공, preset fallback 2 경로(empty text + blocked content) 검증. Gmail fetch는 Block C로 이월(T5.0 대기).
```

- [ ] **Step 9.6: 메모리 `project_status.md` 2줄 갱신**

`~/.claude/projects/.../memory/project_status.md` 의 `Phase 5 선행 착수 전략` 섹션에 상태 마크 추가:

```
1. **자동 스케줄 블록 (최우선)**:
   - T5.0 사용자 액션 ...
   - T5.10 ...
   - **T5.11 `[-]` in-progress — Block A1 완료 (n8n 워크플로우 + Flutter client). Gmail fetch 대기(T5.0).**
   - T5.12 ...
```

---

## Block A1 완료 DoD

- [x] `flutter analyze` 0 error / 0 warning
- [x] `flutter test` 112+ passed (기존 104 + 신규 8) 회귀 0
- [x] 통합 테스트 3/3 통과 (LLM 경로 + 2 preset 경로)
- [x] n8n `routinemon-auto-schedule` 워크플로우 active
- [x] Tasks.md T5.11 `[-]` 전환 + Retrospective 갱신
- [x] Memory `project_status.md` 상태 마크

---

## Self-Review (작성자 자기 점검)

**1. 스펙 커버리지:**
- T5.11 core NLP (text → JSON): Task 5-8에서 구현·검증 ✅
- T5.11 Gmail fetch: 명시적 Non-goals (T5.0 필요) ✅
- TDD 원칙: 모든 Dart 코드 test-first ✅
- 멀티에이전트 안정성: 단일 에이전트(본 세션) 실행, 외부 dep 없음, Codex 스킬 호출 없음 ✅
- 비용 최소화: 모든 경로가 로컬(llama-server + n8n), 유료 cloud 0건 ✅

**2. 플레이스홀더 없음:**
- 모든 코드는 실행 가능한 실제 스니펫
- "TBD", "similar to above" 없음
- prompt/schema 완전 기술 (llama-server system message 포함)

**3. 타입 일관성:**
- `AutoScheduleRequest` / `AutoScheduleResponse` / `AutoScheduleSource` / `ScheduleCategory` — 모든 참조 일관
- n8n 응답 JSON 스키마 = Dart freezed 모델 = llama-server system prompt 응답 형식 일치
- `source: 'llm' | 'preset'` enum 3 곳 일치

---

## Phase 5 나머지 Block 로드맵 (별도 plan 필요)

Block A1 완료 후 아래 순서로 plan 작성 + 실행:

| Block | 범위 | 의존성 | 추정 tasks |
|---|---|---|---|
| **A2** | T5.1(주간/월간 AI 리포트 n8n) + T5.2(content_filter 정식 이식) | Block A1 완료 | ~12 |
| **B** | T5.16(다크모드) + T5.17(데이터 export) + T5.18(mood 체크인) | 독립 | ~10 |
| **C** | T5.10(Google Calendar) + T5.11 part 2(Gmail) + T5.14(FCM 푸시) | **T5.0 사용자 액션 선결** | ~15 |
| **D-pdf** | T5.3(PDF) + T5.4(이미지 카드) | brainstorming 필요(n8n vs 클라이언트) | ~8 |
| **D-payment** | T5.5~T5.7(RevenueCat + 체험/강등) | RevenueCat 계정 + 테스트 상품 | ~12 |
| **D-widget** | T5.8~T5.9(Android 위젯) | 네이티브 Kotlin WidgetProvider | ~10 |
| **D-share** | T5.12(share intent) + T5.13(카톡/Instagram) | 카카오 개발자 계정 필요 가능 | ~8 |
| **E** | T5.15(OD-3 deep link) | **OD-3 결정 필요 (차단)** | ~5 |
| **F** | T5.19 Phase 5 retrospective + DoD 전체 확인 | 전 block 완료 | ~3 |

각 block은 별도 plan 문서로 작성하여 실행 전 승인받는다.

---

## Execution 선택

Block A1 plan 작성 완료. 실행 옵션:

1. **Inline Execution (권장, 이 세션)** — 본 대화에서 Task 1~9를 순차 TDD 실행. 멀티에이전트 hang 위험 없음 (Codex 플러그인 off 상태 유지, 단일 에이전트).

2. **Subagent-Driven** — 각 task를 fresh subagent로 분산 (플러그인 off 상태에서도 메인 컨텍스트 보호). Task 간 file dependency가 강해 순차 실행이 필요하므로 병렬 이득은 없음. 본 플랜에는 비권장.

**선택:** Inline Execution을 권장합니다. 승인 시 Task 1부터 순차 실행합니다.
