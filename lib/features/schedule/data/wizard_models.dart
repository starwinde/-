// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:routinemon/features/schedule/domain/conflict_report.dart';
import 'package:routinemon/features/schedule/domain/lifestyle_enums.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

export 'package:routinemon/features/schedule/domain/conflict_report.dart';
export 'package:routinemon/features/schedule/domain/lifestyle_enums.dart';

part 'wizard_models.freezed.dart';
part 'wizard_models.g.dart';

enum LifestyleStatus {
  @JsonValue('worker') worker,
  @JsonValue('student') student,
  @JsonValue('freelancer') freelancer,
  @JsonValue('homemaker') homemaker,
  @JsonValue('retired') retired,
  @JsonValue('other') other,
}

enum WorkDays {
  @JsonValue('d5') d5,
  @JsonValue('d6') d6,
  @JsonValue('d3to4') d3to4,
  @JsonValue('remote') remote,
  @JsonValue('irregular') irregular,
}

enum FocusTimeWindow {
  @JsonValue('earlyMorning') earlyMorning,
  @JsonValue('morning') morning,
  @JsonValue('afternoon') afternoon,
  @JsonValue('evening') evening,
  @JsonValue('night') night,
}

enum ExerciseFrequency {
  @JsonValue('none') none,
  @JsonValue('light') light,
  @JsonValue('moderate') moderate,
  @JsonValue('daily') daily,
}

enum HobbyPreference {
  @JsonValue('weekdayEvening') weekdayEvening,
  @JsonValue('weekend') weekend,
  @JsonValue('none') none,
}

enum FreeTimeMin {
  @JsonValue('oneHour') oneHour,
  @JsonValue('twoHours') twoHours,
  @JsonValue('threeHoursPlus') threeHoursPlus,
}

// WakeTime, SleepTime, Chronotype 는 domain/lifestyle_enums.dart 로 이전 (도메인 의존성 방향 §3.2).
// 본 파일 상단 export 로 기존 import 호환 유지.

enum WorkHours {
  @JsonValue('nine_to_six') nineToSix,
  @JsonValue('flexible') flexible,
  @JsonValue('night_or_shift') nightOrShift,
  @JsonValue('remote') remote,
  @JsonValue('other') other,
}

enum CommuteTime {
  @JsonValue('under_30') under30,
  @JsonValue('about_1h') about1h,
  @JsonValue('one_to_two_h') oneToTwoH,
  @JsonValue('no_commute') noCommute,
}

enum MealPattern {
  @JsonValue('regular_3') regular3,
  @JsonValue('irregular') irregular,
  @JsonValue('two_meals') twoMeals,
  @JsonValue('intermittent_fasting') intermittentFasting,
  @JsonValue('other') other,
}

enum ExercisePreferredTime {
  @JsonValue('morning') morning,
  @JsonValue('lunch') lunch,
  @JsonValue('evening') evening,
  @JsonValue('weekend') weekend,
  @JsonValue('flexible') flexible,
}

enum GoalFocus {
  @JsonValue('work_study') workStudy,
  @JsonValue('health') health,
  @JsonValue('hobby_growth') hobbyGrowth,
  @JsonValue('relationships') relationships,
  @JsonValue('rest') rest,
}

enum WizardSource {
  @JsonValue('rule') rule,
  @JsonValue('llm') llm,
  @JsonValue('preset') preset,
}

@JsonEnum(alwaysCreate: true)
enum EnhanceObjective {
  @JsonValue('diversify_titles') diversifyTitles,
  @JsonValue('rebalance_load') rebalanceLoad,
  @JsonValue('add_recovery') addRecovery,
  @JsonValue('refine_categories') refineCategories,
}

@freezed
sealed class WizardAnswers with _$WizardAnswers {
  const factory WizardAnswers({
    required LifestyleStatus status,
    @JsonKey(name: 'wake_time') required WakeTime wakeTime,
    @JsonKey(name: 'sleep_time') required SleepTime sleepTime,
    required Chronotype chronotype,
    @JsonKey(name: 'work_days') required WorkDays workDays,
    @JsonKey(name: 'work_hours') required WorkHours workHours,
    @JsonKey(name: 'commute_time') CommuteTime? commuteTime,
    @JsonKey(name: 'meal_pattern') required MealPattern mealPattern,
    @JsonKey(name: 'focus_time') required FocusTimeWindow focusTime,
    required ExerciseFrequency exercise,
    @JsonKey(name: 'exercise_preferred_time')
    ExercisePreferredTime? exercisePreferredTime,
    required HobbyPreference hobby,
    @JsonKey(name: 'goal_focus') required GoalFocus goalFocus,
    @JsonKey(name: 'free_time') required FreeTimeMin freeTime,
    @JsonKey(name: 'fixed_schedules') String? fixedSchedules,
    @JsonKey(name: 'user_locale') @Default('ko') String userLocale,
    @JsonKey(name: 'past_week_context') PastWeekContext? pastWeekContext,
  }) = _WizardAnswers;

  factory WizardAnswers.fromJson(Map<String, dynamic> json) =>
      _$WizardAnswersFromJson(json);
}

/// Past execution context summarising the user's last [weeksObserved] weeks
/// of schedule completion and focus performance. Injected into the wizard's
/// systemPrompt so the LLM can adapt the proposed schedule to actual habits.
@freezed
sealed class PastWeekContext with _$PastWeekContext {
  const factory PastWeekContext({
    @JsonKey(name: 'weekly_completion_rate') required double weeklyCompletionRate,
    @JsonKey(name: 'lowest_completion_category') String? lowestCompletionCategory,
    @JsonKey(name: 'most_missed_time_block') String? mostMissedTimeBlock,
    @JsonKey(name: 'focus_ratio_avg') required double focusRatioAvg,
    @JsonKey(name: 'weeks_observed') required int weeksObserved,
  }) = _PastWeekContext;

  factory PastWeekContext.fromJson(Map<String, dynamic> json) =>
      _$PastWeekContextFromJson(json);
}

@freezed
sealed class GeneratedScheduleItem with _$GeneratedScheduleItem {
  const GeneratedScheduleItem._();

  const factory GeneratedScheduleItem({
    required String title,
    @JsonKey(name: 'day_of_week') required int dayOfWeek,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    @JsonKey(fromJson: _catFromJson, toJson: _catToJson)
    required ScheduleCategory category,
    @Default([]) List<String> tags,
    @Default(WizardSource.rule) WizardSource source,
    double? confidence,
  }) = _GeneratedScheduleItem;

  /// Resolves this item's startTime into an absolute DateTime given
  /// the Monday of the target week.
  DateTime resolveStart(DateTime weekStartMonday) =>
      _resolveDateTime(weekStartMonday, dayOfWeek, startTime);

  DateTime resolveEnd(DateTime weekStartMonday) =>
      _resolveDateTime(weekStartMonday, dayOfWeek, endTime);

  factory GeneratedScheduleItem.fromJson(Map<String, dynamic> json) =>
      _$GeneratedScheduleItemFromJson(json);
}

ScheduleCategory _catFromJson(String v) => ScheduleCategory.fromString(v);
String _catToJson(ScheduleCategory c) => c.name;

DateTime _resolveDateTime(DateTime weekStart, int dayOfWeek, String hhmm) {
  final clampedDay = dayOfWeek.clamp(0, 6);
  final day = weekStart.add(Duration(days: clampedDay));
  final parts = hhmm.split(':');
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  return DateTime(day.year, day.month, day.day, hour, minute);
}

@freezed
sealed class FollowupOption with _$FollowupOption {
  const factory FollowupOption({
    required String value,
    required String label,
  }) = _FollowupOption;

  factory FollowupOption.fromJson(Map<String, dynamic> json) =>
      _$FollowupOptionFromJson(json);
}

@freezed
sealed class FollowupQuestion with _$FollowupQuestion {
  const factory FollowupQuestion({
    required String id,
    required String question,
    required List<FollowupOption> options,
  }) = _FollowupQuestion;

  factory FollowupQuestion.fromJson(Map<String, dynamic> json) =>
      _$FollowupQuestionFromJson(json);
}

@freezed
sealed class RefinementTurn with _$RefinementTurn {
  const factory RefinementTurn({
    required int turn,
    required List<GeneratedScheduleItem> items,
    @JsonKey(name: 'followup_answers')
    @Default(<String, String>{}) Map<String, String> followupAnswers,
    @JsonKey(name: 'diff_summary') String? diffSummary,
    required DateTime timestamp,
  }) = _RefinementTurn;

  factory RefinementTurn.fromJson(Map<String, dynamic> json) =>
      _$RefinementTurnFromJson(json);
}

@freezed
sealed class RefinementSession with _$RefinementSession {
  const RefinementSession._();

  const factory RefinementSession({
    @JsonKey(name: 'conversation_id') required String conversationId,
    @Default(<RefinementTurn>[]) List<RefinementTurn> history,
  }) = _RefinementSession;

  /// Issue 07 / ADR 0003 — gemma-4-e4b 8192 maxTokens 안전선.
  static const int maxTurns = 5;

  int get turnCount => history.length;
  bool get isFull => turnCount >= maxTurns;

  /// 마지막 2턴만 윈도잉 (토큰 예산 ≤ 8KB 보호).
  List<RefinementTurn> get window =>
      history.length <= 2 ? history : history.sublist(history.length - 2);

  factory RefinementSession.fromJson(Map<String, dynamic> json) =>
      _$RefinementSessionFromJson(json);
}

@freezed
sealed class WeeklyWizardResponse with _$WeeklyWizardResponse {
  const factory WeeklyWizardResponse({
    required List<GeneratedScheduleItem> items,
    required WizardSource source,
    @JsonKey(name: 'followup_questions')
    @Default(<FollowupQuestion>[])
    List<FollowupQuestion> followupQuestions,
    @Default(<ConflictReport>[]) List<ConflictReport> conflicts,
    @JsonKey(name: 'diff_summary') String? diffSummary,
    @JsonKey(name: 'conversation_id') String? conversationId,
    @Default(0) int turn,
    @Default(<String>[]) List<String> warnings,
  }) = _WeeklyWizardResponse;

  factory WeeklyWizardResponse.fromJson(Map<String, dynamic> json) =>
      _$WeeklyWizardResponseFromJson(json);
}
