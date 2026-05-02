import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/data/schedule_repository.dart';

void main() {
  late AppDatabase db;
  late ScheduleRepository repo;
  const userId = 'test-user-id';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ScheduleRepository(db);
  });

  tearDown(() => db.close());

  group('ScheduleRepository.insertMany', () {
    test('bulk inserts schedules and enqueues one outbox entry per row',
        () async {
      final items = [
        SchedulesCompanion.insert(
          userId: userId,
          title: '러닝',
          category: 'health',
          tags: Value(jsonEncode(const ['morning'])),
          startTime: Value(DateTime(2026, 4, 20, 6, 30)),
          endTime: Value(DateTime(2026, 4, 20, 7, 15)),
        ),
        SchedulesCompanion.insert(
          userId: userId,
          title: '공부',
          category: 'study',
          startTime: Value(DateTime(2026, 4, 21, 9)),
          endTime: Value(DateTime(2026, 4, 21, 10)),
        ),
        SchedulesCompanion.insert(
          userId: userId,
          title: '업무',
          category: 'work',
        ),
      ];

      final ids = await repo.insertMany(items);

      expect(ids, hasLength(3));
      expect(ids.every((id) => id > 0), isTrue);

      final schedules = await db.select(db.schedules).get();
      expect(schedules, hasLength(3));

      final outbox = await db.select(db.outbox).get();
      expect(outbox, hasLength(3));
      expect(outbox.every((o) => o.targetTable == 'schedules'), isTrue);
      expect(outbox.every((o) => o.operation == 'insert'), isTrue);
    });

    test('returns empty list when given empty input', () async {
      final ids = await repo.insertMany(const []);

      expect(ids, isEmpty);
      final schedules = await db.select(db.schedules).get();
      expect(schedules, isEmpty);
      final outbox = await db.select(db.outbox).get();
      expect(outbox, isEmpty);
    });
  });
}
