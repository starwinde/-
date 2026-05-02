import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';

/// Watches active (non-deleted, non-todo) schedules for [userId].
final activeSchedulesProvider =
    StreamProvider.family<List<Schedule>, String>((ref, userId) {
  return ref.watch(scheduleRepositoryProvider).watchActive(userId);
});

/// Watches active to-do items for [userId].
final activeTodosProvider =
    StreamProvider.family<List<Schedule>, String>((ref, userId) {
  return ref.watch(scheduleRepositoryProvider).watchActiveTodos(userId);
});

/// Watches all non-deleted schedules (time-slot items + todos) for [userId].
/// [WeeklyGridView] consumes this to render both types in one grid.
final allActiveSchedulesProvider =
    StreamProvider.family<List<Schedule>, String>((ref, userId) {
  return ref.watch(scheduleRepositoryProvider).watchAllActive(userId);
});

/// Watches schedules by category. Key: `userId|category`.
final schedulesByCategoryProvider =
    StreamProvider.family<List<Schedule>, ({String userId, String category})>(
        (ref, params) {
  return ref
      .watch(scheduleRepositoryProvider)
      .watchByCategory(params.userId, params.category);
});

/// Watches soft-deleted schedules (trash) for [userId].
final trashSchedulesProvider =
    StreamProvider.family<List<Schedule>, String>((ref, userId) {
  return ref.watch(scheduleRepositoryProvider).watchTrash(userId);
});
