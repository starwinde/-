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
}
