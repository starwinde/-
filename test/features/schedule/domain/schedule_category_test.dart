import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

void main() {
  group('ScheduleCategory', () {
    test('has exactly 5 values per PRD 2.8', () {
      expect(ScheduleCategory.values.length, 5);
    });

    test('fromString returns correct category', () {
      expect(ScheduleCategory.fromString('work'), ScheduleCategory.work);
      expect(ScheduleCategory.fromString('study'), ScheduleCategory.study);
      expect(ScheduleCategory.fromString('hobby'), ScheduleCategory.hobby);
      expect(ScheduleCategory.fromString('health'), ScheduleCategory.health);
      expect(ScheduleCategory.fromString('etc'), ScheduleCategory.etc);
    });

    test('fromString falls back to etc for unknown values', () {
      expect(ScheduleCategory.fromString('unknown'), ScheduleCategory.etc);
      expect(ScheduleCategory.fromString(''), ScheduleCategory.etc);
    });
  });
}
