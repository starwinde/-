# ADR 0002 — Schedule Conflict Detection Policy

- Status: Accepted (임계치는 1주차 실측 후 재조정 가능)
- Date: 2026-05-03
- 관련 이슈: `.scratch/weekly-wizard-v2/issues/03-schedule-conflict-detector.md`, `04-models-and-service-path-a.md`, `05-preview-conflict-badges.md`
- 영향 받는 코드: `lib/features/schedule/domain/schedule_conflict_detector.dart`, `lib/features/schedule/domain/conflict_report.dart`, `lib/features/schedule/data/wizard_models.dart`, `lib/features/schedule/presentation/wizard_preview_page.dart`

## Context

기존 wizard 는 생성된 일정과 (a) 자기 자신 슬롯 간 (b) 기존 DB schedules 간 시간 겹침을 검사하지 않았다. 사용자는 충돌을 수동으로 발견해야 했고, 적용 후에야 알아차리는 경우가 발생.

`.scratch/auto-schedule/PRD.md` 의 비범위에 "일정 충돌 자동 해결 (사용자가 수동으로 처리)" 가 명시되어 있어 **자동 해결은 비범위**, 다만 wizard 측은 **감지 + 사용자 알림**은 필수.

## Decision

5종 ConflictKind 와 severity 분류를 정의하고 자동 호출 지점을 두 곳으로 한정한다.

### ConflictKind + Severity

| Kind | Severity | 의미 | 임계치 |
|---|---|---|---|
| `timeOverlap` | error | 동일 day 내 두 신규 items 의 [start, end) 구간 겹침 | strict |
| `existingOverlap` | error | 신규 items 와 기존 DB schedules (deletedAt is null & 같은 ISO week) 간 겹침 | strict |
| `noBreak` | warning | 인접 items gap < `kMinBreakMin` (=15) 분, work→work 는 `kMinBreakWorkToWork` (=30) | gap < threshold |
| `categoryMonotony` | warning | 동일 day 동일 category `kCategoryMonotonyN` (=3) 회 연속 | sliding window |
| `outsideAwake` | warning | wake 이전 / sleep 이후 배치 (자정 넘김 윈도우 처리 포함) | AwakeWindow.contains() |

### 자동 호출 지점

1. **생성 직후 자동**: `WeeklyWizardService.generate()` 가 Path A 결과에 `ScheduleConflictDetector.detect()` 호출 → `WeeklyWizardResponse.conflicts` 첨부.
2. **적용 직전 재검사 (선택적, UI 측)**: `WizardPreviewPage._apply()` 트랜잭션 직전에 사용자가 항목 수정한 가능성을 고려한 재검사 후 confirm dialog 표시.

### UI 정책

- 행별 뱃지 (error 빨강 / warning 노랑 / clean 무뱃지)
- 페이지 상단 summary banner (error N건 / warning M건)
- 행 탭 → bottom sheet 에 충돌 상세 (kind, message, 영향 행)
- error severity 가 1건이라도 있으면 적용 전 confirm dialog ("그래도 적용?")

## Consequences

긍정:
- 사용자가 적용 전 충돌을 인지 가능, 수동 처리 경로 명확.
- ConflictKind 가 enum 으로 고정되어 신규 카테고리 추가 시 일관된 규칙 강제.
- 단위 테스트 ≥ 18 (`test/features/schedule/domain/schedule_conflict_detector_test.dart`).

부정 / 트레이드오프:
- 임계치 (15/30/3) 는 1주차 실측 데이터 없이 설정. 실측 후 재조정 (Open Decision §2, `.scratch/weekly-wizard-v2/PRD.md`).
- 자동 해결은 비범위 — 사용자가 매번 수동 처리해야 함. v1.x 후속 결정.

## Verification

- 단위 테스트: 5종 ConflictKind 양/음성 (≥ 15)
- ConflictReport JSON round-trip
- WeeklyWizardService 통합 테스트 (Path A) 에서 conflict 첨부 확인
- 실기기 시나리오 (Issue 08): 같은 주에 기존 일정 1건 등록 후 wizard 재진입 → EXISTING_OVERLAP 뱃지 표시
