// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiReportInputData {

// 이행 강도 (execution intensity)
@JsonKey(name: 'focus_sessions') int get focusSessions;@JsonKey(name: 'avg_focus_ratio') double get avgFocusRatio;@JsonKey(name: 'planned_minutes') int get plannedMinutes;@JsonKey(name: 'actual_focus_minutes') int get actualFocusMinutes;@JsonKey(name: 'sessions_by_grade') Map<String, int> get sessionsByGrade;// 체크 강도 (completion intensity)
@JsonKey(name: 'todos_total') int get todosTotal;@JsonKey(name: 'todos_completed') int get todosCompleted;@JsonKey(name: 'todos_completed_on_due_day') int get todosCompletedOnDueDay;@JsonKey(name: 'non_todo_completed') int get nonTodoCompleted;// legacy aliases retained for compatibility
@JsonKey(name: 'tasks_completed') int get tasksCompleted;@JsonKey(name: 'tasks_total') int get tasksTotal;// 작성 강도 (authoring intensity)
@JsonKey(name: 'schedules_created') int get schedulesCreated;@JsonKey(name: 'schedules_total_minutes') int get schedulesTotalMinutes;@JsonKey(name: 'category_distribution') Map<String, int> get categoryDistribution;// streak (carry-over)
@JsonKey(name: 'streak_days') int get streakDays;
/// Create a copy of AiReportInputData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiReportInputDataCopyWith<AiReportInputData> get copyWith => _$AiReportInputDataCopyWithImpl<AiReportInputData>(this as AiReportInputData, _$identity);

  /// Serializes this AiReportInputData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiReportInputData&&(identical(other.focusSessions, focusSessions) || other.focusSessions == focusSessions)&&(identical(other.avgFocusRatio, avgFocusRatio) || other.avgFocusRatio == avgFocusRatio)&&(identical(other.plannedMinutes, plannedMinutes) || other.plannedMinutes == plannedMinutes)&&(identical(other.actualFocusMinutes, actualFocusMinutes) || other.actualFocusMinutes == actualFocusMinutes)&&const DeepCollectionEquality().equals(other.sessionsByGrade, sessionsByGrade)&&(identical(other.todosTotal, todosTotal) || other.todosTotal == todosTotal)&&(identical(other.todosCompleted, todosCompleted) || other.todosCompleted == todosCompleted)&&(identical(other.todosCompletedOnDueDay, todosCompletedOnDueDay) || other.todosCompletedOnDueDay == todosCompletedOnDueDay)&&(identical(other.nonTodoCompleted, nonTodoCompleted) || other.nonTodoCompleted == nonTodoCompleted)&&(identical(other.tasksCompleted, tasksCompleted) || other.tasksCompleted == tasksCompleted)&&(identical(other.tasksTotal, tasksTotal) || other.tasksTotal == tasksTotal)&&(identical(other.schedulesCreated, schedulesCreated) || other.schedulesCreated == schedulesCreated)&&(identical(other.schedulesTotalMinutes, schedulesTotalMinutes) || other.schedulesTotalMinutes == schedulesTotalMinutes)&&const DeepCollectionEquality().equals(other.categoryDistribution, categoryDistribution)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,focusSessions,avgFocusRatio,plannedMinutes,actualFocusMinutes,const DeepCollectionEquality().hash(sessionsByGrade),todosTotal,todosCompleted,todosCompletedOnDueDay,nonTodoCompleted,tasksCompleted,tasksTotal,schedulesCreated,schedulesTotalMinutes,const DeepCollectionEquality().hash(categoryDistribution),streakDays);

@override
String toString() {
  return 'AiReportInputData(focusSessions: $focusSessions, avgFocusRatio: $avgFocusRatio, plannedMinutes: $plannedMinutes, actualFocusMinutes: $actualFocusMinutes, sessionsByGrade: $sessionsByGrade, todosTotal: $todosTotal, todosCompleted: $todosCompleted, todosCompletedOnDueDay: $todosCompletedOnDueDay, nonTodoCompleted: $nonTodoCompleted, tasksCompleted: $tasksCompleted, tasksTotal: $tasksTotal, schedulesCreated: $schedulesCreated, schedulesTotalMinutes: $schedulesTotalMinutes, categoryDistribution: $categoryDistribution, streakDays: $streakDays)';
}


}

/// @nodoc
abstract mixin class $AiReportInputDataCopyWith<$Res>  {
  factory $AiReportInputDataCopyWith(AiReportInputData value, $Res Function(AiReportInputData) _then) = _$AiReportInputDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'focus_sessions') int focusSessions,@JsonKey(name: 'avg_focus_ratio') double avgFocusRatio,@JsonKey(name: 'planned_minutes') int plannedMinutes,@JsonKey(name: 'actual_focus_minutes') int actualFocusMinutes,@JsonKey(name: 'sessions_by_grade') Map<String, int> sessionsByGrade,@JsonKey(name: 'todos_total') int todosTotal,@JsonKey(name: 'todos_completed') int todosCompleted,@JsonKey(name: 'todos_completed_on_due_day') int todosCompletedOnDueDay,@JsonKey(name: 'non_todo_completed') int nonTodoCompleted,@JsonKey(name: 'tasks_completed') int tasksCompleted,@JsonKey(name: 'tasks_total') int tasksTotal,@JsonKey(name: 'schedules_created') int schedulesCreated,@JsonKey(name: 'schedules_total_minutes') int schedulesTotalMinutes,@JsonKey(name: 'category_distribution') Map<String, int> categoryDistribution,@JsonKey(name: 'streak_days') int streakDays
});




}
/// @nodoc
class _$AiReportInputDataCopyWithImpl<$Res>
    implements $AiReportInputDataCopyWith<$Res> {
  _$AiReportInputDataCopyWithImpl(this._self, this._then);

  final AiReportInputData _self;
  final $Res Function(AiReportInputData) _then;

/// Create a copy of AiReportInputData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? focusSessions = null,Object? avgFocusRatio = null,Object? plannedMinutes = null,Object? actualFocusMinutes = null,Object? sessionsByGrade = null,Object? todosTotal = null,Object? todosCompleted = null,Object? todosCompletedOnDueDay = null,Object? nonTodoCompleted = null,Object? tasksCompleted = null,Object? tasksTotal = null,Object? schedulesCreated = null,Object? schedulesTotalMinutes = null,Object? categoryDistribution = null,Object? streakDays = null,}) {
  return _then(_self.copyWith(
focusSessions: null == focusSessions ? _self.focusSessions : focusSessions // ignore: cast_nullable_to_non_nullable
as int,avgFocusRatio: null == avgFocusRatio ? _self.avgFocusRatio : avgFocusRatio // ignore: cast_nullable_to_non_nullable
as double,plannedMinutes: null == plannedMinutes ? _self.plannedMinutes : plannedMinutes // ignore: cast_nullable_to_non_nullable
as int,actualFocusMinutes: null == actualFocusMinutes ? _self.actualFocusMinutes : actualFocusMinutes // ignore: cast_nullable_to_non_nullable
as int,sessionsByGrade: null == sessionsByGrade ? _self.sessionsByGrade : sessionsByGrade // ignore: cast_nullable_to_non_nullable
as Map<String, int>,todosTotal: null == todosTotal ? _self.todosTotal : todosTotal // ignore: cast_nullable_to_non_nullable
as int,todosCompleted: null == todosCompleted ? _self.todosCompleted : todosCompleted // ignore: cast_nullable_to_non_nullable
as int,todosCompletedOnDueDay: null == todosCompletedOnDueDay ? _self.todosCompletedOnDueDay : todosCompletedOnDueDay // ignore: cast_nullable_to_non_nullable
as int,nonTodoCompleted: null == nonTodoCompleted ? _self.nonTodoCompleted : nonTodoCompleted // ignore: cast_nullable_to_non_nullable
as int,tasksCompleted: null == tasksCompleted ? _self.tasksCompleted : tasksCompleted // ignore: cast_nullable_to_non_nullable
as int,tasksTotal: null == tasksTotal ? _self.tasksTotal : tasksTotal // ignore: cast_nullable_to_non_nullable
as int,schedulesCreated: null == schedulesCreated ? _self.schedulesCreated : schedulesCreated // ignore: cast_nullable_to_non_nullable
as int,schedulesTotalMinutes: null == schedulesTotalMinutes ? _self.schedulesTotalMinutes : schedulesTotalMinutes // ignore: cast_nullable_to_non_nullable
as int,categoryDistribution: null == categoryDistribution ? _self.categoryDistribution : categoryDistribution // ignore: cast_nullable_to_non_nullable
as Map<String, int>,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AiReportInputData].
extension AiReportInputDataPatterns on AiReportInputData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiReportInputData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiReportInputData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiReportInputData value)  $default,){
final _that = this;
switch (_that) {
case _AiReportInputData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiReportInputData value)?  $default,){
final _that = this;
switch (_that) {
case _AiReportInputData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'focus_sessions')  int focusSessions, @JsonKey(name: 'avg_focus_ratio')  double avgFocusRatio, @JsonKey(name: 'planned_minutes')  int plannedMinutes, @JsonKey(name: 'actual_focus_minutes')  int actualFocusMinutes, @JsonKey(name: 'sessions_by_grade')  Map<String, int> sessionsByGrade, @JsonKey(name: 'todos_total')  int todosTotal, @JsonKey(name: 'todos_completed')  int todosCompleted, @JsonKey(name: 'todos_completed_on_due_day')  int todosCompletedOnDueDay, @JsonKey(name: 'non_todo_completed')  int nonTodoCompleted, @JsonKey(name: 'tasks_completed')  int tasksCompleted, @JsonKey(name: 'tasks_total')  int tasksTotal, @JsonKey(name: 'schedules_created')  int schedulesCreated, @JsonKey(name: 'schedules_total_minutes')  int schedulesTotalMinutes, @JsonKey(name: 'category_distribution')  Map<String, int> categoryDistribution, @JsonKey(name: 'streak_days')  int streakDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiReportInputData() when $default != null:
return $default(_that.focusSessions,_that.avgFocusRatio,_that.plannedMinutes,_that.actualFocusMinutes,_that.sessionsByGrade,_that.todosTotal,_that.todosCompleted,_that.todosCompletedOnDueDay,_that.nonTodoCompleted,_that.tasksCompleted,_that.tasksTotal,_that.schedulesCreated,_that.schedulesTotalMinutes,_that.categoryDistribution,_that.streakDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'focus_sessions')  int focusSessions, @JsonKey(name: 'avg_focus_ratio')  double avgFocusRatio, @JsonKey(name: 'planned_minutes')  int plannedMinutes, @JsonKey(name: 'actual_focus_minutes')  int actualFocusMinutes, @JsonKey(name: 'sessions_by_grade')  Map<String, int> sessionsByGrade, @JsonKey(name: 'todos_total')  int todosTotal, @JsonKey(name: 'todos_completed')  int todosCompleted, @JsonKey(name: 'todos_completed_on_due_day')  int todosCompletedOnDueDay, @JsonKey(name: 'non_todo_completed')  int nonTodoCompleted, @JsonKey(name: 'tasks_completed')  int tasksCompleted, @JsonKey(name: 'tasks_total')  int tasksTotal, @JsonKey(name: 'schedules_created')  int schedulesCreated, @JsonKey(name: 'schedules_total_minutes')  int schedulesTotalMinutes, @JsonKey(name: 'category_distribution')  Map<String, int> categoryDistribution, @JsonKey(name: 'streak_days')  int streakDays)  $default,) {final _that = this;
switch (_that) {
case _AiReportInputData():
return $default(_that.focusSessions,_that.avgFocusRatio,_that.plannedMinutes,_that.actualFocusMinutes,_that.sessionsByGrade,_that.todosTotal,_that.todosCompleted,_that.todosCompletedOnDueDay,_that.nonTodoCompleted,_that.tasksCompleted,_that.tasksTotal,_that.schedulesCreated,_that.schedulesTotalMinutes,_that.categoryDistribution,_that.streakDays);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'focus_sessions')  int focusSessions, @JsonKey(name: 'avg_focus_ratio')  double avgFocusRatio, @JsonKey(name: 'planned_minutes')  int plannedMinutes, @JsonKey(name: 'actual_focus_minutes')  int actualFocusMinutes, @JsonKey(name: 'sessions_by_grade')  Map<String, int> sessionsByGrade, @JsonKey(name: 'todos_total')  int todosTotal, @JsonKey(name: 'todos_completed')  int todosCompleted, @JsonKey(name: 'todos_completed_on_due_day')  int todosCompletedOnDueDay, @JsonKey(name: 'non_todo_completed')  int nonTodoCompleted, @JsonKey(name: 'tasks_completed')  int tasksCompleted, @JsonKey(name: 'tasks_total')  int tasksTotal, @JsonKey(name: 'schedules_created')  int schedulesCreated, @JsonKey(name: 'schedules_total_minutes')  int schedulesTotalMinutes, @JsonKey(name: 'category_distribution')  Map<String, int> categoryDistribution, @JsonKey(name: 'streak_days')  int streakDays)?  $default,) {final _that = this;
switch (_that) {
case _AiReportInputData() when $default != null:
return $default(_that.focusSessions,_that.avgFocusRatio,_that.plannedMinutes,_that.actualFocusMinutes,_that.sessionsByGrade,_that.todosTotal,_that.todosCompleted,_that.todosCompletedOnDueDay,_that.nonTodoCompleted,_that.tasksCompleted,_that.tasksTotal,_that.schedulesCreated,_that.schedulesTotalMinutes,_that.categoryDistribution,_that.streakDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiReportInputData implements AiReportInputData {
  const _AiReportInputData({@JsonKey(name: 'focus_sessions') required this.focusSessions, @JsonKey(name: 'avg_focus_ratio') required this.avgFocusRatio, @JsonKey(name: 'planned_minutes') this.plannedMinutes = 0, @JsonKey(name: 'actual_focus_minutes') this.actualFocusMinutes = 0, @JsonKey(name: 'sessions_by_grade') final  Map<String, int> sessionsByGrade = const <String, int>{}, @JsonKey(name: 'todos_total') this.todosTotal = 0, @JsonKey(name: 'todos_completed') this.todosCompleted = 0, @JsonKey(name: 'todos_completed_on_due_day') this.todosCompletedOnDueDay = 0, @JsonKey(name: 'non_todo_completed') this.nonTodoCompleted = 0, @JsonKey(name: 'tasks_completed') required this.tasksCompleted, @JsonKey(name: 'tasks_total') required this.tasksTotal, @JsonKey(name: 'schedules_created') this.schedulesCreated = 0, @JsonKey(name: 'schedules_total_minutes') this.schedulesTotalMinutes = 0, @JsonKey(name: 'category_distribution') final  Map<String, int> categoryDistribution = const <String, int>{}, @JsonKey(name: 'streak_days') required this.streakDays}): _sessionsByGrade = sessionsByGrade,_categoryDistribution = categoryDistribution;
  factory _AiReportInputData.fromJson(Map<String, dynamic> json) => _$AiReportInputDataFromJson(json);

// 이행 강도 (execution intensity)
@override@JsonKey(name: 'focus_sessions') final  int focusSessions;
@override@JsonKey(name: 'avg_focus_ratio') final  double avgFocusRatio;
@override@JsonKey(name: 'planned_minutes') final  int plannedMinutes;
@override@JsonKey(name: 'actual_focus_minutes') final  int actualFocusMinutes;
 final  Map<String, int> _sessionsByGrade;
@override@JsonKey(name: 'sessions_by_grade') Map<String, int> get sessionsByGrade {
  if (_sessionsByGrade is EqualUnmodifiableMapView) return _sessionsByGrade;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sessionsByGrade);
}

// 체크 강도 (completion intensity)
@override@JsonKey(name: 'todos_total') final  int todosTotal;
@override@JsonKey(name: 'todos_completed') final  int todosCompleted;
@override@JsonKey(name: 'todos_completed_on_due_day') final  int todosCompletedOnDueDay;
@override@JsonKey(name: 'non_todo_completed') final  int nonTodoCompleted;
// legacy aliases retained for compatibility
@override@JsonKey(name: 'tasks_completed') final  int tasksCompleted;
@override@JsonKey(name: 'tasks_total') final  int tasksTotal;
// 작성 강도 (authoring intensity)
@override@JsonKey(name: 'schedules_created') final  int schedulesCreated;
@override@JsonKey(name: 'schedules_total_minutes') final  int schedulesTotalMinutes;
 final  Map<String, int> _categoryDistribution;
@override@JsonKey(name: 'category_distribution') Map<String, int> get categoryDistribution {
  if (_categoryDistribution is EqualUnmodifiableMapView) return _categoryDistribution;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categoryDistribution);
}

// streak (carry-over)
@override@JsonKey(name: 'streak_days') final  int streakDays;

/// Create a copy of AiReportInputData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiReportInputDataCopyWith<_AiReportInputData> get copyWith => __$AiReportInputDataCopyWithImpl<_AiReportInputData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiReportInputDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiReportInputData&&(identical(other.focusSessions, focusSessions) || other.focusSessions == focusSessions)&&(identical(other.avgFocusRatio, avgFocusRatio) || other.avgFocusRatio == avgFocusRatio)&&(identical(other.plannedMinutes, plannedMinutes) || other.plannedMinutes == plannedMinutes)&&(identical(other.actualFocusMinutes, actualFocusMinutes) || other.actualFocusMinutes == actualFocusMinutes)&&const DeepCollectionEquality().equals(other._sessionsByGrade, _sessionsByGrade)&&(identical(other.todosTotal, todosTotal) || other.todosTotal == todosTotal)&&(identical(other.todosCompleted, todosCompleted) || other.todosCompleted == todosCompleted)&&(identical(other.todosCompletedOnDueDay, todosCompletedOnDueDay) || other.todosCompletedOnDueDay == todosCompletedOnDueDay)&&(identical(other.nonTodoCompleted, nonTodoCompleted) || other.nonTodoCompleted == nonTodoCompleted)&&(identical(other.tasksCompleted, tasksCompleted) || other.tasksCompleted == tasksCompleted)&&(identical(other.tasksTotal, tasksTotal) || other.tasksTotal == tasksTotal)&&(identical(other.schedulesCreated, schedulesCreated) || other.schedulesCreated == schedulesCreated)&&(identical(other.schedulesTotalMinutes, schedulesTotalMinutes) || other.schedulesTotalMinutes == schedulesTotalMinutes)&&const DeepCollectionEquality().equals(other._categoryDistribution, _categoryDistribution)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,focusSessions,avgFocusRatio,plannedMinutes,actualFocusMinutes,const DeepCollectionEquality().hash(_sessionsByGrade),todosTotal,todosCompleted,todosCompletedOnDueDay,nonTodoCompleted,tasksCompleted,tasksTotal,schedulesCreated,schedulesTotalMinutes,const DeepCollectionEquality().hash(_categoryDistribution),streakDays);

@override
String toString() {
  return 'AiReportInputData(focusSessions: $focusSessions, avgFocusRatio: $avgFocusRatio, plannedMinutes: $plannedMinutes, actualFocusMinutes: $actualFocusMinutes, sessionsByGrade: $sessionsByGrade, todosTotal: $todosTotal, todosCompleted: $todosCompleted, todosCompletedOnDueDay: $todosCompletedOnDueDay, nonTodoCompleted: $nonTodoCompleted, tasksCompleted: $tasksCompleted, tasksTotal: $tasksTotal, schedulesCreated: $schedulesCreated, schedulesTotalMinutes: $schedulesTotalMinutes, categoryDistribution: $categoryDistribution, streakDays: $streakDays)';
}


}

/// @nodoc
abstract mixin class _$AiReportInputDataCopyWith<$Res> implements $AiReportInputDataCopyWith<$Res> {
  factory _$AiReportInputDataCopyWith(_AiReportInputData value, $Res Function(_AiReportInputData) _then) = __$AiReportInputDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'focus_sessions') int focusSessions,@JsonKey(name: 'avg_focus_ratio') double avgFocusRatio,@JsonKey(name: 'planned_minutes') int plannedMinutes,@JsonKey(name: 'actual_focus_minutes') int actualFocusMinutes,@JsonKey(name: 'sessions_by_grade') Map<String, int> sessionsByGrade,@JsonKey(name: 'todos_total') int todosTotal,@JsonKey(name: 'todos_completed') int todosCompleted,@JsonKey(name: 'todos_completed_on_due_day') int todosCompletedOnDueDay,@JsonKey(name: 'non_todo_completed') int nonTodoCompleted,@JsonKey(name: 'tasks_completed') int tasksCompleted,@JsonKey(name: 'tasks_total') int tasksTotal,@JsonKey(name: 'schedules_created') int schedulesCreated,@JsonKey(name: 'schedules_total_minutes') int schedulesTotalMinutes,@JsonKey(name: 'category_distribution') Map<String, int> categoryDistribution,@JsonKey(name: 'streak_days') int streakDays
});




}
/// @nodoc
class __$AiReportInputDataCopyWithImpl<$Res>
    implements _$AiReportInputDataCopyWith<$Res> {
  __$AiReportInputDataCopyWithImpl(this._self, this._then);

  final _AiReportInputData _self;
  final $Res Function(_AiReportInputData) _then;

/// Create a copy of AiReportInputData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? focusSessions = null,Object? avgFocusRatio = null,Object? plannedMinutes = null,Object? actualFocusMinutes = null,Object? sessionsByGrade = null,Object? todosTotal = null,Object? todosCompleted = null,Object? todosCompletedOnDueDay = null,Object? nonTodoCompleted = null,Object? tasksCompleted = null,Object? tasksTotal = null,Object? schedulesCreated = null,Object? schedulesTotalMinutes = null,Object? categoryDistribution = null,Object? streakDays = null,}) {
  return _then(_AiReportInputData(
focusSessions: null == focusSessions ? _self.focusSessions : focusSessions // ignore: cast_nullable_to_non_nullable
as int,avgFocusRatio: null == avgFocusRatio ? _self.avgFocusRatio : avgFocusRatio // ignore: cast_nullable_to_non_nullable
as double,plannedMinutes: null == plannedMinutes ? _self.plannedMinutes : plannedMinutes // ignore: cast_nullable_to_non_nullable
as int,actualFocusMinutes: null == actualFocusMinutes ? _self.actualFocusMinutes : actualFocusMinutes // ignore: cast_nullable_to_non_nullable
as int,sessionsByGrade: null == sessionsByGrade ? _self._sessionsByGrade : sessionsByGrade // ignore: cast_nullable_to_non_nullable
as Map<String, int>,todosTotal: null == todosTotal ? _self.todosTotal : todosTotal // ignore: cast_nullable_to_non_nullable
as int,todosCompleted: null == todosCompleted ? _self.todosCompleted : todosCompleted // ignore: cast_nullable_to_non_nullable
as int,todosCompletedOnDueDay: null == todosCompletedOnDueDay ? _self.todosCompletedOnDueDay : todosCompletedOnDueDay // ignore: cast_nullable_to_non_nullable
as int,nonTodoCompleted: null == nonTodoCompleted ? _self.nonTodoCompleted : nonTodoCompleted // ignore: cast_nullable_to_non_nullable
as int,tasksCompleted: null == tasksCompleted ? _self.tasksCompleted : tasksCompleted // ignore: cast_nullable_to_non_nullable
as int,tasksTotal: null == tasksTotal ? _self.tasksTotal : tasksTotal // ignore: cast_nullable_to_non_nullable
as int,schedulesCreated: null == schedulesCreated ? _self.schedulesCreated : schedulesCreated // ignore: cast_nullable_to_non_nullable
as int,schedulesTotalMinutes: null == schedulesTotalMinutes ? _self.schedulesTotalMinutes : schedulesTotalMinutes // ignore: cast_nullable_to_non_nullable
as int,categoryDistribution: null == categoryDistribution ? _self._categoryDistribution : categoryDistribution // ignore: cast_nullable_to_non_nullable
as Map<String, int>,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AiReportRequest {

@JsonKey(name: 'user_id') String get userId; ReportPeriod get period;@JsonKey(name: 'period_start') DateTime get periodStart;@JsonKey(name: 'period_end') DateTime get periodEnd; AiReportInputData get data;@JsonKey(name: 'user_locale') String get userLocale;
/// Create a copy of AiReportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiReportRequestCopyWith<AiReportRequest> get copyWith => _$AiReportRequestCopyWithImpl<AiReportRequest>(this as AiReportRequest, _$identity);

  /// Serializes this AiReportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiReportRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.period, period) || other.period == period)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.data, data) || other.data == data)&&(identical(other.userLocale, userLocale) || other.userLocale == userLocale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,period,periodStart,periodEnd,data,userLocale);

@override
String toString() {
  return 'AiReportRequest(userId: $userId, period: $period, periodStart: $periodStart, periodEnd: $periodEnd, data: $data, userLocale: $userLocale)';
}


}

/// @nodoc
abstract mixin class $AiReportRequestCopyWith<$Res>  {
  factory $AiReportRequestCopyWith(AiReportRequest value, $Res Function(AiReportRequest) _then) = _$AiReportRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, ReportPeriod period,@JsonKey(name: 'period_start') DateTime periodStart,@JsonKey(name: 'period_end') DateTime periodEnd, AiReportInputData data,@JsonKey(name: 'user_locale') String userLocale
});


$AiReportInputDataCopyWith<$Res> get data;

}
/// @nodoc
class _$AiReportRequestCopyWithImpl<$Res>
    implements $AiReportRequestCopyWith<$Res> {
  _$AiReportRequestCopyWithImpl(this._self, this._then);

  final AiReportRequest _self;
  final $Res Function(AiReportRequest) _then;

/// Create a copy of AiReportRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? period = null,Object? periodStart = null,Object? periodEnd = null,Object? data = null,Object? userLocale = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReportPeriod,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AiReportInputData,userLocale: null == userLocale ? _self.userLocale : userLocale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AiReportRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiReportInputDataCopyWith<$Res> get data {
  
  return $AiReportInputDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [AiReportRequest].
extension AiReportRequestPatterns on AiReportRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiReportRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiReportRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiReportRequest value)  $default,){
final _that = this;
switch (_that) {
case _AiReportRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiReportRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AiReportRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  ReportPeriod period, @JsonKey(name: 'period_start')  DateTime periodStart, @JsonKey(name: 'period_end')  DateTime periodEnd,  AiReportInputData data, @JsonKey(name: 'user_locale')  String userLocale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiReportRequest() when $default != null:
return $default(_that.userId,_that.period,_that.periodStart,_that.periodEnd,_that.data,_that.userLocale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  ReportPeriod period, @JsonKey(name: 'period_start')  DateTime periodStart, @JsonKey(name: 'period_end')  DateTime periodEnd,  AiReportInputData data, @JsonKey(name: 'user_locale')  String userLocale)  $default,) {final _that = this;
switch (_that) {
case _AiReportRequest():
return $default(_that.userId,_that.period,_that.periodStart,_that.periodEnd,_that.data,_that.userLocale);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  ReportPeriod period, @JsonKey(name: 'period_start')  DateTime periodStart, @JsonKey(name: 'period_end')  DateTime periodEnd,  AiReportInputData data, @JsonKey(name: 'user_locale')  String userLocale)?  $default,) {final _that = this;
switch (_that) {
case _AiReportRequest() when $default != null:
return $default(_that.userId,_that.period,_that.periodStart,_that.periodEnd,_that.data,_that.userLocale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiReportRequest implements AiReportRequest {
  const _AiReportRequest({@JsonKey(name: 'user_id') required this.userId, required this.period, @JsonKey(name: 'period_start') required this.periodStart, @JsonKey(name: 'period_end') required this.periodEnd, required this.data, @JsonKey(name: 'user_locale') required this.userLocale});
  factory _AiReportRequest.fromJson(Map<String, dynamic> json) => _$AiReportRequestFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override final  ReportPeriod period;
@override@JsonKey(name: 'period_start') final  DateTime periodStart;
@override@JsonKey(name: 'period_end') final  DateTime periodEnd;
@override final  AiReportInputData data;
@override@JsonKey(name: 'user_locale') final  String userLocale;

/// Create a copy of AiReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiReportRequestCopyWith<_AiReportRequest> get copyWith => __$AiReportRequestCopyWithImpl<_AiReportRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiReportRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiReportRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.period, period) || other.period == period)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.data, data) || other.data == data)&&(identical(other.userLocale, userLocale) || other.userLocale == userLocale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,period,periodStart,periodEnd,data,userLocale);

@override
String toString() {
  return 'AiReportRequest(userId: $userId, period: $period, periodStart: $periodStart, periodEnd: $periodEnd, data: $data, userLocale: $userLocale)';
}


}

/// @nodoc
abstract mixin class _$AiReportRequestCopyWith<$Res> implements $AiReportRequestCopyWith<$Res> {
  factory _$AiReportRequestCopyWith(_AiReportRequest value, $Res Function(_AiReportRequest) _then) = __$AiReportRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, ReportPeriod period,@JsonKey(name: 'period_start') DateTime periodStart,@JsonKey(name: 'period_end') DateTime periodEnd, AiReportInputData data,@JsonKey(name: 'user_locale') String userLocale
});


@override $AiReportInputDataCopyWith<$Res> get data;

}
/// @nodoc
class __$AiReportRequestCopyWithImpl<$Res>
    implements _$AiReportRequestCopyWith<$Res> {
  __$AiReportRequestCopyWithImpl(this._self, this._then);

  final _AiReportRequest _self;
  final $Res Function(_AiReportRequest) _then;

/// Create a copy of AiReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? period = null,Object? periodStart = null,Object? periodEnd = null,Object? data = null,Object? userLocale = null,}) {
  return _then(_AiReportRequest(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReportPeriod,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AiReportInputData,userLocale: null == userLocale ? _self.userLocale : userLocale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AiReportRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiReportInputDataCopyWith<$Res> get data {
  
  return $AiReportInputDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$AiReportResponse {

 String get summary; List<String> get insights; List<String> get suggestions; String get encouragement; AiReportSource get source;
/// Create a copy of AiReportResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiReportResponseCopyWith<AiReportResponse> get copyWith => _$AiReportResponseCopyWithImpl<AiReportResponse>(this as AiReportResponse, _$identity);

  /// Serializes this AiReportResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiReportResponse&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.insights, insights)&&const DeepCollectionEquality().equals(other.suggestions, suggestions)&&(identical(other.encouragement, encouragement) || other.encouragement == encouragement)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,summary,const DeepCollectionEquality().hash(insights),const DeepCollectionEquality().hash(suggestions),encouragement,source);

@override
String toString() {
  return 'AiReportResponse(summary: $summary, insights: $insights, suggestions: $suggestions, encouragement: $encouragement, source: $source)';
}


}

/// @nodoc
abstract mixin class $AiReportResponseCopyWith<$Res>  {
  factory $AiReportResponseCopyWith(AiReportResponse value, $Res Function(AiReportResponse) _then) = _$AiReportResponseCopyWithImpl;
@useResult
$Res call({
 String summary, List<String> insights, List<String> suggestions, String encouragement, AiReportSource source
});




}
/// @nodoc
class _$AiReportResponseCopyWithImpl<$Res>
    implements $AiReportResponseCopyWith<$Res> {
  _$AiReportResponseCopyWithImpl(this._self, this._then);

  final AiReportResponse _self;
  final $Res Function(AiReportResponse) _then;

/// Create a copy of AiReportResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? insights = null,Object? suggestions = null,Object? encouragement = null,Object? source = null,}) {
  return _then(_self.copyWith(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,insights: null == insights ? _self.insights : insights // ignore: cast_nullable_to_non_nullable
as List<String>,suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<String>,encouragement: null == encouragement ? _self.encouragement : encouragement // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AiReportSource,
  ));
}

}


/// Adds pattern-matching-related methods to [AiReportResponse].
extension AiReportResponsePatterns on AiReportResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiReportResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiReportResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiReportResponse value)  $default,){
final _that = this;
switch (_that) {
case _AiReportResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiReportResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AiReportResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String summary,  List<String> insights,  List<String> suggestions,  String encouragement,  AiReportSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiReportResponse() when $default != null:
return $default(_that.summary,_that.insights,_that.suggestions,_that.encouragement,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String summary,  List<String> insights,  List<String> suggestions,  String encouragement,  AiReportSource source)  $default,) {final _that = this;
switch (_that) {
case _AiReportResponse():
return $default(_that.summary,_that.insights,_that.suggestions,_that.encouragement,_that.source);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String summary,  List<String> insights,  List<String> suggestions,  String encouragement,  AiReportSource source)?  $default,) {final _that = this;
switch (_that) {
case _AiReportResponse() when $default != null:
return $default(_that.summary,_that.insights,_that.suggestions,_that.encouragement,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiReportResponse implements AiReportResponse {
  const _AiReportResponse({required this.summary, required final  List<String> insights, required final  List<String> suggestions, required this.encouragement, required this.source}): _insights = insights,_suggestions = suggestions;
  factory _AiReportResponse.fromJson(Map<String, dynamic> json) => _$AiReportResponseFromJson(json);

@override final  String summary;
 final  List<String> _insights;
@override List<String> get insights {
  if (_insights is EqualUnmodifiableListView) return _insights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_insights);
}

 final  List<String> _suggestions;
@override List<String> get suggestions {
  if (_suggestions is EqualUnmodifiableListView) return _suggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestions);
}

@override final  String encouragement;
@override final  AiReportSource source;

/// Create a copy of AiReportResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiReportResponseCopyWith<_AiReportResponse> get copyWith => __$AiReportResponseCopyWithImpl<_AiReportResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiReportResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiReportResponse&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._insights, _insights)&&const DeepCollectionEquality().equals(other._suggestions, _suggestions)&&(identical(other.encouragement, encouragement) || other.encouragement == encouragement)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,summary,const DeepCollectionEquality().hash(_insights),const DeepCollectionEquality().hash(_suggestions),encouragement,source);

@override
String toString() {
  return 'AiReportResponse(summary: $summary, insights: $insights, suggestions: $suggestions, encouragement: $encouragement, source: $source)';
}


}

/// @nodoc
abstract mixin class _$AiReportResponseCopyWith<$Res> implements $AiReportResponseCopyWith<$Res> {
  factory _$AiReportResponseCopyWith(_AiReportResponse value, $Res Function(_AiReportResponse) _then) = __$AiReportResponseCopyWithImpl;
@override @useResult
$Res call({
 String summary, List<String> insights, List<String> suggestions, String encouragement, AiReportSource source
});




}
/// @nodoc
class __$AiReportResponseCopyWithImpl<$Res>
    implements _$AiReportResponseCopyWith<$Res> {
  __$AiReportResponseCopyWithImpl(this._self, this._then);

  final _AiReportResponse _self;
  final $Res Function(_AiReportResponse) _then;

/// Create a copy of AiReportResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? insights = null,Object? suggestions = null,Object? encouragement = null,Object? source = null,}) {
  return _then(_AiReportResponse(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,insights: null == insights ? _self._insights : insights // ignore: cast_nullable_to_non_nullable
as List<String>,suggestions: null == suggestions ? _self._suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<String>,encouragement: null == encouragement ? _self.encouragement : encouragement // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AiReportSource,
  ));
}


}

// dart format on
