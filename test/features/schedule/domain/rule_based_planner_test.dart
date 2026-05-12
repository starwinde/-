import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/role_answer_projector.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/domain/rule_based_planner.dart';
import 'package:routinemon/features/schedule/domain/role_wizard.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

const _planner = RuleBasedPlanner();
final _weekStart = DateTime(2026, 5, 4); // 월요일

WizardAnswers _baseAnswers({
  LifestyleStatus status = LifestyleStatus.worker,
  WakeTime wake = WakeTime.morning79,
  SleepTime sleep = SleepTime.midnight231,
  Chronotype chrono = Chronotype.middle,
  WorkDays workDays = WorkDays.d5,
  WorkHours workHours = WorkHours.nineToSix,
  CommuteTime? commute = CommuteTime.under30,
  MealPattern meal = MealPattern.regular3,
  FocusTimeWindow focus = FocusTimeWindow.morning,
  ExerciseFrequency exercise = ExerciseFrequency.moderate,
  ExercisePreferredTime? exercisePref = ExercisePreferredTime.evening,
  HobbyPreference hobby = HobbyPreference.weekdayEvening,
  GoalFocus goal = GoalFocus.workStudy,
  FreeTimeMin free = FreeTimeMin.twoHours,
  String? fixedSchedules,
  PastWeekContext? past,
}) =>
    WizardAnswers(
      status: status,
      wakeTime: wake,
      sleepTime: sleep,
      chronotype: chrono,
      workDays: workDays,
      workHours: workHours,
      commuteTime: commute,
      mealPattern: meal,
      focusTime: focus,
      exercise: exercise,
      exercisePreferredTime: exercisePref,
      hobby: hobby,
      goalFocus: goal,
      freeTime: free,
      fixedSchedules: fixedSchedules,
      pastWeekContext: past,
    );

bool _hasSelfOverlap(List<GeneratedScheduleItem> items) {
  final byDay = <int, List<GeneratedScheduleItem>>{};
  for (final i in items) {
    byDay.putIfAbsent(i.dayOfWeek, () => []).add(i);
  }
  for (final list in byDay.values) {
    final sorted = [...list]..sort((a, b) => a.startTime.compareTo(b.startTime));
    for (var i = 0; i < sorted.length - 1; i++) {
      if (sorted[i].endTime.compareTo(sorted[i + 1].startTime) > 0) return true;
    }
  }
  return false;
}

void main() {
  group('RuleBasedPlanner — 핵심 보장', () {
    test('결정론: 동일 입력 → 동일 출력', () {
      final ans = _baseAnswers();
      final a = _planner.plan(answers: ans, weekStart: _weekStart);
      final b = _planner.plan(answers: ans, weekStart: _weekStart);
      expect(a.items.length, b.items.length);
      for (var i = 0; i < a.items.length; i++) {
        expect(a.items[i].title, b.items[i].title);
        expect(a.items[i].dayOfWeek, b.items[i].dayOfWeek);
        expect(a.items[i].startTime, b.items[i].startTime);
        expect(a.items[i].endTime, b.items[i].endTime);
      }
    });

    test('items.length ∈ [10, 18] — 기본 worker/d5/workStudy', () {
      final r = _planner.plan(answers: _baseAnswers(), weekStart: _weekStart);
      expect(r.items.length, inInclusiveRange(10, 18));
    });

    test('자기 자신 시간 겹침 0건 — 기본 worker', () {
      final r = _planner.plan(answers: _baseAnswers(), weekStart: _weekStart);
      expect(_hasSelfOverlap(r.items), isFalse);
    });

    test('warnings 기본 빈 리스트', () {
      final r = _planner.plan(answers: _baseAnswers(), weekStart: _weekStart);
      expect(r.warnings, isEmpty);
    });

    test('50ms 예산 — Stopwatch 측정', () {
      final ans = _baseAnswers();
      final sw = Stopwatch()..start();
      _planner.plan(answers: ans, weekStart: _weekStart);
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50));
    });
  });

  group('RuleBasedPlanner — LifestyleStatus 매트릭스', () {
    for (final status in LifestyleStatus.values) {
      test('status=$status 기본 파라미터 → 10~18, no overlap', () {
        final r = _planner.plan(
          answers: _baseAnswers(status: status),
          weekStart: _weekStart,
        );
        expect(
          r.items.length,
          inInclusiveRange(10, 18),
          reason: 'status=$status length=${r.items.length}',
        );
        expect(_hasSelfOverlap(r.items), isFalse);
      });
    }
  });

  group('RuleBasedPlanner — WorkDays / WorkHours', () {
    for (final wd in WorkDays.values) {
      test('workDays=$wd → 10~18, no overlap', () {
        final r = _planner.plan(
          answers: _baseAnswers(workDays: wd),
          weekStart: _weekStart,
        );
        expect(r.items.length, inInclusiveRange(10, 18));
        expect(_hasSelfOverlap(r.items), isFalse);
      });
    }

    test('workHours=flexible → 10~18, no overlap', () {
      final r = _planner.plan(
        answers: _baseAnswers(workHours: WorkHours.flexible),
        weekStart: _weekStart,
      );
      expect(r.items.length, inInclusiveRange(10, 18));
      expect(_hasSelfOverlap(r.items), isFalse);
    });

    test('workHours=remote → 10~18, no overlap', () {
      final r = _planner.plan(
        answers: _baseAnswers(workHours: WorkHours.remote),
        weekStart: _weekStart,
      );
      expect(r.items.length, inInclusiveRange(10, 18));
      expect(_hasSelfOverlap(r.items), isFalse);
    });
  });

  group('RuleBasedPlanner — GoalFocus', () {
    for (final goal in GoalFocus.values) {
      test('goalFocus=$goal → 10~18, no overlap', () {
        final r = _planner.plan(
          answers: _baseAnswers(goal: goal),
          weekStart: _weekStart,
        );
        expect(
          r.items.length,
          inInclusiveRange(10, 18),
          reason: 'goal=$goal length=${r.items.length}',
        );
        expect(_hasSelfOverlap(r.items), isFalse);
      });
    }
  });

  group('RuleBasedPlanner — Exercise / Hobby', () {
    test('exercise=none → exercise 슬롯 0건', () {
      final r = _planner.plan(
        answers: _baseAnswers(exercise: ExerciseFrequency.none),
        weekStart: _weekStart,
      );
      final exercise = r.items.where((i) => i.tags.contains('exercise'));
      expect(exercise, isEmpty);
    });

    test('exercise=daily → 7건, category=health', () {
      final r = _planner.plan(
        answers: _baseAnswers(exercise: ExerciseFrequency.daily),
        weekStart: _weekStart,
      );
      final exercise = r.items.where((i) => i.tags.contains('exercise'));
      expect(exercise.length, 7);
      expect(
        exercise.every((i) => i.category == ScheduleCategory.health),
        isTrue,
      );
    });

    test('hobby=none → hobby 슬롯 0건', () {
      final r = _planner.plan(
        answers: _baseAnswers(
          hobby: HobbyPreference.none,
          goal: GoalFocus.workStudy,
        ),
        weekStart: _weekStart,
      );
      final hobbies = r.items.where((i) => i.tags.contains('hobby'));
      expect(hobbies, isEmpty);
    });

    test('hobby=weekend → 토/일 2건', () {
      final r = _planner.plan(
        answers: _baseAnswers(hobby: HobbyPreference.weekend),
        weekStart: _weekStart,
      );
      final hobbies =
          r.items.where((i) => i.tags.contains('hobby')).toList(growable: false);
      expect(hobbies.length, 2);
      expect(hobbies.map((i) => i.dayOfWeek).toSet(), {5, 6});
    });
  });

  group('RuleBasedPlanner — fixedSchedules 정규식 파서', () {
    test('한국어 "월/수 18시 PT 1시간" → 월/수 18:00~19:00 슬롯 2건', () {
      final r = _planner.plan(
        answers: _baseAnswers(fixedSchedules: '월/수 18시 PT 1시간'),
        weekStart: _weekStart,
      );
      final fixed = r.items.where((i) => i.tags.contains('fixed')).toList();
      expect(fixed.length, 2);
      expect(fixed.map((i) => i.dayOfWeek).toSet(), {0, 2});
      expect(fixed.first.startTime, '18:00');
      expect(fixed.first.endTime, '19:00');
      expect(r.warnings, isEmpty);
    });

    test('영어 "Mon 7am gym 30min" → 월 07:00~07:30', () {
      final r = _planner.plan(
        answers: _baseAnswers(fixedSchedules: 'Mon 7am gym 30min'),
        weekStart: _weekStart,
      );
      final fixed = r.items.where((i) => i.tags.contains('fixed')).toList();
      expect(fixed.length, 1);
      expect(fixed.first.dayOfWeek, 0);
      expect(fixed.first.startTime, '07:00');
      expect(fixed.first.endTime, '07:30');
    });

    test('파싱 실패: 요일 없음 → warnings 누적', () {
      final r = _planner.plan(
        answers: _baseAnswers(fixedSchedules: '오후 3시 회의'),
        weekStart: _weekStart,
      );
      expect(r.warnings, isNotEmpty);
      expect(r.warnings.first, contains('파싱 실패'));
      // 다른 일정은 정상
      expect(r.items.length, inInclusiveRange(10, 18));
    });

    test('빈 fixedSchedules → warnings 0', () {
      final r = _planner.plan(
        answers: _baseAnswers(fixedSchedules: ''),
        weekStart: _weekStart,
      );
      expect(r.warnings, isEmpty);
    });

    test('null fixedSchedules → warnings 0', () {
      final r = _planner.plan(
        answers: _baseAnswers(),
        weekStart: _weekStart,
      );
      expect(r.warnings, isEmpty);
    });

    test('여러 줄 — 일부 성공, 일부 warnings', () {
      final r = _planner.plan(
        answers: _baseAnswers(fixedSchedules: '화 19시 운동 1시간\nrandom 텍스트'),
        weekStart: _weekStart,
      );
      final fixed = r.items.where((i) => i.tags.contains('fixed')).toList();
      expect(fixed.length, 1);
      expect(fixed.first.dayOfWeek, 1);
      expect(r.warnings.length, 1);
    });
  });

  group('RuleBasedPlanner — PastWeekContext 보정', () {
    test('completionRate < 0.5 → items 30% 감소', () {
      final base =
          _planner.plan(answers: _baseAnswers(), weekStart: _weekStart);
      final reduced = _planner.plan(
        answers: _baseAnswers(
          past: const PastWeekContext(
            weeklyCompletionRate: 0.3,
            focusRatioAvg: 0.4,
            weeksObserved: 4,
          ),
        ),
        weekStart: _weekStart,
      );
      expect(reduced.items.length, lessThan(base.items.length));
    });

    test('completionRate ≥ 0.5 → 보정 없음 (기본 분포 유지)', () {
      final r = _planner.plan(
        answers: _baseAnswers(
          past: const PastWeekContext(
            weeklyCompletionRate: 0.8,
            focusRatioAvg: 0.7,
            weeksObserved: 4,
          ),
        ),
        weekStart: _weekStart,
      );
      expect(r.items.length, inInclusiveRange(10, 18));
    });
  });

  group('RuleBasedPlanner — 자가 검증 매트릭스 샘플', () {
    test('student / d6 / hobbyGrowth — 분포 정상', () {
      final r = _planner.plan(
        answers: _baseAnswers(
          status: LifestyleStatus.student,
          workDays: WorkDays.d6,
          goal: GoalFocus.hobbyGrowth,
          hobby: HobbyPreference.weekend,
          exercise: ExerciseFrequency.light,
        ),
        weekStart: _weekStart,
      );
      expect(r.items.length, inInclusiveRange(10, 18));
      expect(_hasSelfOverlap(r.items), isFalse);
      // 학생은 work category 가 study 로
      final spineItems =
          r.items.where((i) => i.tags.contains('work-spine')).toList();
      expect(
        spineItems.every((i) => i.category == ScheduleCategory.study),
        isTrue,
      );
    });

    test('homemaker / 휴식 goal — 업무 슬롯 없음, 10건 이상', () {
      final r = _planner.plan(
        answers: _baseAnswers(
          status: LifestyleStatus.homemaker,
          goal: GoalFocus.rest,
        ),
        weekStart: _weekStart,
      );
      expect(r.items.length, greaterThanOrEqualTo(10));
      final spine = r.items.where((i) => i.tags.contains('work-spine'));
      expect(spine, isEmpty);
    });

    test('freelancer / flexible / earlyMorning focus — 분포 정상', () {
      final r = _planner.plan(
        answers: _baseAnswers(
          status: LifestyleStatus.freelancer,
          workHours: WorkHours.flexible,
          focus: FocusTimeWindow.earlyMorning,
        ),
        weekStart: _weekStart,
      );
      expect(r.items.length, inInclusiveRange(10, 18));
      expect(_hasSelfOverlap(r.items), isFalse);
    });
  });

  // 2026-05-12 sparse-weekday 회귀: 사용자가 본 "화/목만 채워짐" 패턴이 v3
  // 위저드 worker + work_form=shift 결정론 결과임을, office_9_6 입력은
  // 평일 5일 모두 채움을 확정한다. RoleAnswerProjector → RuleBasedPlanner
  // 파이프라인 end-to-end.
  group('RuleBasedPlanner — sparse-weekday 회귀 (v3 worker)', () {
    test('worker + office_9_6 → 평일 5일 work-spine, 9:00 시작', () {
      final draft = const RoleAnswerDraft(role: Role.worker)
          .setAnswer('work_form', 'office_9_6');
      final answers = RoleAnswerProjector.project(draft);
      final r = _planner.plan(answers: answers, weekStart: _weekStart);
      final spine =
          r.items.where((i) => i.tags.contains('work-spine')).toList();
      expect(spine.length, 5, reason: '월~금 5일 모두 work-spine');
      final spineDays = spine.map((i) => i.dayOfWeek).toSet();
      expect(spineDays, {0, 1, 2, 3, 4});
      expect(spine.every((i) => i.startTime == '09:00'), isTrue);
    });

    test('worker + work_form=shift → 화/목/토 3일만 work-spine (사용자 보고 패턴)', () {
      final draft = const RoleAnswerDraft(role: Role.worker)
          .setAnswer('work_form', 'shift');
      final answers = RoleAnswerProjector.project(draft);
      final r = _planner.plan(answers: answers, weekStart: _weekStart);
      final spine =
          r.items.where((i) => i.tags.contains('work-spine')).toList();
      expect(spine.length, 3);
      expect(spine.map((i) => i.dayOfWeek).toSet(), {1, 3, 5});
      expect(spine.every((i) => i.startTime == '22:00'), isTrue);
    });
  });
}
