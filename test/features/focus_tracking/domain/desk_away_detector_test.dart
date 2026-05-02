import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/focus_tracking/domain/desk_away_detector.dart';

void main() {
  late DeskAwayDetector detector;

  setUp(() {
    detector = DeskAwayDetector();
  });

  group('DeskAwayDetector', () {
    test('첫 이탈 → -3', () {
      final now = DateTime(2026, 4, 16, 10);
      expect(detector.onDeskAway(now), -3);
    });

    test('30분 내 재이탈 → 0 (쿨다운)', () {
      final first = DateTime(2026, 4, 16, 10);
      detector.onDeskAway(first);

      final within = first.add(const Duration(minutes: 29));
      expect(detector.onDeskAway(within), 0);
    });

    test('정확히 30분 후 재이탈 → -3', () {
      final first = DateTime(2026, 4, 16, 10);
      detector.onDeskAway(first);

      final exactly30 = first.add(const Duration(minutes: 30));
      expect(detector.onDeskAway(exactly30), -3);
    });

    test('30분 후 재이탈 → -3', () {
      final first = DateTime(2026, 4, 16, 10);
      detector.onDeskAway(first);

      final after = first.add(const Duration(minutes: 31));
      expect(detector.onDeskAway(after), -3);
    });

    test('일일 3회(= -9) 후 → 0 (max)', () {
      final base = DateTime(2026, 4, 16, 8);

      // 1회: -3
      expect(detector.onDeskAway(base), -3);
      // 2회: -3 (30분 후)
      expect(
        detector.onDeskAway(base.add(const Duration(minutes: 30))),
        -3,
      );
      // 3회: -3 (60분 후)
      expect(
        detector.onDeskAway(base.add(const Duration(minutes: 60))),
        -3,
      );
      // 4회: 0 (일일 max -9 도달)
      expect(
        detector.onDeskAway(base.add(const Duration(minutes: 90))),
        0,
      );
    });

    test('일일 max 도달 후에도 0 유지', () {
      final base = DateTime(2026, 4, 16, 8);

      // 3회 소진
      detector.onDeskAway(base);
      detector.onDeskAway(base.add(const Duration(minutes: 30)));
      detector.onDeskAway(base.add(const Duration(minutes: 60)));

      // 4회, 5회 모두 0
      expect(
        detector.onDeskAway(base.add(const Duration(minutes: 90))),
        0,
      );
      expect(
        detector.onDeskAway(base.add(const Duration(minutes: 120))),
        0,
      );
    });

    test('일일 리셋 후 → 다시 -3', () {
      final base = DateTime(2026, 4, 16, 8);

      // 3회 소진
      detector.onDeskAway(base);
      detector.onDeskAway(base.add(const Duration(minutes: 30)));
      detector.onDeskAway(base.add(const Duration(minutes: 60)));

      // max 도달
      expect(
        detector.onDeskAway(base.add(const Duration(minutes: 90))),
        0,
      );

      // 리셋
      detector.resetDaily();

      // 리셋 후 다시 -3
      final nextDay = DateTime(2026, 4, 17, 8);
      expect(detector.onDeskAway(nextDay), -3);
    });

    test('쿨다운 중 리셋해도 쿨다운 해제', () {
      final base = DateTime(2026, 4, 16, 8);
      detector.onDeskAway(base);

      detector.resetDaily();

      // 리셋 후 즉시 이탈 가능 (쿨다운 초기화됨)
      final sameTime = base.add(const Duration(minutes: 5));
      expect(detector.onDeskAway(sameTime), -3);
    });

    test('dailyHpLoss getter 정확성', () {
      final base = DateTime(2026, 4, 16, 8);

      expect(detector.dailyHpLoss, 0);

      detector.onDeskAway(base);
      expect(detector.dailyHpLoss, 3);

      detector.onDeskAway(base.add(const Duration(minutes: 30)));
      expect(detector.dailyHpLoss, 6);

      detector.onDeskAway(base.add(const Duration(minutes: 60)));
      expect(detector.dailyHpLoss, 9);
    });
  });
}
