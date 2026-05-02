import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';

part 'report_aggregator.g.dart';

/// Aggregates Drift-backed schedule + session data into the
/// [AiReportInputData] payload (작성/이행/체크 3축) and the wizard's
/// [PastWeekContext] (직전 N주 이행 패턴 요약).
class ReportAggregator {
  ReportAggregator(this._db);

  final AppDatabase _db;

  /// Aggregates the report period [range] for [userId].
  Future<AiReportInputData> aggregate({
    required String userId,
    required DateTimeRange range,
  }) async {
    final schedules = await _querySchedules(userId, range);
    final sessions = await _querySessions(userId, range);

    final schedulesCreated = schedules.length;
    final schedulesTotalMinutes = schedules.fold<int>(
      0,
      (acc, s) => acc + _scheduleDurationMin(s),
    );
    final categoryDistribution = <String, int>{};
    for (final s in schedules) {
      categoryDistribution.update(
        s.category,
        (v) => v + 1,
        ifAbsent: () => 1,
      );
    }

    final todos = schedules.where((s) => s.isTodo).toList(growable: false);
    final todosTotal = todos.length;
    final todosCompleted = todos.where((s) => s.isCompleted).length;
    final todosCompletedOnDueDay = todos.where((s) {
      if (!s.isCompleted) return false;
      final start = s.startTime ?? s.createdAt;
      final updatedDay = DateTime(
        s.updatedAt.year,
        s.updatedAt.month,
        s.updatedAt.day,
      );
      final dueDay = DateTime(start.year, start.month, start.day);
      return updatedDay == dueDay;
    }).length;
    final nonTodoCompleted =
        schedules.where((s) => !s.isTodo && s.isCompleted).length;

    final focusSessions = sessions.length;
    final actualFocusMinutes =
        sessions.fold<int>(0, (acc, s) => acc + s.actualFocusMin);
    final plannedMinutes =
        sessions.fold<int>(0, (acc, s) => acc + s.plannedDurationMin);
    final ratios = sessions
        .map((s) => s.focusRatio ?? 0.0)
        .where((r) => r > 0)
        .toList(growable: false);
    final avgFocusRatio = ratios.isEmpty
        ? 0.0
        : ratios.reduce((a, b) => a + b) / ratios.length;
    final sessionsByGrade = <String, int>{};
    for (final s in sessions) {
      final g = s.grade;
      if (g == null || g.isEmpty) continue;
      sessionsByGrade.update(g, (v) => v + 1, ifAbsent: () => 1);
    }

    final streakDays = await _computeStreak(userId, range.end);

    return AiReportInputData(
      focusSessions: focusSessions,
      avgFocusRatio: avgFocusRatio,
      plannedMinutes: plannedMinutes,
      actualFocusMinutes: actualFocusMinutes,
      sessionsByGrade: sessionsByGrade,
      todosTotal: todosTotal,
      todosCompleted: todosCompleted,
      todosCompletedOnDueDay: todosCompletedOnDueDay,
      nonTodoCompleted: nonTodoCompleted,
      tasksCompleted: todosCompleted,
      tasksTotal: todosTotal,
      schedulesCreated: schedulesCreated,
      schedulesTotalMinutes: schedulesTotalMinutes,
      categoryDistribution: categoryDistribution,
      streakDays: streakDays,
    );
  }

  /// Computes the past-N-weeks execution context for the wizard.
  /// Returns `null` when there is no observable data (no schedules in the
  /// look-back window) so the wizard can fall back to lifestyle-only.
  Future<PastWeekContext?> pastWeekContext({
    required String userId,
    int weeks = 4,
  }) async {
    if (weeks <= 0) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lookbackStart = today.subtract(Duration(days: 7 * weeks));
    final range = DateTimeRange(start: lookbackStart, end: today);

    final schedules = await _querySchedules(userId, range);
    if (schedules.isEmpty) return null;
    final sessions = await _querySessions(userId, range);

    final completedCount = schedules.where((s) => s.isCompleted).length;
    final completionRate =
        schedules.isEmpty ? 0.0 : completedCount / schedules.length;

    final missByCategory = <String, int>{};
    final totalByCategory = <String, int>{};
    for (final s in schedules) {
      totalByCategory.update(s.category, (v) => v + 1, ifAbsent: () => 1);
      if (!s.isCompleted) {
        missByCategory.update(s.category, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    String? lowestCategory;
    var worstRate = -1.0;
    totalByCategory.forEach((cat, total) {
      if (total < 2) return; // ignore noise
      final missed = missByCategory[cat] ?? 0;
      final rate = missed / total;
      if (rate > worstRate) {
        worstRate = rate;
        lowestCategory = cat;
      }
    });

    final missByBlock = <String, int>{
      'morning': 0,
      'afternoon': 0,
      'evening': 0,
      'night': 0,
    };
    for (final s in schedules) {
      if (s.isCompleted) continue;
      final start = s.startTime;
      if (start == null) continue;
      final block = _timeBlock(start.hour);
      missByBlock.update(block, (v) => v + 1, ifAbsent: () => 1);
    }
    String? worstBlock;
    var worstBlockMisses = 0;
    missByBlock.forEach((block, misses) {
      if (misses > worstBlockMisses) {
        worstBlockMisses = misses;
        worstBlock = block;
      }
    });

    final focusRatios = sessions
        .map((s) => s.focusRatio ?? 0.0)
        .where((r) => r > 0)
        .toList(growable: false);
    final focusRatioAvg = focusRatios.isEmpty
        ? 0.0
        : focusRatios.reduce((a, b) => a + b) / focusRatios.length;

    return PastWeekContext(
      weeklyCompletionRate: completionRate,
      lowestCompletionCategory: lowestCategory,
      mostMissedTimeBlock: worstBlockMisses == 0 ? null : worstBlock,
      focusRatioAvg: focusRatioAvg,
      weeksObserved: weeks,
    );
  }

  Future<List<Schedule>> _querySchedules(
    String userId,
    DateTimeRange range,
  ) async {
    final query = _db.select(_db.schedules)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.deletedAt.isNull() &
            t.createdAt.isBetweenValues(range.start, range.end),
      );
    return query.get();
  }

  Future<List<Session>> _querySessions(
    String userId,
    DateTimeRange range,
  ) async {
    final query = _db.select(_db.sessions)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.createdAt.isBetweenValues(range.start, range.end),
      );
    return query.get();
  }

  Future<int> _computeStreak(String userId, DateTime end) async {
    final cutoff = end.subtract(const Duration(days: 60));
    final query = _db.select(_db.dailyScores)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.date.isBiggerOrEqualValue(cutoff) &
            t.date.isSmallerOrEqualValue(end),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    final rows = await query.get();
    var streak = 0;
    var cursor = DateTime(end.year, end.month, end.day);
    for (final r in rows) {
      final d = DateTime(r.date.year, r.date.month, r.date.day);
      if (d == cursor) {
        if (r.totalFocusMinutes > 0) {
          streak += 1;
          cursor = cursor.subtract(const Duration(days: 1));
        } else {
          break;
        }
      } else if (d.isBefore(cursor)) {
        break;
      }
    }
    return streak;
  }

  int _scheduleDurationMin(Schedule s) {
    final start = s.startTime;
    final end = s.endTime;
    if (start == null || end == null) return 0;
    final diff = end.difference(start).inMinutes;
    return diff > 0 ? diff : 0;
  }

  String _timeBlock(int hour) {
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    if (hour < 22) return 'evening';
    return 'night';
  }
}

/// Provides [ReportAggregator] wired to the global [AppDatabase].
@riverpod
ReportAggregator reportAggregator(Ref ref) =>
    ReportAggregator(ref.watch(appDatabaseProvider));
