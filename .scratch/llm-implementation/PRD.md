# LLM Implementation Plan — 미구현·가구현 정식 구현

작성일: 2026-05-12
근거: 디바이스 E2E 검증 후속 (project_device_e2e_2026_05_12.md) + Explore 인벤토리 결과
스택: Flutter + Riverpod / n8n (https://localhost:5678) / llama-server-8600-v2 primary + LM Studio fallback

---

## 1. 진단 요약

### 1.1 LLM 호출 6개 webhook 인벤토리

| Webhook | 호출 지점 | 코드 상태 | 실 호출 검증 |
|---|---|---|---|
| `/webhook/routinemon/ai/welcome` | `egg_hatch_page.dart:84` | 완전 구현 + fallback | ❌ 야간 백엔드 down → fallback path 만 시각 확인 |
| `/webhook/routinemon/ai/weekly-report` | `ai_report_service.dart` | 완전 구현 + preset fallback | ❌ 미검증 |
| `/webhook/routinemon/ai/monthly-report` | `ai_report_service.dart` | 완전 구현 + preset fallback | ❌ 미검증 |
| `/webhook/routinemon/auto-schedule` | `auto_schedule_service.dart` | 완전 구현 + empty fallback | ❌ 미검증 |
| `/webhook/routinemon/weekly-wizard` (enhance/refine) | `weekly_wizard_service.dart` | 완전 구현 + rule fallback | ❌ 미검증 |
| `/webhook/routinemon/pdf-report` | `pdf_report_service.dart` | 완전 구현 (LLM 무관, puppeteer) | ❌ 미검증 |

### 1.2 미구현·가구현 4항목 (★)

| ID | 항목 | 근거 | 현재 상태 |
|---|---|---|---|
| L1 | Role-wizard 종료 LLM 후처리 | UC2 사용자 원안 ("마지막에 LLM 통한 추가 질의·명칭 변경") | RoleAnswerProjector 결정론적 매핑만, LLM 0% |
| L2 | Mood AI 분석/제안 | PRD §2.19 | 데이터 수집만 (SharedPrefs), 분석 0% |
| L3 | Notification 자동 추천 | PRD §2.11 | 고정 6채널 알림만, LLM 추천 0% |
| L4 | Gmail NLP 일정 추출 | PRD §2.16 / T5.11 | n8n 워크플로우 기초만, Flutter OAuth fetch 미완료 |

---

## 2. 비목표 (Out-of-scope)

- 수익화·Pro 게이트 (feedback_no_monetization_yet)
- Calendar 쓰기 동기화 (v1.1+ 범위)
- 외부 클라우드 LLM (Gemini/OpenAI/Cloudflare 모두 폐기됨, 로컬 LLM only)
- 새 백엔드 인프라 추가 (n8n + llama-server + LM Studio 만 사용)

---

## 3. Phase A — 기존 5 webhook 실 호출 회귀 검증

목적: "완전 구현" 으로 분류된 5개 LLM 경로가 실 백엔드 가동 시 동작하는지 확정.

| Step | 작업 | 검증 |
|---|---|---|
| A1 | llama-server-8600-v2 기동 확인 (`curl localhost:8600/health`) | health JSON OK |
| A2 | n8n 기동 확인 + 6 webhook active 상태 점검 (`/healthz` + workflow list) | 6 webhook 모두 active |
| A3 | LM Studio fallback 모델 기동 확인 (gemma-4-26b-a4b) | LM Studio API ping OK |
| A4 | egg-hatch 환영 인사 실 호출 (디바이스 신규 펫 생성) | 응답 200 + greeting 텍스트 fallback 아닌 LLM 생성 확인 |
| A5 | weekly-report 실 호출 (`/ai/report` weekly) | 보고서 본문 + source=llm |
| A6 | monthly-report 실 호출 (`/ai/report` monthly) | 보고서 본문 + source=llm |
| A7 | auto-schedule 실 호출 (자유형 텍스트 → 일정) | 구조화 응답 정상 |
| A8 | weekly-wizard enhance 실 호출 (위저드 enhance mode) | rule seed 가 LLM 응답으로 대체됨 확인 |
| A9 | weekly-wizard refine 실 호출 (2턴 multi-turn) | 마지막 2턴 윈도잉 동작 |
| A10 | pdf-report 실 호출 + 디바이스 share sheet | PDF 파일 정상 생성 + 공유 가능 |

**DoD**: 10개 step 모두 통과. Fallback path 가 실 호출 가능 path 를 가려서 회귀를 감추는 위험 제거.

**Commit 기준**: A4-A10 각각의 회귀가 발견되면 별 commit. 회귀 없으면 PRD/Tasks 의 LLM 항목 상태를 "검증됨" 마킹하는 메모 commit 만.

---

## 4. Phase B — L1 Role-wizard 종료 LLM 후처리 (UC2 사용자 원안 완성)

### 4.1 명세

사용자 원안: "각 직업(역할)별 7가지 질의 후, **마지막에 LLM 을 통한 추가 질의나 명칭 변경**".

기능:
1. RoleAnswerDraft(role + 7 answer) 완료 시 LLM 호출 → 다음 중 하나 반환:
   - **추가 질의**: draft 만 가지고 결정 못 한 디테일 (예: "주간 운동을 화/목 으로 고정할까요, 가능한 날 분산할까요?")
   - **명칭 제안**: 사용자 일정 카테고리/태그/요일 라벨을 personalize (예: "스터디" → "토목기사 시험 대비")
2. 사용자 응답 후 RoleAnswerProjector 가 보강된 `WizardAnswers` 생성

### 4.2 새 n8n webhook `/webhook/routinemon/role-wizard-finalize`

요청 페이로드:
```json
{
  "role": "worker",
  "answers": {"q1":"opt-a","q2":"opt-b",...},
  "locale": "ko",
  "turn": 0
}
```

응답 (둘 중 하나):
```json
{"type": "question", "question": "...", "options": ["...", "..."]}
{"type": "finalize", "personalizedLabels": {"focus":"...","goalFocus":"..."}}
```

### 4.3 Flutter 구현 (TDD)

- 신규 `lib/features/schedule/data/role_wizard_finalize_service.dart` (도메인 모델 + API call + retry/fallback)
- 신규 `lib/features/schedule/domain/role_wizard_finalize_models.dart` (freezed 회피, 순수 immutable Dart)
- 신규 `lib/features/schedule/presentation/role_wizard_finalize_step.dart` (page extension)
- 기존 `role_wizard_page.dart` 의 `_showCompletion` 을 finalize step 으로 교체
- 기존 `role_answer_projector.dart` 에 personalizedLabels merge 추가

### 4.4 fallback

- LLM 응답 실패: 기존 결정론적 projector 결과 그대로 사용 + 사용자에게 "맞춤형 추천 비활성" snackbar
- 응답 형식 invalid: skip + 같은 fallback

### 4.5 Test

- service unit: 응답 type=question/finalize/error 3 case + retry
- model unit: JSON encode/decode
- widget: finalize step 렌더 + 추가 질의 답변 후 preview 진입

### 4.6 DoD

- 새 webhook active + flutter test ≥ +10 / analyze 0 / 디바이스에서 7-question 완주 후 LLM step 진입 시각 확인

---

## 5. Phase C — L2 Mood AI 분석/제안

### 5.1 명세

PRD §2.19 근거: 일일 1~5 이모지 데이터를 활용한 분석/제안 LLM 호출.

기능:
1. Mood 페이지 (`mood_history_page`) 에 "AI 분석 보기" 버튼 추가
2. 최근 7~30일 mood 이력 → LLM 으로 패턴 분석 + 1~3 문장 제안
3. 응답을 `mood_insight.dart` 모델로 저장 (Drift) — 캐싱 24h

### 5.2 새 n8n webhook `/webhook/routinemon/ai/mood-insight`

요청:
```json
{
  "moods": [{"date":"2026-05-11","emoji":"😊","score":4}, ...],
  "windowDays": 7,
  "locale": "ko"
}
```

응답:
```json
{
  "summary": "최근 7일 평균 기분은 좋음 (3.8/5)",
  "pattern": "주중 안정, 일요일 하락",
  "suggestion": "일요일 저녁 가벼운 산책을 일정에 추가해보세요"
}
```

### 5.3 Flutter 구현 (TDD)

- 신규 `lib/features/mood/data/mood_insight_service.dart`
- 신규 `lib/features/mood/domain/mood_insight.dart` (model)
- 신규 `lib/features/mood/data/mood_insight_repository.dart` (Drift cache + outbox)
- 새 Drift table `mood_insights` (id/userId/createdAt/summary/pattern/suggestion/windowStart/windowEnd)
- 신규 `lib/features/mood/presentation/mood_insight_tile.dart` (history page 상단)

### 5.4 fallback

- LLM 실패: "분석 데이터 부족" 텍스트
- 7일 이상 데이터 없으면 호출 skip

### 5.5 Test

- service unit (응답 OK / 4xx / 5xx / network)
- model JSON encode/decode
- repository: 24h 캐시 hit / miss
- widget: tile 렌더 / refresh

### 5.6 DoD

- mood 7일 데이터 + LLM 응답으로 insight tile 렌더 시각 확인 / +15 test / analyze 0

---

## 6. Phase D — L3 Notification 자동 추천

### 6.1 명세

PRD §2.11 근거: 6채널 알림 기본. 자동 추천 = "사용자 행동 패턴 기반 알림 시각·메시지 LLM 생성".

기능:
1. 매일 1회 (예: 23:30) 워커가 LLM 에 "내일 추천 알림 3개" 요청
2. 응답 받은 알림을 다음 날 스케줄링 (기존 notification channel 재사용)
3. 사용자 설정에서 ON/OFF 토글 (default OFF — UC3 와 동일 가드 원칙)

### 6.2 새 n8n webhook `/webhook/routinemon/ai/notification-suggest`

요청:
```json
{
  "userId": "...",
  "recentSchedules": [...],
  "recentMoods": [...],
  "recentUsage": [...],
  "locale": "ko",
  "date": "2026-05-13"
}
```

응답:
```json
{
  "notifications": [
    {"time": "08:30", "title": "...", "body": "...", "channel": "schedule"},
    ...
  ]
}
```

### 6.3 Flutter 구현 (TDD)

- 신규 `lib/features/notification/data/notification_suggest_service.dart`
- 신규 `lib/features/notification/domain/suggested_notification.dart`
- 기존 알림 채널 (6종) 재사용
- 새 SharedPrefs flag `notification_ai_suggest_enabled` (default OFF)
- 신규 `lib/features/notification/application/daily_suggest_worker.dart` (workmanager 기존 의존 활용, 새 foreground service 추가 안 함 — Eng P1 원칙)

### 6.4 fallback

- LLM 실패: 추천 알림 0개 (조용히 skip)
- 응답 형식 invalid: skip

### 6.5 Test

- service unit
- worker schedule unit
- 설정 페이지 토글 widget test
- end-to-end: 토글 ON → 워커 trigger → notifications 스케줄됨 (mocked)

### 6.6 DoD

- 디바이스 토글 ON 후 다음 날 알림 등록 확인 / +20 test / analyze 0

---

## 7. Phase E — L4 Gmail NLP 일정 추출 (가구현 → 완성)

### 7.1 명세

PRD §2.16 + T5.11. 이미 n8n 측 워크플로우는 기초 있음 (`.scratch/auto-schedule/`).

기능:
1. Phase 5 OAuth 선행 완료 후 Gmail fetch
2. 가져온 이메일 본문을 LLM 으로 일정 추출 (자유형 텍스트 → 구조화 일정)
3. 사용자 confirm 후 schedule insert

### 7.2 의존성

- T5.0 Gmail OAuth 미완료 — **선행 필요**. 본 phase 는 T5.0 완료 전까지 BLOCKED.

### 7.3 Flutter 구현 스케치 (T5.0 후)

- 신규 `lib/features/gmail/data/gmail_nlp_service.dart` (auto_schedule_service 재사용)
- 신규 `lib/features/gmail/presentation/gmail_extract_page.dart` (추출 결과 confirm UI)
- 기존 `/webhook/routinemon/auto-schedule` 재사용 — Gmail 본문을 input 으로 전달

### 7.4 fallback

- OAuth 실패 / Gmail API rate limit: 사용자에게 명시 에러
- LLM 추출 결과 0건: "추출된 일정 없음" 표시

### 7.5 Test / DoD

- 본 phase 는 T5.0 완료 후 별도 plan revision

---

## 8. Phase F — UI / 설정 토글 통합

각 신규 LLM 기능마다 settings 페이지에 토글 추가:

| 항목 | SharedPrefs key | Default |
|---|---|---|
| Role-wizard finalize LLM | `role_wizard_finalize_enabled` | ON |
| Mood AI insight | `mood_insight_enabled` | ON |
| Notification AI 추천 | `notification_ai_suggest_enabled` | OFF |
| 실시간 HP (기존) | `realtime_hp_enabled` | OFF |

신규 page section "AI 기능" 만들고 4 토글 묶음.

---

## 9. 실행 순서 & 의존성

```
A (검증)
├─ A1~A3 백엔드 기동
├─ A4 환영 인사 ✓
├─ A5~A6 리포트 ✓
├─ A7 auto-schedule ✓
├─ A8~A9 weekly-wizard ✓
└─ A10 PDF ✓

B (Role-wizard finalize) — A8 완료 후 진행
C (Mood insight) — A 완료 후 병렬 가능
D (Notification AI) — A + C 완료 후 (mood 데이터 사용)
E (Gmail NLP) — T5.0 BLOCKED
F (Settings 토글) — B/C/D 각각 완료 직후 incremental

총 신규 commit 예상: A 검증 메모 1 + B 5 + C 4 + D 4 + F 2 ≈ 16 commits
총 신규 test 예상: +50~70
```

---

## 10. 우선순위 결정 권고

| 순위 | Phase | 이유 |
|---|---|---|
| 1 | A | 기존 5 LLM 경로의 실 동작 여부가 모든 후속 phase 의 전제 (n8n workflow 노출, 응답 schema 확인) |
| 2 | B (L1) | UC2 사용자 원안 미완 상태 해소. 다른 phase 보다 사용자 직접 언급 항목 |
| 3 | C (L2) | Mood 데이터는 이미 쌓이고 있음 — 가치 가장 빠르게 발현 |
| 4 | D (L3) | C 의 mood data 와 결합 시 정확도 향상 |
| 5 | E (L4) | T5.0 OAuth 선행 필요 — 별 트랙 |

---

## 11. Open Decisions (사용자 결정 대기)

1. **D1 — Mood insight 기본 ON/OFF?** 원안: ON (가치 즉시 발현). 대안: OFF (privacy gate).
2. **D2 — Notification AI 추천 기본 ON/OFF?** 원안: OFF (행동 학습 데이터 부족 시 노이즈). 대안: ON.
3. **D3 — Role-wizard finalize 단계를 강제 / skippable?** 원안: skippable (LLM 실패 시 결정론 projector 로 graceful). 대안: 강제 (UC2 의도 강화).
4. **D4 — Gmail NLP 를 T5.0 와 묶을지, 본 plan 의 별 phase 로 분리할지?** 원안: 분리 (본 plan 은 LLM 만 책임). 대안: 묶음.

---

## 12. 즉시 실행 가능 task

사용자 wake 시 백엔드 기동만 확인되면:
- A1~A10 회귀 검증 (자율 가능, 약 30~60분)
- A 결과 무회귀 시 → B Phase 자율 착수 (TDD red→green, 약 2~3 시간)

회귀 발견 시 사용자 결정 후 진행.

---

## 13. 참조

- 기존 webhook 사용 규칙: `rules.md §9` (3회 재시도, backoff 500ms→1.5s→3.5s)
- LLM 기동/관리: `~/.claude/projects/-home-str-dgx-spark-Desktop-Reward-Based-Self-Management-AppReward-Based-Self-Management-App/memory/reference_n8n.md`
- 부재 webhook 추가 시 n8n 워크플로우 명세는 `~/.claude/projects/-home-str-dgx-spark-Desktop-Reward-Based-Self-Management-AppReward-Based-Self-Management-App/memory/reference_local_tools.md` 도구 사용
- Eng 원칙 P1 (4th foreground service 회피) — 모든 신규 phase 에 적용
