// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auto_schedule_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AutoScheduleRequest {

 String get text;@JsonKey(name: 'user_locale') String get userLocale;
/// Create a copy of AutoScheduleRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoScheduleRequestCopyWith<AutoScheduleRequest> get copyWith => _$AutoScheduleRequestCopyWithImpl<AutoScheduleRequest>(this as AutoScheduleRequest, _$identity);

  /// Serializes this AutoScheduleRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoScheduleRequest&&(identical(other.text, text) || other.text == text)&&(identical(other.userLocale, userLocale) || other.userLocale == userLocale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,userLocale);

@override
String toString() {
  return 'AutoScheduleRequest(text: $text, userLocale: $userLocale)';
}


}

/// @nodoc
abstract mixin class $AutoScheduleRequestCopyWith<$Res>  {
  factory $AutoScheduleRequestCopyWith(AutoScheduleRequest value, $Res Function(AutoScheduleRequest) _then) = _$AutoScheduleRequestCopyWithImpl;
@useResult
$Res call({
 String text,@JsonKey(name: 'user_locale') String userLocale
});




}
/// @nodoc
class _$AutoScheduleRequestCopyWithImpl<$Res>
    implements $AutoScheduleRequestCopyWith<$Res> {
  _$AutoScheduleRequestCopyWithImpl(this._self, this._then);

  final AutoScheduleRequest _self;
  final $Res Function(AutoScheduleRequest) _then;

/// Create a copy of AutoScheduleRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? userLocale = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,userLocale: null == userLocale ? _self.userLocale : userLocale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AutoScheduleRequest].
extension AutoScheduleRequestPatterns on AutoScheduleRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutoScheduleRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutoScheduleRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutoScheduleRequest value)  $default,){
final _that = this;
switch (_that) {
case _AutoScheduleRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutoScheduleRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AutoScheduleRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text, @JsonKey(name: 'user_locale')  String userLocale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutoScheduleRequest() when $default != null:
return $default(_that.text,_that.userLocale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text, @JsonKey(name: 'user_locale')  String userLocale)  $default,) {final _that = this;
switch (_that) {
case _AutoScheduleRequest():
return $default(_that.text,_that.userLocale);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text, @JsonKey(name: 'user_locale')  String userLocale)?  $default,) {final _that = this;
switch (_that) {
case _AutoScheduleRequest() when $default != null:
return $default(_that.text,_that.userLocale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AutoScheduleRequest implements AutoScheduleRequest {
  const _AutoScheduleRequest({required this.text, @JsonKey(name: 'user_locale') required this.userLocale});
  factory _AutoScheduleRequest.fromJson(Map<String, dynamic> json) => _$AutoScheduleRequestFromJson(json);

@override final  String text;
@override@JsonKey(name: 'user_locale') final  String userLocale;

/// Create a copy of AutoScheduleRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutoScheduleRequestCopyWith<_AutoScheduleRequest> get copyWith => __$AutoScheduleRequestCopyWithImpl<_AutoScheduleRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutoScheduleRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutoScheduleRequest&&(identical(other.text, text) || other.text == text)&&(identical(other.userLocale, userLocale) || other.userLocale == userLocale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,userLocale);

@override
String toString() {
  return 'AutoScheduleRequest(text: $text, userLocale: $userLocale)';
}


}

/// @nodoc
abstract mixin class _$AutoScheduleRequestCopyWith<$Res> implements $AutoScheduleRequestCopyWith<$Res> {
  factory _$AutoScheduleRequestCopyWith(_AutoScheduleRequest value, $Res Function(_AutoScheduleRequest) _then) = __$AutoScheduleRequestCopyWithImpl;
@override @useResult
$Res call({
 String text,@JsonKey(name: 'user_locale') String userLocale
});




}
/// @nodoc
class __$AutoScheduleRequestCopyWithImpl<$Res>
    implements _$AutoScheduleRequestCopyWith<$Res> {
  __$AutoScheduleRequestCopyWithImpl(this._self, this._then);

  final _AutoScheduleRequest _self;
  final $Res Function(_AutoScheduleRequest) _then;

/// Create a copy of AutoScheduleRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? userLocale = null,}) {
  return _then(_AutoScheduleRequest(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,userLocale: null == userLocale ? _self.userLocale : userLocale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AutoScheduleResponse {

 String get title;@JsonKey(name: 'start_time') DateTime? get startTime;@JsonKey(name: 'end_time') DateTime? get endTime;@JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson) ScheduleCategory get category; List<String> get tags; double get confidence; AutoScheduleSource get source;
/// Create a copy of AutoScheduleResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoScheduleResponseCopyWith<AutoScheduleResponse> get copyWith => _$AutoScheduleResponseCopyWithImpl<AutoScheduleResponse>(this as AutoScheduleResponse, _$identity);

  /// Serializes this AutoScheduleResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoScheduleResponse&&(identical(other.title, title) || other.title == title)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,startTime,endTime,category,const DeepCollectionEquality().hash(tags),confidence,source);

@override
String toString() {
  return 'AutoScheduleResponse(title: $title, startTime: $startTime, endTime: $endTime, category: $category, tags: $tags, confidence: $confidence, source: $source)';
}


}

/// @nodoc
abstract mixin class $AutoScheduleResponseCopyWith<$Res>  {
  factory $AutoScheduleResponseCopyWith(AutoScheduleResponse value, $Res Function(AutoScheduleResponse) _then) = _$AutoScheduleResponseCopyWithImpl;
@useResult
$Res call({
 String title,@JsonKey(name: 'start_time') DateTime? startTime,@JsonKey(name: 'end_time') DateTime? endTime,@JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson) ScheduleCategory category, List<String> tags, double confidence, AutoScheduleSource source
});




}
/// @nodoc
class _$AutoScheduleResponseCopyWithImpl<$Res>
    implements $AutoScheduleResponseCopyWith<$Res> {
  _$AutoScheduleResponseCopyWithImpl(this._self, this._then);

  final AutoScheduleResponse _self;
  final $Res Function(AutoScheduleResponse) _then;

/// Create a copy of AutoScheduleResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? startTime = freezed,Object? endTime = freezed,Object? category = null,Object? tags = null,Object? confidence = null,Object? source = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ScheduleCategory,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AutoScheduleSource,
  ));
}

}


/// Adds pattern-matching-related methods to [AutoScheduleResponse].
extension AutoScheduleResponsePatterns on AutoScheduleResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutoScheduleResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutoScheduleResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutoScheduleResponse value)  $default,){
final _that = this;
switch (_that) {
case _AutoScheduleResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutoScheduleResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AutoScheduleResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title, @JsonKey(name: 'start_time')  DateTime? startTime, @JsonKey(name: 'end_time')  DateTime? endTime, @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)  ScheduleCategory category,  List<String> tags,  double confidence,  AutoScheduleSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutoScheduleResponse() when $default != null:
return $default(_that.title,_that.startTime,_that.endTime,_that.category,_that.tags,_that.confidence,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title, @JsonKey(name: 'start_time')  DateTime? startTime, @JsonKey(name: 'end_time')  DateTime? endTime, @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)  ScheduleCategory category,  List<String> tags,  double confidence,  AutoScheduleSource source)  $default,) {final _that = this;
switch (_that) {
case _AutoScheduleResponse():
return $default(_that.title,_that.startTime,_that.endTime,_that.category,_that.tags,_that.confidence,_that.source);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title, @JsonKey(name: 'start_time')  DateTime? startTime, @JsonKey(name: 'end_time')  DateTime? endTime, @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)  ScheduleCategory category,  List<String> tags,  double confidence,  AutoScheduleSource source)?  $default,) {final _that = this;
switch (_that) {
case _AutoScheduleResponse() when $default != null:
return $default(_that.title,_that.startTime,_that.endTime,_that.category,_that.tags,_that.confidence,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AutoScheduleResponse extends AutoScheduleResponse {
  const _AutoScheduleResponse({required this.title, @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'end_time') required this.endTime, @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson) required this.category, required final  List<String> tags, required this.confidence, required this.source}): _tags = tags,super._();
  factory _AutoScheduleResponse.fromJson(Map<String, dynamic> json) => _$AutoScheduleResponseFromJson(json);

@override final  String title;
@override@JsonKey(name: 'start_time') final  DateTime? startTime;
@override@JsonKey(name: 'end_time') final  DateTime? endTime;
@override@JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson) final  ScheduleCategory category;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  double confidence;
@override final  AutoScheduleSource source;

/// Create a copy of AutoScheduleResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutoScheduleResponseCopyWith<_AutoScheduleResponse> get copyWith => __$AutoScheduleResponseCopyWithImpl<_AutoScheduleResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutoScheduleResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutoScheduleResponse&&(identical(other.title, title) || other.title == title)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,startTime,endTime,category,const DeepCollectionEquality().hash(_tags),confidence,source);

@override
String toString() {
  return 'AutoScheduleResponse(title: $title, startTime: $startTime, endTime: $endTime, category: $category, tags: $tags, confidence: $confidence, source: $source)';
}


}

/// @nodoc
abstract mixin class _$AutoScheduleResponseCopyWith<$Res> implements $AutoScheduleResponseCopyWith<$Res> {
  factory _$AutoScheduleResponseCopyWith(_AutoScheduleResponse value, $Res Function(_AutoScheduleResponse) _then) = __$AutoScheduleResponseCopyWithImpl;
@override @useResult
$Res call({
 String title,@JsonKey(name: 'start_time') DateTime? startTime,@JsonKey(name: 'end_time') DateTime? endTime,@JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson) ScheduleCategory category, List<String> tags, double confidence, AutoScheduleSource source
});




}
/// @nodoc
class __$AutoScheduleResponseCopyWithImpl<$Res>
    implements _$AutoScheduleResponseCopyWith<$Res> {
  __$AutoScheduleResponseCopyWithImpl(this._self, this._then);

  final _AutoScheduleResponse _self;
  final $Res Function(_AutoScheduleResponse) _then;

/// Create a copy of AutoScheduleResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? startTime = freezed,Object? endTime = freezed,Object? category = null,Object? tags = null,Object? confidence = null,Object? source = null,}) {
  return _then(_AutoScheduleResponse(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ScheduleCategory,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AutoScheduleSource,
  ));
}


}

// dart format on
