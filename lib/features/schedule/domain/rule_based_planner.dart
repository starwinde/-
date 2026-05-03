// Pure Dart. Path A 결정론 알고리즘 (rules.md §3.3).
// Input: WizardAnswers + 월요일 weekStart. Output: 10~18개 GeneratedScheduleItem.
// 동일 입력 → 동일 출력. ≤ 50ms. ADR 0001.
//
// 알고리즘 단계:
//   1. awake window 해석
//   2. workdays / workWindow 해석
//   3. 우선순위 슬롯 배치 (work spine → focus → exercise → hobby)
//   4. fixedSchedules 정규식 파서
//   5. 자기 자신 시간 겹침 해소 (낮은 우선순위 drop)
//   6. PastWeekContext 보정 (이행률 < 0.5 → 30% drop)
//   7. 10~18 범위 보정 (부족 시 보강, 초과 시 drop)
//   8. day → start 정렬 후 GeneratedScheduleItem 변환

import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/domain/awake_window.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';
import 'package:routinemon/features/schedule/domain/wizard_rule_params.dart';

class RuleBasedPlanResult {
  const RuleBasedPlanResult({required this.items, required this.warnings});

  final List<GeneratedScheduleItem> items;
  final List<String> warnings;
}

class RuleBasedPlanner {
  const RuleBasedPlanner();

  RuleBasedPlanResult plan({
    required WizardAnswers answers,
    required DateTime weekStart,
  }) {
    final awake = AwakeWindow.resolve(
      answers.wakeTime,
      answers.sleepTime,
      answers.chronotype,
    );
    final workdays = _resolveWorkdays(answers.workDays);
    final workWindow = _resolveWorkWindow(
      answers.workHours,
      answers.focusTime,
      awake,
    );
    final hasWork = answers.status != LifestyleStatus.homemaker &&
        answers.status != LifestyleStatus.retired;

    final slots = <_Slot>[];
    final warnings = <String>[];

    if (hasWork) {
      slots.addAll(_workSpine(workdays, workWindow, answers));
    }
    slots.addAll(_focusBlocks(workdays, workWindow, awake, answers, hasWork));
    slots.addAll(_exerciseBlocks(awake, workWindow, answers));
    slots.addAll(_hobbyBlocks(awake, workWindow, answers));

    final fixed = _parseFixed(answers.fixedSchedules, warnings);
    slots.addAll(fixed);

    final resolved = _resolveOverlaps(slots);
    final adjusted = _applyPastWeek(resolved, answers.pastWeekContext);
    final ranged = _capRange(adjusted, awake, answers, hasWork, workdays);
    ranged.sort(_compareSlot);

    return RuleBasedPlanResult(
      items: ranged.map(_toItem).toList(growable: false),
      warnings: warnings,
    );
  }
}

class _Slot {
  _Slot({
    required this.title,
    required this.dayOfWeek,
    required this.startMin,
    required this.endMin,
    required this.category,
    required this.priority,
    this.tags = const [],
  });

  final String title;
  final int dayOfWeek; // 0=Mon, 6=Sun
  final int startMin;
  final int endMin;
  final ScheduleCategory category;
  final int priority; // higher = keep over lower on conflict
  final List<String> tags;
}

int _compareSlot(_Slot a, _Slot b) {
  final d = a.dayOfWeek.compareTo(b.dayOfWeek);
  if (d != 0) return d;
  return a.startMin.compareTo(b.startMin);
}

GeneratedScheduleItem _toItem(_Slot s) => GeneratedScheduleItem(
      title: s.title,
      dayOfWeek: s.dayOfWeek,
      startTime: _hhmm(s.startMin),
      endTime: _hhmm(s.endMin),
      category: s.category,
      tags: s.tags,
    );

String _hhmm(int min) {
  final h = (min ~/ 60) % 24;
  final m = min % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

List<int> _resolveWorkdays(WorkDays days) {
  switch (days) {
    case WorkDays.d5:
      return const [0, 1, 2, 3, 4]; // Mon-Fri
    case WorkDays.d6:
      return const [0, 1, 2, 3, 4, 5]; // Mon-Sat
    case WorkDays.d3to4:
      return const [0, 2, 4]; // Mon/Wed/Fri
    case WorkDays.remote:
      return const [0, 1, 2, 3, 4]; // 동일 5일이지만 가중치는 다른 곳에서
    case WorkDays.irregular:
      return const [1, 3, 5]; // Tue/Thu/Sat
  }
}

({int startMin, int endMin}) _resolveWorkWindow(
  WorkHours hours,
  FocusTimeWindow focus,
  AwakeWindow awake,
) {
  switch (hours) {
    case WorkHours.nineToSix:
      return (startMin: 9 * 60, endMin: 18 * 60);
    case WorkHours.flexible:
      final center = _focusCenter(focus);
      return (
        startMin: (center - 4 * 60).clamp(awake.startMinute, awake.endMinute),
        endMin: (center + 4 * 60).clamp(awake.startMinute, awake.endMinute),
      );
    case WorkHours.nightOrShift:
      return (startMin: 22 * 60, endMin: 30 * 60); // 22:00 ~ 06:00+1d
    case WorkHours.remote:
      return (startMin: 10 * 60, endMin: 19 * 60);
    case WorkHours.other:
      return (startMin: 10 * 60, endMin: 18 * 60);
  }
}

int _focusCenter(FocusTimeWindow w) {
  switch (w) {
    case FocusTimeWindow.earlyMorning:
      return 6 * 60;
    case FocusTimeWindow.morning:
      return 10 * 60;
    case FocusTimeWindow.afternoon:
      return 14 * 60;
    case FocusTimeWindow.evening:
      return 19 * 60;
    case FocusTimeWindow.night:
      return 22 * 60;
  }
}

ScheduleCategory _statusToWorkCategory(LifestyleStatus s) {
  switch (s) {
    case LifestyleStatus.student:
      return ScheduleCategory.study;
    case LifestyleStatus.worker:
    case LifestyleStatus.freelancer:
    case LifestyleStatus.homemaker:
    case LifestyleStatus.retired:
    case LifestyleStatus.other:
      return ScheduleCategory.work;
  }
}

String _statusToWorkTitle(LifestyleStatus s) {
  switch (s) {
    case LifestyleStatus.student:
      return '수업/학습';
    case LifestyleStatus.worker:
      return '핵심 업무';
    case LifestyleStatus.freelancer:
      return '핵심 작업';
    case LifestyleStatus.homemaker:
    case LifestyleStatus.retired:
    case LifestyleStatus.other:
      return '핵심 활동';
  }
}

List<_Slot> _workSpine(
  List<int> workdays,
  ({int startMin, int endMin}) work,
  WizardAnswers ans,
) {
  final cat = _statusToWorkCategory(ans.status);
  final title = _statusToWorkTitle(ans.status);
  final start = work.startMin;
  final end = (start + 2 * 60).clamp(start, work.endMin);
  return workdays
      .map(
        (d) => _Slot(
          title: title,
          dayOfWeek: d,
          startMin: start,
          endMin: end,
          category: cat,
          priority: 90,
          tags: const ['work-spine'],
        ),
      )
      .toList(growable: false);
}

List<_Slot> _focusBlocks(
  List<int> workdays,
  ({int startMin, int endMin}) work,
  AwakeWindow awake,
  WizardAnswers ans,
  bool hasWork,
) {
  final out = <_Slot>[];
  final goal = ans.goalFocus;
  final cat = _statusToWorkCategory(ans.status);
  final pmStart = ((work.startMin + work.endMin) ~/ 2 + 30).clamp(
    awake.startMinute,
    awake.endMinute - kFocusBlockMinDeep,
  );
  final pmEnd = pmStart + kFocusBlockMinDeep;

  // work_study: 평일 PM 90' deep focus
  if (goal == GoalFocus.workStudy && hasWork) {
    for (final d in workdays) {
      out.add(
        _Slot(
          title: '딥 포커스',
          dayOfWeek: d,
          startMin: pmStart,
          endMin: pmEnd,
          category: cat,
          priority: 70,
          tags: const ['focus', 'deep'],
        ),
      );
    }
  } else if (goal == GoalFocus.hobbyGrowth) {
    // 취미 성장: 평일 저녁 1회 + 주말 2회 shallow
    final eveStart = (awake.endMinute - 3 * 60)
        .clamp(awake.startMinute, awake.endMinute - kFocusBlockMinShallow);
    final eveEnd = eveStart + kFocusBlockMinShallow;
    for (final d in [1, 3, 5, 6]) {
      out.add(
        _Slot(
          title: '몰입 시간 (취미 성장)',
          dayOfWeek: d,
          startMin: eveStart,
          endMin: eveEnd,
          category: ScheduleCategory.hobby,
          priority: 60,
          tags: const ['focus', 'hobby-growth'],
        ),
      );
    }
  } else if (goal == GoalFocus.health) {
    // 건강: 컨디션 케어 슬롯 평일 3회
    for (final d in [0, 2, 4]) {
      out.add(
        _Slot(
          title: '컨디션 케어',
          dayOfWeek: d,
          startMin: awake.startMinute + 30,
          endMin: awake.startMinute + 30 + kFocusBlockMinShallow,
          category: ScheduleCategory.health,
          priority: 60,
          tags: const ['focus', 'health'],
        ),
      );
    }
  } else if (goal == GoalFocus.relationships) {
    // 관계: 평일 저녁 통화 / 주말 만남
    for (final d in [2, 5]) {
      out.add(
        _Slot(
          title: '관계 시간',
          dayOfWeek: d,
          startMin: awake.endMinute - 2 * 60,
          endMin: awake.endMinute - 60,
          category: ScheduleCategory.etc,
          priority: 60,
          tags: const ['focus', 'relationships'],
        ),
      );
    }
  } else {
    // rest: 휴식 블록 평일 3회
    for (final d in [0, 2, 4]) {
      out.add(
        _Slot(
          title: '휴식 / 리커버리',
          dayOfWeek: d,
          startMin: awake.endMinute - 90,
          endMin: awake.endMinute - 30,
          category: ScheduleCategory.etc,
          priority: 60,
          tags: const ['focus', 'rest'],
        ),
      );
    }
  }
  return out;
}

List<_Slot> _exerciseBlocks(
  AwakeWindow awake,
  ({int startMin, int endMin}) work,
  WizardAnswers ans,
) {
  final freq = ans.exercise;
  if (freq == ExerciseFrequency.none) return const [];
  final duration = switch (freq) {
    ExerciseFrequency.light => kExerciseDurationLight,
    ExerciseFrequency.moderate => kExerciseDurationModerate,
    ExerciseFrequency.daily => kExerciseDurationDaily,
    ExerciseFrequency.none => 0,
  };
  final count = switch (freq) {
    ExerciseFrequency.light => 2,
    ExerciseFrequency.moderate => 3,
    ExerciseFrequency.daily => 7,
    ExerciseFrequency.none => 0,
  };
  final start = _exerciseStart(ans.exercisePreferredTime, awake, work);
  final days = _exerciseDays(count);
  return days
      .map(
        (d) => _Slot(
          title: '운동',
          dayOfWeek: d,
          startMin: start,
          endMin: start + duration,
          category: ScheduleCategory.health,
          priority: 50,
          tags: const ['exercise'],
        ),
      )
      .toList(growable: false);
}

int _exerciseStart(
  ExercisePreferredTime? pref,
  AwakeWindow awake,
  ({int startMin, int endMin}) work,
) {
  switch (pref ?? ExercisePreferredTime.flexible) {
    case ExercisePreferredTime.morning:
      return awake.startMinute;
    case ExercisePreferredTime.lunch:
      return ((work.startMin + work.endMin) ~/ 2 - 30).clamp(
        awake.startMinute,
        awake.endMinute - 60,
      );
    case ExercisePreferredTime.evening:
      return (work.endMin + 30)
          .clamp(awake.startMinute, awake.endMinute - 60);
    case ExercisePreferredTime.weekend:
    case ExercisePreferredTime.flexible:
      return (awake.endMinute - 2 * 60)
          .clamp(awake.startMinute, awake.endMinute - 60);
  }
}

List<int> _exerciseDays(int count) {
  // 결정론 분포: 주 N회 → 균등 spacing
  switch (count) {
    case 0:
      return const [];
    case 2:
      return const [1, 4]; // Tue, Fri
    case 3:
      return const [0, 2, 4]; // Mon, Wed, Fri
    case 7:
      return const [0, 1, 2, 3, 4, 5, 6];
    default:
      return List.generate(count.clamp(0, 7), (i) => i);
  }
}

List<_Slot> _hobbyBlocks(
  AwakeWindow awake,
  ({int startMin, int endMin}) work,
  WizardAnswers ans,
) {
  switch (ans.hobby) {
    case HobbyPreference.none:
      return const [];
    case HobbyPreference.weekdayEvening:
      final start = (work.endMin + 60)
          .clamp(awake.startMinute, awake.endMinute - kHobbyDurationWeekday);
      return [1, 3]
          .map(
            (d) => _Slot(
              title: '취미 시간',
              dayOfWeek: d,
              startMin: start,
              endMin: start + kHobbyDurationWeekday,
              category: ScheduleCategory.hobby,
              priority: 40,
              tags: const ['hobby'],
            ),
          )
          .toList(growable: false);
    case HobbyPreference.weekend:
      final start = (awake.startMinute + 3 * 60)
          .clamp(awake.startMinute, awake.endMinute - kHobbyDurationWeekend);
      return [5, 6]
          .map(
            (d) => _Slot(
              title: '취미 시간',
              dayOfWeek: d,
              startMin: start,
              endMin: start + kHobbyDurationWeekend,
              category: ScheduleCategory.hobby,
              priority: 40,
              tags: const ['hobby'],
            ),
          )
          .toList(growable: false);
  }
}

// fixedSchedules 정규식 파서 — 한국어/영어 best-effort.
// 매칭 형식 예: "월/수 18시 PT 1시간", "Mon 7am gym 30min"
final _korDayPattern =
    RegExp(r'(월|화|수|목|금|토|일)([\s/,]*([월화수목금토일]))*');
final _engDayPattern = RegExp(
  r'(Mon|Tue|Wed|Thu|Fri|Sat|Sun)',
  caseSensitive: false,
);
final _timePattern = RegExp(
  r'(\d{1,2})\s*(?::|시|am|pm|AM|PM)\s*(\d{0,2})?',
);
final _durPattern = RegExp(r'(\d+)\s*(시간|hr|hours|h|분|min|minutes|m)');

const _korDayMap = {'월': 0, '화': 1, '수': 2, '목': 3, '금': 4, '토': 5, '일': 6};
const _engDayMap = {
  'mon': 0,
  'tue': 1,
  'wed': 2,
  'thu': 3,
  'fri': 4,
  'sat': 5,
  'sun': 6,
};

List<_Slot> _parseFixed(String? raw, List<String> warnings) {
  if (raw == null || raw.trim().isEmpty) return const [];
  final lines = raw.split(RegExp(r'[\n;]'));
  final out = <_Slot>[];
  for (final line in lines) {
    final s = line.trim();
    if (s.isEmpty) continue;
    final days = _extractDays(s);
    if (days.isEmpty) {
      warnings.add('파싱 실패 (요일 미발견): $s');
      continue;
    }
    final timeM = _timePattern.firstMatch(s);
    if (timeM == null) {
      warnings.add('파싱 실패 (시간 미발견): $s');
      continue;
    }
    final hour = int.tryParse(timeM.group(1) ?? '') ?? -1;
    if (hour < 0 || hour > 23) {
      warnings.add('파싱 실패 (시간 범위): $s');
      continue;
    }
    final minute = int.tryParse(timeM.group(2) ?? '') ?? 0;
    final start = hour * 60 + minute;
    final dur = _extractDuration(s) ?? 60;
    final end = start + dur;
    final title = _extractTitle(s) ?? '고정 일정';
    for (final d in days) {
      out.add(
        _Slot(
          title: title,
          dayOfWeek: d,
          startMin: start,
          endMin: end,
          category: ScheduleCategory.etc,
          priority: 95, // fixedSchedules: spine 다음 우선순위
          tags: const ['fixed'],
        ),
      );
    }
  }
  return out;
}

List<int> _extractDays(String s) {
  final days = <int>{};
  for (final entry in _korDayMap.entries) {
    if (s.contains(entry.key)) days.add(entry.value);
  }
  for (final m in _engDayPattern.allMatches(s)) {
    final key = m.group(1)!.toLowerCase();
    final d = _engDayMap[key];
    if (d != null) days.add(d);
  }
  final sorted = days.toList()..sort();
  return sorted;
}

int? _extractDuration(String s) {
  final m = _durPattern.firstMatch(s);
  if (m == null) return null;
  final n = int.tryParse(m.group(1) ?? '');
  if (n == null) return null;
  final unit = m.group(2) ?? '';
  if (unit.startsWith('시간') || unit.startsWith('h')) return n * 60;
  return n;
}

String? _extractTitle(String s) {
  // 요일/시간/기간 문자열을 제거하고 남은 단어 중 첫 번째 토큰
  var stripped = s
      .replaceAll(_korDayPattern, ' ')
      .replaceAll(_engDayPattern, ' ')
      .replaceAll(_timePattern, ' ')
      .replaceAll(_durPattern, ' ')
      .replaceAll(RegExp(r'[/,]'), ' ')
      .trim();
  stripped = stripped.replaceAll(RegExp(r'\s+'), ' ');
  if (stripped.isEmpty) return null;
  return stripped;
}

List<_Slot> _resolveOverlaps(List<_Slot> slots) {
  final byDay = <int, List<_Slot>>{};
  for (final s in slots) {
    byDay.putIfAbsent(s.dayOfWeek, () => []).add(s);
  }
  final out = <_Slot>[];
  for (final entry in byDay.entries) {
    final list = entry.value..sort((a, b) => a.startMin.compareTo(b.startMin));
    final keep = <_Slot>[];
    for (final s in list) {
      final overlaps = keep.where(
        (k) => !(s.endMin <= k.startMin || s.startMin >= k.endMin),
      );
      if (overlaps.isEmpty) {
        keep.add(s);
        continue;
      }
      // priority 비교: 둘 다 keep 보다 높으면 교체
      final maxOverlapPriority =
          overlaps.map((k) => k.priority).reduce((a, b) => a > b ? a : b);
      if (s.priority > maxOverlapPriority) {
        keep.removeWhere(
          (k) => !(s.endMin <= k.startMin || s.startMin >= k.endMin),
        );
        keep.add(s);
      }
      // else: drop s
    }
    out.addAll(keep);
  }
  return out;
}

List<_Slot> _applyPastWeek(List<_Slot> slots, PastWeekContext? ctx) {
  if (ctx == null) return slots;
  if (ctx.weeklyCompletionRate >= kPastWeekLowThreshold) return slots;
  final keepCount = (slots.length * kPastWeekReductionRatio).floor();
  final sorted = [...slots]..sort((a, b) => b.priority.compareTo(a.priority));
  return sorted.take(keepCount).toList(growable: false);
}

List<_Slot> _capRange(
  List<_Slot> slots,
  AwakeWindow awake,
  WizardAnswers ans,
  bool hasWork,
  List<int> workdays,
) {
  // 최대 18 cap
  final list = [...slots];
  if (list.length > 18) {
    list.sort((a, b) => b.priority.compareTo(a.priority));
    list.length = 18;
  }
  // 최소 10 보강 (보강 슬롯 generic)
  if (list.length < 10) {
    final fillers = _generateFillers(
      awake,
      ans,
      hasWork,
      workdays,
      neededCount: 10 - list.length,
      existing: list,
    );
    list.addAll(fillers);
  }
  return list;
}

List<_Slot> _generateFillers(
  AwakeWindow awake,
  WizardAnswers ans,
  bool hasWork,
  List<int> workdays,
  {required int neededCount,
  required List<_Slot> existing}) {
  final fillers = <_Slot>[];
  // 자기 관리 슬롯 (각 day 에 1개씩 검토)
  final occupied = <int, List<_Slot>>{};
  for (final s in existing) {
    occupied.putIfAbsent(s.dayOfWeek, () => []).add(s);
  }
  // 끼니 1개 / day (lunch 위치)
  const lunchStart = 12 * 60 + 30;
  const lunchEnd = lunchStart + kMealDurationLunch;
  for (var d = 0; d < 7 && fillers.length < neededCount; d++) {
    if (_dayHasOverlap(occupied[d] ?? const [], lunchStart, lunchEnd)) continue;
    fillers.add(
      _Slot(
        title: '점심 / 휴식',
        dayOfWeek: d,
        startMin: lunchStart,
        endMin: lunchEnd,
        category: ScheduleCategory.etc,
        priority: 30,
        tags: const ['meal', 'filler'],
      ),
    );
  }
  // 부족하면 evening recap
  for (var d = 0; d < 7 && fillers.length < neededCount; d++) {
    final start = awake.endMinute - 90;
    final end = start + 30;
    if (_dayHasOverlap(
      [...(occupied[d] ?? const <_Slot>[]), ...fillers.where((f) => f.dayOfWeek == d)],
      start,
      end,
    )) continue;
    fillers.add(
      _Slot(
        title: '하루 회고',
        dayOfWeek: d,
        startMin: start,
        endMin: end,
        category: ScheduleCategory.etc,
        priority: 25,
        tags: const ['review', 'filler'],
      ),
    );
  }
  return fillers;
}

bool _dayHasOverlap(List<_Slot> day, int start, int end) {
  return day.any(
    (s) => !(end <= s.startMin || start >= s.endMin),
  );
}
