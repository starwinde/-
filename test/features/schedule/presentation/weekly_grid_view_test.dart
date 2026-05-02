import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/presentation/weekly_grid_view.dart';

void main() {
  group('WeeklyGridView.mondayOfWeek', () {
    test('returns same date when given a Monday', () {
      // 2026-04-20 is a Monday.
      final monday = DateTime(2026, 4, 20);
      final result = WeeklyGridView.mondayOfWeek(monday);
      expect(result, DateTime(2026, 4, 20));
    });

    test('returns the Monday of the same week for a Tuesday', () {
      // 2026-04-21 (Tue) -> 2026-04-20 (Mon).
      final tuesday = DateTime(2026, 4, 21, 15, 30);
      final result = WeeklyGridView.mondayOfWeek(tuesday);
      expect(result, DateTime(2026, 4, 20));
    });

    test('returns the Monday of the same week for a Sunday', () {
      // 2026-04-26 (Sun) -> 2026-04-20 (Mon).
      final sunday = DateTime(2026, 4, 26, 23, 59);
      final result = WeeklyGridView.mondayOfWeek(sunday);
      expect(result, DateTime(2026, 4, 20));
    });

    test('zeroes out the time component', () {
      final input = DateTime(2026, 4, 22, 13, 45, 30);
      final result = WeeklyGridView.mondayOfWeek(input);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });
  });
}
