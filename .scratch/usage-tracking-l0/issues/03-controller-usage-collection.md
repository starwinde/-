# 03 — DisturbanceController 사용 정보 수집

Status: done — 2026-05-03 (`DisturbanceController._onAppPaused` 가 active 일정 시 `_pausedAt` + `_pausedScheduleId` 캡처. L0 는 액션 early-return. `_onAppResumed` 가 `_recordUsage()` 호출 → `usageApi.queryUsageStats` → 본인 패키지 제외 + `UsageLogRepository.insert`. native API 실패 swallow + debug log. 단위 테스트는 controller 가 ref 를 통해 provider 주입을 받아 mocking 까다로움 — 통합 검증은 issue 05 실기기 시나리오 1/2 에서.)
의존성: 01, 02
관련 ADR: 0004

## 목적

`DisturbanceController` 의 paused→resumed 사이클 동안 active 일정이 진행 중이고 `allowDisruption=true` 이면, `queryUsageStats(pausedAt, now)` 호출 → `UsageLogRepository.insert()` 로 누적.

L0 는 이 수집만 수행하고 그 외 액션을 스킵. L1/L2/L3 도 동일한 수집을 수행 (상위 단계 + 사용 기록).

## 변경 파일

- `lib/features/disturbance/application/disturbance_controller.dart`
- `test/features/disturbance/application/disturbance_controller_test.dart` (신규 또는 확장)

## 동작 명세

**`_onAppPaused`**:
1. active 일정 + `allowDisruption=true` 게이트 통과 시 현재 시각 `_pausedAt = now` 저장.
2. `level = DisturbanceLevel.fromInt(intensity)` 결정.
3. `if (level != l0)` 인 경우만 기존 진동/오버레이/홈/잠금 로직 실행.

**`_onAppResumed`**:
1. `_pausedAt` 이 있고 active 일정이 동일하게 진행 중이면 `usageApi.queryUsageStats(_pausedAt, now)` 호출.
2. 결과 List<AppUsageInfo> 를 totalTimeInForeground > 0 인 항목만 `UsageLog` 로 insert.
   - `userId, scheduleId, packageName, totalMs=info.totalTimeInForeground, rangeStart=_pausedAt, rangeEnd=now, capturedAt=now`.
3. 기존 정리 로직 (cancelPeriodicTimers / dismissOverlay) 실행.
4. `_pausedAt = null`.

**자기-루틴몬 패키지 필터**: `com.starwinde.routinemon` 본인 패키지는 항상 제외.

## DI

`DisturbanceController` 생성자에 `UsageLogRepository repo` + `UsageApi api` 주입 (기존 `DisturbanceApi` 와 별개). riverpod provider `disturbanceControllerProvider` 갱신.

## 단위 테스트 (mock UsageApi + mock repo)

- L0 일정 paused→resumed 시 vibrate 호출 0회, repo.insert 1회 이상 호출
- L2 일정 paused→resumed 시 launchHome 호출 1회, repo.insert 1회 이상 호출
- queryUsageStats 가 빈 리스트 반환 시 repo.insert 호출 0회
- 본인 패키지(`com.starwinde.routinemon`) 필터링
- pausedAt 이 null 이면 (active 일정 없이 paused) repo.insert 호출 0회
- queryUsageStats 가 throw 시 controller 가 swallow + 다음 사이클 정상 동작 (사용자 차단 금지)

## DoD

- [ ] L0/L1/L2/L3 모두에서 사용 기록 수집 동작
- [ ] 본인 패키지 제외
- [ ] queryUsageStats 실패 swallow
- [ ] 단위 테스트 ≥ 6
- [ ] `flutter analyze` 0 warning, `flutter test` 회귀 0건

## 검증

- 단위 테스트
- 실기기 통합은 issue 05
