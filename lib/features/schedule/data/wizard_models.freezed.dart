// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wizard_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WizardAnswers {

 LifestyleStatus get status;@JsonKey(name: 'wake_time') WakeTime get wakeTime;@JsonKey(name: 'sleep_time') SleepTime get sleepTime; Chronotype get chronotype;@JsonKey(name: 'work_days') WorkDays get workDays;@JsonKey(name: 'work_hours') WorkHours get workHours;@JsonKey(name: 'commute_time') CommuteTime? get commuteTime;@JsonKey(name: 'meal_pattern') MealPattern get mealPattern;@JsonKey(name: 'focus_time') FocusTimeWindow get focusTime; ExerciseFrequency get exercise;@JsonKey(name: 'exercise_preferred_time') ExercisePreferredTime? get exercisePreferredTime; HobbyPreference get hobby;@JsonKey(name: 'goal_focus') GoalFocus get goalFocus;@JsonKey(name: 'free_time') FreeTimeMin get freeTime;@JsonKey(name: 'fixed_schedules') String? get fixedSchedules;@JsonKey(name: 'user_locale') String get userLocale;@JsonKey(name: 'past_week_context') PastWeekContext? get pastWeekContext;
/// Create a copy of WizardAnswers
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WizardAnswersCopyWith<WizardAnswers> get copyWith => _$WizardAnswersCopyWithImpl<WizardAnswers>(this as WizardAnswers, _$identity);

  /// Serializes this WizardAnswers to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WizardAnswers&&(identical(other.status, status) || other.status == status)&&(identical(other.wakeTime, wakeTime) || other.wakeTime == wakeTime)&&(identical(other.sleepTime, sleepTime) || other.sleepTime == sleepTime)&&(identical(other.chronotype, chronotype) || other.chronotype == chronotype)&&(identical(other.workDays, workDays) || other.workDays == workDays)&&(identical(other.workHours, workHours) || other.workHours == workHours)&&(identical(other.commuteTime, commuteTime) || other.commuteTime == commuteTime)&&(identical(other.mealPattern, mealPattern) || other.mealPattern == mealPattern)&&(identical(other.focusTime, focusTime) || other.focusTime == focusTime)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&(identical(other.exercisePreferredTime, exercisePreferredTime) || other.exercisePreferredTime == exercisePreferredTime)&&(identical(other.hobby, hobby) || other.hobby == hobby)&&(identical(other.goalFocus, goalFocus) || other.goalFocus == goalFocus)&&(identical(other.freeTime, freeTime) || other.freeTime == freeTime)&&(identical(other.fixedSchedules, fixedSchedules) || other.fixedSchedules == fixedSchedules)&&(identical(other.userLocale, userLocale) || other.userLocale == userLocale)&&(identical(other.pastWeekContext, pastWeekContext) || other.pastWeekContext == pastWeekContext));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,wakeTime,sleepTime,chronotype,workDays,workHours,commuteTime,mealPattern,focusTime,exercise,exercisePreferredTime,hobby,goalFocus,freeTime,fixedSchedules,userLocale,pastWeekContext);

@override
String toString() {
  return 'WizardAnswers(status: $status, wakeTime: $wakeTime, sleepTime: $sleepTime, chronotype: $chronotype, workDays: $workDays, workHours: $workHours, commuteTime: $commuteTime, mealPattern: $mealPattern, focusTime: $focusTime, exercise: $exercise, exercisePreferredTime: $exercisePreferredTime, hobby: $hobby, goalFocus: $goalFocus, freeTime: $freeTime, fixedSchedules: $fixedSchedules, userLocale: $userLocale, pastWeekContext: $pastWeekContext)';
}


}

/// @nodoc
abstract mixin class $WizardAnswersCopyWith<$Res>  {
  factory $WizardAnswersCopyWith(WizardAnswers value, $Res Function(WizardAnswers) _then) = _$WizardAnswersCopyWithImpl;
@useResult
$Res call({
 LifestyleStatus status,@JsonKey(name: 'wake_time') WakeTime wakeTime,@JsonKey(name: 'sleep_time') SleepTime sleepTime, Chronotype chronotype,@JsonKey(name: 'work_days') WorkDays workDays,@JsonKey(name: 'work_hours') WorkHours workHours,@JsonKey(name: 'commute_time') CommuteTime? commuteTime,@JsonKey(name: 'meal_pattern') MealPattern mealPattern,@JsonKey(name: 'focus_time') FocusTimeWindow focusTime, ExerciseFrequency exercise,@JsonKey(name: 'exercise_preferred_time') ExercisePreferredTime? exercisePreferredTime, HobbyPreference hobby,@JsonKey(name: 'goal_focus') GoalFocus goalFocus,@JsonKey(name: 'free_time') FreeTimeMin freeTime,@JsonKey(name: 'fixed_schedules') String? fixedSchedules,@JsonKey(name: 'user_locale') String userLocale,@JsonKey(name: 'past_week_context') PastWeekContext? pastWeekContext
});


$PastWeekContextCopyWith<$Res>? get pastWeekContext;

}
/// @nodoc
class _$WizardAnswersCopyWithImpl<$Res>
    implements $WizardAnswersCopyWith<$Res> {
  _$WizardAnswersCopyWithImpl(this._self, this._then);

  final WizardAnswers _self;
  final $Res Function(WizardAnswers) _then;

/// Create a copy of WizardAnswers
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? wakeTime = null,Object? sleepTime = null,Object? chronotype = null,Object? workDays = null,Object? workHours = null,Object? commuteTime = freezed,Object? mealPattern = null,Object? focusTime = null,Object? exercise = null,Object? exercisePreferredTime = freezed,Object? hobby = null,Object? goalFocus = null,Object? freeTime = null,Object? fixedSchedules = freezed,Object? userLocale = null,Object? pastWeekContext = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LifestyleStatus,wakeTime: null == wakeTime ? _self.wakeTime : wakeTime // ignore: cast_nullable_to_non_nullable
as WakeTime,sleepTime: null == sleepTime ? _self.sleepTime : sleepTime // ignore: cast_nullable_to_non_nullable
as SleepTime,chronotype: null == chronotype ? _self.chronotype : chronotype // ignore: cast_nullable_to_non_nullable
as Chronotype,workDays: null == workDays ? _self.workDays : workDays // ignore: cast_nullable_to_non_nullable
as WorkDays,workHours: null == workHours ? _self.workHours : workHours // ignore: cast_nullable_to_non_nullable
as WorkHours,commuteTime: freezed == commuteTime ? _self.commuteTime : commuteTime // ignore: cast_nullable_to_non_nullable
as CommuteTime?,mealPattern: null == mealPattern ? _self.mealPattern : mealPattern // ignore: cast_nullable_to_non_nullable
as MealPattern,focusTime: null == focusTime ? _self.focusTime : focusTime // ignore: cast_nullable_to_non_nullable
as FocusTimeWindow,exercise: null == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as ExerciseFrequency,exercisePreferredTime: freezed == exercisePreferredTime ? _self.exercisePreferredTime : exercisePreferredTime // ignore: cast_nullable_to_non_nullable
as ExercisePreferredTime?,hobby: null == hobby ? _self.hobby : hobby // ignore: cast_nullable_to_non_nullable
as HobbyPreference,goalFocus: null == goalFocus ? _self.goalFocus : goalFocus // ignore: cast_nullable_to_non_nullable
as GoalFocus,freeTime: null == freeTime ? _self.freeTime : freeTime // ignore: cast_nullable_to_non_nullable
as FreeTimeMin,fixedSchedules: freezed == fixedSchedules ? _self.fixedSchedules : fixedSchedules // ignore: cast_nullable_to_non_nullable
as String?,userLocale: null == userLocale ? _self.userLocale : userLocale // ignore: cast_nullable_to_non_nullable
as String,pastWeekContext: freezed == pastWeekContext ? _self.pastWeekContext : pastWeekContext // ignore: cast_nullable_to_non_nullable
as PastWeekContext?,
  ));
}
/// Create a copy of WizardAnswers
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PastWeekContextCopyWith<$Res>? get pastWeekContext {
    if (_self.pastWeekContext == null) {
    return null;
  }

  return $PastWeekContextCopyWith<$Res>(_self.pastWeekContext!, (value) {
    return _then(_self.copyWith(pastWeekContext: value));
  });
}
}


/// Adds pattern-matching-related methods to [WizardAnswers].
extension WizardAnswersPatterns on WizardAnswers {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WizardAnswers value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WizardAnswers() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WizardAnswers value)  $default,){
final _that = this;
switch (_that) {
case _WizardAnswers():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WizardAnswers value)?  $default,){
final _that = this;
switch (_that) {
case _WizardAnswers() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LifestyleStatus status, @JsonKey(name: 'wake_time')  WakeTime wakeTime, @JsonKey(name: 'sleep_time')  SleepTime sleepTime,  Chronotype chronotype, @JsonKey(name: 'work_days')  WorkDays workDays, @JsonKey(name: 'work_hours')  WorkHours workHours, @JsonKey(name: 'commute_time')  CommuteTime? commuteTime, @JsonKey(name: 'meal_pattern')  MealPattern mealPattern, @JsonKey(name: 'focus_time')  FocusTimeWindow focusTime,  ExerciseFrequency exercise, @JsonKey(name: 'exercise_preferred_time')  ExercisePreferredTime? exercisePreferredTime,  HobbyPreference hobby, @JsonKey(name: 'goal_focus')  GoalFocus goalFocus, @JsonKey(name: 'free_time')  FreeTimeMin freeTime, @JsonKey(name: 'fixed_schedules')  String? fixedSchedules, @JsonKey(name: 'user_locale')  String userLocale, @JsonKey(name: 'past_week_context')  PastWeekContext? pastWeekContext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WizardAnswers() when $default != null:
return $default(_that.status,_that.wakeTime,_that.sleepTime,_that.chronotype,_that.workDays,_that.workHours,_that.commuteTime,_that.mealPattern,_that.focusTime,_that.exercise,_that.exercisePreferredTime,_that.hobby,_that.goalFocus,_that.freeTime,_that.fixedSchedules,_that.userLocale,_that.pastWeekContext);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LifestyleStatus status, @JsonKey(name: 'wake_time')  WakeTime wakeTime, @JsonKey(name: 'sleep_time')  SleepTime sleepTime,  Chronotype chronotype, @JsonKey(name: 'work_days')  WorkDays workDays, @JsonKey(name: 'work_hours')  WorkHours workHours, @JsonKey(name: 'commute_time')  CommuteTime? commuteTime, @JsonKey(name: 'meal_pattern')  MealPattern mealPattern, @JsonKey(name: 'focus_time')  FocusTimeWindow focusTime,  ExerciseFrequency exercise, @JsonKey(name: 'exercise_preferred_time')  ExercisePreferredTime? exercisePreferredTime,  HobbyPreference hobby, @JsonKey(name: 'goal_focus')  GoalFocus goalFocus, @JsonKey(name: 'free_time')  FreeTimeMin freeTime, @JsonKey(name: 'fixed_schedules')  String? fixedSchedules, @JsonKey(name: 'user_locale')  String userLocale, @JsonKey(name: 'past_week_context')  PastWeekContext? pastWeekContext)  $default,) {final _that = this;
switch (_that) {
case _WizardAnswers():
return $default(_that.status,_that.wakeTime,_that.sleepTime,_that.chronotype,_that.workDays,_that.workHours,_that.commuteTime,_that.mealPattern,_that.focusTime,_that.exercise,_that.exercisePreferredTime,_that.hobby,_that.goalFocus,_that.freeTime,_that.fixedSchedules,_that.userLocale,_that.pastWeekContext);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LifestyleStatus status, @JsonKey(name: 'wake_time')  WakeTime wakeTime, @JsonKey(name: 'sleep_time')  SleepTime sleepTime,  Chronotype chronotype, @JsonKey(name: 'work_days')  WorkDays workDays, @JsonKey(name: 'work_hours')  WorkHours workHours, @JsonKey(name: 'commute_time')  CommuteTime? commuteTime, @JsonKey(name: 'meal_pattern')  MealPattern mealPattern, @JsonKey(name: 'focus_time')  FocusTimeWindow focusTime,  ExerciseFrequency exercise, @JsonKey(name: 'exercise_preferred_time')  ExercisePreferredTime? exercisePreferredTime,  HobbyPreference hobby, @JsonKey(name: 'goal_focus')  GoalFocus goalFocus, @JsonKey(name: 'free_time')  FreeTimeMin freeTime, @JsonKey(name: 'fixed_schedules')  String? fixedSchedules, @JsonKey(name: 'user_locale')  String userLocale, @JsonKey(name: 'past_week_context')  PastWeekContext? pastWeekContext)?  $default,) {final _that = this;
switch (_that) {
case _WizardAnswers() when $default != null:
return $default(_that.status,_that.wakeTime,_that.sleepTime,_that.chronotype,_that.workDays,_that.workHours,_that.commuteTime,_that.mealPattern,_that.focusTime,_that.exercise,_that.exercisePreferredTime,_that.hobby,_that.goalFocus,_that.freeTime,_that.fixedSchedules,_that.userLocale,_that.pastWeekContext);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WizardAnswers implements WizardAnswers {
  const _WizardAnswers({required this.status, @JsonKey(name: 'wake_time') required this.wakeTime, @JsonKey(name: 'sleep_time') required this.sleepTime, required this.chronotype, @JsonKey(name: 'work_days') required this.workDays, @JsonKey(name: 'work_hours') required this.workHours, @JsonKey(name: 'commute_time') this.commuteTime, @JsonKey(name: 'meal_pattern') required this.mealPattern, @JsonKey(name: 'focus_time') required this.focusTime, required this.exercise, @JsonKey(name: 'exercise_preferred_time') this.exercisePreferredTime, required this.hobby, @JsonKey(name: 'goal_focus') required this.goalFocus, @JsonKey(name: 'free_time') required this.freeTime, @JsonKey(name: 'fixed_schedules') this.fixedSchedules, @JsonKey(name: 'user_locale') this.userLocale = 'ko', @JsonKey(name: 'past_week_context') this.pastWeekContext});
  factory _WizardAnswers.fromJson(Map<String, dynamic> json) => _$WizardAnswersFromJson(json);

@override final  LifestyleStatus status;
@override@JsonKey(name: 'wake_time') final  WakeTime wakeTime;
@override@JsonKey(name: 'sleep_time') final  SleepTime sleepTime;
@override final  Chronotype chronotype;
@override@JsonKey(name: 'work_days') final  WorkDays workDays;
@override@JsonKey(name: 'work_hours') final  WorkHours workHours;
@override@JsonKey(name: 'commute_time') final  CommuteTime? commuteTime;
@override@JsonKey(name: 'meal_pattern') final  MealPattern mealPattern;
@override@JsonKey(name: 'focus_time') final  FocusTimeWindow focusTime;
@override final  ExerciseFrequency exercise;
@override@JsonKey(name: 'exercise_preferred_time') final  ExercisePreferredTime? exercisePreferredTime;
@override final  HobbyPreference hobby;
@override@JsonKey(name: 'goal_focus') final  GoalFocus goalFocus;
@override@JsonKey(name: 'free_time') final  FreeTimeMin freeTime;
@override@JsonKey(name: 'fixed_schedules') final  String? fixedSchedules;
@override@JsonKey(name: 'user_locale') final  String userLocale;
@override@JsonKey(name: 'past_week_context') final  PastWeekContext? pastWeekContext;

/// Create a copy of WizardAnswers
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WizardAnswersCopyWith<_WizardAnswers> get copyWith => __$WizardAnswersCopyWithImpl<_WizardAnswers>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WizardAnswersToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WizardAnswers&&(identical(other.status, status) || other.status == status)&&(identical(other.wakeTime, wakeTime) || other.wakeTime == wakeTime)&&(identical(other.sleepTime, sleepTime) || other.sleepTime == sleepTime)&&(identical(other.chronotype, chronotype) || other.chronotype == chronotype)&&(identical(other.workDays, workDays) || other.workDays == workDays)&&(identical(other.workHours, workHours) || other.workHours == workHours)&&(identical(other.commuteTime, commuteTime) || other.commuteTime == commuteTime)&&(identical(other.mealPattern, mealPattern) || other.mealPattern == mealPattern)&&(identical(other.focusTime, focusTime) || other.focusTime == focusTime)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&(identical(other.exercisePreferredTime, exercisePreferredTime) || other.exercisePreferredTime == exercisePreferredTime)&&(identical(other.hobby, hobby) || other.hobby == hobby)&&(identical(other.goalFocus, goalFocus) || other.goalFocus == goalFocus)&&(identical(other.freeTime, freeTime) || other.freeTime == freeTime)&&(identical(other.fixedSchedules, fixedSchedules) || other.fixedSchedules == fixedSchedules)&&(identical(other.userLocale, userLocale) || other.userLocale == userLocale)&&(identical(other.pastWeekContext, pastWeekContext) || other.pastWeekContext == pastWeekContext));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,wakeTime,sleepTime,chronotype,workDays,workHours,commuteTime,mealPattern,focusTime,exercise,exercisePreferredTime,hobby,goalFocus,freeTime,fixedSchedules,userLocale,pastWeekContext);

@override
String toString() {
  return 'WizardAnswers(status: $status, wakeTime: $wakeTime, sleepTime: $sleepTime, chronotype: $chronotype, workDays: $workDays, workHours: $workHours, commuteTime: $commuteTime, mealPattern: $mealPattern, focusTime: $focusTime, exercise: $exercise, exercisePreferredTime: $exercisePreferredTime, hobby: $hobby, goalFocus: $goalFocus, freeTime: $freeTime, fixedSchedules: $fixedSchedules, userLocale: $userLocale, pastWeekContext: $pastWeekContext)';
}


}

/// @nodoc
abstract mixin class _$WizardAnswersCopyWith<$Res> implements $WizardAnswersCopyWith<$Res> {
  factory _$WizardAnswersCopyWith(_WizardAnswers value, $Res Function(_WizardAnswers) _then) = __$WizardAnswersCopyWithImpl;
@override @useResult
$Res call({
 LifestyleStatus status,@JsonKey(name: 'wake_time') WakeTime wakeTime,@JsonKey(name: 'sleep_time') SleepTime sleepTime, Chronotype chronotype,@JsonKey(name: 'work_days') WorkDays workDays,@JsonKey(name: 'work_hours') WorkHours workHours,@JsonKey(name: 'commute_time') CommuteTime? commuteTime,@JsonKey(name: 'meal_pattern') MealPattern mealPattern,@JsonKey(name: 'focus_time') FocusTimeWindow focusTime, ExerciseFrequency exercise,@JsonKey(name: 'exercise_preferred_time') ExercisePreferredTime? exercisePreferredTime, HobbyPreference hobby,@JsonKey(name: 'goal_focus') GoalFocus goalFocus,@JsonKey(name: 'free_time') FreeTimeMin freeTime,@JsonKey(name: 'fixed_schedules') String? fixedSchedules,@JsonKey(name: 'user_locale') String userLocale,@JsonKey(name: 'past_week_context') PastWeekContext? pastWeekContext
});


@override $PastWeekContextCopyWith<$Res>? get pastWeekContext;

}
/// @nodoc
class __$WizardAnswersCopyWithImpl<$Res>
    implements _$WizardAnswersCopyWith<$Res> {
  __$WizardAnswersCopyWithImpl(this._self, this._then);

  final _WizardAnswers _self;
  final $Res Function(_WizardAnswers) _then;

/// Create a copy of WizardAnswers
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? wakeTime = null,Object? sleepTime = null,Object? chronotype = null,Object? workDays = null,Object? workHours = null,Object? commuteTime = freezed,Object? mealPattern = null,Object? focusTime = null,Object? exercise = null,Object? exercisePreferredTime = freezed,Object? hobby = null,Object? goalFocus = null,Object? freeTime = null,Object? fixedSchedules = freezed,Object? userLocale = null,Object? pastWeekContext = freezed,}) {
  return _then(_WizardAnswers(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LifestyleStatus,wakeTime: null == wakeTime ? _self.wakeTime : wakeTime // ignore: cast_nullable_to_non_nullable
as WakeTime,sleepTime: null == sleepTime ? _self.sleepTime : sleepTime // ignore: cast_nullable_to_non_nullable
as SleepTime,chronotype: null == chronotype ? _self.chronotype : chronotype // ignore: cast_nullable_to_non_nullable
as Chronotype,workDays: null == workDays ? _self.workDays : workDays // ignore: cast_nullable_to_non_nullable
as WorkDays,workHours: null == workHours ? _self.workHours : workHours // ignore: cast_nullable_to_non_nullable
as WorkHours,commuteTime: freezed == commuteTime ? _self.commuteTime : commuteTime // ignore: cast_nullable_to_non_nullable
as CommuteTime?,mealPattern: null == mealPattern ? _self.mealPattern : mealPattern // ignore: cast_nullable_to_non_nullable
as MealPattern,focusTime: null == focusTime ? _self.focusTime : focusTime // ignore: cast_nullable_to_non_nullable
as FocusTimeWindow,exercise: null == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as ExerciseFrequency,exercisePreferredTime: freezed == exercisePreferredTime ? _self.exercisePreferredTime : exercisePreferredTime // ignore: cast_nullable_to_non_nullable
as ExercisePreferredTime?,hobby: null == hobby ? _self.hobby : hobby // ignore: cast_nullable_to_non_nullable
as HobbyPreference,goalFocus: null == goalFocus ? _self.goalFocus : goalFocus // ignore: cast_nullable_to_non_nullable
as GoalFocus,freeTime: null == freeTime ? _self.freeTime : freeTime // ignore: cast_nullable_to_non_nullable
as FreeTimeMin,fixedSchedules: freezed == fixedSchedules ? _self.fixedSchedules : fixedSchedules // ignore: cast_nullable_to_non_nullable
as String?,userLocale: null == userLocale ? _self.userLocale : userLocale // ignore: cast_nullable_to_non_nullable
as String,pastWeekContext: freezed == pastWeekContext ? _self.pastWeekContext : pastWeekContext // ignore: cast_nullable_to_non_nullable
as PastWeekContext?,
  ));
}

/// Create a copy of WizardAnswers
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PastWeekContextCopyWith<$Res>? get pastWeekContext {
    if (_self.pastWeekContext == null) {
    return null;
  }

  return $PastWeekContextCopyWith<$Res>(_self.pastWeekContext!, (value) {
    return _then(_self.copyWith(pastWeekContext: value));
  });
}
}


/// @nodoc
mixin _$PastWeekContext {

@JsonKey(name: 'weekly_completion_rate') double get weeklyCompletionRate;@JsonKey(name: 'lowest_completion_category') String? get lowestCompletionCategory;@JsonKey(name: 'most_missed_time_block') String? get mostMissedTimeBlock;@JsonKey(name: 'focus_ratio_avg') double get focusRatioAvg;@JsonKey(name: 'weeks_observed') int get weeksObserved;
/// Create a copy of PastWeekContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PastWeekContextCopyWith<PastWeekContext> get copyWith => _$PastWeekContextCopyWithImpl<PastWeekContext>(this as PastWeekContext, _$identity);

  /// Serializes this PastWeekContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PastWeekContext&&(identical(other.weeklyCompletionRate, weeklyCompletionRate) || other.weeklyCompletionRate == weeklyCompletionRate)&&(identical(other.lowestCompletionCategory, lowestCompletionCategory) || other.lowestCompletionCategory == lowestCompletionCategory)&&(identical(other.mostMissedTimeBlock, mostMissedTimeBlock) || other.mostMissedTimeBlock == mostMissedTimeBlock)&&(identical(other.focusRatioAvg, focusRatioAvg) || other.focusRatioAvg == focusRatioAvg)&&(identical(other.weeksObserved, weeksObserved) || other.weeksObserved == weeksObserved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weeklyCompletionRate,lowestCompletionCategory,mostMissedTimeBlock,focusRatioAvg,weeksObserved);

@override
String toString() {
  return 'PastWeekContext(weeklyCompletionRate: $weeklyCompletionRate, lowestCompletionCategory: $lowestCompletionCategory, mostMissedTimeBlock: $mostMissedTimeBlock, focusRatioAvg: $focusRatioAvg, weeksObserved: $weeksObserved)';
}


}

/// @nodoc
abstract mixin class $PastWeekContextCopyWith<$Res>  {
  factory $PastWeekContextCopyWith(PastWeekContext value, $Res Function(PastWeekContext) _then) = _$PastWeekContextCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'weekly_completion_rate') double weeklyCompletionRate,@JsonKey(name: 'lowest_completion_category') String? lowestCompletionCategory,@JsonKey(name: 'most_missed_time_block') String? mostMissedTimeBlock,@JsonKey(name: 'focus_ratio_avg') double focusRatioAvg,@JsonKey(name: 'weeks_observed') int weeksObserved
});




}
/// @nodoc
class _$PastWeekContextCopyWithImpl<$Res>
    implements $PastWeekContextCopyWith<$Res> {
  _$PastWeekContextCopyWithImpl(this._self, this._then);

  final PastWeekContext _self;
  final $Res Function(PastWeekContext) _then;

/// Create a copy of PastWeekContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weeklyCompletionRate = null,Object? lowestCompletionCategory = freezed,Object? mostMissedTimeBlock = freezed,Object? focusRatioAvg = null,Object? weeksObserved = null,}) {
  return _then(_self.copyWith(
weeklyCompletionRate: null == weeklyCompletionRate ? _self.weeklyCompletionRate : weeklyCompletionRate // ignore: cast_nullable_to_non_nullable
as double,lowestCompletionCategory: freezed == lowestCompletionCategory ? _self.lowestCompletionCategory : lowestCompletionCategory // ignore: cast_nullable_to_non_nullable
as String?,mostMissedTimeBlock: freezed == mostMissedTimeBlock ? _self.mostMissedTimeBlock : mostMissedTimeBlock // ignore: cast_nullable_to_non_nullable
as String?,focusRatioAvg: null == focusRatioAvg ? _self.focusRatioAvg : focusRatioAvg // ignore: cast_nullable_to_non_nullable
as double,weeksObserved: null == weeksObserved ? _self.weeksObserved : weeksObserved // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PastWeekContext].
extension PastWeekContextPatterns on PastWeekContext {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PastWeekContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PastWeekContext() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PastWeekContext value)  $default,){
final _that = this;
switch (_that) {
case _PastWeekContext():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PastWeekContext value)?  $default,){
final _that = this;
switch (_that) {
case _PastWeekContext() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'weekly_completion_rate')  double weeklyCompletionRate, @JsonKey(name: 'lowest_completion_category')  String? lowestCompletionCategory, @JsonKey(name: 'most_missed_time_block')  String? mostMissedTimeBlock, @JsonKey(name: 'focus_ratio_avg')  double focusRatioAvg, @JsonKey(name: 'weeks_observed')  int weeksObserved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PastWeekContext() when $default != null:
return $default(_that.weeklyCompletionRate,_that.lowestCompletionCategory,_that.mostMissedTimeBlock,_that.focusRatioAvg,_that.weeksObserved);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'weekly_completion_rate')  double weeklyCompletionRate, @JsonKey(name: 'lowest_completion_category')  String? lowestCompletionCategory, @JsonKey(name: 'most_missed_time_block')  String? mostMissedTimeBlock, @JsonKey(name: 'focus_ratio_avg')  double focusRatioAvg, @JsonKey(name: 'weeks_observed')  int weeksObserved)  $default,) {final _that = this;
switch (_that) {
case _PastWeekContext():
return $default(_that.weeklyCompletionRate,_that.lowestCompletionCategory,_that.mostMissedTimeBlock,_that.focusRatioAvg,_that.weeksObserved);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'weekly_completion_rate')  double weeklyCompletionRate, @JsonKey(name: 'lowest_completion_category')  String? lowestCompletionCategory, @JsonKey(name: 'most_missed_time_block')  String? mostMissedTimeBlock, @JsonKey(name: 'focus_ratio_avg')  double focusRatioAvg, @JsonKey(name: 'weeks_observed')  int weeksObserved)?  $default,) {final _that = this;
switch (_that) {
case _PastWeekContext() when $default != null:
return $default(_that.weeklyCompletionRate,_that.lowestCompletionCategory,_that.mostMissedTimeBlock,_that.focusRatioAvg,_that.weeksObserved);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PastWeekContext implements PastWeekContext {
  const _PastWeekContext({@JsonKey(name: 'weekly_completion_rate') required this.weeklyCompletionRate, @JsonKey(name: 'lowest_completion_category') this.lowestCompletionCategory, @JsonKey(name: 'most_missed_time_block') this.mostMissedTimeBlock, @JsonKey(name: 'focus_ratio_avg') required this.focusRatioAvg, @JsonKey(name: 'weeks_observed') required this.weeksObserved});
  factory _PastWeekContext.fromJson(Map<String, dynamic> json) => _$PastWeekContextFromJson(json);

@override@JsonKey(name: 'weekly_completion_rate') final  double weeklyCompletionRate;
@override@JsonKey(name: 'lowest_completion_category') final  String? lowestCompletionCategory;
@override@JsonKey(name: 'most_missed_time_block') final  String? mostMissedTimeBlock;
@override@JsonKey(name: 'focus_ratio_avg') final  double focusRatioAvg;
@override@JsonKey(name: 'weeks_observed') final  int weeksObserved;

/// Create a copy of PastWeekContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PastWeekContextCopyWith<_PastWeekContext> get copyWith => __$PastWeekContextCopyWithImpl<_PastWeekContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PastWeekContextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PastWeekContext&&(identical(other.weeklyCompletionRate, weeklyCompletionRate) || other.weeklyCompletionRate == weeklyCompletionRate)&&(identical(other.lowestCompletionCategory, lowestCompletionCategory) || other.lowestCompletionCategory == lowestCompletionCategory)&&(identical(other.mostMissedTimeBlock, mostMissedTimeBlock) || other.mostMissedTimeBlock == mostMissedTimeBlock)&&(identical(other.focusRatioAvg, focusRatioAvg) || other.focusRatioAvg == focusRatioAvg)&&(identical(other.weeksObserved, weeksObserved) || other.weeksObserved == weeksObserved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weeklyCompletionRate,lowestCompletionCategory,mostMissedTimeBlock,focusRatioAvg,weeksObserved);

@override
String toString() {
  return 'PastWeekContext(weeklyCompletionRate: $weeklyCompletionRate, lowestCompletionCategory: $lowestCompletionCategory, mostMissedTimeBlock: $mostMissedTimeBlock, focusRatioAvg: $focusRatioAvg, weeksObserved: $weeksObserved)';
}


}

/// @nodoc
abstract mixin class _$PastWeekContextCopyWith<$Res> implements $PastWeekContextCopyWith<$Res> {
  factory _$PastWeekContextCopyWith(_PastWeekContext value, $Res Function(_PastWeekContext) _then) = __$PastWeekContextCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'weekly_completion_rate') double weeklyCompletionRate,@JsonKey(name: 'lowest_completion_category') String? lowestCompletionCategory,@JsonKey(name: 'most_missed_time_block') String? mostMissedTimeBlock,@JsonKey(name: 'focus_ratio_avg') double focusRatioAvg,@JsonKey(name: 'weeks_observed') int weeksObserved
});




}
/// @nodoc
class __$PastWeekContextCopyWithImpl<$Res>
    implements _$PastWeekContextCopyWith<$Res> {
  __$PastWeekContextCopyWithImpl(this._self, this._then);

  final _PastWeekContext _self;
  final $Res Function(_PastWeekContext) _then;

/// Create a copy of PastWeekContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weeklyCompletionRate = null,Object? lowestCompletionCategory = freezed,Object? mostMissedTimeBlock = freezed,Object? focusRatioAvg = null,Object? weeksObserved = null,}) {
  return _then(_PastWeekContext(
weeklyCompletionRate: null == weeklyCompletionRate ? _self.weeklyCompletionRate : weeklyCompletionRate // ignore: cast_nullable_to_non_nullable
as double,lowestCompletionCategory: freezed == lowestCompletionCategory ? _self.lowestCompletionCategory : lowestCompletionCategory // ignore: cast_nullable_to_non_nullable
as String?,mostMissedTimeBlock: freezed == mostMissedTimeBlock ? _self.mostMissedTimeBlock : mostMissedTimeBlock // ignore: cast_nullable_to_non_nullable
as String?,focusRatioAvg: null == focusRatioAvg ? _self.focusRatioAvg : focusRatioAvg // ignore: cast_nullable_to_non_nullable
as double,weeksObserved: null == weeksObserved ? _self.weeksObserved : weeksObserved // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GeneratedScheduleItem {

 String get title;@JsonKey(name: 'day_of_week') int get dayOfWeek;@JsonKey(name: 'start_time') String get startTime;@JsonKey(name: 'end_time') String get endTime;@JsonKey(fromJson: _catFromJson, toJson: _catToJson) ScheduleCategory get category; List<String> get tags;
/// Create a copy of GeneratedScheduleItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratedScheduleItemCopyWith<GeneratedScheduleItem> get copyWith => _$GeneratedScheduleItemCopyWithImpl<GeneratedScheduleItem>(this as GeneratedScheduleItem, _$identity);

  /// Serializes this GeneratedScheduleItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratedScheduleItem&&(identical(other.title, title) || other.title == title)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,dayOfWeek,startTime,endTime,category,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'GeneratedScheduleItem(title: $title, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, category: $category, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $GeneratedScheduleItemCopyWith<$Res>  {
  factory $GeneratedScheduleItemCopyWith(GeneratedScheduleItem value, $Res Function(GeneratedScheduleItem) _then) = _$GeneratedScheduleItemCopyWithImpl;
@useResult
$Res call({
 String title,@JsonKey(name: 'day_of_week') int dayOfWeek,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime,@JsonKey(fromJson: _catFromJson, toJson: _catToJson) ScheduleCategory category, List<String> tags
});




}
/// @nodoc
class _$GeneratedScheduleItemCopyWithImpl<$Res>
    implements $GeneratedScheduleItemCopyWith<$Res> {
  _$GeneratedScheduleItemCopyWithImpl(this._self, this._then);

  final GeneratedScheduleItem _self;
  final $Res Function(GeneratedScheduleItem) _then;

/// Create a copy of GeneratedScheduleItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,Object? category = null,Object? tags = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ScheduleCategory,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratedScheduleItem].
extension GeneratedScheduleItemPatterns on GeneratedScheduleItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratedScheduleItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratedScheduleItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratedScheduleItem value)  $default,){
final _that = this;
switch (_that) {
case _GeneratedScheduleItem():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratedScheduleItem value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratedScheduleItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(fromJson: _catFromJson, toJson: _catToJson)  ScheduleCategory category,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratedScheduleItem() when $default != null:
return $default(_that.title,_that.dayOfWeek,_that.startTime,_that.endTime,_that.category,_that.tags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(fromJson: _catFromJson, toJson: _catToJson)  ScheduleCategory category,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _GeneratedScheduleItem():
return $default(_that.title,_that.dayOfWeek,_that.startTime,_that.endTime,_that.category,_that.tags);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(fromJson: _catFromJson, toJson: _catToJson)  ScheduleCategory category,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _GeneratedScheduleItem() when $default != null:
return $default(_that.title,_that.dayOfWeek,_that.startTime,_that.endTime,_that.category,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeneratedScheduleItem extends GeneratedScheduleItem {
  const _GeneratedScheduleItem({required this.title, @JsonKey(name: 'day_of_week') required this.dayOfWeek, @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'end_time') required this.endTime, @JsonKey(fromJson: _catFromJson, toJson: _catToJson) required this.category, final  List<String> tags = const []}): _tags = tags,super._();
  factory _GeneratedScheduleItem.fromJson(Map<String, dynamic> json) => _$GeneratedScheduleItemFromJson(json);

@override final  String title;
@override@JsonKey(name: 'day_of_week') final  int dayOfWeek;
@override@JsonKey(name: 'start_time') final  String startTime;
@override@JsonKey(name: 'end_time') final  String endTime;
@override@JsonKey(fromJson: _catFromJson, toJson: _catToJson) final  ScheduleCategory category;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of GeneratedScheduleItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratedScheduleItemCopyWith<_GeneratedScheduleItem> get copyWith => __$GeneratedScheduleItemCopyWithImpl<_GeneratedScheduleItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeneratedScheduleItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratedScheduleItem&&(identical(other.title, title) || other.title == title)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,dayOfWeek,startTime,endTime,category,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'GeneratedScheduleItem(title: $title, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, category: $category, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$GeneratedScheduleItemCopyWith<$Res> implements $GeneratedScheduleItemCopyWith<$Res> {
  factory _$GeneratedScheduleItemCopyWith(_GeneratedScheduleItem value, $Res Function(_GeneratedScheduleItem) _then) = __$GeneratedScheduleItemCopyWithImpl;
@override @useResult
$Res call({
 String title,@JsonKey(name: 'day_of_week') int dayOfWeek,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime,@JsonKey(fromJson: _catFromJson, toJson: _catToJson) ScheduleCategory category, List<String> tags
});




}
/// @nodoc
class __$GeneratedScheduleItemCopyWithImpl<$Res>
    implements _$GeneratedScheduleItemCopyWith<$Res> {
  __$GeneratedScheduleItemCopyWithImpl(this._self, this._then);

  final _GeneratedScheduleItem _self;
  final $Res Function(_GeneratedScheduleItem) _then;

/// Create a copy of GeneratedScheduleItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,Object? category = null,Object? tags = null,}) {
  return _then(_GeneratedScheduleItem(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ScheduleCategory,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$FollowupOption {

 String get value; String get label;
/// Create a copy of FollowupOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowupOptionCopyWith<FollowupOption> get copyWith => _$FollowupOptionCopyWithImpl<FollowupOption>(this as FollowupOption, _$identity);

  /// Serializes this FollowupOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowupOption&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,label);

@override
String toString() {
  return 'FollowupOption(value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class $FollowupOptionCopyWith<$Res>  {
  factory $FollowupOptionCopyWith(FollowupOption value, $Res Function(FollowupOption) _then) = _$FollowupOptionCopyWithImpl;
@useResult
$Res call({
 String value, String label
});




}
/// @nodoc
class _$FollowupOptionCopyWithImpl<$Res>
    implements $FollowupOptionCopyWith<$Res> {
  _$FollowupOptionCopyWithImpl(this._self, this._then);

  final FollowupOption _self;
  final $Res Function(FollowupOption) _then;

/// Create a copy of FollowupOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? label = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowupOption].
extension FollowupOptionPatterns on FollowupOption {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowupOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowupOption() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowupOption value)  $default,){
final _that = this;
switch (_that) {
case _FollowupOption():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowupOption value)?  $default,){
final _that = this;
switch (_that) {
case _FollowupOption() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowupOption() when $default != null:
return $default(_that.value,_that.label);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String label)  $default,) {final _that = this;
switch (_that) {
case _FollowupOption():
return $default(_that.value,_that.label);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String label)?  $default,) {final _that = this;
switch (_that) {
case _FollowupOption() when $default != null:
return $default(_that.value,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowupOption implements FollowupOption {
  const _FollowupOption({required this.value, required this.label});
  factory _FollowupOption.fromJson(Map<String, dynamic> json) => _$FollowupOptionFromJson(json);

@override final  String value;
@override final  String label;

/// Create a copy of FollowupOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowupOptionCopyWith<_FollowupOption> get copyWith => __$FollowupOptionCopyWithImpl<_FollowupOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowupOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowupOption&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,label);

@override
String toString() {
  return 'FollowupOption(value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class _$FollowupOptionCopyWith<$Res> implements $FollowupOptionCopyWith<$Res> {
  factory _$FollowupOptionCopyWith(_FollowupOption value, $Res Function(_FollowupOption) _then) = __$FollowupOptionCopyWithImpl;
@override @useResult
$Res call({
 String value, String label
});




}
/// @nodoc
class __$FollowupOptionCopyWithImpl<$Res>
    implements _$FollowupOptionCopyWith<$Res> {
  __$FollowupOptionCopyWithImpl(this._self, this._then);

  final _FollowupOption _self;
  final $Res Function(_FollowupOption) _then;

/// Create a copy of FollowupOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? label = null,}) {
  return _then(_FollowupOption(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FollowupQuestion {

 String get id; String get question; List<FollowupOption> get options;
/// Create a copy of FollowupQuestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowupQuestionCopyWith<FollowupQuestion> get copyWith => _$FollowupQuestionCopyWithImpl<FollowupQuestion>(this as FollowupQuestion, _$identity);

  /// Serializes this FollowupQuestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowupQuestion&&(identical(other.id, id) || other.id == id)&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other.options, options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,question,const DeepCollectionEquality().hash(options));

@override
String toString() {
  return 'FollowupQuestion(id: $id, question: $question, options: $options)';
}


}

/// @nodoc
abstract mixin class $FollowupQuestionCopyWith<$Res>  {
  factory $FollowupQuestionCopyWith(FollowupQuestion value, $Res Function(FollowupQuestion) _then) = _$FollowupQuestionCopyWithImpl;
@useResult
$Res call({
 String id, String question, List<FollowupOption> options
});




}
/// @nodoc
class _$FollowupQuestionCopyWithImpl<$Res>
    implements $FollowupQuestionCopyWith<$Res> {
  _$FollowupQuestionCopyWithImpl(this._self, this._then);

  final FollowupQuestion _self;
  final $Res Function(FollowupQuestion) _then;

/// Create a copy of FollowupQuestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? question = null,Object? options = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<FollowupOption>,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowupQuestion].
extension FollowupQuestionPatterns on FollowupQuestion {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowupQuestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowupQuestion() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowupQuestion value)  $default,){
final _that = this;
switch (_that) {
case _FollowupQuestion():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowupQuestion value)?  $default,){
final _that = this;
switch (_that) {
case _FollowupQuestion() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String question,  List<FollowupOption> options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowupQuestion() when $default != null:
return $default(_that.id,_that.question,_that.options);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String question,  List<FollowupOption> options)  $default,) {final _that = this;
switch (_that) {
case _FollowupQuestion():
return $default(_that.id,_that.question,_that.options);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String question,  List<FollowupOption> options)?  $default,) {final _that = this;
switch (_that) {
case _FollowupQuestion() when $default != null:
return $default(_that.id,_that.question,_that.options);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowupQuestion implements FollowupQuestion {
  const _FollowupQuestion({required this.id, required this.question, required final  List<FollowupOption> options}): _options = options;
  factory _FollowupQuestion.fromJson(Map<String, dynamic> json) => _$FollowupQuestionFromJson(json);

@override final  String id;
@override final  String question;
 final  List<FollowupOption> _options;
@override List<FollowupOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}


/// Create a copy of FollowupQuestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowupQuestionCopyWith<_FollowupQuestion> get copyWith => __$FollowupQuestionCopyWithImpl<_FollowupQuestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowupQuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowupQuestion&&(identical(other.id, id) || other.id == id)&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other._options, _options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,question,const DeepCollectionEquality().hash(_options));

@override
String toString() {
  return 'FollowupQuestion(id: $id, question: $question, options: $options)';
}


}

/// @nodoc
abstract mixin class _$FollowupQuestionCopyWith<$Res> implements $FollowupQuestionCopyWith<$Res> {
  factory _$FollowupQuestionCopyWith(_FollowupQuestion value, $Res Function(_FollowupQuestion) _then) = __$FollowupQuestionCopyWithImpl;
@override @useResult
$Res call({
 String id, String question, List<FollowupOption> options
});




}
/// @nodoc
class __$FollowupQuestionCopyWithImpl<$Res>
    implements _$FollowupQuestionCopyWith<$Res> {
  __$FollowupQuestionCopyWithImpl(this._self, this._then);

  final _FollowupQuestion _self;
  final $Res Function(_FollowupQuestion) _then;

/// Create a copy of FollowupQuestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? question = null,Object? options = null,}) {
  return _then(_FollowupQuestion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<FollowupOption>,
  ));
}


}


/// @nodoc
mixin _$WeeklyWizardResponse {

 List<GeneratedScheduleItem> get items; WizardSource get source;@JsonKey(name: 'followup_questions') List<FollowupQuestion> get followupQuestions;
/// Create a copy of WeeklyWizardResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyWizardResponseCopyWith<WeeklyWizardResponse> get copyWith => _$WeeklyWizardResponseCopyWithImpl<WeeklyWizardResponse>(this as WeeklyWizardResponse, _$identity);

  /// Serializes this WeeklyWizardResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyWizardResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.followupQuestions, followupQuestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),source,const DeepCollectionEquality().hash(followupQuestions));

@override
String toString() {
  return 'WeeklyWizardResponse(items: $items, source: $source, followupQuestions: $followupQuestions)';
}


}

/// @nodoc
abstract mixin class $WeeklyWizardResponseCopyWith<$Res>  {
  factory $WeeklyWizardResponseCopyWith(WeeklyWizardResponse value, $Res Function(WeeklyWizardResponse) _then) = _$WeeklyWizardResponseCopyWithImpl;
@useResult
$Res call({
 List<GeneratedScheduleItem> items, WizardSource source,@JsonKey(name: 'followup_questions') List<FollowupQuestion> followupQuestions
});




}
/// @nodoc
class _$WeeklyWizardResponseCopyWithImpl<$Res>
    implements $WeeklyWizardResponseCopyWith<$Res> {
  _$WeeklyWizardResponseCopyWithImpl(this._self, this._then);

  final WeeklyWizardResponse _self;
  final $Res Function(WeeklyWizardResponse) _then;

/// Create a copy of WeeklyWizardResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? source = null,Object? followupQuestions = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GeneratedScheduleItem>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WizardSource,followupQuestions: null == followupQuestions ? _self.followupQuestions : followupQuestions // ignore: cast_nullable_to_non_nullable
as List<FollowupQuestion>,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyWizardResponse].
extension WeeklyWizardResponsePatterns on WeeklyWizardResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyWizardResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyWizardResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyWizardResponse value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyWizardResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyWizardResponse value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyWizardResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GeneratedScheduleItem> items,  WizardSource source, @JsonKey(name: 'followup_questions')  List<FollowupQuestion> followupQuestions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyWizardResponse() when $default != null:
return $default(_that.items,_that.source,_that.followupQuestions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GeneratedScheduleItem> items,  WizardSource source, @JsonKey(name: 'followup_questions')  List<FollowupQuestion> followupQuestions)  $default,) {final _that = this;
switch (_that) {
case _WeeklyWizardResponse():
return $default(_that.items,_that.source,_that.followupQuestions);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GeneratedScheduleItem> items,  WizardSource source, @JsonKey(name: 'followup_questions')  List<FollowupQuestion> followupQuestions)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyWizardResponse() when $default != null:
return $default(_that.items,_that.source,_that.followupQuestions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyWizardResponse implements WeeklyWizardResponse {
  const _WeeklyWizardResponse({required final  List<GeneratedScheduleItem> items, required this.source, @JsonKey(name: 'followup_questions') final  List<FollowupQuestion> followupQuestions = const <FollowupQuestion>[]}): _items = items,_followupQuestions = followupQuestions;
  factory _WeeklyWizardResponse.fromJson(Map<String, dynamic> json) => _$WeeklyWizardResponseFromJson(json);

 final  List<GeneratedScheduleItem> _items;
@override List<GeneratedScheduleItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  WizardSource source;
 final  List<FollowupQuestion> _followupQuestions;
@override@JsonKey(name: 'followup_questions') List<FollowupQuestion> get followupQuestions {
  if (_followupQuestions is EqualUnmodifiableListView) return _followupQuestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_followupQuestions);
}


/// Create a copy of WeeklyWizardResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyWizardResponseCopyWith<_WeeklyWizardResponse> get copyWith => __$WeeklyWizardResponseCopyWithImpl<_WeeklyWizardResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyWizardResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyWizardResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other._followupQuestions, _followupQuestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),source,const DeepCollectionEquality().hash(_followupQuestions));

@override
String toString() {
  return 'WeeklyWizardResponse(items: $items, source: $source, followupQuestions: $followupQuestions)';
}


}

/// @nodoc
abstract mixin class _$WeeklyWizardResponseCopyWith<$Res> implements $WeeklyWizardResponseCopyWith<$Res> {
  factory _$WeeklyWizardResponseCopyWith(_WeeklyWizardResponse value, $Res Function(_WeeklyWizardResponse) _then) = __$WeeklyWizardResponseCopyWithImpl;
@override @useResult
$Res call({
 List<GeneratedScheduleItem> items, WizardSource source,@JsonKey(name: 'followup_questions') List<FollowupQuestion> followupQuestions
});




}
/// @nodoc
class __$WeeklyWizardResponseCopyWithImpl<$Res>
    implements _$WeeklyWizardResponseCopyWith<$Res> {
  __$WeeklyWizardResponseCopyWithImpl(this._self, this._then);

  final _WeeklyWizardResponse _self;
  final $Res Function(_WeeklyWizardResponse) _then;

/// Create a copy of WeeklyWizardResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? source = null,Object? followupQuestions = null,}) {
  return _then(_WeeklyWizardResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GeneratedScheduleItem>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WizardSource,followupQuestions: null == followupQuestions ? _self._followupQuestions : followupQuestions // ignore: cast_nullable_to_non_nullable
as List<FollowupQuestion>,
  ));
}


}

// dart format on
