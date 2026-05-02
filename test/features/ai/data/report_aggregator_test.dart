import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/ai/data/report_aggregator.dart';

void main() {
  late AppDatabase db;
  late ReportAggregator aggregator;

  const userId = 'u1';
  final monday = DateTime(2026, 4, 20);
  final sunday = DateTime(2026, 4, 26, 23, 59, 59);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    aggregator = ReportAggregator(db);
  });

  tearDown(() => db.close());

  group('aggregate', () {
    test('returns zeros when no data exists', () async {
      final data = await aggregator.aggregate(
        userId: userId,
        range: DateTimeRange(start: monday, end: sunday),
      );
      expect(data.focusSessions, 0);
      expect(data.schedulesCreated, 0);
      expect(data.todosTotal, 0);
      expect(data.streakDays, 0);
    });

    test('counts schedules and todos within the window', () async {
      // Inside window — todo, completed
      await db.into(db.schedules).insert(
            SchedulesCompanion.insert(
              userId: userId,
              title: 'A',
              category: 'work',
              isTodo: const Value(true),
              isCompleted: const Value(true),
              startTime: Value(monday.add(const Duration(hours: 9))),
              endTime: Value(monday.add(const Duration(hours: 11))),
              createdAt: Value(monday.add(const Duration(hours: 1))),
            ),
          );
      // Inside window — todo, not completed
      await db.into(db.schedules).insert(
            SchedulesCompanion.insert(
              userId: userId,
              title: 'B',
              category: 'study',
              isTodo: const Value(true),
              startTime: Value(monday.add(const Duration(days: 1, hours: 20))),
              endTime: Value(monday.add(const Duration(days: 1, hours: 22))),
              createdAt: Value(monday.add(const Duration(hours: 2))),
            ),
          );
      // Outside window
      await db.into(db.schedules).insert(
            SchedulesCompanion.insert(
              userId: userId,
              title: 'old',
              category: 'work',
              createdAt: Value(monday.subtract(const Duration(days: 30))),
            ),
          );
      // Different user
      await db.into(db.schedules).insert(
            SchedulesCompanion.insert(
              userId: 'other',
              title: 'X',
              category: 'work',
              createdAt: Value(monday.add(const Duration(hours: 5))),
            ),
          );
      // Soft-deleted
      await db.into(db.schedules).insert(
            SchedulesCompanion.insert(
              userId: userId,
              title: 'deleted',
              category: 'hobby',
              createdAt: Value(monday.add(const Duration(hours: 6))),
              deletedAt: Value(monday.add(const Duration(hours: 7))),
            ),
          );

      final data = await aggregator.aggregate(
        userId: userId,
        range: DateTimeRange(start: monday, end: sunday),
      );

      expect(data.schedulesCreated, 2);
      expect(data.todosTotal, 2);
      expect(data.todosCompleted, 1);
      expect(data.categoryDistribution['work'], 1);
      expect(data.categoryDistribution['study'], 1);
    });

    test('aggregates session metrics', () async {
      await db.into(db.sessions).insert(
            SessionsCompanion.insert(
              userId: userId,
              startTime: monday.add(const Duration(hours: 9)),
              endTime: Value(monday.add(const Duration(hours: 10))),
              plannedDurationMin: const Value(60),
              actualFocusMin: const Value(48),
              focusRatio: const Value(0.8),
              grade: const Value('A'),
              createdAt: Value(monday.add(const Duration(hours: 10))),
            ),
          );
      await db.into(db.sessions).insert(
            SessionsCompanion.insert(
              userId: userId,
              startTime: monday.add(const Duration(days: 1, hours: 9)),
              endTime: Value(monday.add(const Duration(days: 1, hours: 10))),
              plannedDurationMin: const Value(60),
              actualFocusMin: const Value(36),
              focusRatio: const Value(0.6),
              grade: const Value('B'),
              createdAt: Value(monday.add(const Duration(days: 1, hours: 10))),
            ),
          );

      final data = await aggregator.aggregate(
        userId: userId,
        range: DateTimeRange(start: monday, end: sunday),
      );

      expect(data.focusSessions, 2);
      expect(data.plannedMinutes, 120);
      expect(data.actualFocusMinutes, 84);
      expect(data.avgFocusRatio, closeTo(0.7, 1e-9));
      expect(data.sessionsByGrade['A'], 1);
      expect(data.sessionsByGrade['B'], 1);
    });
  });

  group('pastWeekContext', () {
    test('returns null when no schedules exist', () async {
      final ctx = await aggregator.pastWeekContext(userId: userId);
      expect(ctx, isNull);
    });

    test('summarises completion rate and lowest category', () async {
      final now = DateTime.now();
      final base = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 5));
      // 3 study schedules: only 1 completed → study is worst
      for (var i = 0; i < 3; i++) {
        await db.into(db.schedules).insert(
              SchedulesCompanion.insert(
                userId: userId,
                title: 'S$i',
                category: 'study',
                isCompleted: Value(i == 0),
                startTime: Value(base.add(Duration(days: i, hours: 20))),
                endTime: Value(base.add(Duration(days: i, hours: 22))),
                createdAt: Value(base.add(Duration(days: i))),
              ),
            );
      }
      // 2 work schedules: both completed → not worst
      for (var i = 0; i < 2; i++) {
        await db.into(db.schedules).insert(
              SchedulesCompanion.insert(
                userId: userId,
                title: 'W$i',
                category: 'work',
                isCompleted: const Value(true),
                startTime: Value(base.add(Duration(days: i, hours: 9))),
                endTime: Value(base.add(Duration(days: i, hours: 11))),
                createdAt: Value(base.add(Duration(days: i))),
              ),
            );
      }

      final ctx = await aggregator.pastWeekContext(userId: userId);
      expect(ctx, isNotNull);
      expect(ctx!.weeksObserved, 4);
      expect(ctx.weeklyCompletionRate, closeTo(3 / 5, 1e-9));
      expect(ctx.lowestCompletionCategory, 'study');
      expect(ctx.mostMissedTimeBlock, 'evening');
    });
  });
}
