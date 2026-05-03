# 08 — Analytics + ADR + 실기기 보고서

Status: in-progress
의존성: 07
관련 ADR: 0001, 0002, (선택) 0003
진행: 2026-05-03 — ADR 0001/0002 머지 (`docs/adr/`), analytics_events.md 4종 정의 (wizard_generated/conflict_detected/enhanced/applied), test-report.md skeleton 작성. **Deferred**: (a) analytics 발송 wiring (analytics service 미구현, billing 연동 후속 이슈). (b) ADR 0003 (n8n 토큰 ≤ 8KB 실측 후). (c) 실기기 5 시나리오 — ADB 미연결 + llama-server-8600 down 으로 후속.

## 목적

v2 채택률/품질 측정 인프라 정착 + 거버넌스 결정 ADR 머지 + 실기기 5 시나리오 통과 보고서.

## 변경/신규 파일

### 수정
- `lib/features/schedule/data/weekly_wizard_service.dart` (analytics 호출 inject)
- `lib/features/schedule/presentation/wizard_preview_page.dart` (apply 시 호출)
- `analytics_events.md` (이벤트 4종 정의)

### 신규
- `docs/adr/0001-weekly-wizard-rule-based-default.md`
- `docs/adr/0002-schedule-conflict-detection-policy.md`
- `docs/adr/0003-llm-multi-turn-refinement-window.md` (선택)
- `.scratch/weekly-wizard-v2/test-report.md`

## 설계 메모

### Analytics 이벤트

| Event | 발송 시점 | 속성 |
|---|---|---|
| `wizard_generated` | `service.generate()` 후 응답 직전 | `path`: `rule`/`llm`/`preset`, `items_count`, `conflicts_count`, `warnings_count` |
| `wizard_conflict_detected` | conflicts 가 비어있지 않을 때 | `kind` (각 conflict 별 1회), `severity` |
| `wizard_enhanced` | `service.enhance()` 성공 시 | `objective`, `turn`, `retry_count` |
| `wizard_applied` | preview `_apply()` 트랜잭션 직후 | `path`, `items_count`, `confirm_after_conflict`: bool |

`AnalyticsService` (또는 동등) 가 이미 존재하면 재사용. 없으면 단순 print/logger placeholder + TODO 주석 (별도 이슈로 분리는 v2 비범위).

### ADR 골자 (`/grill-with-docs` 권장)

#### 0001 — Weekly Wizard rule-based default
- **Context**: LLM (LM Studio gemma-4-e4b) 다운/지연 시 사용자 빈 결과. §9.3 미준수.
- **Decision**: rule-based 가 기본, LLM 은 옵트인 enhance.
- **Consequences**: §9.3 적용 범위 LLM 경로로 한정. §9.4 무료 사용자 AI 금지 자연 만족. 사용자별 학습 보류 (Open Decision §1).

#### 0002 — Schedule conflict detection policy
- **Context**: wizard 생성 일정이 기존 schedules 와 겹치면 사용자 인지 불가.
- **Decision**: 5종 ConflictKind + severity 정책. 자동 호출 (생성 직후) + 재검사 (적용 직전).
- **Consequences**: 자동 해결은 비범위 (수동 처리만). 임계치 (MIN_BREAK_MIN=15, MONOTONY_N=3) 는 1주차 측정 후 재조정.

#### 0003 (선택) — LLM multi-turn refinement window
- **Context**: gemma-4-e4b 8192 maxTokens 제약.
- **Decision**: 마지막 2턴 윈도잉, 5턴 상한.
- **Consequences**: 토큰 예산 ≤ 8KB 보장. 더 긴 대화는 user-initiated full reset 후 재시작.

### 실기기 보고서 (`.scratch/weekly-wizard-v2/test-report.md`)

5 시나리오 (plan §검증 전략 §실기기 검증):
1. 신규 사용자 15-step → preview 즉시 (≤ 1s) Path A 표시 → 적용 → schedule_page
2. enhance 토글 ON (Pro) → 1.5~5s 응답, diff_summary 표시
3. LM Studio 종료 후 enhance ON → 3 retry → seed + toast
4. 같은 주에 기존 일정 1건 등록 → wizard 재진입 → EXISTING_OVERLAP 뱃지
5. refine 5회 → "더 이상 재생성 불가" 가드

각 시나리오마다 PASS/FAIL + 스크린샷 또는 로그 발췌.

## DoD

- [ ] analytics 이벤트 4종 발송 검증 (단위 또는 통합 테스트, mock analytics)
- [ ] `analytics_events.md` 4종 추가
- [ ] ADR 0001 머지 (`/grill-with-docs` 권장)
- [ ] ADR 0002 머지
- [ ] (선택) ADR 0003 머지
- [ ] 실기기 5 시나리오 PASS, `test-report.md` 작성
- [ ] `flutter analyze` 0 warning
- [ ] `flutter test` 회귀 0건
- [ ] PRD/Tasks Last Updated 갱신, 본 이슈 Status: done 전환
- [ ] 본 PRD `.scratch/weekly-wizard-v2/PRD.md` 의 DoD 모두 체크

## 검증

- 단위 + 통합 + 실기기
- 보고서 작성 후 사용자 리뷰
