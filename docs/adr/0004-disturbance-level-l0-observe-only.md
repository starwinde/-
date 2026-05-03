# ADR 0004 — Disturbance Level L0 = Observe-only, 모든 단계에서 사용 정보 기록

- Status: Accepted
- Date: 2026-05-03
- Supersedes: —
- Superseded by: —

## Context

T5.21 (rev 22) 에서 일정별 방해 허용을 도입하며 강도 3단계(L1/L2/L3) 를 두었다. L1+ 의 방해 동작은 명확하지만, **사용자가 어떤 앱에서 얼마나 머물렀는지** 자체는 어디서도 누적되지 않았다. 결과적으로:

1. 방해를 켜기에는 너무 부담스러운 일정 (회의 직전 짧은 휴식 등) 에서 어떤 앱이 시간을 잠식하는지 파악 불가.
2. L1/L2/L3 사용자도 방해가 "왜 효과가 있었는지" 를 사후 회고할 데이터가 없다 (효과 측정 불능).
3. UsageStats 권한은 이미 온보딩에서 받았는데 그 데이터를 일정 컨텍스트로 묶어 활용하는 통합 지점이 없다.

## Decision

`DisturbanceLevel` 에 **L0 (observe-only)** 를 추가한다. L0 의 정의:

- 방해 허용이 켜진 일정에서 사용자가 다른 앱을 사용해도 진동/오버레이/홈 이동/잠금 등 모든 액션을 수행하지 않는다.
- 그러나 paused→resumed 사이의 `UsageApi.queryUsageStats(pausedAt, now)` 결과를 신규 `usage_logs` 테이블에 누적한다.

**L1/L2/L3 도 동일한 사용 기록을 함께 수집한다.** 즉 사용 기록은 모든 단계의 공통 베이스라인이며, 단계는 그 위에 액션을 더하는 정도 차이로 정의된다.

홈 대시보드에 `MoodCheckInTile` 패턴의 `UsageLogTile` 을 추가하여 오늘 top-3 패키지 + 합계 분을 노출. 상세 이력은 `/usage/history`.

## Alternatives considered

1. **L0 없이 `allowDisruption=true` + 신규 `recordUsage=true` 별도 토글**
   - 장점: 강도 단계는 그대로 유지.
   - 단점: 사용자 입장에서 "방해 허용 ON / 강도 None / 기록 ON" 3중 토글이 인지 부담. L0 라는 단일 단계가 더 직관적.
2. **모든 일정에서 항상 사용 기록**
   - 장점: 별도 설정 불필요.
   - 단점: 사용자가 명시 동의하지 않은 일정에서도 기록 → 프라이버시 우려. `allowDisruption` 게이트로 사용자 동의를 명시 받는 현재 구조가 더 안전.
3. **수집 주기를 60초 polling 으로 정밀화**
   - 장점: paused 가 일어나지 않는 긴 사용 시나리오 (예: 게임 30분) 를 시간 단위로 쪼갬.
   - 단점: 배터리 영향 + Foreground Service 필요. 1차는 paused→resumed 사이클로 충분, 1주차 측정 후 재검토 (Open Decision §2).

## Consequences

**긍정**:
- 방해 부담 없는 사용자도 `allowDisruption=true + L0` 으로 자기관찰 데이터 수집 가능.
- 방해 사용자는 행동 변화를 사후 회고 데이터로 검증 가능.
- 단일 게이트(`allowDisruption`) + 단일 강도 축(0~3) 으로 규칙 단순화.

**부정**:
- DB schemaVersion v3→v4 마이그레이션 필요.
- `UsageLogs` 테이블이 시간이 지나며 누적 → 1주차 측정 후 prune 정책 필요 (Open Decision §4).
- 본인 패키지(`com.starwinde.routinemon`) 필터링 로직이 누락되면 무한 수집 → controller 에서 명시 제외 (issue 03).

## Open Decisions (PRD 동기화)

- L0 가 신규 일정 기본값? — 1차 1 유지, 1주차 후 재결정.
- 패키지명 → 표시명 매핑 — 1차 packageName 노출, PackageManager 캐시 후속.
- 이력 보관 기간 — 1차 무제한, 30/90일 prune 후속.
- 수집 정밀도 — paused→resumed 1차, 60s polling 후속 (배터리 영향 측정 필요).

## 관련 이슈

- `.scratch/usage-tracking-l0/issues/01-domain-l0-enum.md`
- `.scratch/usage-tracking-l0/issues/02-db-migration-and-repository.md`
- `.scratch/usage-tracking-l0/issues/03-controller-usage-collection.md`
- `.scratch/usage-tracking-l0/issues/04-create-page-l0-radio.md`
- `.scratch/usage-tracking-l0/issues/05-home-tile-and-history.md`
