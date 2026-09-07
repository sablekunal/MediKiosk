// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'intake_turn.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IntakeTurnResponse {

@JsonKey(name: 'next_prompt') String get nextQuestion;@JsonKey(defaultValue: 'voice') String get expectedInputType;// Default to voice if not provided
@JsonKey(name: 'next_slot') String? get activeGrammar;@JsonKey(name: 'collected_slots') Map<String, dynamic>? get slotFillingProgress; List<String>? get options;
/// Create a copy of IntakeTurnResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntakeTurnResponseCopyWith<IntakeTurnResponse> get copyWith => _$IntakeTurnResponseCopyWithImpl<IntakeTurnResponse>(this as IntakeTurnResponse, _$identity);

  /// Serializes this IntakeTurnResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IntakeTurnResponse&&(identical(other.nextQuestion, nextQuestion) || other.nextQuestion == nextQuestion)&&(identical(other.expectedInputType, expectedInputType) || other.expectedInputType == expectedInputType)&&(identical(other.activeGrammar, activeGrammar) || other.activeGrammar == activeGrammar)&&const DeepCollectionEquality().equals(other.slotFillingProgress, slotFillingProgress)&&const DeepCollectionEquality().equals(other.options, options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nextQuestion,expectedInputType,activeGrammar,const DeepCollectionEquality().hash(slotFillingProgress),const DeepCollectionEquality().hash(options));

@override
String toString() {
  return 'IntakeTurnResponse(nextQuestion: $nextQuestion, expectedInputType: $expectedInputType, activeGrammar: $activeGrammar, slotFillingProgress: $slotFillingProgress, options: $options)';
}


}

/// @nodoc
abstract mixin class $IntakeTurnResponseCopyWith<$Res>  {
  factory $IntakeTurnResponseCopyWith(IntakeTurnResponse value, $Res Function(IntakeTurnResponse) _then) = _$IntakeTurnResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'next_prompt') String nextQuestion,@JsonKey(defaultValue: 'voice') String expectedInputType,@JsonKey(name: 'next_slot') String? activeGrammar,@JsonKey(name: 'collected_slots') Map<String, dynamic>? slotFillingProgress, List<String>? options
});




}
/// @nodoc
class _$IntakeTurnResponseCopyWithImpl<$Res>
    implements $IntakeTurnResponseCopyWith<$Res> {
  _$IntakeTurnResponseCopyWithImpl(this._self, this._then);

  final IntakeTurnResponse _self;
  final $Res Function(IntakeTurnResponse) _then;

/// Create a copy of IntakeTurnResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nextQuestion = null,Object? expectedInputType = null,Object? activeGrammar = freezed,Object? slotFillingProgress = freezed,Object? options = freezed,}) {
  return _then(_self.copyWith(
nextQuestion: null == nextQuestion ? _self.nextQuestion : nextQuestion // ignore: cast_nullable_to_non_nullable
as String,expectedInputType: null == expectedInputType ? _self.expectedInputType : expectedInputType // ignore: cast_nullable_to_non_nullable
as String,activeGrammar: freezed == activeGrammar ? _self.activeGrammar : activeGrammar // ignore: cast_nullable_to_non_nullable
as String?,slotFillingProgress: freezed == slotFillingProgress ? _self.slotFillingProgress : slotFillingProgress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,options: freezed == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [IntakeTurnResponse].
extension IntakeTurnResponsePatterns on IntakeTurnResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IntakeTurnResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IntakeTurnResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IntakeTurnResponse value)  $default,){
final _that = this;
switch (_that) {
case _IntakeTurnResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IntakeTurnResponse value)?  $default,){
final _that = this;
switch (_that) {
case _IntakeTurnResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'next_prompt')  String nextQuestion, @JsonKey(defaultValue: 'voice')  String expectedInputType, @JsonKey(name: 'next_slot')  String? activeGrammar, @JsonKey(name: 'collected_slots')  Map<String, dynamic>? slotFillingProgress,  List<String>? options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IntakeTurnResponse() when $default != null:
return $default(_that.nextQuestion,_that.expectedInputType,_that.activeGrammar,_that.slotFillingProgress,_that.options);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'next_prompt')  String nextQuestion, @JsonKey(defaultValue: 'voice')  String expectedInputType, @JsonKey(name: 'next_slot')  String? activeGrammar, @JsonKey(name: 'collected_slots')  Map<String, dynamic>? slotFillingProgress,  List<String>? options)  $default,) {final _that = this;
switch (_that) {
case _IntakeTurnResponse():
return $default(_that.nextQuestion,_that.expectedInputType,_that.activeGrammar,_that.slotFillingProgress,_that.options);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'next_prompt')  String nextQuestion, @JsonKey(defaultValue: 'voice')  String expectedInputType, @JsonKey(name: 'next_slot')  String? activeGrammar, @JsonKey(name: 'collected_slots')  Map<String, dynamic>? slotFillingProgress,  List<String>? options)?  $default,) {final _that = this;
switch (_that) {
case _IntakeTurnResponse() when $default != null:
return $default(_that.nextQuestion,_that.expectedInputType,_that.activeGrammar,_that.slotFillingProgress,_that.options);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IntakeTurnResponse extends IntakeTurnResponse {
  const _IntakeTurnResponse({@JsonKey(name: 'next_prompt') required this.nextQuestion, @JsonKey(defaultValue: 'voice') required this.expectedInputType, @JsonKey(name: 'next_slot') this.activeGrammar, @JsonKey(name: 'collected_slots') final  Map<String, dynamic>? slotFillingProgress, final  List<String>? options}): _slotFillingProgress = slotFillingProgress,_options = options,super._();
  factory _IntakeTurnResponse.fromJson(Map<String, dynamic> json) => _$IntakeTurnResponseFromJson(json);

@override@JsonKey(name: 'next_prompt') final  String nextQuestion;
@override@JsonKey(defaultValue: 'voice') final  String expectedInputType;
// Default to voice if not provided
@override@JsonKey(name: 'next_slot') final  String? activeGrammar;
 final  Map<String, dynamic>? _slotFillingProgress;
@override@JsonKey(name: 'collected_slots') Map<String, dynamic>? get slotFillingProgress {
  final value = _slotFillingProgress;
  if (value == null) return null;
  if (_slotFillingProgress is EqualUnmodifiableMapView) return _slotFillingProgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _options;
@override List<String>? get options {
  final value = _options;
  if (value == null) return null;
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of IntakeTurnResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IntakeTurnResponseCopyWith<_IntakeTurnResponse> get copyWith => __$IntakeTurnResponseCopyWithImpl<_IntakeTurnResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IntakeTurnResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IntakeTurnResponse&&(identical(other.nextQuestion, nextQuestion) || other.nextQuestion == nextQuestion)&&(identical(other.expectedInputType, expectedInputType) || other.expectedInputType == expectedInputType)&&(identical(other.activeGrammar, activeGrammar) || other.activeGrammar == activeGrammar)&&const DeepCollectionEquality().equals(other._slotFillingProgress, _slotFillingProgress)&&const DeepCollectionEquality().equals(other._options, _options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nextQuestion,expectedInputType,activeGrammar,const DeepCollectionEquality().hash(_slotFillingProgress),const DeepCollectionEquality().hash(_options));

@override
String toString() {
  return 'IntakeTurnResponse(nextQuestion: $nextQuestion, expectedInputType: $expectedInputType, activeGrammar: $activeGrammar, slotFillingProgress: $slotFillingProgress, options: $options)';
}


}

/// @nodoc
abstract mixin class _$IntakeTurnResponseCopyWith<$Res> implements $IntakeTurnResponseCopyWith<$Res> {
  factory _$IntakeTurnResponseCopyWith(_IntakeTurnResponse value, $Res Function(_IntakeTurnResponse) _then) = __$IntakeTurnResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'next_prompt') String nextQuestion,@JsonKey(defaultValue: 'voice') String expectedInputType,@JsonKey(name: 'next_slot') String? activeGrammar,@JsonKey(name: 'collected_slots') Map<String, dynamic>? slotFillingProgress, List<String>? options
});




}
/// @nodoc
class __$IntakeTurnResponseCopyWithImpl<$Res>
    implements _$IntakeTurnResponseCopyWith<$Res> {
  __$IntakeTurnResponseCopyWithImpl(this._self, this._then);

  final _IntakeTurnResponse _self;
  final $Res Function(_IntakeTurnResponse) _then;

/// Create a copy of IntakeTurnResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nextQuestion = null,Object? expectedInputType = null,Object? activeGrammar = freezed,Object? slotFillingProgress = freezed,Object? options = freezed,}) {
  return _then(_IntakeTurnResponse(
nextQuestion: null == nextQuestion ? _self.nextQuestion : nextQuestion // ignore: cast_nullable_to_non_nullable
as String,expectedInputType: null == expectedInputType ? _self.expectedInputType : expectedInputType // ignore: cast_nullable_to_non_nullable
as String,activeGrammar: freezed == activeGrammar ? _self.activeGrammar : activeGrammar // ignore: cast_nullable_to_non_nullable
as String?,slotFillingProgress: freezed == slotFillingProgress ? _self._slotFillingProgress : slotFillingProgress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,options: freezed == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
