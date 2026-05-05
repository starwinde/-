import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/focus_tracking/application/xp_calculator.dart'
    as xp_calc;
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';

part 'session_repository.g.dart';

/// Repository for focus Sessions with outbox enqueue (rules.md §3.7).
class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  /// Find an active (no endTime) session for [scheduleId], or create one
  /// rooted at [startTime] with [plannedDurationMin].
  Future<int> getOrCreateActiveSession({
    required String userId,
    required int scheduleId,
    required DateTime startTime,
    required int plannedDurationMin,
  }) async {
    final existing = await (_db.select(_db.sessions)
          ..where((s) =>
              s.userId.equals(userId) &
              s.scheduleId.equals(scheduleId) &
              s.endTime.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing.id;

    final id = await _db.transaction(() async {
      final newId = await _db.into(_db.sessions).insert(
            SessionsCompanion.insert(
              userId: userId,
              scheduleId: Value(scheduleId),
              startTime: startTime,
              plannedDurationMin: Value(plannedDurationMin),
              isActive: const Value(true),
            ),
          );
      await _db.into(_db.outbox).insert(
            OutboxCompanion.insert(
              targetTable: 'sessions',
              rowId: newId.toString(),
              operation: 'insert',
              payload: '{}',
            ),
          );
      return newId;
    });
    return id;
  }

  /// Append usage minutes to the session (focus + blacklist).
  Future<void> appendUsage({
    required int sessionId,
    required int focusedMinDelta,
    required int blacklistMinDelta,
  }) async {
    if (focusedMinDelta == 0 && blacklistMinDelta == 0) return;
    await _db.transaction(() async {
      final row = await (_db.select(_db.sessions)
            ..where((s) => s.id.equals(sessionId)))
          .getSingle();
      await (_db.update(_db.sessions)..where((s) => s.id.equals(sessionId)))
          .write(
        SessionsCompanion(
          actualFocusMin: Value(row.actualFocusMin + focusedMinDelta),
          blacklistUsageMin:
              Value(row.blacklistUsageMin + blacklistMinDelta),
        ),
      );
      await _db.into(_db.outbox).insert(
            OutboxCompanion.insert(
              targetTable: 'sessions',
              rowId: sessionId.toString(),
              operation: 'update',
              payload: '{}',
            ),
          );
    });
  }

  /// Close the session: set endTime + compute focusRatio + grade.
  Future<void> endSession(int sessionId, DateTime endTime) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.sessions)
            ..where((s) => s.id.equals(sessionId)))
          .getSingle();
      if (row.endTime != null) return;

      final planned = row.plannedDurationMin;
      final ratio = planned > 0
          ? (row.actualFocusMin / planned).clamp(0.0, 1.0)
          : 0.0;
      final grade = planned > 0 ? xp_calc.gradeFromRatio(ratio).name : null;

      await (_db.update(_db.sessions)..where((s) => s.id.equals(sessionId)))
          .write(
        SessionsCompanion(
          endTime: Value(endTime),
          focusRatio: Value(ratio),
          grade: Value(grade),
          isActive: const Value(false),
        ),
      );
      await _db.into(_db.outbox).insert(
            OutboxCompanion.insert(
              targetTable: 'sessions',
              rowId: sessionId.toString(),
              operation: 'update',
              payload: '{}',
            ),
          );
    });
  }

  /// All sessions for [userId] within the local day of [date].
  Future<List<Session>> getSessionsForDate(
    String userId,
    DateTime date,
  ) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.sessions)
          ..where(
            (s) =>
                s.userId.equals(userId) &
                s.startTime.isBiggerOrEqualValue(start) &
                s.startTime.isSmallerThanValue(end),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.startTime)]))
        .get();
  }
}

/// Provides the [SessionRepository] backed by the app database.
@riverpod
SessionRepository sessionRepository(Ref ref) {
  return SessionRepository(ref.watch(appDatabaseProvider));
}
