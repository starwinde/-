import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/focus_tracking/domain/blacklist_intervention.dart';

void main() {
  late BlacklistIntervention intervention;

  setUp(() {
    intervention = BlacklistIntervention();
  });

  group('BlacklistIntervention', () {
    test('1회 → notification', () {
      expect(
        intervention.onBlacklistAppOpened(),
        InterventionLevel.notification,
      );
    });

    test('2회 → notification (아직 3 미만)', () {
      intervention.onBlacklistAppOpened(); // 1회
      expect(
        intervention.onBlacklistAppOpened(), // 2회
        InterventionLevel.notification,
      );
    });

    test('3회 → popup', () {
      intervention.onBlacklistAppOpened(); // 1회
      intervention.onBlacklistAppOpened(); // 2회
      expect(
        intervention.onBlacklistAppOpened(), // 3회
        InterventionLevel.popup,
      );
    });

    test('4회 → popup (아직 5 미만)', () {
      for (var i = 0; i < 3; i++) {
        intervention.onBlacklistAppOpened();
      }
      expect(
        intervention.onBlacklistAppOpened(), // 4회
        InterventionLevel.popup,
      );
    });

    test('5회 → fullscreen', () {
      for (var i = 0; i < 4; i++) {
        intervention.onBlacklistAppOpened();
      }
      expect(
        intervention.onBlacklistAppOpened(), // 5회
        InterventionLevel.fullscreen,
      );
    });

    test('6회 이상 → fullscreen 유지', () {
      for (var i = 0; i < 5; i++) {
        intervention.onBlacklistAppOpened();
      }
      expect(
        intervention.onBlacklistAppOpened(), // 6회
        InterventionLevel.fullscreen,
      );
      expect(
        intervention.onBlacklistAppOpened(), // 7회
        InterventionLevel.fullscreen,
      );
    });

    test('리셋 후 → 다시 1부터', () {
      // 5회까지 진행
      for (var i = 0; i < 5; i++) {
        intervention.onBlacklistAppOpened();
      }

      intervention.resetSession();

      // 리셋 후 1회 → notification
      expect(
        intervention.onBlacklistAppOpened(),
        InterventionLevel.notification,
      );
    });

    test('openCount getter 정확성', () {
      expect(intervention.openCount, 0);

      intervention.onBlacklistAppOpened();
      expect(intervention.openCount, 1);

      intervention.onBlacklistAppOpened();
      expect(intervention.openCount, 2);

      intervention.resetSession();
      expect(intervention.openCount, 0);
    });
  });
}
