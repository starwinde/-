// Pure Dart. 5종 ConflictKind 감지 (rules.md §3.3, ADR 0002).
// 호출 지점: (a) 생성 직후 자동 (b) 적용 직전 재검사.
import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/domain/awake_window.dart';
import 'package:routinemon/features/schedule/domain/conflict_report.dart';
import 'package:routinemon/features/schedule/domain/wizard_rule_params.dart';

typedef ExistingScheduleRef = ({int id, DateTime? start, DateTime? end});

class ScheduleConflictDetector {
  const ScheduleConflictDetector();

  List<ConflictReport> detect({
    required List<GeneratedScheduleItem> proposed,
    required Iterable<ExistingScheduleRef> existingThisWeek,
    required AwakeWindow awake,
    required DateTime weekStart,
  }) {
    final reports = <ConflictReport>[];
    reports.addAll(_timeOverlaps(proposed));
    reports.addAll(_existingOverlaps(proposed, existingThisWeek, weekStart));
    reports.addAll(_noBreaks(proposed));
    reports.addAll(_categoryMonotony(proposed));
    reports.addAll(_outsideAwake(proposed, awake));
    return reports;
  }
}

int _toMinutes(String hhmm) {
  final p = hhmm.split(':');
  final h = int.tryParse(p[0]) ?? 0;
  final m = p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0;
  return h * 60 + m;
}

List<ConflictReport> _timeOverlaps(List<GeneratedScheduleItem> items) {
  final out = <ConflictReport>[];
  final byDay = <int, List<int>>{};
  for (var i = 0; i < items.length; i++) {
    byDay.putIfAbsent(items[i].dayOfWeek, () => []).add(i);
  }
  for (final entry in byDay.entries) {
    final indices = entry.value;
    for (var i = 0; i < indices.length; i++) {
      for (var j = i + 1; j < indices.length; j++) {
        final a = items[indices[i]];
        final b = items[indices[j]];
        final aStart = _toMinutes(a.startTime);
        final aEnd = _toMinutes(a.endTime);
        final bStart = _toMinutes(b.startTime);
        final bEnd = _toMinutes(b.endTime);
        if (!(aEnd <= bStart || bEnd <= aStart)) {
          out.add(
            ConflictReport(
              kind: ConflictKind.timeOverlap,
              indices: [indices[i], indices[j]],
              severity: ConflictSeverity.error,
              message:
                  '시간 겹침: ${a.title}(${a.startTime}~${a.endTime}) vs ${b.title}(${b.startTime}~${b.endTime})',
            ),
          );
        }
      }
    }
  }
  return out;
}

List<ConflictReport> _existingOverlaps(
  List<GeneratedScheduleItem> proposed,
  Iterable<ExistingScheduleRef> existing,
  DateTime weekStart,
) {
  final weekEnd = weekStart.add(const Duration(days: 7));
  final out = <ConflictReport>[];
  final relevantExisting = existing
      .where(
        (e) =>
            e.start != null &&
            e.end != null &&
            !e.end!.isBefore(weekStart) &&
            e.start!.isBefore(weekEnd),
      )
      .toList(growable: false);
  for (var i = 0; i < proposed.length; i++) {
    final p = proposed[i];
    final pStart = p.resolveStart(weekStart);
    final pEnd = p.resolveEnd(weekStart);
    for (final e in relevantExisting) {
      if (!(pEnd.isBefore(e.start!) || e.end!.isBefore(pStart) ||
          pEnd.isAtSameMomentAs(e.start!) || pStart.isAtSameMomentAs(e.end!))) {
        out.add(
          ConflictReport(
            kind: ConflictKind.existingOverlap,
            indices: [i],
            severity: ConflictSeverity.error,
            message: '기존 일정과 겹침: ${p.title}',
            existingId: e.id,
          ),
        );
      }
    }
  }
  return out;
}

List<ConflictReport> _noBreaks(List<GeneratedScheduleItem> items) {
  final out = <ConflictReport>[];
  final byDay = <int, List<int>>{};
  for (var i = 0; i < items.length; i++) {
    byDay.putIfAbsent(items[i].dayOfWeek, () => []).add(i);
  }
  for (final entry in byDay.entries) {
    final sorted = [...entry.value]
      ..sort((a, b) =>
          _toMinutes(items[a].startTime).compareTo(_toMinutes(items[b].startTime)));
    for (var i = 0; i < sorted.length - 1; i++) {
      final cur = items[sorted[i]];
      final next = items[sorted[i + 1]];
      final gap = _toMinutes(next.startTime) - _toMinutes(cur.endTime);
      if (gap < 0) continue; // overlap → 이미 timeOverlap 으로 보고됨
      final threshold = (cur.tags.contains('work-spine') ||
              cur.tags.contains('focus')) &&
              (next.tags.contains('work-spine') || next.tags.contains('focus'))
          ? kMinBreakWorkToWork
          : kMinBreakMin;
      if (gap < threshold) {
        out.add(
          ConflictReport(
            kind: ConflictKind.noBreak,
            indices: [sorted[i], sorted[i + 1]],
            severity: ConflictSeverity.warning,
            message:
                '휴식 부족: ${cur.title}(~${cur.endTime}) → ${next.title}(${next.startTime}~) gap=${gap}분',
          ),
        );
      }
    }
  }
  return out;
}

List<ConflictReport> _categoryMonotony(List<GeneratedScheduleItem> items) {
  final out = <ConflictReport>[];
  final byDay = <int, List<int>>{};
  for (var i = 0; i < items.length; i++) {
    byDay.putIfAbsent(items[i].dayOfWeek, () => []).add(i);
  }
  for (final entry in byDay.entries) {
    final sorted = [...entry.value]
      ..sort((a, b) =>
          _toMinutes(items[a].startTime).compareTo(_toMinutes(items[b].startTime)));
    for (var i = 0; i + kCategoryMonotonyN - 1 < sorted.length; i++) {
      final window = sorted.sublist(i, i + kCategoryMonotonyN);
      final cat = items[window.first].category;
      if (window.every((idx) => items[idx].category == cat)) {
        out.add(
          ConflictReport(
            kind: ConflictKind.categoryMonotony,
            indices: window,
            severity: ConflictSeverity.warning,
            message: '같은 카테고리($cat) ${kCategoryMonotonyN}회 연속',
          ),
        );
      }
    }
  }
  return out;
}

List<ConflictReport> _outsideAwake(
  List<GeneratedScheduleItem> items,
  AwakeWindow awake,
) {
  final out = <ConflictReport>[];
  for (var i = 0; i < items.length; i++) {
    final start = _toMinutes(items[i].startTime);
    final end = _toMinutes(items[i].endTime);
    final endNormalized = end <= start ? end + 24 * 60 : end;
    final crossesMidnight = awake.endMinute > 24 * 60;
    if (crossesMidnight) {
      // start should be ≥ awake.startMinute, endNormalized ≤ awake.endMinute
      if (start < awake.startMinute || endNormalized > awake.endMinute) {
        out.add(
          ConflictReport(
            kind: ConflictKind.outsideAwake,
            indices: [i],
            severity: ConflictSeverity.warning,
            message: '깨어있는 시간 외: ${items[i].title} (${items[i].startTime}~${items[i].endTime})',
          ),
        );
      }
    } else {
      if (start < awake.startMinute || end > awake.endMinute) {
        out.add(
          ConflictReport(
            kind: ConflictKind.outsideAwake,
            indices: [i],
            severity: ConflictSeverity.warning,
            message: '깨어있는 시간 외: ${items[i].title} (${items[i].startTime}~${items[i].endTime})',
          ),
        );
      }
    }
  }
  return out;
}
