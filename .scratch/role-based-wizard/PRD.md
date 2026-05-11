# Plan 2 — Role-based Wizard (7-branch + 최종 선택적 LLM)

> 2026-05-11 작성. 이후 `superpowers:brainstorming` / `grill-me` / `to-issues` 로 구체화 예정.

## 배경

기존 위저드 두 흐름이 동시 진화하다가 충돌:
- **로컬 (`weekly-wizard-v2`)**: 답변 → 규칙 기반 플래너 → LLM enhance/refine (자동 호출) → 멀티턴 리파인먼트
- **GitHub v0.1.0 (occupation-aware PR1)**: 직업/생활 패턴 기반 위저드 + step 애널리틱스

새 결정 (2026-05-11): **둘 다 폐기, role-based 분기 + 최종 선택적 LLM 로 통일**.

## 핵심 결정

> **사용자 명시 2026-05-11**: "그 규칙을 각 첫 질문 기준으로 다른 최대 7가지 질의를 주는 형태로 변경. 이후 마지막에 LLM 을 통한 추가 질의나 명칭 변경 등을 하는 형태. LLM 이 필요할때만 호출하면 토큰을 절약할수 있으니 해당 부분을 인지하고 추가 계획을 세운다."

## 흐름

```
[Step 1 — 단일 질문]
"당신의 주된 역할/직업은?"
선택지: 학생 / 직장인 / 프리랜서 / 주부 / 자영업 / 군인 / 기타 (7종 후보)
            ↓ 사용자 선택
[Step 2~8 — 역할별 후속 질문 (최대 7개)]
역할별로 다른 7개 질문 세트
예) 학생: 수업 시간대 / 시험기간 / 통학 여부 / 알바 / 자율학습 / 운동 / 휴식 선호
예) 직장인: 근무 형태 / 출퇴근 / 회식 빈도 / 야근 / 운동 / 자녀 유무 / 취미
            ↓ 7-branch 끝
[규칙 기반 일정 생성 — 100% 로컬, LLM 호출 0]
- 답변 → awake_window / rule_based_planner / conflict_detector 재사용
            ↓ 미리보기
[Step 9 — 사용자 검토 + 선택적 LLM 보강]
- "추가 질문 필요?" → YES 일 때만 LLM 호출
- "일정 명칭 자연스럽게 다듬기?" → YES 일 때만 LLM 호출
- LLM 호출은 명시적 사용자 트리거에만 → 평균 토큰 ≈ 0
```

## 목표

- 위저드 1회 완주당 평균 LLM 호출 ≤ 0.5회 (이전 v2 흐름 대비 대폭 감소)
- 역할별 후속 질문 7개씩 = 깊이 있는 컨텍스트 수집
- 마지막 LLM 호출은 사용자가 명시적으로 원할 때만 (체크박스/버튼/AI 도움 토글)

## 비목표

- Pro 게이트 (LLM 사용 = 무료 사용자에게도 노출 — `feedback_no_monetization_yet.md`)
- 결제/quota 시스템

## 시스템 변경 사항

### 새로 만들거나 갈아엎을 것

- `lib/features/schedule/data/wizard_models.dart` — `Role` enum, `Question` sealed class, `Answer` 타입 안전
- `lib/features/schedule/application/wizard_state.dart` — `selectedRole` 필드, 분기 트리 (`Map<Role, List<Question>>`)
- `lib/features/schedule/presentation/wizard_page.dart` — stepper 가 role 에 따라 동적 7 단계 구성
- `lib/features/schedule/data/weekly_wizard_service.dart` — LLM 호출 진입 = preview 페이지의 명시 액션 트리거만

### 재사용 (그대로 유지)

- `lib/features/schedule/domain/awake_window.dart` — 활성 시간대 계산
- `lib/features/schedule/domain/rule_based_planner.dart` — 규칙 기반 플래너
- `lib/features/schedule/domain/schedule_conflict_detector.dart` — 충돌 감지
- `lib/features/schedule/application/wizard_analytics_service.dart` (Phase A 가져온 것) — step view/complete/back/abandon 이벤트 추적

## Open Decisions (이후 스킬 호출로 채울 것)

1. **역할 enum 의 정확한 선택지** — 7종 후보 (학생/직장인/프리랜서/주부/자영업/군인/기타) 가 적절한가? 추가/제외?
2. **각 역할의 후속 질문 정확한 7개** — 도메인 작업 필요. 예시는 위 흐름 참조.
3. **LLM 호출 트리거 UX** — 체크박스? 버튼? "AI 도움" 토글?
4. **토큰 절감 측정 지표** — 현재 vs 신설계 평균 호출 횟수/세션 정의
5. **n8n 워크플로우 호환성** — `n8n/workflows/routinemon-weekly-schedule-wizard.json` 변경 필요 여부
6. **마이그레이션** — 기존 사용자가 v2 위저드로 만든 일정 처리

## DoD

- [ ] 역할 7종 정의 + 각 역할별 후속 질문 7개 도메인 모델
- [ ] `flutter test` 새 role-based 시나리오 ≥ 5개 통과
- [ ] 평균 LLM 호출 ≤ 0.5회/위저드 완주 (애널리틱스 이벤트로 측정)
- [ ] 위저드 완주 → 미리보기 → 일정 저장 디바이스 E2E 통과
- [ ] 기존 `weekly-wizard-v2` 와 occupation-aware 잔재 폐기 (코드 + Tasks/PRD 정리)

## 폐기 처리 대상

- `.scratch/weekly-wizard-v2/` (LLM enhance/refine, 멀티턴 리파인먼트) — 새 흐름과 정면 충돌
- v0.1.0 측 wizard_state/models/page 변경분 — 가져오지 않음
- `n8n/workflows/routinemon-weekly-schedule-wizard.json` 의 자동 LLM 호출 구간

## LLM 호출 분기 가이드

새 설계의 LLM 호출 경로:
- **자동 호출 0** — 위저드 본 흐름에서는 LLM 호출 없음
- **명시 호출만** — 사용자가 "AI 도움" 명시 트리거 시
- **로컬 LLM 우선** — `llama-server-8600-v2` (gemma-4-E2B-it-Q4_K_M, port 8600) — `reference_n8n.md` 참조
- **Fallback** — LM Studio (gemma-4-26b-a4b)
- **API key**: `.env`
