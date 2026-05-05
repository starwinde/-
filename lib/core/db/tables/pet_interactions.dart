import 'package:drift/drift.dart';

/// 펫 인터랙션 기록 (PRD §2.6 / FR-09).
///
/// 일일 한도(먹이 1, 쓰다듬기 3, 놀아주기 1) 는 자정 기준 — 호출자가
/// 오늘 0시 이후 행 수를 세어 강제. 친밀도(intimacy) 는 별도 컬럼이
/// 아니라 `actionType='pet'` 누적 행 수로 도출.
class PetInteractions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  IntColumn get petId =>
      integer().customConstraint('NOT NULL REFERENCES pets(id)')();
  TextColumn get userId => text()();

  /// `feed` (먹이) / `pet` (쓰다듬기) / `play` (놀아주기).
  TextColumn get actionType => text()();

  /// 인터랙션이 적용된 시각.
  DateTimeColumn get performedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
