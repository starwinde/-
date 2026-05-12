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

  // rev 35 — windowed (3-min/-1, schedule cap 5, daily cap 10) +
  // allowDisruption 게이트.
  group('RealtimeHpRule.computeWindowedOutcome', () {
    WindowedMinuteOutcome step(
      WindowedMinuteOutcome prev, {
      required bool phoneInUse,
      bool allowDisruption = true,
      int currentHp = 100,
      int currentXp = 0,
    }) {
      return RealtimeHpRule.computeWindowedOutcome(
        currentHp: prev.newHp == 0 && prev.delta == 0 ? currentHp : prev.newHp,
        currentXp: prev.newXp,
        phoneInUse: phoneInUse,
        allowDisruption: allowDisruption,
        phoneMinutesInSchedule: prev.newPhoneMinutesInSchedule,
        decrementsInSchedule: prev.newDecrementsInSchedule,
        dailyHpLossSoFar: prev.newDailyHpLoss,
        startingIsAlive: prev.isAlive,
      );
    }

    const seed = WindowedMinuteOutcome(
      delta: 0,
      newHp: 100,
      newXp: 0,
      isAlive: true,
      newPhoneMinutesInSchedule: 0,
      newDecrementsInSchedule: 0,
      newDailyHpLoss: 0,
    );

    test('allowDisruption=false → 카운터 변동 없음 (방해 안 허용 일정)', () {
      final r = step(seed, phoneInUse: true, allowDisruption: false);
      expect(r.delta, 0);
      expect(r.newHp, 100);
      expect(r.newPhoneMinutesInSchedule, 0);
      expect(r.newDecrementsInSchedule, 0);
    });

    test('1분, 2분 phone use → no decrement (3 분 미만)', () {
      var r = step(seed, phoneInUse: true);
      expect(r.delta, 0);
      expect(r.newHp, 100);
      expect(r.newPhoneMinutesInSchedule, 1);
      r = step(r, phoneInUse: true);
      expect(r.delta, 0);
      expect(r.newPhoneMinutesInSchedule, 2);
    });

    test('3분째 → -1 HP, 6분째 → 추가 -1', () {
      var r = step(seed, phoneInUse: true);
      r = step(r, phoneInUse: true);
      r = step(r, phoneInUse: true);
      expect(r.delta, -1);
      expect(r.newHp, 99);
      expect(r.newPhoneMinutesInSchedule, 3);
      expect(r.newDecrementsInSchedule, 1);
      expect(r.newDailyHpLoss, 1);

      r = step(r, phoneInUse: true);
      r = step(r, phoneInUse: true);
      r = step(r, phoneInUse: true);
      expect(r.delta, -1);
      expect(r.newHp, 98);
      expect(r.newDecrementsInSchedule, 2);
      expect(r.newDailyHpLoss, 2);
    });

    test('일정 cap 5 — 18 분 이상 사용해도 -5 에서 멈춤', () {
      var r = seed;
      for (var i = 0; i < 21; i++) {
        r = step(r, phoneInUse: true);
      }
      expect(r.newDecrementsInSchedule, 5);
      expect(r.newHp, 95);
      expect(r.newDailyHpLoss, 5);
    });

    test('phoneInUse=false 사이에 끼면 누적 분 정지 (리셋 X)', () {
      var r = step(seed, phoneInUse: true);
      r = step(r, phoneInUse: true);
      expect(r.newPhoneMinutesInSchedule, 2);
      r = step(r, phoneInUse: false);
      expect(r.newPhoneMinutesInSchedule, 2, reason: '폰 안 쓰면 정지만');
      r = step(r, phoneInUse: true);
      expect(r.delta, -1, reason: '3분째 도달 → -1');
      expect(r.newPhoneMinutesInSchedule, 3);
    });

    test('일일 cap 10 — daily 합산 10 도달 시 멈춤', () {
      final preCap = WindowedMinuteOutcome(
        delta: 0,
        newHp: 90,
        newXp: 0,
        isAlive: true,
        newPhoneMinutesInSchedule: 2,
        newDecrementsInSchedule: 4,
        newDailyHpLoss: 10,
      );
      final r = step(preCap, phoneInUse: true);
      expect(r.delta, 0);
      expect(r.newHp, 90);
      expect(r.newPhoneMinutesInSchedule, 3);
    });
  });
}
