// Red: RealtimeHpRule — pure rule for per-minute HP feedback.
//
// 2026-05-12 UC3 implementation per Plan 3 §D + Eng P1 (reuse existing
// 60s tick; do NOT add 4th foreground service).
//
// Off by default (SharedPreferences flag); pure function is always testable.

import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/focus_tracking/domain/realtime_hp_rule.dart';

void main() {
  group('RealtimeHpRule.computeMinuteOutcome', () {
    test('phoneInUse=false → no delta', () {
      final r = RealtimeHpRule.computeMinuteOutcome(
        currentHp: 100,
        currentXp: 0,
        phoneInUse: false,
      );
      expect(r.newHp, 100);
      expect(r.newXp, 0);
      expect(r.isAlive, true);
      expect(r.delta, 0);
    });

    test('phoneInUse=true → -1 HP default', () {
      final r = RealtimeHpRule.computeMinuteOutcome(
        currentHp: 50,
        currentXp: 0,
        phoneInUse: true,
      );
      expect(r.delta, -1);
      expect(r.newHp, 49);
      expect(r.isAlive, true);
    });

    test('hp clamps at 0 when below', () {
      final r = RealtimeHpRule.computeMinuteOutcome(
        currentHp: 1,
        currentXp: 5,
        phoneInUse: true,
        hpPerMinute: -3,
      );
      expect(r.newHp, 0);
      expect(r.isAlive, false);
    });

    test('positive delta clamps at maxHp and overflows to XP (2:1)', () {
      final r = RealtimeHpRule.computeMinuteOutcome(
        currentHp: 99,
        currentXp: 10,
        phoneInUse: false,
        hpPerMinute: 0,
        bonus: 5, // 96→100 (clamp) + overflow 4 → +2 XP
        forceApply: true,
      );
      expect(r.newHp, 100);
      expect(r.newXp, 10 + 2);
    });

    test('isAlive remains false once dead — no resurrection', () {
      final r = RealtimeHpRule.computeMinuteOutcome(
        currentHp: 0,
        currentXp: 0,
        phoneInUse: true,
        startingIsAlive: false,
      );
      expect(r.isAlive, false);
      expect(r.delta, 0,
          reason: 'dead pet does not lose more HP');
    });

    test('configurable hpPerMinute (-5) hits death threshold quickly', () {
      var hp = 12;
      var xp = 0;
      var isAlive = true;
      for (var minute = 0; minute < 3; minute++) {
        final r = RealtimeHpRule.computeMinuteOutcome(
          currentHp: hp,
          currentXp: xp,
          phoneInUse: true,
          hpPerMinute: -5,
          startingIsAlive: isAlive,
        );
        hp = r.newHp;
        xp = r.newXp;
        isAlive = r.isAlive;
      }
      expect(hp, 0);
      expect(isAlive, false);
    });
  });

  group('RealtimeHpRule.isFeatureEnabled', () {
    test('default false (opt-in)', () {
      expect(
        RealtimeHpRule.isFeatureEnabled(null),
        false,
        reason: 'missing pref → disabled',
      );
      expect(
        RealtimeHpRule.isFeatureEnabled(false),
        false,
      );
      expect(
        RealtimeHpRule.isFeatureEnabled(true),
        true,
      );
    });
  });
}
