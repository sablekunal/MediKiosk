// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionResponse {

@JsonKey(name: 'session_id') String get sessionId;@JsonKey(name: 'next_prompt') String? get nextQuestion;@JsonKey(defaultValue: 'text') String? get expectedInputType;@JsonKey(name: 'collected_slots') Map<String, dynamic>? get slotFillingProgress;
/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionResponseCopyWith<SessionResponse> get copyWith => _$SessionResponseCopyWithImpl<SessionResponse>(this as SessionResponse, _$identity);

  /// Serializes this SessionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionResponse&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.nextQuestion, nextQuestion) || other.nextQuestion == nextQuestion)&&(identical(other.expectedInputType, expectedInputType) || other.expectedInputType == expectedInputType)&&const DeepCollectionEquality().equals(other.slotFillingProgress, slotFillingProgress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,nextQuestion,expectedInputType,const DeepCollectionEquality().hash(slotFillingProgress));

@override
String toString() {
  return 'SessionResponse(sessionId: $sessionId, nextQuestion: $nextQuestion, expectedInputType: $expectedInputType, slotFillingProgress: $slotFillingProgress)';
}


}

/// @nodoc
abstract mixin class $SessionResponseCopyWith<$Res>  {
  factory $SessionResponseCopyWith(SessionResponse value, $Res Function(SessionResponse) _then) = _$SessionResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'next_prompt') String? nextQuestion,@JsonKey(defaultValue: 'text') String? expectedInputType,@JsonKey(name: 'collected_slots') Map<String, dynamic>? slotFillingProgress
});




}
/// @nodoc
class _$SessionResponseCopyWithImpl<$Res>
    implements $SessionResponseCopyWith<$Res> {
  _$SessionResponseCopyWithImpl(this._self, this._then);

  final SessionResponse _self;
  final $Res Function(SessionResponse) _then;

/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? nextQuestion = freezed,Object? expectedInputType = freezed,Object? slotFillingProgress = freezed,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,nextQuestion: freezed == nextQuestion ? _self.nextQuestion : nextQuestion // ignore: cast_nullable_to_non_nullable
as String?,expectedInputType: freezed == expectedInputType ? _self.expectedInputType : expectedInputType // ignore: cast_nullable_to_non_nullable
as String?,slotFillingProgress: freezed == slotFillingProgress ? _self.slotFillingProgress : slotFillingProgress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionResponse].
extension SessionResponsePatterns on SessionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionResponse value)  $default,){
final _that = this;
switch (_that) {
case _SessionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'next_prompt')  String? nextQuestion, @JsonKey(defaultValue: 'text')  String? expectedInputType, @JsonKey(name: 'collected_slots')  Map<String, dynamic>? slotFillingProgress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
return $default(_that.sessionId,_that.nextQuestion,_that.expectedInputType,_that.slotFillingProgress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'next_prompt')  String? nextQuestion, @JsonKey(defaultValue: 'text')  String? expectedInputType, @JsonKey(name: 'collected_slots')  Map<String, dynamic>? slotFillingProgress)  $default,) {final _that = this;
switch (_that) {
case _SessionResponse():
return $default(_that.sessionId,_that.nextQuestion,_that.expectedInputType,_that.slotFillingProgress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'next_prompt')  String? nextQuestion, @JsonKey(defaultValue: 'text')  String? expectedInputType, @JsonKey(name: 'collected_slots')  Map<String, dynamic>? slotFillingProgress)?  $default,) {final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
return $default(_that.sessionId,_that.nextQuestion,_that.expectedInputType,_that.slotFillingProgress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionResponse extends SessionResponse {
  const _SessionResponse({@JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'next_prompt') this.nextQuestion, @JsonKey(defaultValue: 'text') this.expectedInputType, @JsonKey(name: 'collected_slots') final  Map<String, dynamic>? slotFillingProgress}): _slotFillingProgress = slotFillingProgress,super._();
  factory _SessionResponse.fromJson(Map<String, dynamic> json) => _$SessionResponseFromJson(json);

@override@JsonKey(name: 'session_id') final  String sessionId;
@override@JsonKey(name: 'next_prompt') final  String? nextQuestion;
@override@JsonKey(defaultValue: 'text') final  String? expectedInputType;
 final  Map<String, dynamic>? _slotFillingProgress;
@override@JsonKey(name: 'collected_slots') Map<String, dynamic>? get slotFillingProgress {
  final value = _slotFillingProgress;
  if (value == null) return null;
  if (_slotFillingProgress is EqualUnmodifiableMapView) return _slotFillingProgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionResponseCopyWith<_SessionResponse> get copyWith => __$SessionResponseCopyWithImpl<_SessionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionResponse&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.nextQuestion, nextQuestion) || other.nextQuestion == nextQuestion)&&(identical(other.expectedInputType, expectedInputType) || other.expectedInputType == expectedInputType)&&const DeepCollectionEquality().equals(other._slotFillingProgress, _slotFillingProgress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,nextQuestion,expectedInputType,const DeepCollectionEquality().hash(_slotFillingProgress));

@override
String toString() {
  return 'SessionResponse(sessionId: $sessionId, nextQuestion: $nextQuestion, expectedInputType: $expectedInputType, slotFillingProgress: $slotFillingProgress)';
}


}

/// @nodoc
abstract mixin class _$SessionResponseCopyWith<$Res> implements $SessionResponseCopyWith<$Res> {
  factory _$SessionResponseCopyWith(_SessionResponse value, $Res Function(_SessionResponse) _then) = __$SessionResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'next_prompt') String? nextQuestion,@JsonKey(defaultValue: 'text') String? expectedInputType,@JsonKey(name: 'collected_slots') Map<String, dynamic>? slotFillingProgress
});




}
/// @nodoc
class __$SessionResponseCopyWithImpl<$Res>
    implements _$SessionResponseCopyWith<$Res> {
  __$SessionResponseCopyWithImpl(this._self, this._then);

  final _SessionResponse _self;
  final $Res Function(_SessionResponse) _then;

/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? nextQuestion = freezed,Object? expectedInputType = freezed,Object? slotFillingProgress = freezed,}) {
  return _then(_SessionResponse(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,nextQuestion: freezed == nextQuestion ? _self.nextQuestion : nextQuestion // ignore: cast_nullable_to_non_nullable
as String?,expectedInputType: freezed == expectedInputType ? _self.expectedInputType : expectedInputType // ignore: cast_nullable_to_non_nullable
as String?,slotFillingProgress: freezed == slotFillingProgress ? _self._slotFillingProgress : slotFillingProgress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
