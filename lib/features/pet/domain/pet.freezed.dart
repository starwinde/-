// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Pet {

 PetSpecies get species; String get name; int get level; int get xp; int get hp; bool get isAlive; DateTime? get createdAt; DateTime? get diedAt; String? get deathCause;
/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PetCopyWith<Pet> get copyWith => _$PetCopyWithImpl<Pet>(this as Pet, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pet&&(identical(other.species, species) || other.species == species)&&(identical(other.name, name) || other.name == name)&&(identical(other.level, level) || other.level == level)&&(identical(other.xp, xp) || other.xp == xp)&&(identical(other.hp, hp) || other.hp == hp)&&(identical(other.isAlive, isAlive) || other.isAlive == isAlive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.diedAt, diedAt) || other.diedAt == diedAt)&&(identical(other.deathCause, deathCause) || other.deathCause == deathCause));
}


@override
int get hashCode => Object.hash(runtimeType,species,name,level,xp,hp,isAlive,createdAt,diedAt,deathCause);

@override
String toString() {
  return 'Pet(species: $species, name: $name, level: $level, xp: $xp, hp: $hp, isAlive: $isAlive, createdAt: $createdAt, diedAt: $diedAt, deathCause: $deathCause)';
}


}

/// @nodoc
abstract mixin class $PetCopyWith<$Res>  {
  factory $PetCopyWith(Pet value, $Res Function(Pet) _then) = _$PetCopyWithImpl;
@useResult
$Res call({
 PetSpecies species, String name, int level, int xp, int hp, bool isAlive, DateTime? createdAt, DateTime? diedAt, String? deathCause
});




}
/// @nodoc
class _$PetCopyWithImpl<$Res>
    implements $PetCopyWith<$Res> {
  _$PetCopyWithImpl(this._self, this._then);

  final Pet _self;
  final $Res Function(Pet) _then;

/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? species = null,Object? name = null,Object? level = null,Object? xp = null,Object? hp = null,Object? isAlive = null,Object? createdAt = freezed,Object? diedAt = freezed,Object? deathCause = freezed,}) {
  return _then(_self.copyWith(
species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as PetSpecies,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,hp: null == hp ? _self.hp : hp // ignore: cast_nullable_to_non_nullable
as int,isAlive: null == isAlive ? _self.isAlive : isAlive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,diedAt: freezed == diedAt ? _self.diedAt : diedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deathCause: freezed == deathCause ? _self.deathCause : deathCause // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Pet].
extension PetPatterns on Pet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pet value)  $default,){
final _that = this;
switch (_that) {
case _Pet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pet value)?  $default,){
final _that = this;
switch (_that) {
case _Pet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PetSpecies species,  String name,  int level,  int xp,  int hp,  bool isAlive,  DateTime? createdAt,  DateTime? diedAt,  String? deathCause)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pet() when $default != null:
return $default(_that.species,_that.name,_that.level,_that.xp,_that.hp,_that.isAlive,_that.createdAt,_that.diedAt,_that.deathCause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PetSpecies species,  String name,  int level,  int xp,  int hp,  bool isAlive,  DateTime? createdAt,  DateTime? diedAt,  String? deathCause)  $default,) {final _that = this;
switch (_that) {
case _Pet():
return $default(_that.species,_that.name,_that.level,_that.xp,_that.hp,_that.isAlive,_that.createdAt,_that.diedAt,_that.deathCause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PetSpecies species,  String name,  int level,  int xp,  int hp,  bool isAlive,  DateTime? createdAt,  DateTime? diedAt,  String? deathCause)?  $default,) {final _that = this;
switch (_that) {
case _Pet() when $default != null:
return $default(_that.species,_that.name,_that.level,_that.xp,_that.hp,_that.isAlive,_that.createdAt,_that.diedAt,_that.deathCause);case _:
  return null;

}
}

}

/// @nodoc


class _Pet implements Pet {
  const _Pet({required this.species, required this.name, this.level = 1, this.xp = 0, this.hp = 100, this.isAlive = true, this.createdAt, this.diedAt, this.deathCause});
  

@override final  PetSpecies species;
@override final  String name;
@override@JsonKey() final  int level;
@override@JsonKey() final  int xp;
@override@JsonKey() final  int hp;
@override@JsonKey() final  bool isAlive;
@override final  DateTime? createdAt;
@override final  DateTime? diedAt;
@override final  String? deathCause;

/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PetCopyWith<_Pet> get copyWith => __$PetCopyWithImpl<_Pet>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pet&&(identical(other.species, species) || other.species == species)&&(identical(other.name, name) || other.name == name)&&(identical(other.level, level) || other.level == level)&&(identical(other.xp, xp) || other.xp == xp)&&(identical(other.hp, hp) || other.hp == hp)&&(identical(other.isAlive, isAlive) || other.isAlive == isAlive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.diedAt, diedAt) || other.diedAt == diedAt)&&(identical(other.deathCause, deathCause) || other.deathCause == deathCause));
}


@override
int get hashCode => Object.hash(runtimeType,species,name,level,xp,hp,isAlive,createdAt,diedAt,deathCause);

@override
String toString() {
  return 'Pet(species: $species, name: $name, level: $level, xp: $xp, hp: $hp, isAlive: $isAlive, createdAt: $createdAt, diedAt: $diedAt, deathCause: $deathCause)';
}


}

/// @nodoc
abstract mixin class _$PetCopyWith<$Res> implements $PetCopyWith<$Res> {
  factory _$PetCopyWith(_Pet value, $Res Function(_Pet) _then) = __$PetCopyWithImpl;
@override @useResult
$Res call({
 PetSpecies species, String name, int level, int xp, int hp, bool isAlive, DateTime? createdAt, DateTime? diedAt, String? deathCause
});




}
/// @nodoc
class __$PetCopyWithImpl<$Res>
    implements _$PetCopyWith<$Res> {
  __$PetCopyWithImpl(this._self, this._then);

  final _Pet _self;
  final $Res Function(_Pet) _then;

/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? species = null,Object? name = null,Object? level = null,Object? xp = null,Object? hp = null,Object? isAlive = null,Object? createdAt = freezed,Object? diedAt = freezed,Object? deathCause = freezed,}) {
  return _then(_Pet(
species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as PetSpecies,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,hp: null == hp ? _self.hp : hp // ignore: cast_nullable_to_non_nullable
as int,isAlive: null == isAlive ? _self.isAlive : isAlive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,diedAt: freezed == diedAt ? _self.diedAt : diedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deathCause: freezed == deathCause ? _self.deathCause : deathCause // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
