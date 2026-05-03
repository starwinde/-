# usage-tracking-l0 — Feature PRD

> 방해 강도 4단계 확장 + 모든 단계 공통 사용 정보 기록 + 홈 대시보드 노출.
> 루트 `PRD.md` §2.8 (일정별 방해 허용) 와 FR-21 의 SoT 갱신 단위. 본 파일은 작업 컨텍스트.

## 목적

T5.21 의 3단계(L1/L2/L3) 방해 허용을 4단계(L0/L1/L2/L3) 로 확장한다.
- **L0**: 방해 동작 없음. 일정 진행 중 다른 앱 사용 시점에 포그라운드 앱 종류 + 동작 시간만 기록.
- **L1/L2/L3**: 기존 동작·이름 유지. 그 위에 L0 와 동일한 사용 기록을 함께 수집.

수집된 사용 정보를 사용자가 확인할 수 있도록 홈 탭(`MoodCheckInTile` 패턴)에 카드로 노출한다.

## 범위

- `DisturbanceLevel` enum 4단계화. `DisturbanceLevel.fromInt(0) → l0`.
- `DisturbanceController` 가 paused→resumed 사이의 사용 통계를 `UsageApi.queryUsageStats(pausedAt, now)` 로 수집해 신규 `usage_logs` 테이블에 누적.
- 모든 단계(L0~L3) 에서 동일한 수집 로직 동작. 차이는 L0 가 그 외 방해 액션(진동/오버레이/홈 이동/잠금) 을 건너뛴다는 점뿐.
- `schedule_create_page` 라디오 4개로 확장. L0 라벨 신규.
- 신규 `UsageLogTile` (홈 대시보드, mood 카드 아래). 신규 `UsageHistoryPage` (`/usage/history`).
- Drift `schemaVersion` v3→v4 마이그레이션, 신규 `UsageLogs` 테이블.

## 비범위

- 패키지명 → 사람이 읽을 수 있는 앱 표시명 매핑 (PackageManager 의존, 후속 이슈로 분리). 1차는 `packageName` 그대로.
- 실시간 대시보드 / 위젯 노출. `UsageHistoryPage` 진입 시점에 read-only 집계만.
- 사용 정보 동기화 (Supabase outbox). 1차는 로컬 전용. 후속에서 outbox 등록 검토.
- L0 를 신규 일정의 기본값으로 채택. 기존 기본값 1 유지, 사용자가 명시 선택만.

## 의존성

- 기존 `UsageApi` (Pigeon, `queryUsageStats(start, end) → List<AppUsageInfo>`).
- 기존 UsageStats 권한 (`hasUsagePermission`) — 온보딩에서 이미 획득.
- 기존 `MoodCheckInTile` 패턴 (홈 카드 디자인 참고).
- Drift schema v3 (현재) → v4 (본 작업).

## DoD

- 5 이슈 (`issues/01..05-*.md`) 모두 Status: done
- `flutter analyze` 0 warning, `flutter test` 회귀 0건
- 신규 단위 테스트 ≥ 25 (enum/마이그레이션/controller/repository/widget)
- 실기기 검증: 일정 생성 시 L0 선택 가능, 일정 진행 중 다른 앱 사용 후 복귀 시 사용 로그 누적, 홈 카드에 오늘 top-3 표시
- 루트 `PRD.md` §2.8 + FR-21 + Tasks.md T5.21 갱신
- ADR 0004 머지

## Open Decisions

1. **L0 가 신규 일정 기본값?** — 1차는 1 유지. 사용 데이터 1주차 측정 후 0/1 중 결정.
2. **수집 주기** — 1차는 paused→resumed 사이클 1회. 정밀도 부족 시 일정 진행 중 60초 polling 도입 검토 (배터리 영향).
3. **표시명 매핑** — 1차는 packageName. 후속에서 PackageManager 캐시 + 한국어 라벨.
4. **이력 보관 기간** — 1차는 무제한. 30/90일 prune 정책은 후속.
5. **L0 가 `allowDisruption=false` 와 어떻게 다른가?** — 결정: `allowDisruption=true` 가 게이트, `disruptionIntensity=0` 이 액션. allow=false 면 수집·동작 모두 비활성. allow=true + L0 면 수집만.

## 관련 ADR

- 0004 — Disturbance Level L0 = observe-only, all-levels usage logging
