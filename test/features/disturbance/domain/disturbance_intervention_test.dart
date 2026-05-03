import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/disturbance/domain/disturbance_intervention.dart';

void main() {
  group('DisturbanceIntervention', () {
    test('L1: 5s overlay every 60s + 200ms vibrate every 20s', () {
      final intervention = DisturbanceIntervention();
      final action = intervention.onActiveUsage(
        DateTime(2026, 4, 25, 10),
        DisturbanceLevel.l1,
      );
      expect(action, isNotNull);
      expect(action!.vibrateMs, 200);
      expect(action.blackOverlayMs, 5000);
      expect(action.launchHome, isFalse);
      expect(action.periodicSec, 60);
      expect(action.periodicVibrateMs, 200);
      expect(action.periodicVibrateSec, 20);
      expect(action.periodicLaunchHome, isFalse);
      expect(action.periodicLockDevice, isFalse);
    });

    test('L2: dialog + home every 60s + 500ms vibrate every 20s', () {
      final intervention = DisturbanceIntervention();
      final action = intervention.onActiveUsage(
        DateTime(2026, 4, 25, 10),
        DisturbanceLevel.l2,
      );
      expect(action!.vibrateMs, 500);
      expect(action.blockDialog, isTrue);
      expect(action.launchHome, isTrue);
      expect(action.periodicSec, 60);
      expect(action.periodicVibrateMs, 500);
      expect(action.periodicVibrateSec, 20);
      expect(action.periodicLaunchHome, isTrue);
      expect(action.periodicLockDevice, isFalse);
    });

    test('L3: lock every 30s + 800ms vibrate every 10s', () {
      final intervention = DisturbanceIntervention();
      final action = intervention.onActiveUsage(
        DateTime(2026, 4, 25, 10),
        DisturbanceLevel.l3,
      );
      expect(action!.vibrateMs, 1000);
      expect(action.blockOverlay, isTrue);
      expect(action.launchHome, isTrue);
      expect(action.periodicSec, 30);
      expect(action.periodicVibrateMs, 800);
      expect(action.periodicVibrateSec, 10);
      expect(action.periodicLockDevice, isTrue);
      expect(action.periodicLaunchHome, isFalse);
    });

    test('cooldown blocks events within 30 seconds', () {
      final intervention = DisturbanceIntervention();
      final t0 = DateTime(2026, 4, 25, 10);
      expect(intervention.onActiveUsage(t0, DisturbanceLevel.l1), isNotNull);
      expect(
        intervention.onActiveUsage(
          t0.add(const Duration(seconds: 29)),
          DisturbanceLevel.l1,
        ),
        isNull,
      );
      expect(
        intervention.onActiveUsage(
          t0.add(const Duration(seconds: 31)),
          DisturbanceLevel.l1,
        ),
        isNotNull,
      );
    });

    test('resetForNewSchedule allows immediate fire', () {
      final intervention = DisturbanceIntervention();
      final t0 = DateTime(2026, 4, 25, 10);
      intervention.onActiveUsage(t0, DisturbanceLevel.l1);
      intervention.resetForNewSchedule();
      expect(
        intervention.onActiveUsage(
          t0.add(const Duration(seconds: 1)),
          DisturbanceLevel.l1,
        ),
        isNotNull,
      );
    });

    test('L0: observe-only — all actions disabled (ADR 0004)', () {
      final intervention = DisturbanceIntervention();
      final action = intervention.onActiveUsage(
        DateTime(2026, 5, 3, 10),
        DisturbanceLevel.l0,
      );
      expect(action, isNotNull);
      expect(action!.vibrateMs, 0);
      expect(action.blackOverlayMs, 0);
      expect(action.blockDialog, isFalse);
      expect(action.launchHome, isFalse);
      expect(action.blockOverlay, isFalse);
      expect(action.periodicSec, 0);
      expect(action.periodicVibrateMs, 0);
      expect(action.periodicLaunchHome, isFalse);
      expect(action.periodicLockDevice, isFalse);
    });

    test('L0 also respects cooldown (consistent firing semantics)', () {
      final intervention = DisturbanceIntervention();
      final t0 = DateTime(2026, 5, 3, 10);
      expect(intervention.onActiveUsage(t0, DisturbanceLevel.l0), isNotNull);
      expect(
        intervention.onActiveUsage(
          t0.add(const Duration(seconds: 10)),
          DisturbanceLevel.l0,
        ),
        isNull,
      );
    });

    test('DisturbanceLevel.fromInt maps 0/1/2/3, others fall back to L1', () {
      expect(DisturbanceLevel.fromInt(0), DisturbanceLevel.l0);
      expect(DisturbanceLevel.fromInt(1), DisturbanceLevel.l1);
      expect(DisturbanceLevel.fromInt(2), DisturbanceLevel.l2);
      expect(DisturbanceLevel.fromInt(3), DisturbanceLevel.l3);
      expect(DisturbanceLevel.fromInt(-1), DisturbanceLevel.l1);
      expect(DisturbanceLevel.fromInt(99), DisturbanceLevel.l1);
    });
  });
}
