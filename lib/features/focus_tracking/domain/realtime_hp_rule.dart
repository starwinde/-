// Real-time HP feedback rule.
//
// 2026-05-12 UC3 — Plan 3 §D implementation. Pure function reused inline
// from ScheduleSessionTrigger._tick() per Eng P1: do NOT add a 4th
// foreground service. The existing 60s tick is the natural hook point.
//
// Off by default (SharedPreferences flag `realtime_hp_enabled`). When on,
// each minute the user spends on blacklisted apps during an active schedule
// reduces pet HP by [hpPerMinute] (default -1).
//
// Daily settlement still runs separately and uses focus ratio aggregates —
// compounding by design (this rule = immediate feedback, settlement = grade
// reward/penalty). Tune via user-facing setting if double-punishment is felt.

import 'package:routinemon/core/constants/xp_rules.dart';

/// SharedPreferences key prefix for daily HP loss counter (rev 35).
/// Concrete key per day: `'$dailyHpLossKeyPrefix$YYYY-MM-DD'`.
const dailyHpLossKeyPrefix = 'daily_hp_loss_';

class MinuteOutcome {
  const MinuteOutcome({
    required this.delta,
    required this.newHp,
    required this.newXp,
    required this.isAlive,
  });
  final int delta;
  final int newHp;
  final int newXp;
  final bool isAlive;
}

/// Outcome of a windowed minute (3-min decrement, schedule + daily caps).
///
/// Caller (ScheduleSessionTrigger) owns the counters and applies the
/// returned new values back to its state. Rule itself is pure.
class WindowedMinuteOutcome {
  const WindowedMinuteOutcome({
    required this.delta,
    required this.newHp,
    required this.newXp,
    required this.isAlive,
    required this.newPhoneMinutesInSchedule,
    required this.newDecrementsInSchedule,
    required this.newDailyHpLoss,
  });
  final int delta;
  final int newHp;
  final int newXp;
  final bool isAlive;
  final int newPhoneMinutesInSchedule;
  final int newDecrementsInSchedule;
  final int newDailyHpLoss;
}

class RealtimeHpRule {
  RealtimeHpRule._();

  /// SharedPreferences key — opt-in feature flag.
  static const featureFlagKey = 'realtime_hp_enabled';

  /// Returns whether the feature should be active given the stored flag.
  /// Null (missing) → false.
  static bool isFeatureEnabled(bool? flag) => flag ?? false;

  /// Computes the HP/XP outcome for a single minute window.
  ///
  /// - [phoneInUse]=false applies no delta (pet stays put).
  /// - [phoneInUse]=true applies [hpPerMinute] (default -1).
  /// - HP clamps to [0, XpRules.maxHp]. Positive overflow → XP at 2:1.
  /// - Death is permanent within a tick — once isAlive=false, no further changes.
  /// - [bonus] + [forceApply] are escape hatches for tests/devops only.
  static MinuteOutcome computeMinuteOutcome({
    required int currentHp,
    required int currentXp,
    required bool phoneInUse,
    int hpPerMinute = -1,
    bool startingIsAlive = true,
    int bonus = 0,
    bool forceApply = false,
  }) {
    if (!startingIsAlive) {
      return MinuteOutcome(
        delta: 0,
        newHp: currentHp,
        newXp: currentXp,
        isAlive: false,
      );
    }

    final shouldApply = forceApply || phoneInUse;
    if (!shouldApply) {
      return MinuteOutcome(
        delta: 0,
        newHp: currentHp,
        newXp: currentXp,
        isAlive: true,
      );
    }

    final delta = phoneInUse ? hpPerMinute : 0;
    final raw = currentHp + delta + bonus;

    if (raw >= XpRules.maxHp) {
      final overflow = raw - XpRules.maxHp;
      return MinuteOutcome(
        delta: delta,
        newHp: XpRules.maxHp,
        newXp: currentXp + (overflow ~/ XpRules.hpOverflowXpDivisor),
        isAlive: true,
      );
    }

    if (raw <= 0) {
      return MinuteOutcome(
        delta: delta,
        newHp: 0,
        newXp: currentXp,
        isAlive: false,
      );
    }

    return MinuteOutcome(
      delta: delta,
      newHp: raw,
      newXp: currentXp,
      isAlive: true,
    );
  }

  /// Windowed real-time HP rule (rev 35, 2026-05-12).
  ///
  /// 동작 사양:
  /// 1. `allowDisruption=true` 일정에서만 감소가 발생한다 (방해 알림 게이트
  ///    와 일치). false 이면 카운터 변동 없이 no-op.
  /// 2. `phoneInUse=true` 이면 [phoneMinutesInSchedule] +1. 폰을 잠시
  ///    안 쓰면 누적이 멈출 뿐 리셋되지 않는다 (일정 내 누적).
  /// 3. 누적 분이 [XpRules.realtimeHpMinutesPerDecrement] (3) 배수에 도달
  ///    할 때마다 `-1 HP`.
  /// 4. 한 일정 안에서 감소 횟수는 [XpRules.realtimeHpMaxDecrementsPerSchedule]
  ///    (5) 까지. 즉 한 일정 안 최대 `-5 HP`.
  /// 5. 그날 누적 HP 손실([dailyHpLossSoFar] + 신규 감소) 은
  ///    [XpRules.dailyHpLossCap] (10) 을 넘지 못한다. 정산도 같은 cap 안에서
  ///    차감하므로 실시간 + 정산 합산 ≤ 10.
  static WindowedMinuteOutcome computeWindowedOutcome({
    required int currentHp,
    required int currentXp,
    required bool phoneInUse,
    required bool allowDisruption,
    required int phoneMinutesInSchedule,
    required int decrementsInSchedule,
    required int dailyHpLossSoFar,
    bool startingIsAlive = true,
  }) {
    WindowedMinuteOutcome noop({int? phoneMin, int? dec, int? daily}) =>
        WindowedMinuteOutcome(
          delta: 0,
          newHp: currentHp,
          newXp: currentXp,
          isAlive: startingIsAlive,
          newPhoneMinutesInSchedule: phoneMin ?? phoneMinutesInSchedule,
          newDecrementsInSchedule: dec ?? decrementsInSchedule,
          newDailyHpLoss: daily ?? dailyHpLossSoFar,
        );

    if (!startingIsAlive) return noop();
    if (!allowDisruption) return noop();
    if (!phoneInUse) return noop();

    final newPhoneMin = phoneMinutesInSchedule + 1;
    final isWindowBoundary =
        newPhoneMin % XpRules.realtimeHpMinutesPerDecrement == 0;
    if (!isWindowBoundary) return noop(phoneMin: newPhoneMin);

    final scheduleExhausted =
        decrementsInSchedule >= XpRules.realtimeHpMaxDecrementsPerSchedule;
    final dailyExhausted = dailyHpLossSoFar >= XpRules.dailyHpLossCap;
    if (scheduleExhausted || dailyExhausted) {
      return noop(phoneMin: newPhoneMin);
    }

    const decrement = -1;
    final rawHp = currentHp + decrement;
    final newHp = rawHp < 0 ? 0 : rawHp;
    final alive = newHp > 0;
    return WindowedMinuteOutcome(
      delta: decrement,
      newHp: newHp,
      newXp: currentXp,
      isAlive: alive,
      newPhoneMinutesInSchedule: newPhoneMin,
      newDecrementsInSchedule: decrementsInSchedule + 1,
      newDailyHpLoss: dailyHpLossSoFar + 1,
    );
  }
}
