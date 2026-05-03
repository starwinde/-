import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/domain/awake_window.dart';
import 'package:routinemon/features/schedule/domain/conflict_report.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';
import 'package:routinemon/features/schedule/domain/schedule_conflict_detector.dart';

const _detector = ScheduleConflictDetector();
const _awake = AwakeWindow(startMinute: 7 * 60, endMinute: 23 * 60);
final _weekStart = DateTime(2026, 5, 4); // 월

GeneratedScheduleItem _item({
  String title = 't',
  int day = 0,
  String start = '09:00',
  String end = '10:00',
  ScheduleCategory cat = ScheduleCategory.work,
  List<String> tags = const [],
}) =>
    GeneratedScheduleItem(
      title: title,
      dayOfWeek: day,
      startTime: start,
      endTime: end,
      category: cat,
      tags: tags,
    );

void main() {
  group('TIME_OVERLAP', () {
    test('동일 day 두 items 겹침 → 1건', () {
      final r = _detector.detect(
        proposed: [
          _item(title: 'a', day: 0, start: '09:00', end: '11:00'),
          _item(title: 'b', day: 0, start: '10:00', end: '12:00'),
        ],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      final overlap = r.where((c) => c.kind == ConflictKind.timeOverlap);
      expect(overlap.length, 1);
      expect(overlap.first.severity, ConflictSeverity.error);
      expect(overlap.first.indices, [0, 1]);
    });

    test('인접 (gap=0) → overlap 아님', () {
      final r = _detector.detect(
        proposed: [
          _item(start: '09:00', end: '10:00'),
          _item(start: '10:00', end: '11:00'),
        ],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(
        r.where((c) => c.kind == ConflictKind.timeOverlap),
        isEmpty,
      );
    });

    test('다른 day → overlap 아님', () {
      final r = _detector.detect(
        proposed: [
          _item(day: 0, start: '09:00', end: '11:00'),
          _item(day: 1, start: '10:00', end: '12:00'),
        ],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(r.where((c) => c.kind == ConflictKind.timeOverlap), isEmpty);
    });
  });

  group('EXISTING_OVERLAP', () {
    test('기존 schedule 와 겹치면 1건 + existingId 첨부', () {
      final r = _detector.detect(
        proposed: [_item(day: 0, start: '09:00', end: '10:00')],
        existingThisWeek: [
          (
            id: 42,
            start: DateTime(2026, 5, 4, 9, 30),
            end: DateTime(2026, 5, 4, 10, 30),
          ),
        ],
        awake: _awake,
        weekStart: _weekStart,
      );
      final c = r.where((x) => x.kind == ConflictKind.existingOverlap);
      expect(c.length, 1);
      expect(c.first.existingId, 42);
      expect(c.first.severity, ConflictSeverity.error);
    });

    test('start/end null 인 기존 → 무시', () {
      final r = _detector.detect(
        proposed: [_item(day: 0, start: '09:00', end: '10:00')],
        existingThisWeek: const [(id: 1, start: null, end: null)],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(r.where((c) => c.kind == ConflictKind.existingOverlap), isEmpty);
    });

    test('다른 주 기존 → 무시', () {
      final r = _detector.detect(
        proposed: [_item(day: 0, start: '09:00', end: '10:00')],
        existingThisWeek: [
          (
            id: 1,
            start: DateTime(2026, 5, 11, 9, 0),
            end: DateTime(2026, 5, 11, 10, 0),
          ),
        ],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(r.where((c) => c.kind == ConflictKind.existingOverlap), isEmpty);
    });
  });

  group('NO_BREAK', () {
    test('인접 일반 슬롯 gap=10분 → warning', () {
      final r = _detector.detect(
        proposed: [
          _item(start: '09:00', end: '10:00'),
          _item(start: '10:10', end: '11:00'),
        ],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      final c = r.where((x) => x.kind == ConflictKind.noBreak);
      expect(c.length, 1);
      expect(c.first.severity, ConflictSeverity.warning);
    });

    test('인접 gap=15분 → 통과 (kMinBreakMin 경계)', () {
      final r = _detector.detect(
        proposed: [
          _item(start: '09:00', end: '10:00'),
          _item(start: '10:15', end: '11:00'),
        ],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(r.where((c) => c.kind == ConflictKind.noBreak), isEmpty);
    });

    test('work→work gap=20분 → noBreak (work 임계 30)', () {
      final r = _detector.detect(
        proposed: [
          _item(start: '09:00', end: '10:00', tags: const ['work-spine']),
          _item(start: '10:20', end: '11:00', tags: const ['focus']),
        ],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(r.where((c) => c.kind == ConflictKind.noBreak), isNotEmpty);
    });

    test('work→work gap=30분 → 통과', () {
      final r = _detector.detect(
        proposed: [
          _item(start: '09:00', end: '10:00', tags: const ['work-spine']),
          _item(start: '10:30', end: '11:00', tags: const ['focus']),
        ],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(r.where((c) => c.kind == ConflictKind.noBreak), isEmpty);
    });
  });

  group('CATEGORY_MONOTONY', () {
    test('동일 day 동일 category 3회 연속 → 1건', () {
      final r = _detector.detect(
        proposed: [
          _item(day: 0, start: '09:00', end: '10:00', cat: ScheduleCategory.work),
          _item(day: 0, start: '10:30', end: '11:30', cat: ScheduleCategory.work),
          _item(day: 0, start: '12:00', end: '13:00', cat: ScheduleCategory.work),
        ],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(
        r.where((c) => c.kind == ConflictKind.categoryMonotony).length,
        1,
      );
    });

    test('2회만 → 0건', () {
      final r = _detector.detect(
        proposed: [
          _item(day: 0, start: '09:00', end: '10:00', cat: ScheduleCategory.work),
          _item(day: 0, start: '10:30', end: '11:30', cat: ScheduleCategory.work),
        ],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(
        r.where((c) => c.kind == ConflictKind.categoryMonotony),
        isEmpty,
      );
    });

    test('서로 다른 category 섞임 → 0건', () {
      final r = _detector.detect(
        proposed: [
          _item(day: 0, start: '09:00', end: '10:00', cat: ScheduleCategory.work),
          _item(day: 0, start: '10:30', end: '11:30', cat: ScheduleCategory.health),
          _item(day: 0, start: '12:00', end: '13:00', cat: ScheduleCategory.work),
        ],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(
        r.where((c) => c.kind == ConflictKind.categoryMonotony),
        isEmpty,
      );
    });
  });

  group('OUTSIDE_AWAKE', () {
    test('wake 이전 → warning', () {
      final r = _detector.detect(
        proposed: [_item(start: '06:00', end: '06:30')],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(
        r.where((c) => c.kind == ConflictKind.outsideAwake).length,
        1,
      );
    });

    test('sleep 이후 → warning', () {
      final r = _detector.detect(
        proposed: [_item(start: '23:30', end: '23:59')],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(
        r.where((c) => c.kind == ConflictKind.outsideAwake).length,
        1,
      );
    });

    test('윈도우 안 → 0건', () {
      final r = _detector.detect(
        proposed: [_item(start: '09:00', end: '17:00')],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(r.where((c) => c.kind == ConflictKind.outsideAwake), isEmpty);
    });
  });

  group('빈 입력 + ConflictReport JSON', () {
    test('빈 proposed → 빈 reports', () {
      final r = _detector.detect(
        proposed: const [],
        existingThisWeek: const [],
        awake: _awake,
        weekStart: _weekStart,
      );
      expect(r, isEmpty);
    });

    test('ConflictReport JSON 직렬화 round-trip', () {
      const c = ConflictReport(
        kind: ConflictKind.timeOverlap,
        indices: [0, 1],
        severity: ConflictSeverity.error,
        message: '테스트',
      );
      final json = c.toJson();
      final round = ConflictReport.fromJson(json);
      expect(round, equals(c));
    });
  });
}
