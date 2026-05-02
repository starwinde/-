import 'dart:async';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/data/schedule_repository.dart';

part 'schedule_notifier.g.dart';

/// Provides the [AppDatabase] singleton instance.
/// Must be keepAlive — Drift DB must never be auto-disposed.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();

/// Provides the [ScheduleRepository] backed by the app database.
@riverpod
ScheduleRepository scheduleRepository(Ref ref) {
  return ScheduleRepository(ref.watch(appDatabaseProvider));
}

/// Manages schedule CRUD operations.
@riverpod
class ScheduleActions extends _$ScheduleActions {
  @override
  FutureOr<void> build() {}

  /// Creates a new schedule.
  Future<int> create({
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
    final repo = ref.read(scheduleRepositoryProvider);
    return repo.insert(
      userId: userId,
      title: title,
      category: category,
      tags: tags,
      startTime: startTime,
      endTime: endTime,
      isTodo: isTodo,
      allowDisruption: allowDisruption,
      disruptionIntensity: disruptionIntensity,
    );
  }

  /// Updates an existing schedule.
  Future<void> updateSchedule({
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
    final repo = ref.read(scheduleRepositoryProvider);
    await repo.update(
      id: id,
      title: title,
      category: category,
      tags: tags,
      startTime: startTime,
      endTime: endTime,
      isCompleted: isCompleted,
      isTodo: isTodo,
      allowDisruption: allowDisruption,
      disruptionIntensity: disruptionIntensity,
    );
  }

  /// Soft deletes a schedule.
  Future<void> softDelete(int id) async {
    await ref.read(scheduleRepositoryProvider).softDelete(id);
  }

  /// Restores a soft-deleted schedule.
  Future<void> restore(int id) async {
    await ref.read(scheduleRepositoryProvider).restore(id);
  }

  /// Permanently deletes a schedule.
  Future<void> permanentDelete(int id) async {
    await ref.read(scheduleRepositoryProvider).permanentDelete(id);
  }
}
