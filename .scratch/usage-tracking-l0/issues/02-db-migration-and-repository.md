# 02 — Drift v3→v4 마이그레이션 + UsageLog 저장소

Status: done — 2026-05-03 (`UsageLogs` 테이블 + Drift v3→v4 마이그레이션 + `UsageLogRepository` (insert/insertMany/getForDate/getForSchedule/aggregateTopPackages/totalMsSince) + 11 단위테스트 PASS)
의존성: 없음 (01과 병렬 가능)
관련 ADR: 0004

## 목적

신규 `UsageLogs` 테이블 + `UsageLogRepository` 추가. Drift `schemaVersion` v3 → v4 마이그레이션.

## 변경 파일

- `lib/core/db/app_database.dart` — table 정의 추가, schemaVersion 인상, onUpgrade 분기
- `lib/core/db/app_database.g.dart` — regenerated (build_runner)
- `lib/features/disturbance/data/usage_log_repository.dart` (신규)
- `test/features/disturbance/data/usage_log_repository_test.dart` (신규)
- `test/core/db/migration_v3_to_v4_test.dart` (신규)

## 스키마

```dart
@DataClassName('UsageLog')
class UsageLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  IntColumn get scheduleId => integer().nullable()();
  TextColumn get packageName => text()();
  IntColumn get totalMs => integer()();
  DateTimeColumn get rangeStart => dateTime()();
  DateTimeColumn get rangeEnd => dateTime()();
  DateTimeColumn get capturedAt => dateTime()();
}
```

인덱스: 필요 시 `(userId, capturedAt DESC)` 복합 인덱스. 1차는 미적용, 1주차 측정 후 결정.

## Repository API

```dart
class UsageLogRepository {
  Future<int> insert({...});
  Future<List<UsageLog>> getForDate(String userId, DateTime date);
  Future<List<UsageLog>> getForSchedule(String userId, int scheduleId);
  Future<Map<String, int>> aggregateTopPackages(String userId, DateTime since, {int limit = 3});
}
```

`aggregateTopPackages` 는 `packageName -> totalMs 합계` 를 반환, totalMs DESC 정렬, top-N 절단. 홈 카드에서 재사용.

## DoD

- [ ] 테이블 + Drift codegen 통과
- [ ] schemaVersion 3 → 4
- [ ] onUpgrade(from=3, to=4) 분기에 CREATE TABLE 실행
- [ ] Migration 단위 테스트: v3 DB 생성 → upgrade → 신규 테이블 존재 확인
- [ ] Repository CRUD 테스트 ≥ 8 (insert, getForDate, getForSchedule, aggregate top-3, 빈 입력)
- [ ] `flutter analyze` 0 warning, `flutter test` 회귀 0건

## 검증

- 단위 테스트 (in-memory drift)
- 실기기는 issue 04 통합 후
