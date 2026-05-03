# 루틴몬 — Tasks

## Meta

- **Current Phase**: 5 (Phase 4 보류 — ComfyUI 환경 이슈로 순서 재조정, 2026-04-18 사용자 승인)
- **Updated**: 2026-05-01 (rev 23 **AI 리포트 + Wizard LangChain 재설계 + LM Studio 단일화**. 사용자 점검 결과 사양 버그 3건 일괄 수정: (1) 리포트 입력이 샘플 하드코딩이었음 → `lib/features/ai/data/report_aggregator.dart` 신규 + `AiReportInputData`에 작성/이행/체크 3축 필드 12개 추가, `ai_report_page._buildRequest()` async + 실제 Drift 집계로 교체. (2) Wizard가 라이프스타일만 보고 일정 생성 → `WizardAnswers.pastWeekContext` 신규 + `report_aggregator.pastWeekContext()` (직전 4주 완료율·미이행 카테고리·미이행 시간대) 자동 주입, n8n systemPrompt에 PAST EXECUTION CONTEXT 섹션 추가. (3) n8n 백엔드 정정 — 전 워크플로우(`routinemon-ai-weekly-report`/`routinemon-ai-monthly-report`/`routinemon-weekly-schedule-wizard`/`routinemon-auto-schedule`)를 LangChain `Basic LLM Chain` + `OpenAI Chat Model` 서브노드 패턴으로 교체, llama-server-8600 폐기 → LM Studio `http://localhost:1234/v1` + `google/gemma-4-e4b` 단일 백엔드. n8n credential `LM Studio Local` 1건 신규 등록 필요. T5.3 PDF 재설계: `routinemon-pdf-report` 워크플로우 폐기, 클라이언트(`pdf` ^3.11.1 + 기존 `printing` ^5.13.4)에서 `AiReportResponse` 직접 렌더(NotoSansKR 다운로드 폰트). 신규 의존성: pdf 직접 추가 1건. 신규 파일: `report_aggregator.dart` + `report_aggregator_test.dart`. 폐기: `routinemon-pdf-report.json`, `pdf_report_integration_test.dart`. flutter analyze 0 errors, flutter test `+192 ~1`(non-integration). 다음 Active Task: T5.3(PDF) 마무리 검수 → T5.21 진입. 이전 rev 22 **T5.21 신규 — 일정별 방해 허용 + 3단계 강도**. 사용자 명시 결정으로 일정에 `allow_disruption`/`disruption_intensity`(1/2/3) 컬럼 추가, schemaVersion v2→v3. L1=짧은 진동+검은 풀스크린 오버레이 5초(Android 일반 앱 화면 OFF 강제 불가 → 오버레이 대체), L2=진동+차단 다이얼로그+홈 강제 이동(Intent ACTION_MAIN/CATEGORY_HOME), L3=강한 진동+풀스크린 차단 + DevicePolicyManager.lockNow 30초 주기(DEVICE_ADMIN 사용자 시스템 설정에서 명시 활성화 필수). 쿨다운 동일 일정 내 30초 1회. 사용자 결정 3건: (1) L1 검은 오버레이, (2) L3 DEVICE_ADMIN 도입, (3) Phase 5 T5.21 배치. PRD §2.8 일정 + FR-21 동기 갱신. n8n 의존 없음(전 동작 클라이언트 측). 신규 의존성 0(Vibrator/DevicePolicyManager 모두 Android SDK). 다음 Active Task: T5.21. 이전 rev 21 **사양 결정 3건 동기화** — T5.3 PDF=n8n HTML→PDF 노드 확정, T5.4 이미지 카드=n8n 확정, T5.8/T5.9 위젯 사이즈 1×1 제거(2×2·4×2만). PRD §2.18 + §3.1 In + Phase 5 DoD + 해당 태스크 라인 동기 갱신. 다음 Active Task: T5.3. 이전 rev 20 **할일 표시 버그 수정** — `watchActive`가 `isTodo.equals(false)` 필터로 할일을 제외하고 있어 WeeklyGridView "할일" 섹션이 영원히 비어 있던 버그. 신규 `watchAllActive(userId)` + `allActiveSchedulesProvider` 추가, WeeklyGridView 스트림을 교체. 기존 `watchActive`/`watchActiveTodos`는 backward compat 유지. adb 원격 제어로 전체 플로우(저장→표시→체크박스 토글) E2E 검증. APK 재설치. 이전 rev 19: Block X (LLM 적응형 2단계 Wizard). — 사용자 요청 "14 질의 이후 LLM이 추가 선택지 제공". n8n 워크플로우 2-mode(initial/refinement) + Validate+Filter 동적 systemPrompt 빌드 + Parse에 followup_questions 포함. WizardResponse에 FollowupQuestion/FollowupOption 모델 + followupQuestions 필드, WeeklyWizardService.refine() 신규, WizardPreviewPage CustomScrollView + ExpansionTile "더 구체화" + 재생성 버튼. 2-agent 팀 `routinemon-p5-x-adaptive`. 새 의존성 0. 신규 tests +8(model 4 + service 4). flutter test `+182 ~4 -1`(rev 18 175 → +8, -1은 기존 flaky LLM integration). smoke: initial → items 16+followups 4 (LLM이 맥락 질문 "출퇴근 수단/학습 목표/취미 유형" 생성), refinement → items 45+followups 0 (답변 반영하여 더 상세히). APK 재설치. 이전 rev 18 수익화 v1.1+ 이월 + T5.17 `[x]`. T5.5/T5.6/T5.7/T5.13 DEFERRED 주석. v1.0 잔여 자율 기능(PDF/이미지카드/위젯/Share intent)은 새 Flutter 패키지 승인 필요. 이전 rev 17: Mood 소급 기록 지원. 이전 rev 16: Block W. — `MoodCheckInDialog`에 날짜·시간 picker 추가, 최대 90일 전까지 선택 가능, "지금" 단축 버튼. T5.18 완료 상태 유지. flutter test `+175 ~4`. APK 재설치. 이전 rev 16: Block W (Wizard 15 질문). 이전 rev 15: Block M (mood 다중 기록+추이). 신규 enum 8종(WakeTime/SleepTime/Chronotype/WorkHours/CommuteTime/MealPattern/ExercisePreferredTime/GoalFocus) + WizardAnswers 필드 8개 추가. WizardPage 동적 스텝 리스트(status 주부·은퇴 시 commute_time 스킵, exercise 없음 시 exercise_preferred_time 스킵) + LinearProgressIndicator N/M. n8n 워크플로우 프롬프트 확장 + max_tokens 4096→8192. 2-agent 팀 `routinemon-p5-w-expand`. 새 의존성 0. flutter test `+175 ~4`(rev 15 171 → +4 신규 wizard_models 3 + 기존 수정). smoke LLM 17 items 생성 확인 (기상·출퇴근·집중·점심·퇴근·저녁·취미·취침 등 라이프스타일 반영). APK 재설치. 이전 rev 15: Block M (mood 확장). 이전 rev 14: Block E. — mood 확장 (timestamp 다중 기록 + fl_chart 추이 그래프). `MoodEntry` 모델 + 신규 storage 규약(`moodEntries_YYYY-MM-DD` JSON 배열) + `mood_YYYY-MM-DD` 레거시 읽기 호환. `MoodHistoryPage` 7/30/90일 LineChart + 오늘 엔트리 리스트 + FAB. `MoodCheckInTile` 재작성(다중 기록 지원 + "기록 보기" 진입점). `/mood/history` 라우트. 2-agent 팀 `routinemon-p5-m-mood` 자율 실행. 새 의존성 0(fl_chart 기존). flutter test `+171 ~4`(rev 14 163 → +8 신규 mood tests), analyze 0, APK 재설치. 이전 rev 14: Block E (일정 편집+완료 토글+할일 섹션) 완료. 일정 카드에 체크박스+strikethrough, onTap→`/schedule/edit/:id`, long-press→softDelete 다이얼로그, 요일 column 하단에 "할일" 섹션 분리(startTime=00:00+isTodo=true 규약), ScheduleCreatePage edit 모드(`scheduleId` 선택 파라미터, 기존값 prefill, 날짜 picker 추가), `ScheduleRepository.update/scheduleActions.updateSchedule`에 `isTodo` 파라미터 확장. 2-agent 팀 `routinemon-p5-e-edit`. 새 의존성 0. flutter test `+163 ~4`(rev 13 161 → +2 신규 smoke), analyze 0, APK 재빌드·Note20 재설치 완료. 이전 rev 13: Block B 잔여 완료(T5.17/T5.18). 2-agent team `routinemon-p5-b-remain`(agent-export/agent-mood) 자율 실행. 새 의존성 0건(Clipboard + SharedPreferences). Settings page 데이터 내보내기 진입점 추가, home dashboard MoodCheckInTile 통합, /settings/export 라우트. flutter test `+161 ~4`(rev 12 152 → +9 신규), analyze 0 warning, APK 재설치 완료. 이전 rev 12: Block S 완료 — T5.20 `[x]`. PRD §2.8 개정(주간 기반 LLM wizard + 수동 추가/편집 공존). 멀티에이전트 팀 `routinemon-p5-s` 5 agents TDD+병렬 실행. 신규 n8n 워크플로우 `routinemon-weekly-schedule-wizard` active + 기타 3 워크플로우 timeout 120s 상향. 전체 flutter test `+152 ~4`(rev 11 132 → +20 신규, 회귀 0). APK 재빌드·Samsung Galaxy Note20 설치·**adb 원격 제어로 Wizard 7단계 자동 실행 → LLM 실제 응답 수신 → 주간 그리드 적용 E2E 검증 완료**. Codex hang 0건. 디버깅 5건: adb reverse 포트 포워딩(5678/8100/8600), HTTPS self-signed cert 수용(debug IOClient), llama-server 모델 E2B→E4B 교체, max_tokens 2048→4096, n8n HTTP timeout 45s→120s. 이전 rev 11: Block A2 + B1 완료. 이전 rev 10: Block A1 완료.)
- **Status legend**: `[ ]` todo, `[-]` in-progress, `[x]` done, `[!]` blocked, `[→]` migrated to `.scratch/<feature>/issues/`

---

## 현재 진행 상태

| Phase | 이름 | 상태 | 예상 일수 |
|---|---|---|---|
| 0 | Bootstrap | `[x]` | 3 |
| 1 | Native UsageStats Bridge | `[x]` | 6 |
| 2 | Auth + Schedule + Pet 도메인 | `[x]` | 8 |
| 3 | Focus Tracking & XP/HP | `[x]` | 8 |
| 4 | Pet Art + Evolution + Interaction | `[!]` | 6 |
| 5 | AI Reports + 결제 + 위젯 + 자동 스케줄 | `[ ]` (선행) | 8 |
| 6 | Closed Beta + 출시 자료 | `[ ]` | 4 |
| 7 | 안정화 + 1.0.0 출시 | `[ ]` | 14 |
| **합계** | | | **57일** |

> ⚠️ 사용자 결정 일정은 45일이지만 페이즈 합계는 57일. 멀티 워커 병렬화로 단축 필요. 페이즈 내부는 warm pool 병렬, 페이즈 경계는 직렬 유지.

> **2026-04-09 rev 2**: 외부 계정 의존 5개 태스크(舊 T0.12~T0.16)를 니드 시점 페이즈로 분산했습니다. 각 페이즈 시작 전 사용자가 외부 계정 작업을 직접 처리해야 진입 가능합니다. (~~Cloudflare~~ → **rev 9에서 Google OAuth + FCM만 유지**→P5, Supabase→P2, GitHub Actions/Sentry/PostHog/Discord→P6)

> **2026-04-18 rev 9**: Phase 4 ↔ Phase 5 실행 순서 스왑. 로컬 ComfyUI 환경 미비로 Phase 4(Pet Art + Evolution + Interaction)를 `[!]` 보류 처리. 실행 순서는 `0→1→2→3→5→4→6→7`로 변경 (번호는 유지, 순서만 변경). Phase 5 선행 착수점은 T5.0(사용자 액션 — rev 9 (3)에서 재정의: Google OAuth Client ID + Gmail/Calendar API + FCM Server Key) → 자동 스케줄 블록(T5.10~T5.12). Phase 4는 ComfyUI 복구 후 Phase 6 진입 전에 재개. 이 변경은 rules.md §2.1 순차 실행 원칙에 대한 사용자 승인 예외다.

---

## Phase 0 — Bootstrap

**목표**: 빈 디렉토리 → Flutter 프로젝트 + Cloudflare Workers scaffold + 거버넌스 3종 (외부 계정 작업 제외)

**DoD**:
- [x] PRD/Tasks/rules 사용자 승인 (T0.1 완료 — 2026-04-09 AskUserQuestion 명시적 승인)
- [x] `flutter analyze` 0 warning (reviewer 재실행 2026-04-09: "No issues found! (ran in 4.8s)", /tmp/reviewer_flutter_analyze.log)
- [x] `flutter build apk --debug` 빌드 성공 (2026-04-10: ✓ Built build/app/outputs/flutter-apk/app-debug.apk 161MB. 수정 3건 — (1) build.gradle.kts isCoreLibraryDesugaringEnabled + desugar_jdk_libs:2.1.4, (2) 루트 build.gradle.kts allprojects Kotlin language/apiVersion 2.0 override (posthog_flutter 1.6 미지원), (3) SDK cmake/ninja x86_64→ARM64 시스템 심볼릭 링크)
- [x] `wrangler dev` 로컬 부팅 + /health 응답 200 (reviewer 재실행: `{"status":"ok","timestamp":"2026-04-09T12:29:02.422Z","service":"routinemon-api"}`, /tmp/reviewer_health.log)
- [x] Pigeon 코드 생성 동작 (Dart/Kotlin 양쪽) (reviewer idempotent 검증: pigeon 재실행 후 .g.dart/.g.kt diff 공백 — /tmp/usage_api_before.g.dart 비교)
- [x] dummy_test.dart 통과 (reviewer: "All tests passed!" sanity check 통과, /tmp/reviewer_flutter_test.log)
- [x] 거버넌스 4파일(PRD/Tasks/rules + REQUIREMENTS_DRAFT STALE) 일관성 확인 (T0.1 완료 시점 사용자 승인)

> **외부 계정 작업 제외**: Cloudflare Secrets / Supabase 프로젝트 / GitHub Actions / Sentry-PostHog SDK 활성화 / Discord webhook은 각 페이즈로 이동했습니다 (아래 표 참조).

**Tasks**:

- [x] T0.1 PRD/Tasks/rules 3종 문서 작성 + 사용자 승인 (DoD: 사용자 명시적 승인 — 2026-04-09 AskUserQuestion "승인 — T0.1 [x]로 전환하고 다음 단계 진행"; REQUIREMENTS_DRAFT.md STALE 통합 완료, PRD §2.15.1 AI 비용 정책 추가, Tasks.md rev 2 외부 계정 5개 분산)
- [x] T0.2 Flutter 프로젝트 scaffold (`flutter create . --org com.starwinde --project-name routinemon`) (DoD: flutter-impl 완료, 35 파일 생성, PRD 4파일 불변 — reviewer 파일 존재 확인: lib/main.dart, lib/app.dart, pubspec.yaml, android/app/src/main/AndroidManifest.xml)
- [x] T0.3 pubspec.yaml 의존성 등록 (Riverpod, go_router, Drift, freezed, Pigeon, supabase_flutter, purchases_flutter, fl_chart, sentry_flutter, posthog_flutter, mocktail) (DoD: flutter-impl 보고 — pub get Got dependencies!, 164 packages, pubspec.lock 39574 bytes 확인)
- [x] T0.4 analysis_options.yaml 강화 (very_good_analysis) (DoD: reviewer `flutter analyze` 재실행 → "No issues found! (ran in 4.8s)")
- [x] T0.5 AndroidManifest.xml 권한 9종 + ForegroundService dataSync (DoD: AndroidManifest.xml 4122 bytes 존재, 12 권한 등재 확인, minSdk 26/target 34 — flutter-impl 보고 및 reviewer 파일 검증)
- [x] T0.6 lib/main.dart, app.dart (ProviderScope, MaterialApp.router, dummy HomePage) (DoD: lib/main.dart 208B + lib/app.dart 1043B 존재, `flutter analyze` 0 issues)
- [x] T0.7 pigeons/usage_api.dart 스텁 + build_runner Pigeon 생성 검증 (DoD: reviewer pigeon 재실행 → .g.dart/.g.kt idempotent 확인, 양쪽 diff 공백)
- [x] T0.8 빈 Drift Database 1개 + 마이그레이션 v1 (DoD: lib/core/db/app_database.g.dart 564B 생성 확인, `flutter analyze` 0 issues)
- [x] T0.9 Cloudflare Workers + Hono scaffold (server/) + wrangler.toml dev/staging/prod (DoD: server/ 디렉토리 생성, wrangler.toml + package.json + tsconfig.json 존재 — reviewer `npx tsc --noEmit` 0 errors)
- [x] T0.10 server/src/middleware/auth.ts (JWT + JWKS 캐싱) — 코드만, Secrets는 P5 (DoD: tsc 0 errors, jose 6.2.2 사용, /tmp/reviewer_tsc.log)
- [x] T0.11 server/src/routes/health.ts + dummy /ai/welcome — 코드만, 실 호출은 P5 (DoD: reviewer `wrangler dev /health` 실측 200 ok — `{"status":"ok","timestamp":"2026-04-09T12:29:02.422Z","service":"routinemon-api"}`; `/ai/welcome` 실측 `{"greeting":"반가워! 우리 함께 멋진 하루를 만들어보자.","petName":null,"source":"preset"}`)
- [x] T0.17 README.md (빌드 방법, 권한 설명, 환경변수) (DoD: reviewer Write로 README.md 완전 대체 — 2026-04-09)
- [x] T0.18 .gitignore + i18n l10n.yaml (ko, en) (DoD: l10n.yaml 97B + lib/l10n/app_ko.arb 50B + lib/l10n/app_en.arb 51B 존재 확인)
- [x] T0.19 dummy_test.dart (DoD: reviewer `flutter test` → "All tests passed!" sanity check 통과, /tmp/reviewer_flutter_test.log)
- [x] T0.20 Phase 0 retrospective (1줄) (DoD: Retrospectives 섹션에 2026-04-09 Phase 0 완료 라인 추가)

### Phase 0에서 분리된 외부 계정 의존 태스크 (rev 2)

| 舊 ID | 새 위치 | 작업 | 사용자 액션 |
|---|---|---|---|
| 舊 T0.13 | **Phase 2 진입 전** (P2.0) | Supabase 프로젝트 생성 + migrations/0001_initial.sql + RLS 정책 | Supabase 계정 + 새 프로젝트 + URL/anon key 발급 |
| 舊 T0.12 | **Phase 5 진입 전** (P5.0, **rev 9 재정의**) | ~~Cloudflare Secrets 셋업~~ → Google OAuth Client ID + Gmail/Calendar API 활성화 + FCM Server Key | ~~Cloudflare/Gemini~~ Google Cloud 프로젝트 + Firebase 프로젝트 (무료) |
| 舊 T0.14 | **Phase 6 진입 전** (P6.0, **rev 9 재정의**) | ~~wrangler deploy preview~~ → .github/workflows/ci.yml (flutter analyze + flutter test + n8n 워크플로우 JSON 린트) | GitHub 저장소 생성 + push 권한 |
| 舊 T0.15 | **Phase 6 진입 전** (P6.0) | Sentry/PostHog/Firebase Analytics SDK 초기화 + opt-in 흐름 | Sentry/PostHog/Firebase 프로젝트 생성 + DSN 발급 |
| 舊 T0.16 | **Phase 6 진입 전** (P6.0) | Discord 서버·채널·Webhook 설정 + 더미 Critical 알림 테스트 | Discord 서버 + 채널 + webhook URL |

---

## Phase 1 — Native UsageStats Bridge

**목표**: Android에서 UsageStats 데이터 → Dart 전달, 권한 플로우 동작 + analytics events spec 골격 수립

**DoD**:
- [x] 실기기에서 권한 거부→허용→queryUsage 정상 동작 (DoD: Samsung Galaxy Note20 SM-N981N Android 13, adb appops allow → 앱 재시작 → PermissionPage 자동 홈 이동, logcat crash/error 0건 — 2026-04-15)
- [x] 권한 거부 상태에서도 앱이 크래시 없이 "권한 필요" 화면 표시 (DoD: 사용자 육안 확인 "보인다", 자물쇠 아이콘 + "설정으로 이동" 버튼 정상 표시, logcat crash 0건 — 2026-04-14)
- [x] Pigeon 인터페이스 변경 시 build_runner로 양쪽 동기화 검증 (DoD: pigeon 재생성 2회 연속 에러 없음 + usage_api.g.dart/UsageApi.g.kt 각 12회 매칭(queryUsageStats/getInstalledPackages/AppUsageInfo), usage_bridge.g.dart 6502B 생성 확인 — reviewer 2026-04-11)
- [x] BlacklistMatcher 단위 테스트 ≥ 5개 통과 (DoD: flutter test 7 passed 3 skipped, test/core/usage/blacklist_matcher_test.dart 6개 전부 통과 — reviewer 2026-04-11)
- [x] `docs/analytics_events.md` 골격 + User Properties 9개 정의 + Phase 1 이벤트 4개 spec 작성 (PRD §2.22 기준) (DoD: PRD §2.22.3 6필드(event_name/trigger/properties/kpi_mapping/phase/sdks) 4개 이벤트 전부 준수 확인 — reviewer 2026-04-11)
- [x] KPI ↔ 이벤트 매핑 표 초기 5개 행 채움 (PRD §2.22.5) (DoD: docs/analytics_events.md §KPI <-> Event Mapping 5행(D7 retention/주간 세션/focus ratio/무료→Pro/Crash-free) — reviewer 2026-04-11)

**Tasks**:

- [x] T1.0 `docs/analytics_events.md` 골격 작성 (PRD §2.22 기준): 헤더, 스키마 형식, User Properties §2.22.4 9개, KPI 매핑 §2.22.5 5행, 핵심 퍼널 §2.22.6 4개, Phase 1 이벤트 4개 (DoD: docs/analytics_events.md 작성 완료, PRD §2.22.3 6필드 준수 — analytics-writer 2026-04-11)
- [x] T1.1 `UsageAccessPermission.kt` (hasPermission, openSettings) (DoD: UsageAccessPermission.kt 작성, AppOpsManager 기반 hasPermission + ACTION_USAGE_ACCESS_SETTINGS openSettings — kotlin-impl 2026-04-11)
- [x] T1.2 `UsageStatsCollector.kt` (queryEvents 기반 직접 합산) (DoD: UsageStatsCollector.kt 작성, queryEvents ACTIVITY_RESUMED/PAUSED 직접 합산 rules.md §7.5 준수 — kotlin-impl 2026-04-11)
- [x] T1.3 `BlacklistMatcher` 순수 Dart + 단위 테스트 (DoD: lib/core/usage/blacklist_matcher.dart 순수 Dart 함수, framework import 0건, 단위 테스트 6개 통과 — dart-impl 2026-04-11, reviewer 검증)
- [x] T1.4 Pigeon API 확장 + UsageApiImpl.kt + MainActivity setUp (DoD: pigeons/usage_api.dart 4 method + AppUsageInfo, pigeon 재생성 성공, UsageApiImpl.kt implements UsageApi, MainActivity.configureFlutterEngine setUp — kotlin-impl 2026-04-11, reviewer 검증)
- [x] T1.5 Dart 측 UsageBridge @riverpod provider (DoD: lib/core/native/usage_bridge.dart 3 provider(usageApi/hasUsagePermission/queryUsageStats/installedPackages) + build_runner → usage_bridge.g.dart 6502B — dart-impl 2026-04-11)
- [x] T1.6 온보딩 권한 요청 페이지 (Settings 이동 흐름) (DoD: lib/features/onboarding/presentation/permission_page.dart + GoRouter /permission 라우트, 권한 거부 시 크래시 없음(try/catch) — dart-impl 2026-04-11)
- [x] T1.7 통합 테스트 (실기기) (DoD: Samsung Galaxy Note20 SM-N981N Android 13에서 앱 설치→실행→권한거부→"권한필요"화면→adb권한허용→앱재시작→자동홈이동 전체 흐름 검증, logcat crash/error 0건. PermissionPage 초기 권한체크→홈 리다이렉트 버그 수정(addPostFrameCallback) — 2026-04-15)
- [x] T1.8 Phase 1 retrospective (DoD: Retrospectives 섹션에 2026-04-11 Phase 1 라인 추가 — reviewer 2026-04-11)

---

## Phase 2 — Auth + Schedule + Pet 도메인

**목표**: 강제 로그인, 일정/할일 CRUD, 펫 도메인 모델·DB·기본 상태 관리

**진입 전 사용자 액션 (P2.0 — 舊 T0.13)**:
- [x] Supabase 계정 + 새 프로젝트 생성 (DoD: self-hosted Docker Compose 가동, localhost:8100/3100 — 2026-04-15)
- [x] Project URL + anon key 발급 → 환경변수로 전달 (DoD: lib/core/config/env.dart + .env ANON_KEY — 2026-04-15)
- [x] migrations/0001_initial.sql 적용 + RLS 정책 검증 (DoD: psql \dt 5테이블 + rowsecurity=t, 14 RLS policies — infra-impl 2026-04-15)

**DoD**:
- [x] Google 로그인 동작 (Supabase Auth) (DoD: Google OAuth Client ID 발급 + Supabase GoTrue Google provider 활성화 + 실기기 Samsung Galaxy Note20에서 Google 로그인 성공, serverClientId 설정 완료 — 2026-04-15)
- [x] JWT가 n8n webhook에 전달되어 검증 통과 (DoD: n8n routinemon-ai-welcome 워크플로우에서 JWT 검증 — Bearer 없으면 401, 있으면 200 + greeting 반환 실측. Workers→n8n 아키텍처 변경 완료 — 2026-04-15)
- [x] 일정·할일 CRUD 동작 (카테고리 + 자유 태그) (DoD: schedule_repository_test.dart 12 tests in-memory Drift 통과, 5 카테고리 enum + 자유 태그 JSON + CRUD + soft delete + outbox enqueue — data-impl+ui-impl 2026-04-15)
- [x] 5단계 온보딩 동작 (DoD: 실기기에서 소개→로그인→권한→집중시간→알선택 전체 흐름 확인. GoRouter keepAlive + onboarding_complete 저장 버그 2건 수정. 크래시 0건 — 2026-04-15)
- [x] 알 부화 5단계 연출 + AI 인사 동기 호출 + 폴백 동작 (DoD: 실기기에서 알→금가루→틀어짐→이름입력→인사 5단계 확인. n8n /webhook/routinemon/ai/welcome 프리셋 폴백 동작. 시작하기→홈 이동 성공 — 2026-04-15)
- [x] `docs/analytics_events.md` Phase 2 이벤트 spec 추가 (DoD: 8개 이벤트 PRD §2.22.3 6필드 준수 — 2026-04-15)
- [x] 온보딩 5단계 퍼널 (PRD §2.22.6) 정의 일관성 확인 (DoD: analytics_events.md 퍼널 signup_started→pet_named 일관 — 2026-04-15)

**Tasks**:

- [x] T2.0 Supabase 프로젝트 생성 + migrations/0001_initial.sql + RLS 정책 (DoD: self-hosted Docker + 5테이블 + 14 RLS policies, psql 검증 — infra-impl 2026-04-15)
- [x] T2.1 Supabase Auth + Google 로그인 UI (DoD: auth_repository.dart + login_page.dart + google_sign_in 패키지, 코드 완료. Google OAuth Client ID 미설정으로 실 로그인 미검증 — auth-impl 2026-04-15)
- [x] T2.2 lib/core/native/api_client.dart 자체 서버 JWT 전달 (DoD: ApiClient Bearer 자동 첨부 + @riverpod provider — auth-impl 2026-04-15)
- [x] T2.3 server/src/middleware/auth.ts JWT 검증 완성 (DoD: Phase 0 코드 유지 + .dev.vars JWKS URL 설정 + /ai/* authMiddleware 적용(F-1 수정) — server-impl 2026-04-15)
- [x] T2.4 Drift sessions_table, tasks_table, pets_table, daily_scores_table, outbox_table (DoD: lib/core/db/tables/ 5파일 + schema v2 + build_runner 성공 — data-impl 2026-04-15)
- [x] T2.5 Schedule feature: 5고정 카테고리 + 자유 태그 + CRUD UI (DoD: domain/data/application/presentation 4-layer + 12 repository tests + outbox enqueue — ui-impl 2026-04-15)
- [x] T2.6 휴지통 (무료 7일 / Pro 60일) (DoD: trash_page.dart soft delete/restore/permanent delete, 기간 제한은 Phase 5 결제 연동 후 — ui-impl 2026-04-15)
- [x] T2.7 Pet 도메인 모델 + 닉네임/별명 검증·검열·길이 제한 (DoD: freezed Pet + PetNameValidator(1-10자+금칙어) + NicknameValidator(2-12자+금칙어, W-7 수정) + 10 tests — data-impl 2026-04-15)
- [x] T2.8 5단계 온보딩 UI (DoD: OnboardingPage PageView 5단계 + GoRouter redirect guard + PermissionPage onComplete 콜백화 + SharedPreferences onboarding_complete — ui-impl 2026-04-15)
- [x] T2.9 AI 첫 일정 제안 (Gemini /ai/schedule_proposal 자체 서버 라우트) (DoD: 5카테고리 프리셋 ko/en + Gemini 분기 준비 + vitest 통과 — server-impl 2026-04-15)
- [x] T2.10 알 부화 5단계 애니메이션 (DoD: EggHatchPage 5단계 AnimatedSwitcher + PetNameValidator + Drift INSERT + outbox + ApiClient /ai/welcome(W-5 수정) — ui-impl 2026-04-15)
- [x] T2.11 server/src/routes/ai.ts /ai/welcome Gemini 분기 (DoD: GEMINI_API_KEY 분기 + 프리셋 폴백 유지 + EN 카테고리 수정(W-3) — server-impl 2026-04-15)
- [x] T2.12 server/src/middleware/content_filter.ts (욕설·자해 검사) (DoD: filterContent() ko/en 욕설+자해 차단 + 5 vitest 통과 — server-impl 2026-04-15)
- [x] T2.13 Phase 2 retrospective (DoD: Retrospectives 섹션에 Phase 2 완료 라인 추가 — 2026-04-15)

---

## Phase 3 — Focus Tracking & XP/HP

**목표**: 세션 추적 → focus_ratio → 등급 → XP/HP 산출 → 진화 체크

**DoD**:
- [ ] 실기기에서 30분 세션 진행 → 종료 시 등급·XP·HP 정확히 산출
- [ ] HP 가중치 차감 + B 등급 즉시 리셋 동작
- [ ] HP 100 overflow → XP 보너스 전환 동작
- [ ] 종별 진화 임계 도달 시 자동 진화 트리거
- [ ] XpCalculator/HpCurve/LevelCurve 단위 테스트 ≥ 15케이스
- [ ] `docs/analytics_events.md` Phase 3 이벤트 spec 추가 (PRD §2.22.2): `focus_session_started`, `focus_session_ended`, `daily_score_recorded`, `pet_evolved`, `hp_critical`, `pet_died`. 특히 `daily_score_recorded.focus_ratio` property는 KPI §8 "평균 focus ratio ≥ 70%" 측정 입력으로 명시
- [ ] 펫 진화 퍼널 (PRD §2.22.6) 정의 일관성 확인

**Tasks**:

- [x] T3.1 lib/core/constants/xp_rules.dart (DoD: FocusGrade enum + GradeReward + XpRules 상수 단일 출처, Codex 확정 수치 전부 반영 — rules-impl 2026-04-15)
- [x] T3.2 XpCalculator 순수 함수 + 단위 테스트 (DoD: gradeFromRatio/xpForGrade/hpForGrade + 7 tests 등급 경계 검증 — rules-impl 2026-04-15)
- [x] T3.3 HpCurve 순수 함수 + 단위 테스트 (DoD: hpDeduction 가중/리셋 + applyHpChange overflow 2:1 + 6 tests — rules-impl 2026-04-15)
- [x] T3.4 LevelCurve 순수 함수 + 단위 테스트 (DoD: checkEvolution 3종 곡선 + shouldDie + 5 tests — rules-impl 2026-04-15)
- [x] T3.5 FocusForegroundService.kt + dataSync foreground type (DoD: START_STICKY + 60초 Handler polling + IMPORTANCE_LOW 알림 채널 — service-impl 2026-04-15)
- [x] T3.6 60초 polling으로 queryEvents → usage_samples 저장 (DoD: FocusSessionController @riverpod Timer.periodic 60초 + FGS background SharedPreferences 캐시 + mergeCachedUsage — service-impl 2026-04-15)
- [x] T3.7 일일 정산 WorkManager + AlarmManager (DoD: workmanager 패키지 + DailySettlementScheduler 24h 주기 기본 04:00 + _timeUntilSettlement — service-impl 2026-04-15)
- [x] T3.8 일일 정산 로직 (DoD: DailySettlement.settle() 순수 함수 — 등급→XP/HP→가중→할일패널티→overflow→진화→사망 + SettlementResult + 16 tests — settlement-impl 2026-04-15)
- [x] T3.9 책상 이탈 감지 (DoD: DeskAwayDetector 순수 Dart — HP -3/회, 30분 쿨다운, 일일 max -9 + 9 tests — interaction-impl 2026-04-15)
- [x] T3.10 할일 미완료 → HP 패널티 (DoD: DailySettlement.taskPenalty() 건당 -3, max -15 + 4 tests — settlement-impl 2026-04-15)
- [x] T3.11 블랙리스트 단계별 개입 (DoD: BlacklistIntervention 순수 Dart + InterventionOverlay UI (SnackBar/AlertDialog/전체화면) + 8 tests — interaction-impl 2026-04-15)
- [x] T3.12 outbox 동기화 엔진 (DoD: OutboxSyncEngine + RemoteSink 추상화 + SupabaseRemoteSink LWW + 5분 Timer + 3회 retry + 9 tests — sync-impl 2026-04-15)
- [x] T3.13 Phase 3 retrospective (DoD: Retrospectives + analytics_events.md Phase 3 이벤트 6개 — 2026-04-15)

---

## Phase 4 — Pet Art (ComfyUI) + Evolution + Interaction

> **상태**: `[!]` 보류 (2026-04-18 사용자 승인). 로컬 ComfyUI 실행 환경 미비로 Phase 5(자동 스케줄) 선행 착수, Phase 4는 ComfyUI 환경 복구 후 Phase 6 진입 전에 재개. PRD §9 OD-8(ComfyUI 실행 책임) 결정도 함께 지연.

**목표**: 픽셀 아트 13세트 생성 → 통합, 진화 애니메이션, 펫 인터랙션

**DoD**:
- [ ] 13세트 PNG 생성 완료, 일관된 픽셀 아트 스타일
- [ ] 진화 애니메이션 2~3초 + 새 일러스트 전환 동작
- [ ] 펫 인터랙션 3종 일일 한도 동작
- [ ] 펫도감 실루엣 → 키운 종 해금
- [ ] Play Store 자료 (아이콘·스크린샷) 초안 생성
- [ ] `docs/analytics_events.md` Phase 4 이벤트 spec 추가 (PRD §2.22.2): `pet_interaction_feed`, `pet_interaction_pet`, `pet_interaction_play`, `pet_dex_unlocked`, `hall_of_fame_viewed`

**Tasks**:

- [ ] T4.1 ComfyUI 1개 LoRA 학습 (새/파충/돌고래 공통 픽셀 스타일)
- [ ] T4.2 13세트 PNG 일괄 생성 (새 5 + 파충 4 + 돌고래 4)
- [ ] T4.3 3종 알 이미지 디자인
- [ ] T4.4 assets/pets/, assets/eggs/ 통합
- [ ] T4.5 진화 애니메이션 2~3초
- [ ] T4.6 펫 인터랙션 UI (먹이·쓰다듬·놀아주기) + 일일 한도 관리
- [ ] T4.7 펫도감 (실루엣 → 해금)
- [ ] T4.8 명예의 전당 사망 기록·정렬·UI
- [ ] T4.9 Play Store 자료 동시 제작 시작
- [ ] T4.10 Phase 4 retrospective

---

## Phase 5 — AI Reports + 결제 + 위젯 + 자동 스케줄

> **이주 알림 (2026-05-03 거버넌스 전환)**: 자동 스케줄 블록 (T5.0 + T5.10~T5.12) 은 `.scratch/auto-schedule/` 로 이주됨. 본 페이즈의 다른 in-progress 블록 (T5.1 ai-reports, T5.21 disturbance) 은 *주된 작업 단위가 될 때* 추가 이주 예정. 완료/Deferred 항목은 이력 보존을 위해 본 파일에 유지.

> **진입 순서 주석 (rev 9)**: 본 페이즈는 Phase 4 보류로 선행 착수한다. 사용자 지시에 따라 **자동 스케줄 블록(T5.0 + T5.10~T5.12)을 최우선**으로 진행하고, 결제(T5.5~T5.7) / 위젯(T5.8~T5.9) / AI 리포트(T5.1~T5.4)는 자동 스케줄 블록 완료 후 순서 결정. Phase 4 재개 시점도 함께 재평가.

**목표**: Pro 차별화 기능 일괄 통합

**진입 전 사용자 액션 (P5.0 — rev 9 재정의, Cloudflare 의존 전면 제거)**:
- [ ] Google Cloud 프로젝트에서 **OAuth 2.0 Client ID (Desktop/Android)** 발급 — Gmail API + Google Calendar API scope 활성화
- [ ] Google Cloud Console에서 **Gmail API + Google Calendar API 활성화** (동일 프로젝트)
- [ ] (선택, T5.14까지 지연 가능) Firebase 프로젝트 생성 + FCM Server Key 발급 (무료 티어)
- [ ] 발급한 키들을 프로젝트 루트 `.env` + n8n Credentials에 저장 (git-ignored 확인)

> **Why**: PRD §2.14 개발 비용 최소화 정책 확정 (2026-04-18 rev 9). Cloudflare Workers + GEMINI_API_KEY 셋업 전면 삭제. AI 호출은 로컬 LLM via n8n으로 대체되어 Gemini/Cloudflare 계정 불필요.

**DoD**:
- [ ] Pro 사용자에게 주간 AI 리포트 자동 생성
- [ ] PDF 다운로드 + 이미지 카드 + 카카오톡/Instagram 공유 동작
- [ ] RevenueCat 결제 흐름 (구매·환불·실패 처리)
- [ ] 무료 15일 체험 → Lite 자동 강등 동작
- [ ] 2종 위젯 (2×2, 4×2) 동작 (rev 21에서 1×1 제외)
- [ ] 일정별 방해 허용 3단계(L1/L2/L3) 동작 (rev 22, T5.21)
- [ ] Google Calendar 일정 읽기 + Gmail NLP 일정 추출 동작
- [ ] Share intent 처리 동작
- [ ] `docs/analytics_events.md` Phase 5 이벤트 spec 추가 (PRD §2.22.2): `paywall_viewed`, `purchase_initiated`, `purchase_completed`, `purchase_failed`, `trial_started`, `trial_expired`, `lite_demoted`, `weekly_report_viewed`, `widget_added`, `auto_schedule_imported`, `share_intent_processed`
- [ ] 결제 3단계 퍼널 (PRD §2.22.6) 정의 일관성 확인 — 무료→Pro 전환율 KPI §8 측정 입력

**Tasks**:

- [→] T5.0 → `.scratch/auto-schedule/issues/01-google-oauth-fcm-setup.md` (이주 2026-05-03)
- [-] T5.1 n8n 워크플로우 `routinemon-ai-weekly-report` + `routinemon-ai-monthly-report` (로컬 LLM 호출 + 폴백) — **Block A2 완료 2026-04-18 (rev 11)**: 2 n8n 워크플로우(weekly ID pV1IjYU3XzFRumXA, monthly ID 2XDn0zQAphZbRc8E, 둘 다 active) + Flutter `AiReportService` + `AiReportRequest/Response/AiReportInputData/ReportPeriod/AiReportSource` freezed 모델. TDD: unit 7 + integration 3 = 10 tests passed. smoke: weekly/monthly 둘 다 source=llm 반환 확인. 실 DB 집계 wiring(focus_sessions/tasks 실데이터)은 Block C 또는 D로 이월.
- [x] T5.2 n8n 워크플로우 내부 content_filter 노드 강화 (Phase 2 `server.archived/middleware/content_filter.ts` 규칙을 JS Code 노드로 이식) — **Block A2 완료 2026-04-18 (rev 11)**: `n8n/shared/content_filter.js` source-of-truth + `lib/core/content/content_filter_types.dart` `ContentFilterReason` enum(selfHarm/profanity/emptyText) + `routinemon-auto-schedule` Validate+Filter 노드 강화(16 키워드, reason 세분화). Dart 3 tests + n8n smoke에서 profanity 차단 실측 통과. DoD 충족 → `[x]`.
- [x] T5.3 PDF 생성: n8n HTML→PDF 노드 (rev 21 확정 — 클라이언트 pdf 패키지 경로 폐기) — **rev 21 완료 2026-04-25**: OD-9 = `n8n-nodes-puppeteer` v1.5.0 채택. 신규 워크플로우 `n8n/workflows/routinemon-pdf-report.json` (ID `XTtI3vBGhMWOt67K`, active, 7 nodes: Webhook→Validate→Is Valid?→Build HTML→Render PDF→Respond PDF / Respond Error) + smoke `n8n/workflows/__smoke__/pdf_report_smoke.sh`. Flutter `lib/features/ai/data/pdf_report_models.dart` (`PdfReportRequest`, `PdfReportMeta` freezed) + `pdf_report_service.dart` (`PdfReportService.render()` → `Uint8List?`) + `lib/features/ai/presentation/ai_report_page.dart` (sample data → LLM 호출 → "PDF 다운로드" FAB → `Printing.sharePdf`). 신규 의존성: `printing ^5.13.4`. UI 진입점: settings 페이지 + `/ai/report` 라우트 (period extra). 검증: (1) **smoke** PDF 122KB %PDF-1.4 A4 한국어 렌더링 OK + 400 응답 OK, (2) **단위 테스트 4 PASS** (200/4xx/5xx/network), (3) **통합 테스트 2/2 PASS**, (4) **flutter test 177 passed 1 skipped 0 failed** 회귀 0건, (5) **analyze 0 warning 0 error**, (6) **실기기 E2E PASS** Samsung Galaxy Note20 (R3CN70T28CZ): APK 설치→홈→설정→"주간 AI 리포트" 진입→LLM 응답 30초 source=llm→FAB 탭→공유 시트→파일관리자 저장→`/sdcard/Download/routinemon-weekly-report.pdf` 165KB %PDF-1.4 매직 OK→logcat crash/error 0건. 워크플로우 JSON 4건 버그 수정 (operation 대소문자 `getPdf`→`getPDF`, 파라미터명 `urlOrHtml`→`url`, 옵션 키 `pdfFormat`→`format`/`pdfPrintBackground`→`printBackground`, HTML 직접 입력 불가 → Build HTML이 `data:text/html;charset=utf-8;base64,...` URL 출력하도록 변경). n8n HTTPS cert 환경 복원 (cert ~/.n8n/ssl/, valid 2027-04-14까지). 멀티에이전트 팀 `routinemon-p5-t53-test` 3-멤버(agent-n8n-deploy/agent-flutter-test/agent-device-e2e, sonnet 4.6) 병렬 실행.
- [ ] T5.4 이미지 카드 생성: n8n HTML→이미지 노드 (rev 21 확정 — Flutter 렌더링 경로 폐기)
- [ ] T5.5 RevenueCat 통합 + 결제 UI + 환불·실패 처리 — **DEFERRED v1.1+ (rev 18, 2026-04-19)**: 사용자 결정으로 수익화 기능 이월. v1.0은 기능 구현 중심.
- [ ] T5.6 무료 15일 체험 흐름 (첫 7일 권한 면제) — **DEFERRED v1.1+ (rev 18)**.
- [ ] T5.7 Lite ↔ Pro 자동 강등 (Pro 만료 시) — **DEFERRED v1.1+ (rev 18)**.
- [ ] T5.8 홈스크린 위젯 2×2, 4×2 (Android Widget Provider, rev 21에서 1×1 제외)
- [ ] T5.9 위젯 갱신 (30분 + 이벤트 트리거, 2×2·4×2 모두)
- [→] T5.10 → `.scratch/auto-schedule/issues/02-google-calendar-read.md` (이주 2026-05-03)
- [→] T5.11 → `.scratch/auto-schedule/issues/03-gmail-nlp-extraction.md` (이주 2026-05-03; Block A1 완료분 + 잔여 작업 보존)
- [→] T5.12 → `.scratch/auto-schedule/issues/04-share-intent.md` (이주 2026-05-03)
- [ ] T5.13 카카오톡 + Instagram 스토리 공유 — **DEFERRED v1.1+ (rev 18)**: 카카오 개발자 계정·SDK 등록 필요 + 수익화 이월과 함께 이관.
- [ ] T5.14 n8n 워크플로우 `routinemon-push` — Firebase FCM REST API 호출 (HTTP Request 노드) + 일일 정산 푸시 (n8n cron)
- [ ] T5.15 푸시 deep link 매핑 (OD-3 결정)
- [x] T5.16 다크모드 + 시스템 따라가기 + 수동 오버라이드 — **Block B1 완료 2026-04-18 (rev 11)**: `lib/core/theme/app_theme.dart` light/dark ThemeData (seed 0xFFA8D8B9 파스텔 그린) + `theme_mode_provider.dart` @Riverpod keepAlive class(SharedPreferences 'theme_mode' 지속) + `lib/features/settings/presentation/settings_page.dart` 3 RadioListTile(system/light/dark) + `/settings` 라우트 + home AppBar 설정 아이콘. `MaterialApp.router` darkTheme + themeMode 통합. 3 tests pass, analyze 0 warning. APK 빌드 + 실기기(Samsung Galaxy Note20) 설치 성공 — 실 테스트 완료.
- [x] T5.17 데이터 내보내기 (JSON, v1.0 무제한) — **rev 13 코드 완료 2026-04-19 → rev 18 `[x]` 전환 (수익화 이월로 Pro 게이트 제거)**: `lib/features/data_export/` JSON export + Clipboard + settings 진입점. 4 tests passed. CSV 포맷 + Pro quota 재활성은 v1.1 수익화 도입 시.
- [x] T5.18 mood 체크인 UI + 누락 시 중립값 — **rev 13 완료 2026-04-19** + **rev 15 확장 2026-04-19**: `lib/features/mood/` SharedPreferences 기반 `MoodRepository` + 5 이모지 다이얼로그 + home dashboard `MoodCheckInTile`. `getMoodOrNeutral()` 누락 시 3 (PRD §2.19). **rev 15 Block M**: timestamp 기반 다중 기록 지원(하루 여러 번 체크인), `MoodEntry(timestamp+mood)` 데이터 모델, `moodEntries_YYYY-MM-DD` JSON 배열 키, `mood_YYYY-MM-DD` 레거시 읽기 호환, `MoodHistoryPage` fl_chart LineChart(7/30/90일) + 오늘 엔트리 리스트 + FAB, `MoodCheckInTile` 재작성(건수+최신 이모지+체크인+기록 보기), `/mood/history` 라우트. 13 mood tests + 1 smoke passed.
- [ ] T5.19 Phase 5 retrospective
- [x] T5.20 **주간 Schedule Wizard** (rev 12 신규 → rev 16 질문 15개 확장 → **rev 19 LLM 적응형 2단계 wizard**): `+` 버튼 → 15 라이프스타일 질문 wizard → n8n `routinemon-weekly-schedule-wizard` (initial + refinement 2-mode) → 로컬 LLM 주간 일정 + **follow-up 질문 3~5개** 생성 → Preview ExpansionTile에서 사용자 답변 → "재생성" 버튼 → LLM refinement → items 업데이트 → bulk INSERT. 주간 그리드(월~일 7-col), 편집/완료 토글/할일 섹션, 수동 경로 유지. **Block S 완료 2026-04-18 (rev 12)**: n8n 워크플로우 `routinemon-weekly-schedule-wizard` (ID ZarYI57NKdZgQSzi, active) + 기타 3 워크플로우 timeout 120s 상향, wizard_models/weekly_wizard_service/insertMany, wizard_page 7-step + wizard_preview_page + WizardState, WeeklyGridView(wide/narrow responsive), schedule_page 전환(주간 뷰 + Wizard FAB + 수동 추가 icon), /schedule/wizard·/schedule/wizard/preview 라우트, api_client.dart debug IOClient + badCertificateCallback. **실기기 E2E 검증 완료** (Samsung Galaxy Note20, adb 원격 제어로 Wizard 7단계 자동 진행 → LLM 실제 응답 수신 → bulk INSERT → 주간 그리드 월요일 탭에 6+ LLM 생성 고유 제목 일정 표시 — "아침 집중 공부 시간/직장 업무/점심시간 휴식/운동/저녁 취미 활동" 등 preset과 명확히 구분되는 LLM 결과). unit/smoke 17 + integration 3 신규 tests pass. DoD 전체 충족.
- [-] T5.21 **일정별 방해 허용 + 3단계 강도** (rev 22 신규 2026-04-25): Drift `schedules` 컬럼 2개(`allow_disruption` BOOL default false, `disruption_intensity` INT default 1) + schemaVersion v2→v3 + MigrationStrategy. Pigeon `DisturbanceApi`(vibrate/launchHome/lockDevice/requestDeviceAdmin/isDeviceAdminActive) + Kotlin 구현(VibrationEffect Android 8+, Intent ACTION_MAIN+CATEGORY_HOME, DevicePolicyManager.lockNow). DeviceAdminReceiver(`<receiver android:permission="BIND_DEVICE_ADMIN">`) + `device_admin.xml`(force-lock policy). 검은/차단 오버레이(L1=BlackOverlay 5초/L2=BlockDialog+홈 강제/L3=BlockFullscreen+lockNow 30초 주기). DisturbanceController(현재 활성 일정 stream + 60s 폴링 → 활성 사용 패키지 감지 → 강도별 액션). ScheduleCreatePage SwitchListTile + 강도 1/2/3 RadioGroup + L3 선택 시 DEVICE_ADMIN 활성화 인텐트 안내. 쿨다운 동일 일정 내 30초 1회. **DoD**: ① schedules 마이그레이션 v2→v3 in-memory 검증, ② 단위 테스트 disturbance_intervention 5 + active_schedule_provider 4 PASS, ③ flutter test 회귀 0건, ④ flutter analyze 0 warning, ⑤ Note20 실기기 L1/L2/L3 시나리오 모두 동작 + DEVICE_ADMIN 활성화 인텐트 안내, ⑥ 앱 실행 시 logcat crash/error 0건. n8n 의존 없음.

---

## Phase 6 — Closed Beta + 출시 자료

**목표**: Closed Beta 5–10명 (가족·친구) + 출시 자료 + 베타 트랙 업로드

**진입 전 사용자 액션 (P6.0 — 舊 T0.14, T0.15, T0.16)**:
- [ ] GitHub 저장소 생성 + 첫 push (git init/remote add/push)
- [ ] Sentry 프로젝트 생성 + DSN 발급
- [ ] PostHog 프로젝트 생성 + API key 발급 + Session Replay 기능 활성화 (PRD §2.21.1)
- [ ] Firebase 프로젝트 생성 + google-services.json 다운로드 + Performance Monitoring 활성화 (PRD §2.21.1)
- [ ] Discord 서버 + Critical 알림 채널 + webhook URL 발급

**DoD**:
- [ ] Play Console Closed Test 트랙 활성화
- [ ] 가족·친구 5–10명 베타 빌드 설치·구동
- [ ] Play Store Data Safety form 제출
- [ ] 개인정보처리방침 + ToS GitHub Pages 호스팅
- [ ] 오픈소스 라이선스 표시 화면 동작
- [ ] GitHub Actions CI 그린 (flutter analyze + flutter test + n8n 워크플로우 JSON 린트) — rev 9에서 wrangler deploy 제거
- [ ] Discord에 7개 Critical 임계(C-1~C-7) 모두 dry-run 알림 도착 확인 (PRD §2.21.2)
- [ ] Sentry/PostHog/Firebase SDK 실제 이벤트 송신 검증
- [ ] PostHog Session Replay 베타 빌드에서 ON 동작 확인 (PRD §2.21.1)
- [ ] Firebase Performance Monitoring NFR-03(콜드 스타트 <2s) / NFR-04(배터리 <5%/day) 실측 데이터 수집
- [ ] `docs/analytics_events.md` Phase 6 이벤트 추가 (`beta_tester_invited`, `beta_session`, `feedback_submitted`)
- [ ] `docs/analytics_events.md` 전체 일관성 검토 (Phase 1~6 이벤트 + KPI §8 5개 모두 매핑됨, 누락 0)
- [ ] PostHog 대시보드에 핵심 4 funnel (PRD §2.22.6) 모두 등록 + 베타 데이터 수신 확인

**Tasks**:

- [ ] T6.0a .github/workflows/ci.yml (flutter analyze + flutter test + n8n 워크플로우 JSON 린트) — 舊 T0.14, rev 9에서 wrangler deploy 경로 폐기
- [ ] T6.0b Sentry/PostHog/Firebase Analytics SDK 활성화 + opt-in 흐름 — 舊 T0.15
- [ ] T6.0c Discord 서버·채널·Webhook 설정 + 더미 Critical 알림 테스트 — 舊 T0.16
- [ ] T6.0d PostHog Session Replay + Firebase Performance Monitoring 베타 한정 활성화 (Remote Config 토글 또는 build flavor `beta` 분기, PRD §2.21.1)
- [ ] T6.0e Discord Critical alert 7개 임계 (C-1~C-7) 자체 서버에서 구현 (PRD §2.21.2): n8n cron 워크플로우 + Sentry alert rule + n8n execution metric + LLM 처리량 counter + dry-run 검증 (rev 9에서 Cloudflare Workers 경로 폐기)
- [ ] T6.0f PostHog 대시보드 구성: 핵심 4 funnel + KPI §8 5개 metric + user property cohort 5개 (free/trial/pro/lite/locale)
- [ ] T6.0g `docs/analytics_events.md` 전체 spec 일관성 검토 + 누락 이벤트 추가 (Phase 1~6 종합)
- [ ] T6.1 릴리스 키스토어 + signing config
- [ ] T6.2 ProGuard/R8 룰 (Drift, Pigeon, Supabase, RevenueCat)
- [ ] T6.3 Play Console Closed Test 트랙 설정
- [ ] T6.4 Play Store Data Safety form 작성·제출
- [ ] T6.5 개인정보처리방침 작성 + GitHub Pages 호스팅
- [ ] T6.6 ToS 표준 템플릿 + 커스터마이징 + GitHub Pages
- [ ] T6.7 About > Open Source Notice 화면
- [ ] T6.8 Play Store 메타데이터 (아이콘·스크린샷·설명·키워드)
- [ ] T6.9 베타 빌드 업로드 + 가족·친구 직접 연락
- [ ] T6.10 Closed Beta 인센티브 결정 (OD-7)
- [ ] T6.11 OD-3 deep link 매핑 확정
- [ ] T6.12 OD-4 동기화 충돌 알림 정책 확정
- [ ] T6.13 OD-5 FOMO 알림 정책 확정
- [ ] T6.14 Phase 6 retrospective

---

## Phase 7 — 안정화 + 1.0.0 출시

**목표**: 1주 버그픽스 + 1주 내부 검증 → 정식 1.0.0 출시 + 베타 한정 측정 도구 OFF

**DoD**:
- [ ] Critical/High 버그 0건
- [ ] 회귀 테스트 + end-to-end smoke 통과
- [ ] Production 트랙 1.0.0 서명·업로드
- [ ] 출시 후 2주간 최소 운영 모드 진입
- [ ] PostHog Session Replay 출시 빌드에서 OFF 검증 (PRD §2.21.1)
- [ ] Firebase Performance Monitoring 출시 빌드에서 OFF 검증 (PRD §2.21.1)
- [ ] 베타 KPI §8 5개 baseline 측정값 PRD §8 또는 별도 baseline 문서에 기록

**Tasks**:

- [ ] T7.1 베타 원격측정(Sentry/PostHog/Firebase) 데이터 분석 + KPI §8 baseline 산출
- [ ] T7.2 Critical/High 버그픽스 (1주)
- [ ] T7.3 내부 검증 회귀 테스트 (1주)
- [ ] T7.4 end-to-end smoke (J1~J5)
- [ ] T7.5 Production 트랙 1.0.0 서명·업로드
- [ ] T7.6 출시 후 2주 최소 운영 모드 진입
- [ ] T7.7 PostHog Session Replay + Firebase Performance Monitoring 출시 빌드에서 OFF 전환 (Remote Config 또는 build flavor 분리, PRD §2.21.1)
- [ ] T7.8 Discord Critical alert 임계값 v1.1 calibration 메모 (PRD §2.21.2 임계가 베타 트래픽 기준 적정한지 평가, 결과를 retrospective에 기록)
- [ ] T7.9 Phase 7 retrospective + 1.0.0 launch retrospective

---

## Backlog (페이즈 미배정, v1.1+)

- B-01 iOS 지원
- B-02 Apple 로그인
- B-03 친구·소셜·리더보드
- B-04 사용자 맞춤 펫 (AI 생성)
- B-05 다중 펫 동시 사육
- B-06 Accessibility Service 기반 실시간 차단
- B-07 Apple Watch / Wear OS
- B-08 위젯 디자인 확장
- B-09 AR 기반 집중 세션 (물리적 공간 인식 + 집중 시간 트래킹 연동, ARCore)

---

## Retrospectives

- 2026-04-09 v2 plan 작성 완료, Phase 0 진입. T0.1 in-progress.
- 2026-04-09 rev 2: REQUIREMENTS_DRAFT 14개 미결정 정리 (13개 PRD에 이미 반영, 1개 §2.15.1로 신규 추가). 외부 계정 의존 5개 태스크를 Phase 2/5/6으로 분산. T0.1 사용자 승인 [x] 전환. 도구 설치 백그라운드 시작.
- 2026-04-09 rev 4: 분석 이벤트 거버넌스 도입 — PRD §2.21.1 분석 stack 표 + §2.21.2 Discord Critical 임계 7건 + §2.22 신설(이벤트 spec 골격, User Properties 9개, KPI 매핑 5행, 핵심 퍼널 4개). Tasks.md에 T1.0 (analytics_events.md 골격), Phase 2~6 DoD에 페이즈별 이벤트 spec 의무, Phase 6에 T6.0d~g (Performance/Replay 베타 활성화 + Critical alert 구현 + PostHog 대시보드 + 일관성 검토), Phase 7에 T7.7~9 (Performance/Replay 출시 OFF + 임계 calibration). 사용자 결정: Stack 3개 유지 + 이벤트 spec 페이즈별 incremental + Performance/Replay 베타만 ON + Discord 임계 PRD §2.21.2 즉시 보강.
- 2026-04-09 Phase 0 완료. 4-멤버 팀(researcher/flutter-impl/server-impl/reviewer) 멀티에이전트 병렬 실행. flutter analyze 0 issues, tsc 0 errors, wrangler dev /health 200 ok. 특이사항: Riverpod/Pigeon/very_good_analysis는 구버전 stable 유지(최신 아님, rules 위반 없음). intl은 flutter_localizations pin 때문에 ^0.20.2로 한 단계 조정. ARM64 workerd 부팅 확인.
- 2026-04-11 Phase 1 코드 완료. 4-멤버 팀(analytics-writer/kotlin-impl/dart-impl/reviewer). BlacklistMatcher를 Dart 순수 함수로 변경(검토 에이전트 §3-B 반영). flutter analyze 0 issues, flutter test 7/7 passed + 3 skipped(integration). Pigeon 재생성 idempotent 확인. Anti-pattern 점검 통과(수기 MethodChannel 0건, domain framework import 0건, 하드코딩 API 키 0건). 실기기 DoD 2건 미충족(실기기 미연결) → Phase 2 blocked until 사용자 실기기 검증.
- 2026-04-15 Phase 1 완료. Samsung Galaxy Note20 (SM-N981N, Android 13) USB 연결. 실기기 DoD 2건 통과: (1) 권한 거부 상태 → "권한 필요" 화면 정상 표시, 크래시 0건 (2026-04-14), (2) adb 권한 허용 → 앱 재시작 → 자동 홈 이동 (2026-04-15). 버그 1건 발견·수정: PermissionPage 초기 로딩 시 권한 allow여도 홈 미이동 → addPostFrameCallback으로 자동 리다이렉트 추가. Phase 2 진입.
- 2026-04-15 Phase 2 코드 완료. 6-멤버 팀(infra-impl/auth-impl/data-impl/ui-impl/server-impl/code-reviewer). TDD 적용: Pet domain 10 tests, Schedule repository 12 tests, Auth 11 tests, content_filter 5 tests, AI routes 6 tests. Code review FAIL 3건 + WARN 3건 전부 수정. Supabase self-hosted + 5테이블 + 14 RLS policies.
- 2026-04-15 Phase 2 완료. Google OAuth Client ID 발급 + GoTrue Google provider 활성화. 실기기 E2E 검증: Google 로그인→온보딩 5단계→알 부화→AI 인사(프리셋)→홈 전체 흐름 성공. GoRouter 버그 2건 수정(routerProvider keepAlive, onboarding_complete 미저장). 아키텍처 변경: Workers→n8n. n8n 워크플로우 3개(routinemon-health/ai-welcome/ai-schedule-proposal) 생성 + JWT 검증 동작 확인. server/→server.archived/. Phase 3 진입.
- 2026-04-15 Phase 3 코드 완료. 5-멤버 팀(rules-impl/interaction-impl/service-impl/settlement-impl/sync-impl). TDD 적용: XpCalculator 7 + HpCurve 6 + LevelCurve 5 + DeskAway 9 + BlacklistIntervention 8 + DailySettlement 16 + OutboxSync 9 = 60 tests 추가. Codex 확정 수치: HP overflow 2:1, 책상이탈 -3 max -9, 할일 -3 max -15, 60초 polling, 서버 LWW ms. flutter test 104 passed. analytics_events.md Phase 3 이벤트 6개. Phase 4 진입. 실기기 DoD(30분 세션 E2E)는 사용자 별도.
- 2026-04-18 rev 9: Phase 4 ↔ Phase 5 실행 순서 스왑. 로컬 ComfyUI 실행 환경 미비(PRD §9 OD-8과 연결)로 Phase 4(Pet Art + Evolution + Interaction)를 `[!]` 보류, Phase 5 자동 스케줄 블록(T5.0 + T5.10~T5.12)부터 선행 착수. 실행 순서는 `0→1→2→3→5→4→6→7`로 변경, 페이즈 번호는 유지. rules.md §2.1 순차 실행 원칙 예외를 사용자가 명시 승인. Active Phase: 5, Active Task 결정 예정(T5.0 사용자 액션 또는 T5.10 Google Calendar OAuth).
- 2026-04-18 rev 9 (2): LLM 제공자 공식 전환 — Gemini Flash → 로컬 LLM via n8n. Primary: llama-server-8600-v2 (http://localhost:8600, `gemma-4-E2B-it-Q4_K_M`, OpenAI 호환), fallback: LM Studio(1234, gemma-4-26b-a4b). 갱신 범위: PRD §2.15(AI 코치)·§2.15.1(비용→처리량 정책)·§2.16(자동 스케줄)·§3.1(MVP In), rules.md §9(Gemini→LLM 일반화, §9.6 신규), Tasks.md T5.11(n8n 워크플로우 기반 재정의). 2026-04-15 Workers→n8n 변경 시 누락됐던 PRD 갱신 빚(§2.15 Gemini 잔존)을 이번에 청산. 신규 n8n 워크플로우 작성 사용자 승인 확보 — T5.11은 `routinemon-auto-schedule` 신규 워크플로우로 구현 예정.
- 2026-04-18 rev 9 (3): Cloudflare Workers 전면 폐기 + 개발 비용 최소화 원칙 공식화. PRD §2.14 "자체 서버 (Cloudflare Workers + Hono)" → "n8n self-hosted + 로컬 LLM"으로 재작성, 유료 cloud 서비스 v1.0까지 신규 도입 금지(허용: Supabase self-hosted + RevenueCat + FCM 무료 티어). rules.md §8 전면 재작성 + §8.7(유료 cloud 승인 규칙) 신규. PRD §2.21 모니터링 출처 Cloudflare→n8n, §2.21.2 C-1~C-7 모두 n8n 기반으로 교체(C-3 cost→LLM 처리량, C-5 wrangler→n8n). Phase 5 P5.0 사용자 액션 전면 재정의: Cloudflare 계정/GEMINI_API_KEY/wrangler 삭제, Google OAuth Client + Gmail/Calendar API + FCM Server Key만 유지. T5.0 재정의, T5.1~T5.4 Hono 경로 폐기→n8n 워크플로우/클라이언트 렌더링, T5.14 push.ts→n8n HTTP Request 노드, T6.0e Discord alert 구현 n8n 기반. 현재 스택: Flutter + Drift + Supabase(Docker) + n8n + llama-server-8600-v2 + RevenueCat + FCM 무료.
- 2026-04-18 rev 10: Phase 5 Block A1 완료. 4-멤버 멀티에이전트 팀(routinemon-p5-a1: agent-models/agent-comment/agent-n8n-spec/agent-service/agent-integration) 5단계 stage 순차-병렬 실행. Codex 플러그인 off 유지로 Stop-hook hang 0건. TDD 엄격 적용: red → fail 확인 → green → regression 체크 패턴 모든 Dart 태스크 준수. 산출물 — (파일) `lib/features/schedule/data/auto_schedule_models.dart`, `auto_schedule_service.dart` + `.freezed.dart` + `.g.dart`, `test/features/schedule/data/*` (9 tests), `test/integration/auto_schedule_integration_test.dart` (3 tests), `n8n/workflows/routinemon-auto-schedule.json` (8 nodes), `n8n/workflows/__smoke__/auto_schedule_smoke.sh`; `lib/core/native/api_client.dart` 주석 rev 9 정정. (n8n 서버) 워크플로우 ID `NrqMGblcgsOTX0f4` active. (테스트) flutter test +116 ~4 (baseline +104 ~4 → +12 신규), analyze 0 error/warning. (실측) smoke 3/3 통과, 통합 3/3 통과. 발견한 이슈: (a) n8n webhook body 접근 `$input.first().json.body` 정상 확인, (b) gemma-4-E2B 모델이 response_format=json_object에도 markdown 코드펜스로 응답 → Parse LLM JSON 노드에서 fence strip 추가, (c) thinking 모드로 max_tokens 512 소진 → 2048 상향 + system prompt "no reasoning" 강화. plan: `docs/superpowers/plans/2026-04-18-phase-5-block-a1.md`. T5.11 상태 `[-]` — Gmail fetch는 T5.0 사용자 액션 후 Block C로 이월.
- 2026-04-19 rev 20: 시간 없는 할일 표시 버그 수정. 사용자가 "시간 지정 없는 할일이 제대로 동작하는지 테스트" 요청 → adb 원격 제어 기반 E2E 검증 중 발견. 저장은 정상(DB에 `is_todo=1, start_time=00:00 KST`)인데 WeeklyGridView에 안 보임. 원인: Block E 구현 시 `ScheduleRepository.watchActive`가 `isTodo.equals(false)`로 할일 제외하는 기존 의미를 남겨둔 채 WeeklyGridView가 `activeSchedulesProvider` → `watchActive` 사용. 할일 섹션 분리 로직이 아무리 정교해도 상류 스트림이 todos를 필터해 버리면 영원히 비어 있음. 수정: (a) `watchAllActive(userId)` — deletedAt.isNull()만 필터, todos 포함, (b) `allActiveSchedulesProvider` 신규, (c) `weekly_grid_view.dart`가 `allActiveSchedulesProvider` 사용, (d) 기존 `watchActive`/`watchActiveTodos`/테스트는 backward compat로 유지(다른 호출자 영향 0). E2E adb 검증: 수동 추가(TimelessTodo1) → 저장 → 일 19 탭 하단 "할일" 섹션 3개 표시 확인 → 체크박스 탭 → 녹색 체크 + strikethrough 반영 확인. APK 재빌드·Note20 재설치 완료.
- 2026-04-19 rev 19: Block X (LLM 적응형 2단계 Wizard) 완료. 사용자 요청: "14개 질의를 통한 시간표 이후 추가 질의를 LLM이 요청 → 추가 선택지 제공 형태". 2-agent 팀 `routinemon-p5-x-adaptive`(agent-x-model + agent-x-ui). 산출물: (a) `WeeklyWizardResponse`에 `followupQuestions: List<FollowupQuestion>` + `FollowupQuestion(id, question, options)` + `FollowupOption(value, label)` freezed 모델, (b) `WeeklyWizardService.refine(answers, weekStart, previousItems, followupAnswers)` 신규 (동일 webhook 재활용, body에 `refinement` 키 포함), (c) n8n 워크플로우 2-mode 확장: Validate+Filter 노드가 `isRefinement` 감지해 systemPrompt 동적 빌드 (initial → 10-18 items + 3-5 follow-ups / refinement → refined items only), Parse LLM JSON 노드가 `followup_questions` 파싱·검증 추가, Preset Fallback은 `followup_questions: []`, (d) WizardPreviewPage를 ListView.builder → CustomScrollView + SliverList(items) + SliverToBoxAdapter(ExpansionTile "🎯 더 구체화하기") + 동적 `RadioGroup<String>` + "재생성" 버튼(모든 답변 후 활성, 재생성 중 CircularProgress). 새 의존성 0. 신규 tests +8 (wizard_models 4 + weekly_wizard_service 4). smoke: initial mode `items:16, followups:4` (예: "출퇴근 수단?/학습 목표 분야?/취미 유형?"), refinement mode `items:45, followups:0`. 전체 flutter test `+182 ~4 -1`(rev 18 175 → +8 신규, -1은 기존 flaky LLM integration concurrency 이슈). analyze 0 error/warning. APK 재빌드·Samsung Galaxy Note20 재설치 완료.
- 2026-04-19 rev 18: 수익화 v1.1+ 이월 + T5.17 `[x]` 전환. 사용자 결정: "15일 무료 체험 등 체험 관련 내용은 일단 배제, 기능 구현 중심 진행". PRD §2.17 개정 — RevenueCat/15일 체험/Lite 강등 전 기능 v1.1+로 이월, v1.0은 **기능 구현 중심**. T5.5/T5.6/T5.7/T5.13 태스크 라인에 DEFERRED 주석 추가(상태는 `[ ]` 유지 — 언젠가 다시 활성 가능). T5.17 정리: `DataExportService.hasQuota/recordUsage` 호출 제거, UI 메시지 "v1.0: 무제한 사용" 변경, `[x]` 전환. Pro quota 코드는 남겨둠(v1.1에서 restore). flutter test 회귀 0 예상(UI 문자열만 변경).
- 2026-04-19 rev 17: Mood dialog 소급 기록 지원. 사용자 요청 "이전 날 기분도 작성 가능하도록". 단일 파일 변경 — `lib/features/mood/presentation/mood_check_in_dialog.dart`를 StatefulWidget으로 승격, `DateTime _dateTime` 상태 + 날짜·시간 OutlinedButton + `_pickDate`(range: 90일 전 ~ 오늘) / `_pickTime`(TimePicker) / `_useNow` 단축 액션 추가. `addMoodEntry(_dateTime, mood)`로 저장. `showMoodCheckInDialog(context, {initialDateTime})` signature 확장 — 기존 caller 하위 호환. title "오늘 기분은?" → "기분 기록". flutter test `+175 ~4` (회귀 0), analyze 0 error/warning. APK 재빌드·Samsung Galaxy Note20 재설치 완료.
- 2026-04-19 rev 16: Block W (Wizard 질문 확장 7→15 + 조건부 스킵 2) 완료. 2-agent 팀 `routinemon-p5-w-expand`(agent-w-models + agent-w-ui) 자율 실행. 사용자 요구: "7가지는 부족, 10~20개 + 앞선 답변에 따라 조건부로". 산출물: 신규 enum 8종(WakeTime/SleepTime/Chronotype/WorkHours/CommuteTime/MealPattern/ExercisePreferredTime/GoalFocus), WizardAnswers 15 필드(required 13 + conditional nullable 2), WizardState.WizardDraft + setters 8 추가, wizard_page.dart 전면 재작성(동적 `_visibleSteps(draft)` — commute_time 주부·은퇴 스킵, exercise_preferred_time 운동=없음 스킵), AppBar `LinearProgressIndicator(value=(i+1)/visible)` + "N/M" 텍스트. n8n 프롬프트 확장(15 필드 전달 + 10-18 items + 라이프스타일 반영 instruction) + max_tokens 4096→8192(finish_reason:length 이슈 해소). 실측 smoke: 17 items LLM 생성 확인 (기상→출근→오전 집중→점심→오후 업무→퇴근→저녁→취침 등). 기존 weekly_wizard_service_test 깨짐 → agent-w-models가 `_sampleAnswers` 헬퍼 추가해 수정. 전체 flutter test `+175 ~4`(rev 15 171 → +4 신규), analyze 0 warning. APK 재빌드·Samsung Galaxy Note20 재설치 완료.
- 2026-04-19 rev 15: Block M (mood 확장 — 시점별 다중 기록 + 추이 LineChart) 완료. 2-agent 팀 `routinemon-p5-m-mood`(agent-mood-repo + agent-mood-history) 자율 실행. 사용자 요청: "단순 기분 체크 넘어서 어느 시점에 기분 좋았는지 안 좋았는지 표시". 산출물: `MoodEntry(timestamp+mood)` value class, `MoodRepository` 신규 API(`addMoodEntry`/`getMoodsForDate`/`getLatestMoodForDate`/`getAverageMoodForDate`/`getMoodsInRange`/`getMoodOrNeutral`) + 구 `setMood`/`getMood` deprecated alias로 backward compat, storage 신규 키 `moodEntries_YYYY-MM-DD` JSON 배열 + 레거시 `mood_YYYY-MM-DD` int 읽기 fallback(정오 단일 엔트리로 surface), `MoodHistoryPage` fl_chart LineChart(일별 평균 y 1~5, 기간 7/30/90일 SegmentedButton) + 오늘 엔트리 리스트(HH:MM + 이모지) + FAB + pull-to-refresh, `MoodCheckInTile` 재작성(건수·최신·체크인·기록보기 2버튼), `MoodCheckInDialog` `addMoodEntry` 경유. Main: `/mood/history` 라우트 + app.dart import. 새 의존성 0(fl_chart ^0.69.2 기존). 테스트: mood 13 pass(repo 12 + history smoke 1), 전체 flutter test `+171 ~4`(회귀 0), analyze 0 error/warning. APK 재빌드·Samsung Galaxy Note20 재설치 완료.
- 2026-04-19 rev 14: Block E (일정 편집 + 완료 토글 + "할일" 섹션) 완료. 주간 그리드 카드가 이제 편집/체크박스/삭제 모두 지원. 2-agent 팀 `routinemon-p5-e-edit`(agent-create-edit/agent-grid-ui) 자율 실행. 사용자 결정 반영: (1) 체크박스 = 모든 일정 (b), (2) 시간 없는 할일 = 요일 column 하단 "할일" 섹션 (규약: `startTime.hour==0 && minute==0 && isTodo=true`). Main 후속: `updateSchedule`/`repository.update`에 `isTodo` 파라미터 추가해 편집 모드에서 할일⇄일정 전환 가능, `_isTodoLocked` 제거, `/schedule/edit/:id` 라우트 등록. 새 의존성 0건. flutter test `+163 ~4`(rev 13 161 → +2 신규 smoke). analyze 0 warning. APK 재빌드·Samsung Galaxy Note20 재설치 완료.
- 2026-04-19 rev 13: Block B 잔여(T5.17 Data Export + T5.18 Mood Check-in) 완료. 2-agent 팀 `routinemon-p5-b-remain`(agent-export/agent-mood) 자율 실행 — 사용자 개입 없이 Flutter UI 블록 완성. 산출물: `lib/features/data_export/` (Clipboard JSON + 월간 quota SharedPreferences, Pro 체크 연결은 Block D-pay 후), `lib/features/mood/` (5 이모지 다이얼로그 + home tile + `getMoodOrNeutral()=3` 중립 기본값). Main: settings에 "데이터 내보내기" 진입점 + `/settings/export` 라우트, home `MoodCheckInTile` 통합. 새 의존성 0건(전략: Clipboard + SharedPreferences로 MVP). T5.17은 `[-]`(무료/Pro quota 실제 체크는 D-pay 후), T5.18은 `[x]`. 신규 tests: data_export 4 + mood 5 = 9. 전체 flutter test `+161 ~4`(회귀 0), analyze 0. APK 재빌드·Samsung Galaxy Note20 재설치 완료.
- 2026-04-18 rev 12 (3): **Block S 실기기 E2E 검증 완료 → T5.20 `[x]`**. adb 원격 제어로 Samsung Galaxy Note20에서 wizard 전 과정(7단계 질문→LLM 호출→Preview→적용→주간 그리드 반영) 자동 실행 검증. LLM 생성 고유 제목(아침 집중 공부 시간/직장 업무/점심시간 휴식/저녁 취미 활동 등) 확인 — preset 9개 획일적 이름과 명확히 구분. 추가 해결: n8n HTTP Request timeout 45s→120s (로컬 LLM 생성 시간 실측 31.8s/1643 토큰 = 51 tokens/sec, 주간 일정 응답 60~90s 소요 → 45s 타임아웃 빈번). adb reverse: 5678+8100+8600 포트 포워딩 유지. 최종 flutter test `+152 ~4`(회귀 0).
- 2026-04-18 rev 12 (2): Block S 실행 중 발견 이슈 3건 해결 — (a) llama-server 모델이 `gemma-4-E2B-it-Q4_K_M` → `gemma-4-E4B-it-Q4_K_M`로 바뀜 → 4개 워크플로우(auto-schedule/ai-weekly/ai-monthly/weekly-wizard) 일괄 교체 + PUT. (b) max_tokens 2048로 E4B가 긴 JSON 생성 중 잘림 → 4096 상향 + PUT. (c) Android 기기에서 `localhost:5678` 도달 불가 + HTTPS self-signed cert 거부 → `adb reverse tcp:5678 tcp:8600` + ApiClient에 debug-only IOClient(`badCertificateCallback` host==localhost) 추가. APK 재빌드·재설치. 통합 테스트 3/3 pass. smoke LLM 13 items 반환 확인. 전체 flutter test `+152 ~4`(integration_test 단독 실행 시) 또는 `+151 ~4 -1`(full suite 동시 실행 시 flaky — 3개 integration 파일이 llama-server 동시 호출로 간헐 timeout, 기능 이상 아님). agent-integration-s 관찰: Dart HttpClient `accept-encoding: gzip` + chunked transfer가 n8n body-parser와 충돌 가능 → 통합 테스트에서 `accept-encoding` 제거 + contentLength 명시 처리.
- 2026-04-18 rev 12: Phase 5 Block S (주간 Schedule Wizard) 코드/서버 완료. PRD §2.8 개정(일일 CRUD → 주간 기반 LLM wizard + 수동 공존, 기존 schema 유지). 5-멤버 팀(routinemon-p5-s: agent-n8n-wizard/wizard-service/weekly-grid/wizard-ui/integration-s). 8 stages TDD+병렬. Codex hang 0건. 산출물 — (신규 파일) `n8n/workflows/routinemon-weekly-schedule-wizard.json`(7 노드), `lib/features/schedule/data/wizard_models.dart`+gens, `weekly_wizard_service.dart`+gen, `lib/features/schedule/application/wizard_state.dart`+gen, `lib/features/schedule/presentation/wizard_page.dart` 7-step PageView, `wizard_preview_page.dart`, `weekly_grid_view.dart`(월~일 7 column + narrow 화면 tab fallback), 6개 test 파일(+17 신규). (수정) `schedule_page.dart` 주간 뷰 전환(WeeklyGridView + Wizard FAB + 수동 추가 icon + 휴지통), `app.dart` /schedule/wizard·/schedule/wizard/preview 라우트 추가, `schedule_repository.dart` `insertMany()` 트랜잭션 추가. (n8n) `routinemon-weekly-schedule-wizard` ID ZarYI57NKdZgQSzi active. 발견한 이슈: `JSON.stringify($json.answers)` (객체)가 llama-server messages[].content 필드에서 object로 해석되어 400 오류 → user content를 고정 문자열("Generate the weekly schedule items JSON now based on the above answers.")로 교체, system prompt가 모든 답변을 이미 포함하므로 정보 손실 없음. 테스트 flutter test `+149 ~4`(회귀 0). smoke 2/2 통과(LLM 11 items + preset 9 items). APK 재빌드 + Samsung Galaxy Note20 재설치 성공. plan: `docs/superpowers/plans/2026-04-18-phase-5-block-s-schedule-wizard.md`(미작성 — inline plan). **사용자 실기기 검증 + S-6 통합 테스트 통과 후 T5.20 `[x]` 전환 예정.**
- 2026-04-25 rev 22: T5.21(일정별 방해 허용 + 3단계 강도) 신규 등록 + `[-]` 진입. 사양 동기화 완료(코드 미진입). PRD §2.8 끝에 방해 허용 항목 + FR-21 추가, Phase 5 DoD에 일정별 방해 허용 동작 추가, Tasks T5.21 라인(DoD 6항목) 추가. 사용자 결정 3건: (1) L1 화면 OFF 강제 불가 → 검은 풀스크린 오버레이 5초로 대체, (2) L3 DEVICE_ADMIN 도입 + DevicePolicyManager.lockNow 30초 주기 (사용자 시스템 설정에서 명시 활성화), (3) Phase 5 신규 T5.21 배치(현재 active phase 일치 + 일정·알림·집중 추적 모두에 걸침). Android 일반 앱 제약 사전 조사 — `forceStopPackage` 시스템 전용 → 차단 풀스크린 오버레이 + 홈 강제 이동(Intent ACTION_MAIN/CATEGORY_HOME)으로 대체. 신규 의존성 0(Vibrator/DevicePolicyManager 모두 Android SDK). plan: `~/.claude/plans/concurrent-dancing-badger.md`.
- 2026-04-25 rev 21 (2): T5.3 PDF 생성 완료. `[-]` → `[x]`. 멀티에이전트 팀 `routinemon-p5-t53-test` 3-멤버(sonnet 4.6) 병렬 실행 — agent-n8n-deploy(워크플로우 import + active + smoke + HTTPS 복원) / agent-flutter-test(통합 + 회귀 + analyze) / agent-device-e2e(APK 설치 + adb 원격 PDF 다운로드 E2E). 검증 산출물: smoke PDF 122KB %PDF-1.4 A4 한국어, 통합 테스트 2/2 PASS, flutter test 177 passed 1 skipped 0 failed(회귀 0), analyze 0 warning, 실기기 PDF 165KB `/sdcard/Download/routinemon-weekly-report.pdf` 매직 OK + logcat crash/error 0건. 발견·수정한 이슈 5건: (a) n8n-nodes-puppeteer v1.5.0 노드 인터페이스 4건 — `getPdf`→`getPDF` 대소문자 / `urlOrHtml`→`url` 파라미터명 / `pdfFormat`/`pdfPrintBackground`→`format`/`printBackground` 옵션 키 / `url`이 valid URL이어야 → Build HTML이 `data:text/html;charset=utf-8;base64,...` URI 출력하도록 변경, (b) n8n 재시작 시 N8N_PROTOCOL=https 환경변수 누락 → HTTP로 떨어진 후 통합 테스트 TLS 핸드셰이크 실패 → cert 경로(`~/.n8n/ssl/n8n.crt`/`n8n.key`) 복원하여 HTTPS 재가동. 의존성 1건 추가: `printing ^5.13.4`(rules.md §1.4 사용자 승인). 새 워크플로우 `routinemon-pdf-report` (ID `XTtI3vBGhMWOt67K`, active). 새 라우트 `/ai/report`. UI: settings → "주간/월간 AI 리포트" 진입점 + FAB. plan: `~/.claude/plans/concurrent-dancing-badger.md`.
- 2026-04-25 rev 21: 사양 결정 3건 동기화. 사용자 결정 — (1) T5.3 PDF 생성 = n8n HTML→PDF 노드 확정 (클라이언트 pdf 패키지 경로 폐기), (2) T5.4 이미지 카드 = n8n HTML→이미지 노드 확정 (Flutter 렌더링 경로 폐기), (3) 홈 위젯 사이즈 1×1 제외 → 2×2와 4×2만 지원. 갱신 범위: PRD §2.18(1×1 제거 + 결정 일자 명시) + §3.1 In(위젯 3종→2종) + Tasks.md Meta `Updated` rev 21 + Phase 5 DoD(3종→2종) + T5.3/T5.4/T5.8/T5.9 라인. 다음 Active Task: T5.3. 코드 변경 0(문서만), 회귀 위험 0.
- 2026-04-18 rev 11: Phase 5 Block A2 + B1 완료. 4-멤버 멀티에이전트 팀(routinemon-p5-a2b1: agent-filter/agent-ai-report/agent-theme/agent-ai-integration) 5단계 실행. Codex hang 0건. T5.1 `[-]`(코드/n8n 완료, 실 DB 집계 wiring 이월), T5.2 `[x]`, T5.16 `[x]`. 산출물 — (파일 신규) `n8n/shared/content_filter.js`, `lib/core/content/content_filter_types.dart` + test, `lib/features/ai/data/ai_report_{models,service}.dart` + gens + tests, `n8n/workflows/routinemon-ai-{weekly,monthly}-report.json`, `lib/core/theme/{app_theme,theme_mode_provider}.dart` + gen + test, `lib/features/settings/presentation/settings_page.dart`, `test/integration/ai_report_integration_test.dart`, `build.yaml` (freezed explicit_to_json). (파일 수정) `lib/app.dart`(darkTheme+themeMode+/settings 라우트+home AppBar 아이콘), `n8n/workflows/routinemon-auto-schedule.json`(Validate+Filter 노드 강화). (n8n 서버) auto-schedule PUT 갱신, weekly ID pV1IjYU3XzFRumXA active, monthly ID 2XDn0zQAphZbRc8E active. (테스트) flutter test +132 ~4 (rev 10 +116 → +16 신규), analyze 0 error/warning. (실측 smoke) auto-schedule 기존 3 회귀 pass + profanity 차단 추가 pass + weekly llm source + monthly llm source 검증. (실측 통합) 3/3 pass. (실기기) Samsung Galaxy Note20에 APK 설치 성공(`flutter build apk --debug`). **기술 부채 해결**: (a) workmanager 0.5.2 Flutter v1 embedding API 사용 → 0.9.0으로 업그레이드 + daily_settlement_scheduler.dart 2곳 API 교정(NetworkType.notRequired, ExistingPeriodicWorkPolicy). (b) Kotlin 컴파일러가 libtinfo.so.5 요구 → Ubuntu ARM64는 .so.6만 제공 → user-level symlink `~/.local/lib/libtinfo.so.5` + gradle.properties `-Djava.library.path=/home/str_dgx_spark/.local/lib:/lib/aarch64-linux-gnu`. 이 둘은 Phase 3 T3.7 완료 시점에 APK 빌드를 검증하지 않은 기술 부채. plan: `docs/superpowers/plans/2026-04-18-phase-5-block-a2-b1.md`.
