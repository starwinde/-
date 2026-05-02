import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workmanager/workmanager.dart';

part 'daily_settlement_scheduler.g.dart';

/// Unique task name for the daily settlement periodic task.
const kDailySettlementTask = 'daily-settlement';

/// WorkManager callback dispatcher — must be a top-level function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kDailySettlementTask) {
      // Settlement logic is handled by settlement-impl (T3.8).
      // This worker acts as a trigger; the actual score calculation
      // runs in Dart isolate via Drift.
    }
    return true;
  });
}

/// Default settlement hour (04:00).
const kDefaultSettlementHour = 4;

/// Provides the daily settlement scheduler.
@riverpod
DailySettlementScheduler dailySettlementScheduler(Ref ref) =>
    DailySettlementScheduler();

/// Schedules a daily settlement task via WorkManager.
///
/// PRD 2.10: user-specified time (default 04:00), WorkManager + AlarmManager,
/// server-time based.
class DailySettlementScheduler {
  /// Register the periodic settlement task.
  ///
  /// [settlementHour] — the hour (0-23) at which settlement runs.
  Future<void> schedule({int settlementHour = kDefaultSettlementHour}) async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      kDailySettlementTask,
      kDailySettlementTask,
      frequency: const Duration(hours: 24),
      initialDelay: _timeUntilSettlement(settlementHour),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  /// Cancel the scheduled settlement task.
  Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(kDailySettlementTask);
  }

  /// Calculate delay from now until the next occurrence of
  /// [settlementHour]:00.
  Duration _timeUntilSettlement(int settlementHour) {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, settlementHour);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target.difference(now);
  }
}
