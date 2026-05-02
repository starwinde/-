import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';

/// Returns the schedule whose `[startTime, endTime]` window contains
/// [now], or null when no such schedule exists. Used by the disturbance
/// (T5.21) controller to decide when to enforce a per-schedule
/// disruption policy.
///
/// Ignores soft-deleted, completed, and timeless (todo without
/// startTime/endTime) entries.
Schedule? findCurrentActiveSchedule(List<Schedule> all, DateTime now) {
  for (final s in all) {
    if (s.deletedAt != null) continue;
    if (s.isCompleted) continue;
    final start = s.startTime;
    final end = s.endTime;
    if (start == null || end == null) continue;
    if (now.isBefore(start)) continue;
    if (now.isAfter(end)) continue;
    return s;
  }
  return null;
}

/// Streams the schedule currently active for [userId] (now ∈ [start,end]).
/// Re-evaluated whenever the underlying schedules stream emits.
final currentActiveScheduleProvider =
    StreamProvider.family<Schedule?, String>((ref, userId) {
  return ref
      .watch(scheduleRepositoryProvider)
      .watchAllActive(userId)
      .map((all) => findCurrentActiveSchedule(all, DateTime.now()));
});
