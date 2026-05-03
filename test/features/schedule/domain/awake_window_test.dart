import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/domain/awake_window.dart';
import 'package:routinemon/features/schedule/domain/lifestyle_enums.dart';

void main() {
  group('AwakeWindow.resolve — 결정론 매핑', () {
    test('early57 + early2123 + morning → 06:00 ~ 22:00', () {
      final w = AwakeWindow.resolve(
        WakeTime.early57,
        SleepTime.early2123,
        Chronotype.morning,
      );
      expect(w.startMinute, 6 * 60);
      expect(w.endMinute, 22 * 60);
    });

    test('early57 + early2123 + middle → 06:30 ~ 22:30', () {
      final w = AwakeWindow.resolve(
        WakeTime.early57,
        SleepTime.early2123,
        Chronotype.middle,
      );
      expect(w.startMinute, 6 * 60 + 30);
      expect(w.endMinute, 22 * 60 + 30);
    });

    test('morning79 + midnight231 + middle → 07:30 ~ 24:00', () {
      final w = AwakeWindow.resolve(
        WakeTime.morning79,
        SleepTime.midnight231,
        Chronotype.middle,
      );
      expect(w.startMinute, 7 * 60 + 30);
      expect(w.endMinute, 24 * 60);
    });

    test('late911 + late13 + evening → 10:30 ~ 02:30+1d', () {
      final w = AwakeWindow.resolve(
        WakeTime.late911,
        SleepTime.late13,
        Chronotype.evening,
      );
      expect(w.startMinute, 10 * 60 + 30);
      expect(w.endMinute, 24 * 60 + 2 * 60 + 30);
      expect(w.endMinute > 24 * 60, isTrue);
    });

    test('variable wake + variable sleep + morning → 07:00 ~ 23:00', () {
      final w = AwakeWindow.resolve(
        WakeTime.variable,
        SleepTime.variable,
        Chronotype.morning,
      );
      expect(w.startMinute, 7 * 60);
      expect(w.endMinute, 23 * 60);
    });

    test('variable wake + variable sleep + middle → 08:00 ~ 24:00', () {
      final w = AwakeWindow.resolve(
        WakeTime.variable,
        SleepTime.variable,
        Chronotype.middle,
      );
      expect(w.startMinute, 8 * 60);
      expect(w.endMinute, 24 * 60);
    });

    test('variable wake + variable sleep + evening → 10:00 ~ 25:00', () {
      final w = AwakeWindow.resolve(
        WakeTime.variable,
        SleepTime.variable,
        Chronotype.evening,
      );
      expect(w.startMinute, 10 * 60);
      expect(w.endMinute, 25 * 60);
    });

    test('동일 입력 → 동일 출력 (결정론)', () {
      final a = AwakeWindow.resolve(
        WakeTime.morning79,
        SleepTime.midnight231,
        Chronotype.middle,
      );
      final b = AwakeWindow.resolve(
        WakeTime.morning79,
        SleepTime.midnight231,
        Chronotype.middle,
      );
      expect(a.startMinute, b.startMinute);
      expect(a.endMinute, b.endMinute);
    });
  });

  group('AwakeWindow.contains', () {
    test('윈도우 내부 시각 → true', () {
      const w = AwakeWindow(startMinute: 7 * 60, endMinute: 23 * 60);
      expect(w.contains(12 * 60), isTrue); // 정오
      expect(w.contains(7 * 60), isTrue); // 시작 경계
    });

    test('윈도우 끝 경계 (exclusive) → false', () {
      const w = AwakeWindow(startMinute: 7 * 60, endMinute: 23 * 60);
      expect(w.contains(23 * 60), isFalse);
    });

    test('시작 이전 → false', () {
      const w = AwakeWindow(startMinute: 7 * 60, endMinute: 23 * 60);
      expect(w.contains(6 * 60), isFalse);
    });

    test('자정 넘김 윈도우 — 다음날 0:30 정상 처리', () {
      // 10:00 ~ 02:00+1d
      const w = AwakeWindow(startMinute: 10 * 60, endMinute: 26 * 60);
      // 다음날 0:30 = 절대 분 24*60 + 30 = 1470
      expect(w.contains(0 * 60 + 30, treatAsNextDay: true), isTrue);
      // 같은 날 23:00 = 1380
      expect(w.contains(23 * 60), isTrue);
      // 같은 날 09:00 = 540 → 윈도우 시작 이전
      expect(w.contains(9 * 60), isFalse);
    });

    test('자정 넘김 윈도우 — 다음날 03:00 (윈도우 끝 뒤)', () {
      // 10:00 ~ 02:00+1d (1560)
      const w = AwakeWindow(startMinute: 10 * 60, endMinute: 26 * 60);
      // 다음날 3:00 = 1620 > 1560
      expect(w.contains(3 * 60, treatAsNextDay: true), isFalse);
    });
  });

  group('AwakeWindow.durationMinutes', () {
    test('일반 윈도우 — 양수', () {
      const w = AwakeWindow(startMinute: 7 * 60, endMinute: 23 * 60);
      expect(w.durationMinutes, 16 * 60);
    });

    test('자정 넘김 윈도우 — 양수 (24h 기준)', () {
      const w = AwakeWindow(startMinute: 10 * 60, endMinute: 26 * 60);
      expect(w.durationMinutes, 16 * 60);
    });
  });
}
