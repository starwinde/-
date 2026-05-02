import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/application/active_schedule_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<Schedule> insert({
    required String title,
    required DateTime start,
    required DateTime end,
    bool isCompleted = false,
    DateTime? deletedAt,
  }) async {
    final id = await db.into(db.schedules).insert(
          SchedulesCompanion.insert(
            userId: 'u1',
            title: title,
            category: 'study',
            startTime: Value(start),
            endTime: Value(end),
            isCompleted: Value(isCompleted),
            deletedAt: Value(deletedAt),
          ),
        );
    return (db.select(db.schedules)..where((s) => s.id.equals(id)))
        .getSingle();
  }

  group('findCurrentActiveSchedule', () {
    test('returns the schedule whose window contains now', () async {
      final now = DateTime(2026, 4, 25, 10);
      final s = await insert(
        title: 'A',
        start: now.subtract(const Duration(minutes: 10)),
        end: now.add(const Duration(minutes: 10)),
      );
      expect(findCurrentActiveSchedule([s], now)?.id, s.id);
    });

    test('returns null when now is before startTime', () async {
      final now = DateTime(2026, 4, 25, 10);
      final s = await insert(
        title: 'B',
        start: now.add(const Duration(minutes: 5)),
        end: now.add(const Duration(minutes: 30)),
      );
      expect(findCurrentActiveSchedule([s], now), isNull);
    });

    test('returns null when schedule isCompleted=true', () async {
      final now = DateTime(2026, 4, 25, 10);
      final s = await insert(
        title: 'C',
        start: now.subtract(const Duration(minutes: 10)),
        end: now.add(const Duration(minutes: 10)),
        isCompleted: true,
      );
      expect(findCurrentActiveSchedule([s], now), isNull);
    });

    test('returns null when schedule is soft-deleted', () async {
      final now = DateTime(2026, 4, 25, 10);
      final s = await insert(
        title: 'D',
        start: now.subtract(const Duration(minutes: 10)),
        end: now.add(const Duration(minutes: 10)),
        deletedAt: now,
      );
      expect(findCurrentActiveSchedule([s], now), isNull);
    });
  });
}
