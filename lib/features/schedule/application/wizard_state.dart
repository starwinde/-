import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';

part 'wizard_state.g.dart';

/// In-memory draft of the 15-step (conditionally skipped) wizard answers.
/// Resets when the provider is auto-disposed (entering wizard anew).
class WizardDraft {
  const WizardDraft({
    this.status,
    this.wakeTime,
    this.sleepTime,
    this.chronotype,
    this.workDays,
    this.workHours,
    this.commuteTime,
    this.mealPattern,
    this.focusTime,
    this.exercise,
    this.exercisePreferredTime,
    this.hobby,
    this.goalFocus,
    this.freeTime,
    this.fixedSchedules,
  });

  final LifestyleStatus? status;
  final WakeTime? wakeTime;
  final SleepTime? sleepTime;
  final Chronotype? chronotype;
  final WorkDays? workDays;
  final WorkHours? workHours;
  final CommuteTime? commuteTime;
  final MealPattern? mealPattern;
  final FocusTimeWindow? focusTime;
  final ExerciseFrequency? exercise;
  final ExercisePreferredTime? exercisePreferredTime;
  final HobbyPreference? hobby;
  final GoalFocus? goalFocus;
  final FreeTimeMin? freeTime;
  final String? fixedSchedules;

  WizardDraft copyWith({
    LifestyleStatus? status,
    WakeTime? wakeTime,
    SleepTime? sleepTime,
    Chronotype? chronotype,
    WorkDays? workDays,
    WorkHours? workHours,
    CommuteTime? commuteTime,
    MealPattern? mealPattern,
    FocusTimeWindow? focusTime,
    ExerciseFrequency? exercise,
    ExercisePreferredTime? exercisePreferredTime,
    HobbyPreference? hobby,
    GoalFocus? goalFocus,
    FreeTimeMin? freeTime,
    String? fixedSchedules,
  }) {
    return WizardDraft(
      status: status ?? this.status,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
      chronotype: chronotype ?? this.chronotype,
      workDays: workDays ?? this.workDays,
      workHours: workHours ?? this.workHours,
      commuteTime: commuteTime ?? this.commuteTime,
      mealPattern: mealPattern ?? this.mealPattern,
      focusTime: focusTime ?? this.focusTime,
      exercise: exercise ?? this.exercise,
      exercisePreferredTime:
          exercisePreferredTime ?? this.exercisePreferredTime,
      hobby: hobby ?? this.hobby,
      goalFocus: goalFocus ?? this.goalFocus,
      freeTime: freeTime ?? this.freeTime,
      fixedSchedules: fixedSchedules ?? this.fixedSchedules,
    );
  }
}

/// Holds the in-progress answers for the weekly wizard.
@riverpod
class WizardState extends _$WizardState {
  @override
  WizardDraft build() => const WizardDraft();

  void setStatus(LifestyleStatus v) => state = state.copyWith(status: v);
  void setWakeTime(WakeTime v) => state = state.copyWith(wakeTime: v);
  void setSleepTime(SleepTime v) => state = state.copyWith(sleepTime: v);
  void setChronotype(Chronotype v) => state = state.copyWith(chronotype: v);
  void setWorkDays(WorkDays v) => state = state.copyWith(workDays: v);
  void setWorkHours(WorkHours v) => state = state.copyWith(workHours: v);
  void setCommuteTime(CommuteTime v) =>
      state = state.copyWith(commuteTime: v);
  void setMealPattern(MealPattern v) =>
      state = state.copyWith(mealPattern: v);
  void setFocusTime(FocusTimeWindow v) =>
      state = state.copyWith(focusTime: v);
  void setExercise(ExerciseFrequency v) =>
      state = state.copyWith(exercise: v);
  void setExercisePreferredTime(ExercisePreferredTime v) =>
      state = state.copyWith(exercisePreferredTime: v);
  void setHobby(HobbyPreference v) => state = state.copyWith(hobby: v);
  void setGoalFocus(GoalFocus v) => state = state.copyWith(goalFocus: v);
  void setFreeTime(FreeTimeMin v) => state = state.copyWith(freeTime: v);
  void setFixed(String? v) => state = state.copyWith(fixedSchedules: v);

  /// Returns complete [WizardAnswers] if all required fields are filled,
  /// otherwise null. Conditional fields (commuteTime, exercisePreferredTime)
  /// are passed through as-is since they can legitimately be null.
  WizardAnswers? toAnswers() {
    final s = state;
    if (s.status == null ||
        s.wakeTime == null ||
        s.sleepTime == null ||
        s.chronotype == null ||
        s.workDays == null ||
        s.workHours == null ||
        s.mealPattern == null ||
        s.focusTime == null ||
        s.exercise == null ||
        s.hobby == null ||
        s.goalFocus == null ||
        s.freeTime == null) {
      return null;
    }
    final fixed = s.fixedSchedules;
    return WizardAnswers(
      status: s.status!,
      wakeTime: s.wakeTime!,
      sleepTime: s.sleepTime!,
      chronotype: s.chronotype!,
      workDays: s.workDays!,
      workHours: s.workHours!,
      commuteTime: s.commuteTime,
      mealPattern: s.mealPattern!,
      focusTime: s.focusTime!,
      exercise: s.exercise!,
      exercisePreferredTime: s.exercisePreferredTime,
      hobby: s.hobby!,
      goalFocus: s.goalFocus!,
      freeTime: s.freeTime!,
      fixedSchedules: (fixed == null || fixed.isEmpty) ? null : fixed,
    );
  }
}
