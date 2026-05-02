import 'dart:convert';

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

  group('ScheduleRepository', () {
    test('insert creates schedule and outbox entry', () async {
      final id = await repo.insert(
        userId: userId,
        title: '공부하기',
        category: 'study',
        tags: ['수학', '영어'],
      );

      expect(id, greaterThan(0));

      // Verify schedule was inserted
      final schedules = await db.select(db.schedules).get();
      expect(schedules, hasLength(1));
      expect(schedules.first.title, '공부하기');
      expect(schedules.first.category, 'study');
      expect(jsonDecode(schedules.first.tags), ['수학', '영어']);

      // Verify outbox enqueue
      final outbox = await db.select(db.outbox).get();
      expect(outbox, hasLength(1));
      expect(outbox.first.targetTable, 'schedules');
      expect(outbox.first.operation, 'insert');
    });

    test('insert todo creates schedule with isTodo=true', () async {
      await repo.insert(
        userId: userId,
        title: '약 먹기',
        category: 'health',
        isTodo: true,
      );

      final schedules = await db.select(db.schedules).get();
      expect(schedules.first.isTodo, isTrue);
      expect(schedules.first.isCompleted, isFalse);
    });

    test('softDelete sets deletedAt', () async {
      final id = await repo.insert(
        userId: userId,
        title: '삭제할 일정',
        category: 'etc',
      );

      await repo.softDelete(id);

      final schedule =
          await (db.select(db.schedules)..where((s) => s.id.equals(id)))
              .getSingle();
      expect(schedule.deletedAt, isNotNull);
    });

    test('restore clears deletedAt', () async {
      final id = await repo.insert(
        userId: userId,
        title: '복원할 일정',
        category: 'work',
      );
      await repo.softDelete(id);
      await repo.restore(id);

      final schedule =
          await (db.select(db.schedules)..where((s) => s.id.equals(id)))
              .getSingle();
      expect(schedule.deletedAt, isNull);
    });

    test('permanentDelete removes schedule from database', () async {
      final id = await repo.insert(
        userId: userId,
        title: '영구 삭제',
        category: 'etc',
      );
      await repo.permanentDelete(id);

      final schedules = await db.select(db.schedules).get();
      expect(schedules, isEmpty);
    });

    test('update modifies schedule fields', () async {
      final id = await repo.insert(
        userId: userId,
        title: '원래 제목',
        category: 'work',
      );

      await repo.update(
        id: id,
        title: '수정된 제목',
        category: 'study',
        tags: ['태그1'],
      );

      final schedule =
          await (db.select(db.schedules)..where((s) => s.id.equals(id)))
              .getSingle();
      expect(schedule.title, '수정된 제목');
      expect(schedule.category, 'study');
      expect(jsonDecode(schedule.tags), ['태그1']);
    });

    test('update toggles isCompleted', () async {
      final id = await repo.insert(
        userId: userId,
        title: '할일',
        category: 'etc',
        isTodo: true,
      );

      await repo.update(id: id, isCompleted: true);

      final schedule =
          await (db.select(db.schedules)..where((s) => s.id.equals(id)))
              .getSingle();
      expect(schedule.isCompleted, isTrue);
    });

    test('watchActive excludes deleted and todo items', () async {
      await repo.insert(
        userId: userId,
        title: '활성 일정',
        category: 'work',
      );
      final deletedId = await repo.insert(
        userId: userId,
        title: '삭제된 일정',
        category: 'work',
      );
      await repo.softDelete(deletedId);
      await repo.insert(
        userId: userId,
        title: '할일',
        category: 'work',
        isTodo: true,
      );

      final active = await repo.watchActive(userId).first;
      expect(active, hasLength(1));
      expect(active.first.title, '활성 일정');
    });

    test('watchActiveTodos shows only todo items', () async {
      await repo.insert(
        userId: userId,
        title: '일정',
        category: 'work',
      );
      await repo.insert(
        userId: userId,
        title: '할일',
        category: 'work',
        isTodo: true,
      );

      final todos = await repo.watchActiveTodos(userId).first;
      expect(todos, hasLength(1));
      expect(todos.first.title, '할일');
    });

    test('watchTrash shows only deleted items', () async {
      await repo.insert(
        userId: userId,
        title: '활성',
        category: 'etc',
      );
      final deletedId = await repo.insert(
        userId: userId,
        title: '삭제됨',
        category: 'etc',
      );
      await repo.softDelete(deletedId);

      final trash = await repo.watchTrash(userId).first;
      expect(trash, hasLength(1));
      expect(trash.first.title, '삭제됨');
    });

    test('watchByCategory filters by category', () async {
      await repo.insert(
        userId: userId,
        title: '업무',
        category: 'work',
      );
      await repo.insert(
        userId: userId,
        title: '공부',
        category: 'study',
      );

      final workItems =
          await repo.watchByCategory(userId, 'work').first;
      expect(workItems, hasLength(1));
      expect(workItems.first.title, '업무');
    });

    test('insert with startTime and endTime', () async {
      final start = DateTime(2026, 4, 15, 9);
      final end = DateTime(2026, 4, 15, 10);

      final id = await repo.insert(
        userId: userId,
        title: '회의',
        category: 'work',
        startTime: start,
        endTime: end,
      );

      final schedule =
          await (db.select(db.schedules)..where((s) => s.id.equals(id)))
              .getSingle();
      expect(schedule.startTime, start);
      expect(schedule.endTime, end);
    });

    test('outbox entries accumulate for each operation', () async {
      final id = await repo.insert(
        userId: userId,
        title: '추적',
        category: 'etc',
      );
      await repo.update(id: id, title: '수정');
      await repo.softDelete(id);

      final outbox = await db.select(db.outbox).get();
      // insert + update + softDelete(update)
      expect(outbox, hasLength(3));
    });
  });
}
