// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'socrates_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SocratesData {

 String? get site; String? get onset; String? get character; String? get radiation; List<String>? get associations; String? get timeCourse; String? get exacerbatingFactors; double? get severity;
/// Create a copy of SocratesData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocratesDataCopyWith<SocratesData> get copyWith => _$SocratesDataCopyWithImpl<SocratesData>(this as SocratesData, _$identity);

  /// Serializes this SocratesData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocratesData&&(identical(other.site, site) || other.site == site)&&(identical(other.onset, onset) || other.onset == onset)&&(identical(other.character, character) || other.character == character)&&(identical(other.radiation, radiation) || other.radiation == radiation)&&const DeepCollectionEquality().equals(other.associations, associations)&&(identical(other.timeCourse, timeCourse) || other.timeCourse == timeCourse)&&(identical(other.exacerbatingFactors, exacerbatingFactors) || other.exacerbatingFactors == exacerbatingFactors)&&(identical(other.severity, severity) || other.severity == severity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,site,onset,character,radiation,const DeepCollectionEquality().hash(associations),timeCourse,exacerbatingFactors,severity);

@override
String toString() {
  return 'SocratesData(site: $site, onset: $onset, character: $character, radiation: $radiation, associations: $associations, timeCourse: $timeCourse, exacerbatingFactors: $exacerbatingFactors, severity: $severity)';
}


}

/// @nodoc
abstract mixin class $SocratesDataCopyWith<$Res>  {
  factory $SocratesDataCopyWith(SocratesData value, $Res Function(SocratesData) _then) = _$SocratesDataCopyWithImpl;
@useResult
$Res call({
 String? site, String? onset, String? character, String? radiation, List<String>? associations, String? timeCourse, String? exacerbatingFactors, double? severity
});




}
/// @nodoc
class _$SocratesDataCopyWithImpl<$Res>
    implements $SocratesDataCopyWith<$Res> {
  _$SocratesDataCopyWithImpl(this._self, this._then);

  final SocratesData _self;
  final $Res Function(SocratesData) _then;

/// Create a copy of SocratesData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? site = freezed,Object? onset = freezed,Object? character = freezed,Object? radiation = freezed,Object? associations = freezed,Object? timeCourse = freezed,Object? exacerbatingFactors = freezed,Object? severity = freezed,}) {
  return _then(_self.copyWith(
site: freezed == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String?,onset: freezed == onset ? _self.onset : onset // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,radiation: freezed == radiation ? _self.radiation : radiation // ignore: cast_nullable_to_non_nullable
as String?,associations: freezed == associations ? _self.associations : associations // ignore: cast_nullable_to_non_nullable
as List<String>?,timeCourse: freezed == timeCourse ? _self.timeCourse : timeCourse // ignore: cast_nullable_to_non_nullable
as String?,exacerbatingFactors: freezed == exacerbatingFactors ? _self.exacerbatingFactors : exacerbatingFactors // ignore: cast_nullable_to_non_nullable
as String?,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SocratesData].
extension SocratesDataPatterns on SocratesData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocratesData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocratesData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocratesData value)  $default,){
final _that = this;
switch (_that) {
case _SocratesData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocratesData value)?  $default,){
final _that = this;
switch (_that) {
case _SocratesData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? site,  String? onset,  String? character,  String? radiation,  List<String>? associations,  String? timeCourse,  String? exacerbatingFactors,  double? severity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocratesData() when $default != null:
return $default(_that.site,_that.onset,_that.character,_that.radiation,_that.associations,_that.timeCourse,_that.exacerbatingFactors,_that.severity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? site,  String? onset,  String? character,  String? radiation,  List<String>? associations,  String? timeCourse,  String? exacerbatingFactors,  double? severity)  $default,) {final _that = this;
switch (_that) {
case _SocratesData():
return $default(_that.site,_that.onset,_that.character,_that.radiation,_that.associations,_that.timeCourse,_that.exacerbatingFactors,_that.severity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? site,  String? onset,  String? character,  String? radiation,  List<String>? associations,  String? timeCourse,  String? exacerbatingFactors,  double? severity)?  $default,) {final _that = this;
switch (_that) {
case _SocratesData() when $default != null:
return $default(_that.site,_that.onset,_that.character,_that.radiation,_that.associations,_that.timeCourse,_that.exacerbatingFactors,_that.severity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocratesData implements SocratesData {
  const _SocratesData({this.site, this.onset, this.character, this.radiation, final  List<String>? associations, this.timeCourse, this.exacerbatingFactors, this.severity}): _associations = associations;
  factory _SocratesData.fromJson(Map<String, dynamic> json) => _$SocratesDataFromJson(json);

@override final  String? site;
@override final  String? onset;
@override final  String? character;
@override final  String? radiation;
 final  List<String>? _associations;
@override List<String>? get associations {
  final value = _associations;
  if (value == null) return null;
  if (_associations is EqualUnmodifiableListView) return _associations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? timeCourse;
@override final  String? exacerbatingFactors;
@override final  double? severity;

/// Create a copy of SocratesData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocratesDataCopyWith<_SocratesData> get copyWith => __$SocratesDataCopyWithImpl<_SocratesData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocratesDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocratesData&&(identical(other.site, site) || other.site == site)&&(identical(other.onset, onset) || other.onset == onset)&&(identical(other.character, character) || other.character == character)&&(identical(other.radiation, radiation) || other.radiation == radiation)&&const DeepCollectionEquality().equals(other._associations, _associations)&&(identical(other.timeCourse, timeCourse) || other.timeCourse == timeCourse)&&(identical(other.exacerbatingFactors, exacerbatingFactors) || other.exacerbatingFactors == exacerbatingFactors)&&(identical(other.severity, severity) || other.severity == severity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,site,onset,character,radiation,const DeepCollectionEquality().hash(_associations),timeCourse,exacerbatingFactors,severity);

@override
String toString() {
  return 'SocratesData(site: $site, onset: $onset, character: $character, radiation: $radiation, associations: $associations, timeCourse: $timeCourse, exacerbatingFactors: $exacerbatingFactors, severity: $severity)';
}


}

/// @nodoc
abstract mixin class _$SocratesDataCopyWith<$Res> implements $SocratesDataCopyWith<$Res> {
  factory _$SocratesDataCopyWith(_SocratesData value, $Res Function(_SocratesData) _then) = __$SocratesDataCopyWithImpl;
@override @useResult
$Res call({
 String? site, String? onset, String? character, String? radiation, List<String>? associations, String? timeCourse, String? exacerbatingFactors, double? severity
});




}
/// @nodoc
class __$SocratesDataCopyWithImpl<$Res>
    implements _$SocratesDataCopyWith<$Res> {
  __$SocratesDataCopyWithImpl(this._self, this._then);

  final _SocratesData _self;
  final $Res Function(_SocratesData) _then;

/// Create a copy of SocratesData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? site = freezed,Object? onset = freezed,Object? character = freezed,Object? radiation = freezed,Object? associations = freezed,Object? timeCourse = freezed,Object? exacerbatingFactors = freezed,Object? severity = freezed,}) {
  return _then(_SocratesData(
site: freezed == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String?,onset: freezed == onset ? _self.onset : onset // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,radiation: freezed == radiation ? _self.radiation : radiation // ignore: cast_nullable_to_non_nullable
as String?,associations: freezed == associations ? _self._associations : associations // ignore: cast_nullable_to_non_nullable
as List<String>?,timeCourse: freezed == timeCourse ? _self.timeCourse : timeCourse // ignore: cast_nullable_to_non_nullable
as String?,exacerbatingFactors: freezed == exacerbatingFactors ? _self.exacerbatingFactors : exacerbatingFactors // ignore: cast_nullable_to_non_nullable
as String?,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
