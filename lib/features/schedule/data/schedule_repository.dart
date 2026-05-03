import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:routinemon/core/db/app_database.dart';

/// Repository for Schedule CRUD operations with outbox enqueue (rules.md 3.7).
class ScheduleRepository {
  ScheduleRepository(this._db);

  final AppDatabase _db;

  /// Watches all active (non-deleted) schedules, ordered by creation time.
  Stream<List<Schedule>> watchActive(String userId) {
    return (_db.select(_db.schedules)
          ..where(
            (s) =>
                s.userId.equals(userId) &
                s.deletedAt.isNull() &
                s.isTodo.equals(false),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .watch();
  }

  /// Watches ALL non-deleted schedules (both time-slot items and todos).
  /// Used by [WeeklyGridView] which splits them into time-slot vs "할일"
  /// sections per day column.
  Stream<List<Schedule>> watchAllActive(String userId) {
    return (_db.select(_db.schedules)
          ..where(
            (s) => s.userId.equals(userId) & s.deletedAt.isNull(),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .watch();
  }

  /// Watches all active to-do items (non-deleted, isTodo=true).
  Stream<List<Schedule>> watchActiveTodos(String userId) {
    return (_db.select(_db.schedules)
          ..where(
            (s) =>
                s.userId.equals(userId) &
                s.deletedAt.isNull() &
                s.isTodo.equals(true),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .watch();
  }

  /// Watches all active schedules filtered by category.
  Stream<List<Schedule>> watchByCategory(
    String userId,
    String category,
  ) {
    return (_db.select(_db.schedules)
          ..where(
            (s) =>
                s.userId.equals(userId) &
                s.deletedAt.isNull() &
                s.category.equals(category),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .watch();
  }

  /// Watches soft-deleted schedules (trash).
  Stream<List<Schedule>> watchTrash(String userId) {
    return (_db.select(_db.schedules)
          ..where(
            (s) =>
                s.userId.equals(userId) & s.deletedAt.isNotNull(),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.deletedAt)]))
        .watch();
  }

  /// Inserts a new schedule and enqueues to outbox.
  Future<int> insert({
    required String userId,
    required String title,
    required String category,
    List<String> tags = const [],
    DateTime? startTime,
    DateTime? endTime,
    bool isTodo = false,
    bool allowDisruption = false,
    int disruptionIntensity = 1,
  }) async {
    return _db.transaction(() async {
      final id = await _db.into(_db.schedules).insert(
            SchedulesCompanion.insert(
              userId: userId,
              title: title,
              category: category,
              tags: Value(jsonEncode(tags)),
              startTime: Value(startTime),
              endTime: Value(endTime),
              isTodo: Value(isTodo),
              allowDisruption: Value(allowDisruption),
              disruptionIntensity: Value(disruptionIntensity),
            ),
          );
      await _enqueue('schedules', id.toString(), 'insert');
      return id;
    });
  }

  /// Inserts multiple schedules in a single transaction, enqueueing each
  /// into the outbox for sync.
  Future<List<int>> insertMany(List<SchedulesCompanion> items) async {
    if (items.isEmpty) return const [];
    return _db.transaction(() async {
      final ids = <int>[];
      for (final item in items) {
        final id = await _db.into(_db.schedules).insert(item);
        ids.add(id);
        await _enqueue('schedules', id.toString(), 'insert');
      }
      return ids;
    });
  }

  /// Updates an existing schedule and enqueues to outbox.
  Future<void> update({
    required int id,
    String? title,
    String? category,
    List<String>? tags,
    Value<DateTime?> startTime = const Value.absent(),
    Value<DateTime?> endTime = const Value.absent(),
    bool? isCompleted,
    bool? isTodo,
    bool? allowDisruption,
    int? disruptionIntensity,
  }) async {
    await _db.transaction(() async {
      final companion = SchedulesCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        category: category != null ? Value(category) : const Value.absent(),
        tags: tags != null ? Value(jsonEncode(tags)) : const Value.absent(),
        startTime: startTime,
        endTime: endTime,
        isCompleted:
            isCompleted != null ? Value(isCompleted) : const Value.absent(),
        isTodo: isTodo != null ? Value(isTodo) : const Value.absent(),
        allowDisruption: allowDisruption != null
            ? Value(allowDisruption)
            : const Value.absent(),
        disruptionIntensity: disruptionIntensity != null
            ? Value(disruptionIntensity)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );
      await (_db.update(_db.schedules)..where((s) => s.id.equals(id)))
          .write(companion);
      await _enqueue('schedules', id.toString(), 'update');
    });
  }

  /// Soft deletes a schedule (sets deletedAt).
  Future<void> softDelete(int id) async {
    await _db.transaction(() async {
      await (_db.update(_db.schedules)..where((s) => s.id.equals(id))).write(
        SchedulesCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _enqueue('schedules', id.toString(), 'update');
    });
  }

  /// Soft-deletes multiple schedules in one transaction.
  Future<void> softDeleteMany(List<int> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      final now = DateTime.now();
      for (final id in ids) {
        await (_db.update(_db.schedules)..where((s) => s.id.equals(id)))
            .write(
          SchedulesCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
        await _enqueue('schedules', id.toString(), 'update');
      }
    });
  }

  /// Restores a soft-deleted schedule.
  Future<void> restore(int id) async {
    await _db.transaction(() async {
      await (_db.update(_db.schedules)..where((s) => s.id.equals(id))).write(
        SchedulesCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _enqueue('schedules', id.toString(), 'update');
    });
  }

  /// Permanently deletes a schedule.
  Future<void> permanentDelete(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.schedules)..where((s) => s.id.equals(id))).go();
      await _enqueue('schedules', id.toString(), 'delete');
    });
  }

  Future<void> _enqueue(String table, String rowId, String operation) async {
    await _db.into(_db.outbox).insert(
          OutboxCompanion.insert(
            targetTable: table,
            rowId: rowId,
            operation: operation,
            payload: '{}',
          ),
        );
  }
}
