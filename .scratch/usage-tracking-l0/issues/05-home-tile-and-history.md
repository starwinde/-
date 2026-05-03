# 05 — 홈 카드 (UsageLogTile) + 이력 페이지

Status: done — 2026-05-03 (`UsageLogTile` 홈 카드 + `UsageHistoryPage` (오늘/7일/30일 토글, 패키지별 누적 + 일정별 그룹) + `/usage/history` 라우트 + `app.dart` ListView 에 mood 카드 아래 통합. 0 warning. 단위 widget 테스트는 후속 — 실기기 검증으로 우선 진행.)
의존성: 02 (repo), 03 (수집), 04 (선택 가능)
관련 ADR: 0004

## 목적

홈 대시보드에 `MoodCheckInTile` 패턴의 카드를 추가하여 오늘 누적 사용 기록을 노출. 자세히 보기는 `/usage/history` 라우트.

## 변경 파일

- `lib/features/disturbance/presentation/usage_log_tile.dart` (신규)
- `lib/features/disturbance/presentation/usage_history_page.dart` (신규)
- `lib/app.dart` — 홈 ListView 에 `UsageLogTile()` 추가, `/usage/history` 라우트 등록
- `test/features/disturbance/presentation/usage_log_tile_test.dart` (신규)
- `test/features/disturbance/presentation/usage_history_page_test.dart` (신규)

## UsageLogTile

`MoodCheckInTile` 와 동일 카드 디자인. `repo.aggregateTopPackages(userId, todayMidnight, limit: 3)` 호출:

- 헤더: "오늘 사용 기록"
- 본문: top-3 패키지명 + 분 단위 시간 + 합계 카운트
- 우상단: `Σ N분` 누적
- 액션: "자세히 보기" → `context.push('/usage/history')`
- 데이터 0건: "아직 기록 없음"

## UsageHistoryPage

- 상단: 오늘 / 7일 / 30일 토글
- 본문: 패키지별 누적 막대 (수평) + 일정별 누적 (group by scheduleId, scheduleId null = 일정 외 시간)
- 빈 상태: "기록이 없습니다. 방해 허용이 켜진 일정에서 다른 앱 사용 후 루틴몬으로 돌아오면 기록됩니다."

## DoD

- [ ] 홈 카드가 오늘 top-3 + 합계 분 표시
- [ ] `/usage/history` 라우트 동작
- [ ] 빈 상태 처리
- [ ] widget 테스트 ≥ 5 (오늘 데이터 / 빈 / 자세히 탭 / 7일 토글 / 일정 외 그룹)
- [ ] `flutter analyze` 0 warning, `flutter test` 회귀 0건

## 실기기 검증 시나리오 (test-report.md 갱신)

1. L0 일정 생성 → 일정 진행 중 다른 앱 사용 → 루틴몬 복귀 → 홈 카드 1건 이상 표시
2. L2 일정 생성 → 동일 → 차단 다이얼로그 + 사용 기록 누적 동시 동작
3. 홈 카드 "자세히 보기" → 7일 토글 → 데이터 일관성

## 검증

- widget + 실기기
- 보고서: `.scratch/usage-tracking-l0/test-report.md`
