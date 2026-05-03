import 'package:drift/drift.dart';

/// 일정 진행 중 (allowDisruption=true) paused→resumed 사이클의 포그라운드 앱
/// 사용 정보를 누적하는 테이블. ADR 0004.
class UsageLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 소유자 user id (text, supabase auth user id 또는 'local').
  TextColumn get userId => text()();

  /// 어떤 일정 진행 중에 측정됐는지 (FK to schedules.id, nullable —
  /// 일정 외 시간에 수집된 경우 null).
  IntColumn get scheduleId => integer().nullable()();

  /// 안드로이드 패키지명 (예: `com.android.chrome`).
  TextColumn get packageName => text()();

  /// 해당 윈도 안에서 포그라운드로 누적된 시간 (ms).
  IntColumn get totalMs => integer()();

  /// 측정 윈도 시작 (paused 시각).
  DateTimeColumn get rangeStart => dateTime()();

  /// 측정 윈도 종료 (resumed 시각).
  DateTimeColumn get rangeEnd => dateTime()();

  /// 행 생성 시각.
  DateTimeColumn get capturedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
