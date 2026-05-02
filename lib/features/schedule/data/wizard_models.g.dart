// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wizard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WizardAnswers _$WizardAnswersFromJson(Map<String, dynamic> json) =>
    _WizardAnswers(
      status: $enumDecode(_$LifestyleStatusEnumMap, json['status']),
      wakeTime: $enumDecode(_$WakeTimeEnumMap, json['wake_time']),
      sleepTime: $enumDecode(_$SleepTimeEnumMap, json['sleep_time']),
      chronotype: $enumDecode(_$ChronotypeEnumMap, json['chronotype']),
      workDays: $enumDecode(_$WorkDaysEnumMap, json['work_days']),
      workHours: $enumDecode(_$WorkHoursEnumMap, json['work_hours']),
      commuteTime: $enumDecodeNullable(
        _$CommuteTimeEnumMap,
        json['commute_time'],
      ),
      mealPattern: $enumDecode(_$MealPatternEnumMap, json['meal_pattern']),
      focusTime: $enumDecode(_$FocusTimeWindowEnumMap, json['focus_time']),
      exercise: $enumDecode(_$ExerciseFrequencyEnumMap, json['exercise']),
      exercisePreferredTime: $enumDecodeNullable(
        _$ExercisePreferredTimeEnumMap,
        json['exercise_preferred_time'],
      ),
      hobby: $enumDecode(_$HobbyPreferenceEnumMap, json['hobby']),
      goalFocus: $enumDecode(_$GoalFocusEnumMap, json['goal_focus']),
      freeTime: $enumDecode(_$FreeTimeMinEnumMap, json['free_time']),
      fixedSchedules: json['fixed_schedules'] as String?,
      userLocale: json['user_locale'] as String? ?? 'ko',
      pastWeekContext: json['past_week_context'] == null
          ? null
          : PastWeekContext.fromJson(
              json['past_week_context'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$WizardAnswersToJson(_WizardAnswers instance) =>
    <String, dynamic>{
      'status': _$LifestyleStatusEnumMap[instance.status]!,
      'wake_time': _$WakeTimeEnumMap[instance.wakeTime]!,
      'sleep_time': _$SleepTimeEnumMap[instance.sleepTime]!,
      'chronotype': _$ChronotypeEnumMap[instance.chronotype]!,
      'work_days': _$WorkDaysEnumMap[instance.workDays]!,
      'work_hours': _$WorkHoursEnumMap[instance.workHours]!,
      'commute_time': _$CommuteTimeEnumMap[instance.commuteTime],
      'meal_pattern': _$MealPatternEnumMap[instance.mealPattern]!,
      'focus_time': _$FocusTimeWindowEnumMap[instance.focusTime]!,
      'exercise': _$ExerciseFrequencyEnumMap[instance.exercise]!,
      'exercise_preferred_time':
          _$ExercisePreferredTimeEnumMap[instance.exercisePreferredTime],
      'hobby': _$HobbyPreferenceEnumMap[instance.hobby]!,
      'goal_focus': _$GoalFocusEnumMap[instance.goalFocus]!,
      'free_time': _$FreeTimeMinEnumMap[instance.freeTime]!,
      'fixed_schedules': instance.fixedSchedules,
      'user_locale': instance.userLocale,
      'past_week_context': instance.pastWeekContext?.toJson(),
    };

const _$LifestyleStatusEnumMap = {
  LifestyleStatus.worker: 'worker',
  LifestyleStatus.student: 'student',
  LifestyleStatus.freelancer: 'freelancer',
  LifestyleStatus.homemaker: 'homemaker',
  LifestyleStatus.retired: 'retired',
  LifestyleStatus.other: 'other',
};

const _$WakeTimeEnumMap = {
  WakeTime.early57: 'early_5_7',
  WakeTime.morning79: 'morning_7_9',
  WakeTime.late911: 'late_9_11',
  WakeTime.variable: 'variable',
};

const _$SleepTimeEnumMap = {
  SleepTime.early2123: 'early_21_23',
  SleepTime.midnight231: 'midnight_23_1',
  SleepTime.late13: 'late_1_3',
  SleepTime.variable: 'variable',
};

const _$ChronotypeEnumMap = {
  Chronotype.morning: 'morning',
  Chronotype.middle: 'middle',
  Chronotype.evening: 'evening',
};

const _$WorkDaysEnumMap = {
  WorkDays.d5: 'd5',
  WorkDays.d6: 'd6',
  WorkDays.d3to4: 'd3to4',
  WorkDays.remote: 'remote',
  WorkDays.irregular: 'irregular',
};

const _$WorkHoursEnumMap = {
  WorkHours.nineToSix: 'nine_to_six',
  WorkHours.flexible: 'flexible',
  WorkHours.nightOrShift: 'night_or_shift',
  WorkHours.remote: 'remote',
  WorkHours.other: 'other',
};

const _$CommuteTimeEnumMap = {
  CommuteTime.under30: 'under_30',
  CommuteTime.about1h: 'about_1h',
  CommuteTime.oneToTwoH: 'one_to_two_h',
  CommuteTime.noCommute: 'no_commute',
};

const _$MealPatternEnumMap = {
  MealPattern.regular3: 'regular_3',
  MealPattern.irregular: 'irregular',
  MealPattern.twoMeals: 'two_meals',
  MealPattern.intermittentFasting: 'intermittent_fasting',
  MealPattern.other: 'other',
};

const _$FocusTimeWindowEnumMap = {
  FocusTimeWindow.earlyMorning: 'earlyMorning',
  FocusTimeWindow.morning: 'morning',
  FocusTimeWindow.afternoon: 'afternoon',
  FocusTimeWindow.evening: 'evening',
  FocusTimeWindow.night: 'night',
};

const _$ExerciseFrequencyEnumMap = {
  ExerciseFrequency.none: 'none',
  ExerciseFrequency.light: 'light',
  ExerciseFrequency.moderate: 'moderate',
  ExerciseFrequency.daily: 'daily',
};

const _$ExercisePreferredTimeEnumMap = {
  ExercisePreferredTime.morning: 'morning',
  ExercisePreferredTime.lunch: 'lunch',
  ExercisePreferredTime.evening: 'evening',
  ExercisePreferredTime.weekend: 'weekend',
  ExercisePreferredTime.flexible: 'flexible',
};

const _$HobbyPreferenceEnumMap = {
  HobbyPreference.weekdayEvening: 'weekdayEvening',
  HobbyPreference.weekend: 'weekend',
  HobbyPreference.none: 'none',
};

const _$GoalFocusEnumMap = {
  GoalFocus.workStudy: 'work_study',
  GoalFocus.health: 'health',
  GoalFocus.hobbyGrowth: 'hobby_growth',
  GoalFocus.relationships: 'relationships',
  GoalFocus.rest: 'rest',
};

const _$FreeTimeMinEnumMap = {
  FreeTimeMin.oneHour: 'oneHour',
  FreeTimeMin.twoHours: 'twoHours',
  FreeTimeMin.threeHoursPlus: 'threeHoursPlus',
};

_PastWeekContext _$PastWeekContextFromJson(Map<String, dynamic> json) =>
    _PastWeekContext(
      weeklyCompletionRate: (json['weekly_completion_rate'] as num).toDouble(),
      lowestCompletionCategory: json['lowest_completion_category'] as String?,
      mostMissedTimeBlock: json['most_missed_time_block'] as String?,
      focusRatioAvg: (json['focus_ratio_avg'] as num).toDouble(),
      weeksObserved: (json['weeks_observed'] as num).toInt(),
    );

Map<String, dynamic> _$PastWeekContextToJson(_PastWeekContext instance) =>
    <String, dynamic>{
      'weekly_completion_rate': instance.weeklyCompletionRate,
      'lowest_completion_category': instance.lowestCompletionCategory,
      'most_missed_time_block': instance.mostMissedTimeBlock,
      'focus_ratio_avg': instance.focusRatioAvg,
      'weeks_observed': instance.weeksObserved,
    };

_GeneratedScheduleItem _$GeneratedScheduleItemFromJson(
  Map<String, dynamic> json,
) => _GeneratedScheduleItem(
  title: json['title'] as String,
  dayOfWeek: (json['day_of_week'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  category: _catFromJson(json['category'] as String),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$GeneratedScheduleItemToJson(
  _GeneratedScheduleItem instance,
) => <String, dynamic>{
  'title': instance.title,
  'day_of_week': instance.dayOfWeek,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'category': _catToJson(instance.category),
  'tags': instance.tags,
};

_FollowupOption _$FollowupOptionFromJson(Map<String, dynamic> json) =>
    _FollowupOption(
      value: json['value'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$FollowupOptionToJson(_FollowupOption instance) =>
    <String, dynamic>{'value': instance.value, 'label': instance.label};

_FollowupQuestion _$FollowupQuestionFromJson(Map<String, dynamic> json) =>
    _FollowupQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => FollowupOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FollowupQuestionToJson(_FollowupQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options.map((e) => e.toJson()).toList(),
    };

_WeeklyWizardResponse _$WeeklyWizardResponseFromJson(
  Map<String, dynamic> json,
) => _WeeklyWizardResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => GeneratedScheduleItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  source: $enumDecode(_$WizardSourceEnumMap, json['source']),
  followupQuestions:
      (json['followup_questions'] as List<dynamic>?)
          ?.map((e) => FollowupQuestion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FollowupQuestion>[],
);

Map<String, dynamic> _$WeeklyWizardResponseToJson(
  _WeeklyWizardResponse instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'source': _$WizardSourceEnumMap[instance.source]!,
  'followup_questions': instance.followupQuestions
      .map((e) => e.toJson())
      .toList(),
};

const _$WizardSourceEnumMap = {
  WizardSource.llm: 'llm',
  WizardSource.preset: 'preset',
};
