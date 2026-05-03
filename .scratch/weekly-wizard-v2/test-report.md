# Weekly Wizard v2 — 실기기 검증 보고서

> Issue 08 산출물. 실기기 (Android) 5 시나리오 PASS/FAIL + 로그 발췌.
> Status: **PENDING — 휴대폰 ADB 미연결, llama-server-8600 down 상태로 대기**

## 환경 점검 (2026-05-03 세션 기준)

| 항목 | 상태 | 메모 |
|---|---|---|
| Supabase Docker | ✅ healthy (4시간+ uptime, supabase-db 5432) | 활성화 불필요 |
| n8n (5678) | ✅ /healthz 200 | active |
| LM Studio (1234) | ⚠️ 401 (API key 헤더 없으면 정상 403/401) | fallback LLM |
| llama-server-8600-v2 | ❌ 미응답 | **primary LLM down** — Path B 시나리오 보류 |
| ADB devices | ❌ 0건 | 휴대폰 무선/USB 연결 필요 |

## 자동 테스트 결과 (휴대폰 미연결 상태에서 가능한 부분)

- `flutter analyze`: **0 warning, 0 error** (info-level 만)
- `flutter test test/features/schedule/`: **162/162 PASS** (rule_based_planner 38, conflict_detector 18, weekly_wizard_service 19, wizard_state 11, wizard_preview_page 9, awake_window 15, wizard_models 32, schedule_repository 12, weekly_grid_view 4, schedule_create_page_edit_smoke 4)
- `flutter test` 전체: 215/215 + 4 skipped + LLM-path integration 2 (llama-server-8600 down 으로 대기)

## 시나리오 (실기기 — 미실행)

### 시나리오 1: 신규 사용자 15-step → Path A 즉시 응답 (≤ 1s)
- **목표**: wizard 진입 → 15 step 완료 → preview 즉시 표시 → 적용 → schedule_page 노출
- **상태**: ❌ ADB 미연결로 미실행
- **체크리스트**:
  - [ ] preview 표시 ≤ 1s
  - [ ] items.length ∈ [10, 18]
  - [ ] source 칩 모두 "기본"
  - [ ] conflicts banner 부재 (existing 0건)

### 시나리오 2: enhance 토글 ON (Pro) → 1.5~5s LLM 응답
- **목표**: Path B 정상 동작
- **상태**: ❌ entitlementProvider 미구현 + llama-server-8600 down 으로 미실행
- **선결**: billing wiring + LLM primary 복구

### 시나리오 3: LM Studio 종료 → 3 retry → seed 폴백
- **목표**: §9.3 retry 동작 검증
- **상태**: ❌ ADB 미연결로 실기기 검증 보류 — 단위 테스트 (8개) 통과로 코드 정합성은 확인됨
- **체크리스트**:
  - [ ] 3회 retry 진행 표시기
  - [ ] seed 결과 + warning toast

### 시나리오 4: 같은 주에 기존 일정 1건 → wizard 재진입 → EXISTING_OVERLAP 뱃지
- **목표**: ScheduleConflictDetector + UI 뱃지 검증
- **상태**: ❌ 미실행
- **체크리스트**:
  - [ ] 빨강 error 아이콘
  - [ ] 행 탭 → 충돌 sheet
  - [ ] 적용 시 confirm dialog

### 시나리오 5: refine 5회 → "더 이상 재생성 불가" 가드
- **목표**: RefinementSession.maxTurns 가드 검증
- **상태**: ❌ 미실행. 단위 테스트 (Notifier 6개) 통과로 가드 로직은 확인됨
- **체크리스트**:
  - [ ] "재생성 5/5" 카운터
  - [ ] lock 아이콘 + "한도 도달"
  - [ ] 재생성 버튼 비활성

## 후속 액션

1. ADB 휴대폰 연결 (USB/무선) 후 5 시나리오 순차 실행, 본 보고서에 PASS/FAIL + 스크린샷 기록.
2. llama-server-8600 복구 → integration test `weekly_wizard_integration_test.dart` 재실행.
3. n8n 워크플로우 `routinemon-weekly-schedule-wizard.json` 의 `mode` 분기 추가 (initial/refine/enhance) — 수동 편집 또는 n8n MCP 도구 사용.
4. entitlementProvider (RevenueCat 연동) wiring 후 Pro 게이트 + Paywall UX 결정 → ADR 또는 Open Decision §6 해결.
5. (선택) Issue 07 의 ADR 0003 (multi-turn 토큰 윈도우 ≤ 8KB) — n8n test execution 으로 토큰 사이즈 측정 후 작성.
