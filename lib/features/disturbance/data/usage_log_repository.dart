import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';

part 'usage_log_repository.g.dart';

/// `usage_logs` 테이블 CRUD + 집계. ADR 0004.
class UsageLogRepository {
  UsageLogRepository(this._db);

  final AppDatabase _db;

  /// 단일 행 insert. [packageName] 의 자기 패키지 (`com.starwinde.routinemon`)
  /// 필터링은 호출자(controller) 가 수행한다.
  Future<int> insert({
    required String userId,
    int? scheduleId,
    required String packageName,
    required int totalMs,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    return _db.into(_db.usageLogs).insert(
          UsageLogsCompanion.insert(
            userId: userId,
            scheduleId: Value(scheduleId),
            packageName: packageName,
            totalMs: totalMs,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd,
          ),
        );
  }

  /// 여러 행을 한 트랜잭션에 insert. paused→resumed 사이클의 묶음 저장.
  Future<List<int>> insertMany(List<UsageLogsCompanion> rows) async {
    if (rows.isEmpty) return const [];
    return _db.transaction(() async {
      final ids = <int>[];
      for (final r in rows) {
        ids.add(await _db.into(_db.usageLogs).insert(r));
      }
      return ids;
    });
  }

  /// 특정 일자 [date] 에 누적된 모든 사용 로그.
  Future<List<UsageLog>> getForDate(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.usageLogs)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.capturedAt.isBetweenValues(start, end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]))
        .get();
  }

  /// 특정 일정 [scheduleId] 동안 누적된 모든 사용 로그.
  Future<List<UsageLog>> getForSchedule(
    String userId,
    int scheduleId,
  ) {
    return (_db.select(_db.usageLogs)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.scheduleId.equals(scheduleId),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]))
        .get();
  }

  /// [since] 이후 누적된 패키지별 totalMs 합계 — 내림차순 top-[limit].
  Future<List<({String packageName, int totalMs})>> aggregateTopPackages({
    required String userId,
    required DateTime since,
    int limit = 3,
  }) async {
    final rows = await (_db.select(_db.usageLogs)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.capturedAt.isBiggerOrEqualValue(since),
          ))
        .get();
    final agg = <String, int>{};
    for (final r in rows) {
      agg[r.packageName] = (agg[r.packageName] ?? 0) + r.totalMs;
    }
    final sorted = agg.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .take(limit)
        .map((e) => (packageName: e.key, totalMs: e.value))
        .toList(growable: false);
  }

  /// [since] 이후 패키지 무관 누적 totalMs.
  Future<int> totalMsSince({
    required String userId,
    required DateTime since,
  }) async {
    final rows = await (_db.select(_db.usageLogs)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.capturedAt.isBiggerOrEqualValue(since),
          ))
        .get();
    return rows.fold<int>(0, (acc, r) => acc + r.totalMs);
  }
}

/// Riverpod provider.
@riverpod
UsageLogRepository usageLogRepository(Ref ref) {
  return UsageLogRepository(ref.watch(appDatabaseProvider));
}
