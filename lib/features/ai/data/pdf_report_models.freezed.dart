// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PdfReportMeta {

@JsonKey(name: 'pet_name') String? get petName;@JsonKey(name: 'user_name') String? get userName;@JsonKey(name: 'period_label') String? get periodLabel;
/// Create a copy of PdfReportMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfReportMetaCopyWith<PdfReportMeta> get copyWith => _$PdfReportMetaCopyWithImpl<PdfReportMeta>(this as PdfReportMeta, _$identity);

  /// Serializes this PdfReportMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfReportMeta&&(identical(other.petName, petName) || other.petName == petName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.periodLabel, periodLabel) || other.periodLabel == periodLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,petName,userName,periodLabel);

@override
String toString() {
  return 'PdfReportMeta(petName: $petName, userName: $userName, periodLabel: $periodLabel)';
}


}

/// @nodoc
abstract mixin class $PdfReportMetaCopyWith<$Res>  {
  factory $PdfReportMetaCopyWith(PdfReportMeta value, $Res Function(PdfReportMeta) _then) = _$PdfReportMetaCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'pet_name') String? petName,@JsonKey(name: 'user_name') String? userName,@JsonKey(name: 'period_label') String? periodLabel
});




}
/// @nodoc
class _$PdfReportMetaCopyWithImpl<$Res>
    implements $PdfReportMetaCopyWith<$Res> {
  _$PdfReportMetaCopyWithImpl(this._self, this._then);

  final PdfReportMeta _self;
  final $Res Function(PdfReportMeta) _then;

/// Create a copy of PdfReportMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? petName = freezed,Object? userName = freezed,Object? periodLabel = freezed,}) {
  return _then(_self.copyWith(
petName: freezed == petName ? _self.petName : petName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,periodLabel: freezed == periodLabel ? _self.periodLabel : periodLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfReportMeta].
extension PdfReportMetaPatterns on PdfReportMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfReportMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfReportMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfReportMeta value)  $default,){
final _that = this;
switch (_that) {
case _PdfReportMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfReportMeta value)?  $default,){
final _that = this;
switch (_that) {
case _PdfReportMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'pet_name')  String? petName, @JsonKey(name: 'user_name')  String? userName, @JsonKey(name: 'period_label')  String? periodLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfReportMeta() when $default != null:
return $default(_that.petName,_that.userName,_that.periodLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'pet_name')  String? petName, @JsonKey(name: 'user_name')  String? userName, @JsonKey(name: 'period_label')  String? periodLabel)  $default,) {final _that = this;
switch (_that) {
case _PdfReportMeta():
return $default(_that.petName,_that.userName,_that.periodLabel);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'pet_name')  String? petName, @JsonKey(name: 'user_name')  String? userName, @JsonKey(name: 'period_label')  String? periodLabel)?  $default,) {final _that = this;
switch (_that) {
case _PdfReportMeta() when $default != null:
return $default(_that.petName,_that.userName,_that.periodLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PdfReportMeta implements PdfReportMeta {
  const _PdfReportMeta({@JsonKey(name: 'pet_name') this.petName, @JsonKey(name: 'user_name') this.userName, @JsonKey(name: 'period_label') this.periodLabel});
  factory _PdfReportMeta.fromJson(Map<String, dynamic> json) => _$PdfReportMetaFromJson(json);

@override@JsonKey(name: 'pet_name') final  String? petName;
@override@JsonKey(name: 'user_name') final  String? userName;
@override@JsonKey(name: 'period_label') final  String? periodLabel;

/// Create a copy of PdfReportMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfReportMetaCopyWith<_PdfReportMeta> get copyWith => __$PdfReportMetaCopyWithImpl<_PdfReportMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfReportMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfReportMeta&&(identical(other.petName, petName) || other.petName == petName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.periodLabel, periodLabel) || other.periodLabel == periodLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,petName,userName,periodLabel);

@override
String toString() {
  return 'PdfReportMeta(petName: $petName, userName: $userName, periodLabel: $periodLabel)';
}


}

/// @nodoc
abstract mixin class _$PdfReportMetaCopyWith<$Res> implements $PdfReportMetaCopyWith<$Res> {
  factory _$PdfReportMetaCopyWith(_PdfReportMeta value, $Res Function(_PdfReportMeta) _then) = __$PdfReportMetaCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'pet_name') String? petName,@JsonKey(name: 'user_name') String? userName,@JsonKey(name: 'period_label') String? periodLabel
});




}
/// @nodoc
class __$PdfReportMetaCopyWithImpl<$Res>
    implements _$PdfReportMetaCopyWith<$Res> {
  __$PdfReportMetaCopyWithImpl(this._self, this._then);

  final _PdfReportMeta _self;
  final $Res Function(_PdfReportMeta) _then;

/// Create a copy of PdfReportMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? petName = freezed,Object? userName = freezed,Object? periodLabel = freezed,}) {
  return _then(_PdfReportMeta(
petName: freezed == petName ? _self.petName : petName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,periodLabel: freezed == periodLabel ? _self.periodLabel : periodLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PdfReportRequest {

@JsonKey(name: 'user_id') String get userId; ReportPeriod get period; AiReportResponse get report; PdfReportMeta? get meta;
/// Create a copy of PdfReportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfReportRequestCopyWith<PdfReportRequest> get copyWith => _$PdfReportRequestCopyWithImpl<PdfReportRequest>(this as PdfReportRequest, _$identity);

  /// Serializes this PdfReportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfReportRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.period, period) || other.period == period)&&(identical(other.report, report) || other.report == report)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,period,report,meta);

@override
String toString() {
  return 'PdfReportRequest(userId: $userId, period: $period, report: $report, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $PdfReportRequestCopyWith<$Res>  {
  factory $PdfReportRequestCopyWith(PdfReportRequest value, $Res Function(PdfReportRequest) _then) = _$PdfReportRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, ReportPeriod period, AiReportResponse report, PdfReportMeta? meta
});


$AiReportResponseCopyWith<$Res> get report;$PdfReportMetaCopyWith<$Res>? get meta;

}
/// @nodoc
class _$PdfReportRequestCopyWithImpl<$Res>
    implements $PdfReportRequestCopyWith<$Res> {
  _$PdfReportRequestCopyWithImpl(this._self, this._then);

  final PdfReportRequest _self;
  final $Res Function(PdfReportRequest) _then;

/// Create a copy of PdfReportRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? period = null,Object? report = null,Object? meta = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReportPeriod,report: null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as AiReportResponse,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as PdfReportMeta?,
  ));
}
/// Create a copy of PdfReportRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiReportResponseCopyWith<$Res> get report {
  
  return $AiReportResponseCopyWith<$Res>(_self.report, (value) {
    return _then(_self.copyWith(report: value));
  });
}/// Create a copy of PdfReportRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfReportMetaCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $PdfReportMetaCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [PdfReportRequest].
extension PdfReportRequestPatterns on PdfReportRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfReportRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfReportRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfReportRequest value)  $default,){
final _that = this;
switch (_that) {
case _PdfReportRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfReportRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PdfReportRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  ReportPeriod period,  AiReportResponse report,  PdfReportMeta? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfReportRequest() when $default != null:
return $default(_that.userId,_that.period,_that.report,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  ReportPeriod period,  AiReportResponse report,  PdfReportMeta? meta)  $default,) {final _that = this;
switch (_that) {
case _PdfReportRequest():
return $default(_that.userId,_that.period,_that.report,_that.meta);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  ReportPeriod period,  AiReportResponse report,  PdfReportMeta? meta)?  $default,) {final _that = this;
switch (_that) {
case _PdfReportRequest() when $default != null:
return $default(_that.userId,_that.period,_that.report,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PdfReportRequest implements PdfReportRequest {
  const _PdfReportRequest({@JsonKey(name: 'user_id') required this.userId, required this.period, required this.report, this.meta});
  factory _PdfReportRequest.fromJson(Map<String, dynamic> json) => _$PdfReportRequestFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override final  ReportPeriod period;
@override final  AiReportResponse report;
@override final  PdfReportMeta? meta;

/// Create a copy of PdfReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfReportRequestCopyWith<_PdfReportRequest> get copyWith => __$PdfReportRequestCopyWithImpl<_PdfReportRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfReportRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfReportRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.period, period) || other.period == period)&&(identical(other.report, report) || other.report == report)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,period,report,meta);

@override
String toString() {
  return 'PdfReportRequest(userId: $userId, period: $period, report: $report, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$PdfReportRequestCopyWith<$Res> implements $PdfReportRequestCopyWith<$Res> {
  factory _$PdfReportRequestCopyWith(_PdfReportRequest value, $Res Function(_PdfReportRequest) _then) = __$PdfReportRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, ReportPeriod period, AiReportResponse report, PdfReportMeta? meta
});


@override $AiReportResponseCopyWith<$Res> get report;@override $PdfReportMetaCopyWith<$Res>? get meta;

}
/// @nodoc
class __$PdfReportRequestCopyWithImpl<$Res>
    implements _$PdfReportRequestCopyWith<$Res> {
  __$PdfReportRequestCopyWithImpl(this._self, this._then);

  final _PdfReportRequest _self;
  final $Res Function(_PdfReportRequest) _then;

/// Create a copy of PdfReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? period = null,Object? report = null,Object? meta = freezed,}) {
  return _then(_PdfReportRequest(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReportPeriod,report: null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as AiReportResponse,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as PdfReportMeta?,
  ));
}

/// Create a copy of PdfReportRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiReportResponseCopyWith<$Res> get report {
  
  return $AiReportResponseCopyWith<$Res>(_self.report, (value) {
    return _then(_self.copyWith(report: value));
  });
}/// Create a copy of PdfReportRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfReportMetaCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $PdfReportMetaCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

// dart format on
