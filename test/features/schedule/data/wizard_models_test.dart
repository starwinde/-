import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

WizardAnswers _sampleAnswers({
  LifestyleStatus status = LifestyleStatus.worker,
  WorkDays workDays = WorkDays.d5,
  FocusTimeWindow focusTime = FocusTimeWindow.morning,
  ExerciseFrequency exercise = ExerciseFrequency.light,
  HobbyPreference hobby = HobbyPreference.weekdayEvening,
  FreeTimeMin freeTime = FreeTimeMin.twoHours,
  String? fixedSchedules,
  String userLocale = 'ko',
  WakeTime wakeTime = WakeTime.morning79,
  SleepTime sleepTime = SleepTime.midnight231,
  Chronotype chronotype = Chronotype.middle,
  WorkHours workHours = WorkHours.nineToSix,
  CommuteTime? commuteTime = CommuteTime.under30,
  MealPattern mealPattern = MealPattern.regular3,
  ExercisePreferredTime? exercisePreferredTime =
      ExercisePreferredTime.evening,
  GoalFocus goalFocus = GoalFocus.workStudy,
}) =>
    WizardAnswers(
      status: status,
      workDays: workDays,
      focusTime: focusTime,
      exercise: exercise,
      hobby: hobby,
      freeTime: freeTime,
      fixedSchedules: fixedSchedules,
      userLocale: userLocale,
      wakeTime: wakeTime,
      sleepTime: sleepTime,
      chronotype: chronotype,
      workHours: workHours,
      commuteTime: commuteTime,
      mealPattern: mealPattern,
      exercisePreferredTime: exercisePreferredTime,
      goalFocus: goalFocus,
    );

void main() {
  group('WizardAnswers', () {
    test('toJson uses snake_case keys', () {
      final answers = _sampleAnswers(hobby: HobbyPreference.weekend);

      final json = answers.toJson();

      expect(json['status'], 'worker');
      expect(json['work_days'], 'd5');
      expect(json['focus_time'], 'morning');
      expect(json['exercise'], 'light');
      expect(json['hobby'], 'weekend');
      expect(json['free_time'], 'twoHours');
      expect(json['user_locale'], 'ko');
    });

    test('toJson includes all 15 base fields with snake_case keys', () {
      final answers = _sampleAnswers();

      final json = answers.toJson();

      expect(json['status'], 'worker');
      expect(json['wake_time'], 'morning_7_9');
      expect(json['sleep_time'], 'midnight_23_1');
      expect(json['chronotype'], 'middle');
      expect(json['work_days'], 'd5');
      expect(json['work_hours'], 'nine_to_six');
      expect(json['commute_time'], 'under_30');
      expect(json['meal_pattern'], 'regular_3');
      expect(json['focus_time'], 'morning');
      expect(json['exercise'], 'light');
      expect(json['exercise_preferred_time'], 'evening');
      expect(json['hobby'], 'weekdayEvening');
      expect(json['goal_focus'], 'work_study');
      expect(json['free_time'], 'twoHours');
      expect(json['user_locale'], 'ko');
    });

    test('commuteTime null serializes to null and round-trips', () {
      final answers = _sampleAnswers(
        status: LifestyleStatus.homemaker,
        commuteTime: null,
      );

      final json = answers.toJson();
      expect(json.containsKey('commute_time'), isTrue);
      expect(json['commute_time'], isNull);

      final restored = WizardAnswers.fromJson(json);
      expect(restored.commuteTime, isNull);
      expect(restored.status, LifestyleStatus.homemaker);
    });

    test('exercisePreferredTime null handled when exercise is none', () {
      final answers = _sampleAnswers(
        exercise: ExerciseFrequency.none,
        exercisePreferredTime: null,
      );

      final json = answers.toJson();
      expect(json['exercise'], 'none');
      expect(json.containsKey('exercise_preferred_time'), isTrue);
      expect(json['exercise_preferred_time'], isNull);

      final restored = WizardAnswers.fromJson(json);
      expect(restored.exercise, ExerciseFrequency.none);
      expect(restored.exercisePreferredTime, isNull);
    });

    test('fromJson round-trips all new enum fields', () {
      final original = _sampleAnswers(
        wakeTime: WakeTime.early57,
        sleepTime: SleepTime.late13,
        chronotype: Chronotype.evening,
        workHours: WorkHours.nightOrShift,
        commuteTime: CommuteTime.oneToTwoH,
        mealPattern: MealPattern.intermittentFasting,
        exercisePreferredTime: ExercisePreferredTime.weekend,
        goalFocus: GoalFocus.hobbyGrowth,
      );

      final restored = WizardAnswers.fromJson(original.toJson());

      expect(restored, equals(original));
    });
  });

  group('GeneratedScheduleItem', () {
    test('fromJson parses snake_case fields and category', () {
      final json = {
        'title': '아침 러닝',
        'day_of_week': 2,
        'start_time': '06:30',
        'end_time': '07:15',
        'category': 'health',
        'tags': ['running'],
      };

      final item = GeneratedScheduleItem.fromJson(json);

      expect(item.title, '아침 러닝');
      expect(item.dayOfWeek, 2);
      expect(item.startTime, '06:30');
      expect(item.endTime, '07:15');
      expect(item.category, ScheduleCategory.health);
      expect(item.tags, ['running']);
    });

    test('resolveStart / resolveEnd compose weekStart + day + HH:MM', () {
      // 2026-04-20 is a Monday.
      final weekStart = DateTime(2026, 4, 20);
      const item = GeneratedScheduleItem(
        title: '회의',
        dayOfWeek: 2,
        startTime: '14:30',
        endTime: '15:00',
        category: ScheduleCategory.work,
      );

      expect(item.resolveStart(weekStart), DateTime(2026, 4, 22, 14, 30));
      expect(item.resolveEnd(weekStart), DateTime(2026, 4, 22, 15, 0));
    });

    test('fromJson falls back to etc for unknown category', () {
      final json = <String, dynamic>{
        'title': 'x',
        'day_of_week': 0,
        'start_time': '09:00',
        'end_time': '10:00',
        'category': 'unknown-category',
        'tags': <String>[],
      };

      final item = GeneratedScheduleItem.fromJson(json);

      expect(item.category, ScheduleCategory.etc);
    });
  });

  group('WeeklyWizardResponse', () {
    test('fromJson parses items list and source', () {
      final json = {
        'items': [
          {
            'title': '공부',
            'day_of_week': 1,
            'start_time': '09:00',
            'end_time': '10:00',
            'category': 'study',
            'tags': <String>[],
          },
        ],
        'source': 'llm',
      };

      final resp = WeeklyWizardResponse.fromJson(json);

      expect(resp.items, hasLength(1));
      expect(resp.items.first.title, '공부');
      expect(resp.source, WizardSource.llm);
    });

    test('fromJson defaults followupQuestions to empty when absent', () {
      final json = {
        'items': <Map<String, dynamic>>[],
        'source': 'preset',
      };

      final resp = WeeklyWizardResponse.fromJson(json);

      expect(resp.followupQuestions, isEmpty);
    });

    test('fromJson parses followup_questions when present', () {
      final json = {
        'items': <Map<String, dynamic>>[],
        'source': 'llm',
        'followup_questions': [
          {
            'id': 'q1',
            'question': '운동 강도는 어느 정도가 좋나요?',
            'options': [
              {'value': 'low', 'label': '가볍게'},
              {'value': 'mid', 'label': '보통'},
              {'value': 'high', 'label': '강하게'},
            ],
          },
        ],
      };

      final resp = WeeklyWizardResponse.fromJson(json);

      expect(resp.followupQuestions, hasLength(1));
      expect(resp.followupQuestions.first.id, 'q1');
      expect(resp.followupQuestions.first.options, hasLength(3));
      expect(resp.followupQuestions.first.options[1].value, 'mid');
      expect(resp.followupQuestions.first.options[1].label, '보통');
    });
  });

  group('FollowupOption', () {
    test('fromJson / toJson round-trip', () {
      const option = FollowupOption(value: 'yes', label: '네');

      final json = option.toJson();
      expect(json, {'value': 'yes', 'label': '네'});

      final restored = FollowupOption.fromJson(json);
      expect(restored, equals(option));
    });
  });

  group('FollowupQuestion', () {
    test('fromJson parses question with 3 options', () {
      final json = {
        'id': 'focus-intensity',
        'question': '집중 시간대를 몇 시간으로 할까요?',
        'options': [
          {'value': 'h1', 'label': '1시간'},
          {'value': 'h2', 'label': '2시간'},
          {'value': 'h3', 'label': '3시간 이상'},
        ],
      };

      final q = FollowupQuestion.fromJson(json);

      expect(q.id, 'focus-intensity');
      expect(q.question, '집중 시간대를 몇 시간으로 할까요?');
      expect(q.options, hasLength(3));
      expect(q.options.first.value, 'h1');
      expect(q.options.last.label, '3시간 이상');
    });
  });
}
