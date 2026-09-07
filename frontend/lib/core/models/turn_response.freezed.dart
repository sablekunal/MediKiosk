// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'turn_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TurnResponse {

@JsonKey(name: 'session_id') String get sessionId; String get stage;@JsonKey(name: 'completion_percent') double get completionPercent;@JsonKey(name: 'next_prompt') String get nextPrompt;@JsonKey(name: 'next_slot') String? get nextSlot;@JsonKey(name: 'collected_slots') Map<String, dynamic> get collectedSlots; Map<String, dynamic>? get extraction;
/// Create a copy of TurnResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TurnResponseCopyWith<TurnResponse> get copyWith => _$TurnResponseCopyWithImpl<TurnResponse>(this as TurnResponse, _$identity);

  /// Serializes this TurnResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TurnResponse&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.completionPercent, completionPercent) || other.completionPercent == completionPercent)&&(identical(other.nextPrompt, nextPrompt) || other.nextPrompt == nextPrompt)&&(identical(other.nextSlot, nextSlot) || other.nextSlot == nextSlot)&&const DeepCollectionEquality().equals(other.collectedSlots, collectedSlots)&&const DeepCollectionEquality().equals(other.extraction, extraction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,stage,completionPercent,nextPrompt,nextSlot,const DeepCollectionEquality().hash(collectedSlots),const DeepCollectionEquality().hash(extraction));

@override
String toString() {
  return 'TurnResponse(sessionId: $sessionId, stage: $stage, completionPercent: $completionPercent, nextPrompt: $nextPrompt, nextSlot: $nextSlot, collectedSlots: $collectedSlots, extraction: $extraction)';
}


}

/// @nodoc
abstract mixin class $TurnResponseCopyWith<$Res>  {
  factory $TurnResponseCopyWith(TurnResponse value, $Res Function(TurnResponse) _then) = _$TurnResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId, String stage,@JsonKey(name: 'completion_percent') double completionPercent,@JsonKey(name: 'next_prompt') String nextPrompt,@JsonKey(name: 'next_slot') String? nextSlot,@JsonKey(name: 'collected_slots') Map<String, dynamic> collectedSlots, Map<String, dynamic>? extraction
});




}
/// @nodoc
class _$TurnResponseCopyWithImpl<$Res>
    implements $TurnResponseCopyWith<$Res> {
  _$TurnResponseCopyWithImpl(this._self, this._then);

  final TurnResponse _self;
  final $Res Function(TurnResponse) _then;

/// Create a copy of TurnResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? stage = null,Object? completionPercent = null,Object? nextPrompt = null,Object? nextSlot = freezed,Object? collectedSlots = null,Object? extraction = freezed,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,completionPercent: null == completionPercent ? _self.completionPercent : completionPercent // ignore: cast_nullable_to_non_nullable
as double,nextPrompt: null == nextPrompt ? _self.nextPrompt : nextPrompt // ignore: cast_nullable_to_non_nullable
as String,nextSlot: freezed == nextSlot ? _self.nextSlot : nextSlot // ignore: cast_nullable_to_non_nullable
as String?,collectedSlots: null == collectedSlots ? _self.collectedSlots : collectedSlots // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,extraction: freezed == extraction ? _self.extraction : extraction // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [TurnResponse].
extension TurnResponsePatterns on TurnResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TurnResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TurnResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TurnResponse value)  $default,){
final _that = this;
switch (_that) {
case _TurnResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TurnResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TurnResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId,  String stage, @JsonKey(name: 'completion_percent')  double completionPercent, @JsonKey(name: 'next_prompt')  String nextPrompt, @JsonKey(name: 'next_slot')  String? nextSlot, @JsonKey(name: 'collected_slots')  Map<String, dynamic> collectedSlots,  Map<String, dynamic>? extraction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TurnResponse() when $default != null:
return $default(_that.sessionId,_that.stage,_that.completionPercent,_that.nextPrompt,_that.nextSlot,_that.collectedSlots,_that.extraction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId,  String stage, @JsonKey(name: 'completion_percent')  double completionPercent, @JsonKey(name: 'next_prompt')  String nextPrompt, @JsonKey(name: 'next_slot')  String? nextSlot, @JsonKey(name: 'collected_slots')  Map<String, dynamic> collectedSlots,  Map<String, dynamic>? extraction)  $default,) {final _that = this;
switch (_that) {
case _TurnResponse():
return $default(_that.sessionId,_that.stage,_that.completionPercent,_that.nextPrompt,_that.nextSlot,_that.collectedSlots,_that.extraction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_id')  String sessionId,  String stage, @JsonKey(name: 'completion_percent')  double completionPercent, @JsonKey(name: 'next_prompt')  String nextPrompt, @JsonKey(name: 'next_slot')  String? nextSlot, @JsonKey(name: 'collected_slots')  Map<String, dynamic> collectedSlots,  Map<String, dynamic>? extraction)?  $default,) {final _that = this;
switch (_that) {
case _TurnResponse() when $default != null:
return $default(_that.sessionId,_that.stage,_that.completionPercent,_that.nextPrompt,_that.nextSlot,_that.collectedSlots,_that.extraction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TurnResponse implements TurnResponse {
  const _TurnResponse({@JsonKey(name: 'session_id') required this.sessionId, required this.stage, @JsonKey(name: 'completion_percent') required this.completionPercent, @JsonKey(name: 'next_prompt') required this.nextPrompt, @JsonKey(name: 'next_slot') this.nextSlot, @JsonKey(name: 'collected_slots') required final  Map<String, dynamic> collectedSlots, final  Map<String, dynamic>? extraction}): _collectedSlots = collectedSlots,_extraction = extraction;
  factory _TurnResponse.fromJson(Map<String, dynamic> json) => _$TurnResponseFromJson(json);

@override@JsonKey(name: 'session_id') final  String sessionId;
@override final  String stage;
@override@JsonKey(name: 'completion_percent') final  double completionPercent;
@override@JsonKey(name: 'next_prompt') final  String nextPrompt;
@override@JsonKey(name: 'next_slot') final  String? nextSlot;
 final  Map<String, dynamic> _collectedSlots;
@override@JsonKey(name: 'collected_slots') Map<String, dynamic> get collectedSlots {
  if (_collectedSlots is EqualUnmodifiableMapView) return _collectedSlots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_collectedSlots);
}

 final  Map<String, dynamic>? _extraction;
@override Map<String, dynamic>? get extraction {
  final value = _extraction;
  if (value == null) return null;
  if (_extraction is EqualUnmodifiableMapView) return _extraction;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of TurnResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TurnResponseCopyWith<_TurnResponse> get copyWith => __$TurnResponseCopyWithImpl<_TurnResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TurnResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TurnResponse&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.completionPercent, completionPercent) || other.completionPercent == completionPercent)&&(identical(other.nextPrompt, nextPrompt) || other.nextPrompt == nextPrompt)&&(identical(other.nextSlot, nextSlot) || other.nextSlot == nextSlot)&&const DeepCollectionEquality().equals(other._collectedSlots, _collectedSlots)&&const DeepCollectionEquality().equals(other._extraction, _extraction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,stage,completionPercent,nextPrompt,nextSlot,const DeepCollectionEquality().hash(_collectedSlots),const DeepCollectionEquality().hash(_extraction));

@override
String toString() {
  return 'TurnResponse(sessionId: $sessionId, stage: $stage, completionPercent: $completionPercent, nextPrompt: $nextPrompt, nextSlot: $nextSlot, collectedSlots: $collectedSlots, extraction: $extraction)';
}


}

/// @nodoc
abstract mixin class _$TurnResponseCopyWith<$Res> implements $TurnResponseCopyWith<$Res> {
  factory _$TurnResponseCopyWith(_TurnResponse value, $Res Function(_TurnResponse) _then) = __$TurnResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId, String stage,@JsonKey(name: 'completion_percent') double completionPercent,@JsonKey(name: 'next_prompt') String nextPrompt,@JsonKey(name: 'next_slot') String? nextSlot,@JsonKey(name: 'collected_slots') Map<String, dynamic> collectedSlots, Map<String, dynamic>? extraction
});




}
/// @nodoc
class __$TurnResponseCopyWithImpl<$Res>
    implements _$TurnResponseCopyWith<$Res> {
  __$TurnResponseCopyWithImpl(this._self, this._then);

  final _TurnResponse _self;
  final $Res Function(_TurnResponse) _then;

/// Create a copy of TurnResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? stage = null,Object? completionPercent = null,Object? nextPrompt = null,Object? nextSlot = freezed,Object? collectedSlots = null,Object? extraction = freezed,}) {
  return _then(_TurnResponse(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,completionPercent: null == completionPercent ? _self.completionPercent : completionPercent // ignore: cast_nullable_to_non_nullable
as double,nextPrompt: null == nextPrompt ? _self.nextPrompt : nextPrompt // ignore: cast_nullable_to_non_nullable
as String,nextSlot: freezed == nextSlot ? _self.nextSlot : nextSlot // ignore: cast_nullable_to_non_nullable
as String?,collectedSlots: null == collectedSlots ? _self._collectedSlots : collectedSlots // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,extraction: freezed == extraction ? _self._extraction : extraction // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
