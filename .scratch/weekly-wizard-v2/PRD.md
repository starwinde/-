# weekly-wizard-v2 — Feature PRD

> 주간 일정 생성(Weekly Wizard, T5.20) 의 대대적 개선. 거버넌스 시나리오 2 (`AGENTS.md`) 기반 feature 컨텍스트.
> 루트 `PRD.md` §2.8 (주간 기반 LLM wizard) 의 단일 진실 원천(SoT) 이며, 본 파일은 v2 작업 단위 컨텍스트.

## 목적

현재 단일 LLM 경로 (15-step → n8n LM Studio → 1회 실패 시 빈 폴백) 의 신뢰성 / 품질 / 안정성 문제를 해결한다. **결정론적 rule-based 생성을 1차 시민으로 승격하고, LLM 은 옵트인 enhance 로 격하**하여 사용자가 LLM 다운/지연 상황에서도 즉시 일정을 받을 수 있게 한다.

## 범위

- **Path A — Rule-based (기본)**: WizardAnswers 15 enum → 결정론 알고리즘 → `GeneratedScheduleItem[]`. LLM 호출 0건. 동기 ≤ 50ms.
- **Path B — LLM Enhance (모든 사용자)**: Path A seed + 추가 프롬프트 → n8n LLM → 향상된 items + diff_summary. 3-retry backoff. 실패 시 seed 폴백. (이전 "Pro 옵트인" 표기 폐기 2026-05-03 — 유료/무료 정책 전면 폐기 결정.)
- **충돌 감지**: 5종 ConflictKind (TIME_OVERLAP / EXISTING_OVERLAP / NO_BREAK / CATEGORY_MONOTONY / OUTSIDE_AWAKE). 생성 직후 자동 + 적용 직전 재검사.
- **Multi-turn refinement**: RefinementSession 5턴 상한, 마지막 2턴 history 윈도잉.
- **analytics**: `wizard_generated`(path) / `wizard_conflict_detected`(kind) / `wizard_enhanced`(turn) / `wizard_applied`(count).

## 비범위 (v2)

- 충돌 자동 해결 (사용자가 수동 처리, 뱃지/sheet 만 제공)
- 다국어 NLP (한국어 + 영어만, 루트 PRD 와 일치)
- LLM 제공자 변경 (gemma-4-e4b on LM Studio 유지)
- Cloud LLM 전환 (rules.md §8.7 + PRD §2.14 비용 정책)

## 의존성

- 기존 `apiClientProvider`, `reportAggregatorProvider`
- 기존 n8n 워크플로우 `routinemon-weekly-schedule-wizard` (v2 에서 mode 분기 추가)
- 기존 LM Studio Local credential (변경 없음)
- gemma-4-e4b 8192 maxTokens 제약

## DoD

- 8 이슈 (`issues/01..08-*.md`) 모두 Status: done
- `flutter analyze` 0 warning, `flutter test` 회귀 0건
- 신규 단위 테스트 ≥ 70 (도메인 + 서비스 + 상태 + UI)
- Path A 동작: LM Studio 다운 상태에서 wizard 진행 → 즉시 items 표시 (실기기)
- Path B 동작: enhance 토글 → 1.5~5s 응답 + diff_summary (실기기, 모든 사용자)
- 충돌 감지: 같은 주에 기존 일정 1건 등록 후 wizard 재진입 → EXISTING_OVERLAP 뱃지 (실기기)
- ADR 0001 + 0002 머지 (선택 0003)
- analytics 이벤트 4종 발송 검증

## 작업 순서

`01 → 02 → 03 → 04 → 05 → 06 → 07 → 08` (위상정렬, 일부 병렬 가능: 02·03 은 01 만 끝나면 동시 진행, 05·06 은 04 만 끝나면 동시 진행)

## Open Decisions

1. **Rule-based 파라미터 튜닝 위치**: `wizard_rule_params.dart` const 시작, 이후 사용자별 학습으로 옮길지 — 1주차 측정 후 결정.
2. **Conflict severity 임계치**: NO_BREAK 의 MIN_BREAK_MIN = 15분? 30분? CATEGORY_MONOTONY 의 N=3 회 적정? — 1주차 실측 후 ADR 0002 확정.
3. **Enhance objective 자동 추천 vs 사용자 선택**: 사용자가 4종 직접 선택 vs 자동 추천 ("load 과중 → rebalance" 자동 채택) — UX 선호도 조사.
4. **fixedSchedules 자연어 파서 범위**: 정규식 best-effort 가닥, 한국어 자연어 다양성 커버리지 미정.
5. **Refinement 토큰 윈도우 크기**: 마지막 2턴 vs 3턴 — gemma-4-e4b 실측 throughput 후 결정 (Issue 07 측정 → ADR 0003).
6. ~~Pro 게이트 위반 시 UX~~ — **폐기 2026-05-03** (유료/무료 정책 전면 폐기).

## 관련 ADR

- `docs/adr/0001-weekly-wizard-rule-based-default.md` (Issue 04 머지 전 작성, `/grill-with-docs` 권장)
- `docs/adr/0002-schedule-conflict-detection-policy.md` (Issue 03 후 1주차 실측 후 머지)
- `docs/adr/0003-llm-multi-turn-refinement-window.md` (선택, Issue 07 측정 후)

## 참고

- 루트 `PRD.md` §2.8 (주간 기반 LLM wizard)
- 루트 `Tasks.md` Phase 5 T5.20 (Wizard 1차 구현 완료 — v2 는 그 위에 빌드)
- `rules.md` §9.1~9.6 (AI/LLM 일반 규칙, §9.3 retry 가 Path B 에 적용)
- `lib/features/schedule/data/weekly_wizard_service.dart` (수정 대상)
- `lib/features/schedule/data/wizard_models.dart` (수정 대상)
- `n8n/workflows/routinemon-weekly-schedule-wizard.json` (수정 대상)
- `~/.claude/plans/lexical-crafting-shell.md` (이번 세션 plan)
