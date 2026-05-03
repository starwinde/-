# ADR 0001 — Weekly Wizard: Rule-based 를 기본 경로로 승격

- Status: Accepted
- Date: 2026-05-03
- 관련 이슈: `.scratch/weekly-wizard-v2/issues/04-models-and-service-path-a.md`, `06-llm-enhance-and-retry.md`
- 영향 받는 코드: `lib/features/schedule/data/weekly_wizard_service.dart`, `lib/features/schedule/domain/rule_based_planner.dart`, `n8n/workflows/routinemon-weekly-schedule-wizard.json`

## Context

Phase 5 의 주간 일정 생성 (Weekly Wizard, T5.20) 은 단일 LLM 경로를 사용했다: `WeeklyWizardService.generate()` → n8n `routinemon-weekly-schedule-wizard` → 로컬 LLM (LM Studio gemma-4-e4b 또는 llama-server-8600-v2 gemma-4-E2B-it). 1회 실패 시 즉시 빈 `_preset()` 폴백.

이 구조의 문제:

1. **신뢰성**: LM Studio / llama-server 가 다운, 모델 로딩 지연, 네트워크 끊김 등 운영 환경 변수에 직접 노출. 단일 실패 → 사용자는 빈 결과.
2. **rules.md §9.3 미준수**: "AI 호출 실패 시 3회 재시도 → 폴백 수치 리포트" 가 정착되지 않음 (1회 시도 후 즉시 폴백).
3. **(폐기) rules.md §9.4 와 마찰** — 유료/무료 정책 전면 폐기 (2026-05-03) 으로 본 항목 무효.
4. **출력 품질 단조**: 프롬프트가 generic, past-week context 활용도 낮음, 사용자별 개인화 한계.

대안 검토:

- **A. LLM 강화**: 프롬프트 정교화 + 재시도. 신뢰성 일부 개선되지만 LLM 의존 구조 미해결, §9.4 미해결.
- **B. Cloud LLM 전환**: 안정적이나 PRD §2.14 (개발 비용 정책), rules.md §8.7 (유료 cloud 도입 제약) 위반.
- **C. Rule-based 결정론 + LLM 옵트인** (선택): 결정론 알고리즘이 1차 시민, LLM 은 Pro 전용 향상.

## Decision

생성 경로를 둘로 분리한다:

- **Path A — Rule-based (기본)**: `RuleBasedPlanner` (`lib/features/schedule/domain/rule_based_planner.dart`) 가 결정론 알고리즘으로 `WizardAnswers` → `List<GeneratedScheduleItem>` 생성. LLM 호출 0건. 동기 ≤ 50ms. 모든 사용자에게 제공. 동일 입력 → 동일 출력.
- **Path B — LLM Enhance (모든 사용자)**: `WeeklyWizardService.enhance()` 가 Path A seed 를 LLM 에 전달 → 다양화/재배치/회복 추가/카테고리 정련. rules.md §9.3 의 3-retry backoff (500/1500/3500ms ± 20% jitter) 적용. 4xx 즉시 폴백, 5xx/timeout/parse-fail/empty items 재시도. 3회 모두 실패 시 seed 그대로 반환 + warnings 메시지. (이전 "Pro 옵트인" 표기는 폐기 2026-05-03 — 유료/무료 정책 전면 폐기 결정 반영.)

`WizardSource` enum 에 `rule` 값 추가 (`llm`, `preset` 와 병존). `GeneratedScheduleItem.source` 와 `WeeklyWizardResponse.source` 가 출처를 노출.

## Consequences

긍정:
- LLM 다운 / 지연 시 사용자가 즉시 일정을 받는다.
- §9.3 적용 범위가 LLM 경로 (Path B) 로 명확히 한정.
- LLM 호출 부하 감소 (사용자가 enhance 토글 켤 때만).
- 결정론 출력 → 디버깅/회귀 테스트 용이 (단위 테스트 ≥ 38).

부정 / 트레이드오프:
- 결정론 알고리즘의 출력은 LLM 보다 "단조" 할 수 있다 (template 화). Path B enhance 토글로 보완.
- `wizard_rule_params.dart` const 파라미터 튜닝이 1주차 실측 후 필요 (Open Decision §1, `.scratch/weekly-wizard-v2/PRD.md`).
- 사용자별 학습 / 적응형 출력은 v2 비범위. PastWeekContext 보정 (이행률 < 0.5 → 30% 축소) 외 추가 학습은 후속 결정.

미해결 결정 (PRD Open Decisions 참조):
1. Rule-based 파라미터 튜닝 위치 (const vs 사용자 학습)

## Verification

- 단위 테스트 ≥ 38 (`test/features/schedule/domain/rule_based_planner_test.dart`)
- 결정론 보장 (동일 입력 → 동일 items list)
- 모든 LifestyleStatus × WorkDays × GoalFocus 매트릭스에서 items.length ∈ [10, 18]
- Path B retry 단위 테스트 ≥ 8 (3-retry / 4xx 즉시폴백 / 5xx 재시도 / parse fail / timeout / empty / 1 retry 후 성공)
- 실기기 시나리오 (Issue 08 보고서): LM Studio 종료 후 enhance 토글 → 3회 retry → seed 폴백
