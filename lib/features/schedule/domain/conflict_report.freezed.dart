// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conflict_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConflictReport {

 ConflictKind get kind; List<int> get indices; ConflictSeverity get severity; String get message;@JsonKey(name: 'existing_id') int? get existingId;
/// Create a copy of ConflictReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConflictReportCopyWith<ConflictReport> get copyWith => _$ConflictReportCopyWithImpl<ConflictReport>(this as ConflictReport, _$identity);

  /// Serializes this ConflictReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConflictReport&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.indices, indices)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.message, message) || other.message == message)&&(identical(other.existingId, existingId) || other.existingId == existingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,const DeepCollectionEquality().hash(indices),severity,message,existingId);

@override
String toString() {
  return 'ConflictReport(kind: $kind, indices: $indices, severity: $severity, message: $message, existingId: $existingId)';
}


}

/// @nodoc
abstract mixin class $ConflictReportCopyWith<$Res>  {
  factory $ConflictReportCopyWith(ConflictReport value, $Res Function(ConflictReport) _then) = _$ConflictReportCopyWithImpl;
@useResult
$Res call({
 ConflictKind kind, List<int> indices, ConflictSeverity severity, String message,@JsonKey(name: 'existing_id') int? existingId
});




}
/// @nodoc
class _$ConflictReportCopyWithImpl<$Res>
    implements $ConflictReportCopyWith<$Res> {
  _$ConflictReportCopyWithImpl(this._self, this._then);

  final ConflictReport _self;
  final $Res Function(ConflictReport) _then;

/// Create a copy of ConflictReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? indices = null,Object? severity = null,Object? message = null,Object? existingId = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConflictKind,indices: null == indices ? _self.indices : indices // ignore: cast_nullable_to_non_nullable
as List<int>,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as ConflictSeverity,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,existingId: freezed == existingId ? _self.existingId : existingId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConflictReport].
extension ConflictReportPatterns on ConflictReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConflictReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConflictReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConflictReport value)  $default,){
final _that = this;
switch (_that) {
case _ConflictReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConflictReport value)?  $default,){
final _that = this;
switch (_that) {
case _ConflictReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConflictKind kind,  List<int> indices,  ConflictSeverity severity,  String message, @JsonKey(name: 'existing_id')  int? existingId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConflictReport() when $default != null:
return $default(_that.kind,_that.indices,_that.severity,_that.message,_that.existingId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConflictKind kind,  List<int> indices,  ConflictSeverity severity,  String message, @JsonKey(name: 'existing_id')  int? existingId)  $default,) {final _that = this;
switch (_that) {
case _ConflictReport():
return $default(_that.kind,_that.indices,_that.severity,_that.message,_that.existingId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConflictKind kind,  List<int> indices,  ConflictSeverity severity,  String message, @JsonKey(name: 'existing_id')  int? existingId)?  $default,) {final _that = this;
switch (_that) {
case _ConflictReport() when $default != null:
return $default(_that.kind,_that.indices,_that.severity,_that.message,_that.existingId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConflictReport implements ConflictReport {
  const _ConflictReport({required this.kind, required final  List<int> indices, required this.severity, required this.message, @JsonKey(name: 'existing_id') this.existingId}): _indices = indices;
  factory _ConflictReport.fromJson(Map<String, dynamic> json) => _$ConflictReportFromJson(json);

@override final  ConflictKind kind;
 final  List<int> _indices;
@override List<int> get indices {
  if (_indices is EqualUnmodifiableListView) return _indices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_indices);
}

@override final  ConflictSeverity severity;
@override final  String message;
@override@JsonKey(name: 'existing_id') final  int? existingId;

/// Create a copy of ConflictReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConflictReportCopyWith<_ConflictReport> get copyWith => __$ConflictReportCopyWithImpl<_ConflictReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConflictReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConflictReport&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other._indices, _indices)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.message, message) || other.message == message)&&(identical(other.existingId, existingId) || other.existingId == existingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,const DeepCollectionEquality().hash(_indices),severity,message,existingId);

@override
String toString() {
  return 'ConflictReport(kind: $kind, indices: $indices, severity: $severity, message: $message, existingId: $existingId)';
}


}

/// @nodoc
abstract mixin class _$ConflictReportCopyWith<$Res> implements $ConflictReportCopyWith<$Res> {
  factory _$ConflictReportCopyWith(_ConflictReport value, $Res Function(_ConflictReport) _then) = __$ConflictReportCopyWithImpl;
@override @useResult
$Res call({
 ConflictKind kind, List<int> indices, ConflictSeverity severity, String message,@JsonKey(name: 'existing_id') int? existingId
});




}
/// @nodoc
class __$ConflictReportCopyWithImpl<$Res>
    implements _$ConflictReportCopyWith<$Res> {
  __$ConflictReportCopyWithImpl(this._self, this._then);

  final _ConflictReport _self;
  final $Res Function(_ConflictReport) _then;

/// Create a copy of ConflictReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? indices = null,Object? severity = null,Object? message = null,Object? existingId = freezed,}) {
  return _then(_ConflictReport(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConflictKind,indices: null == indices ? _self._indices : indices // ignore: cast_nullable_to_non_nullable
as List<int>,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as ConflictSeverity,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,existingId: freezed == existingId ? _self.existingId : existingId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
