// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'demographics_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PatientFormData {

 String get givenName; String get familyName; String get birthDate;// YYYY-MM-DD
 String get gender;// male | female | other | unknown
 String get identifier;// ABHA ID
 String get language;
/// Create a copy of PatientFormData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatientFormDataCopyWith<PatientFormData> get copyWith => _$PatientFormDataCopyWithImpl<PatientFormData>(this as PatientFormData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatientFormData&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode => Object.hash(runtimeType,givenName,familyName,birthDate,gender,identifier,language);

@override
String toString() {
  return 'PatientFormData(givenName: $givenName, familyName: $familyName, birthDate: $birthDate, gender: $gender, identifier: $identifier, language: $language)';
}


}

/// @nodoc
abstract mixin class $PatientFormDataCopyWith<$Res>  {
  factory $PatientFormDataCopyWith(PatientFormData value, $Res Function(PatientFormData) _then) = _$PatientFormDataCopyWithImpl;
@useResult
$Res call({
 String givenName, String familyName, String birthDate, String gender, String identifier, String language
});




}
/// @nodoc
class _$PatientFormDataCopyWithImpl<$Res>
    implements $PatientFormDataCopyWith<$Res> {
  _$PatientFormDataCopyWithImpl(this._self, this._then);

  final PatientFormData _self;
  final $Res Function(PatientFormData) _then;

/// Create a copy of PatientFormData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? givenName = null,Object? familyName = null,Object? birthDate = null,Object? gender = null,Object? identifier = null,Object? language = null,}) {
  return _then(_self.copyWith(
givenName: null == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String,familyName: null == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PatientFormData].
extension PatientFormDataPatterns on PatientFormData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatientFormData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatientFormData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatientFormData value)  $default,){
final _that = this;
switch (_that) {
case _PatientFormData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatientFormData value)?  $default,){
final _that = this;
switch (_that) {
case _PatientFormData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String givenName,  String familyName,  String birthDate,  String gender,  String identifier,  String language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatientFormData() when $default != null:
return $default(_that.givenName,_that.familyName,_that.birthDate,_that.gender,_that.identifier,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String givenName,  String familyName,  String birthDate,  String gender,  String identifier,  String language)  $default,) {final _that = this;
switch (_that) {
case _PatientFormData():
return $default(_that.givenName,_that.familyName,_that.birthDate,_that.gender,_that.identifier,_that.language);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String givenName,  String familyName,  String birthDate,  String gender,  String identifier,  String language)?  $default,) {final _that = this;
switch (_that) {
case _PatientFormData() when $default != null:
return $default(_that.givenName,_that.familyName,_that.birthDate,_that.gender,_that.identifier,_that.language);case _:
  return null;

}
}

}

/// @nodoc


class _PatientFormData implements PatientFormData {
  const _PatientFormData({this.givenName = '', this.familyName = '', this.birthDate = '', this.gender = '', this.identifier = '', this.language = 'en'});
  

@override@JsonKey() final  String givenName;
@override@JsonKey() final  String familyName;
@override@JsonKey() final  String birthDate;
// YYYY-MM-DD
@override@JsonKey() final  String gender;
// male | female | other | unknown
@override@JsonKey() final  String identifier;
// ABHA ID
@override@JsonKey() final  String language;

/// Create a copy of PatientFormData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatientFormDataCopyWith<_PatientFormData> get copyWith => __$PatientFormDataCopyWithImpl<_PatientFormData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatientFormData&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode => Object.hash(runtimeType,givenName,familyName,birthDate,gender,identifier,language);

@override
String toString() {
  return 'PatientFormData(givenName: $givenName, familyName: $familyName, birthDate: $birthDate, gender: $gender, identifier: $identifier, language: $language)';
}


}

/// @nodoc
abstract mixin class _$PatientFormDataCopyWith<$Res> implements $PatientFormDataCopyWith<$Res> {
  factory _$PatientFormDataCopyWith(_PatientFormData value, $Res Function(_PatientFormData) _then) = __$PatientFormDataCopyWithImpl;
@override @useResult
$Res call({
 String givenName, String familyName, String birthDate, String gender, String identifier, String language
});




}
/// @nodoc
class __$PatientFormDataCopyWithImpl<$Res>
    implements _$PatientFormDataCopyWith<$Res> {
  __$PatientFormDataCopyWithImpl(this._self, this._then);

  final _PatientFormData _self;
  final $Res Function(_PatientFormData) _then;

/// Create a copy of PatientFormData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? givenName = null,Object? familyName = null,Object? birthDate = null,Object? gender = null,Object? identifier = null,Object? language = null,}) {
  return _then(_PatientFormData(
givenName: null == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String,familyName: null == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
