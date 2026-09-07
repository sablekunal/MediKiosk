// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encounter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CanonicalEncounter {

@JsonKey(name: 'id') String get sessionId; Patient get patient;@JsonKey(name: 'socrates') SocratesData get westernTriage;@JsonKey(name: 'ayurveda') AyurvedaData get ayurvedicTriage; String? get status;@JsonKey(readValue: _readCanonicalId) String? get canonicalId;@JsonKey(name: 'started_at') DateTime? get createdAt;
/// Create a copy of CanonicalEncounter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CanonicalEncounterCopyWith<CanonicalEncounter> get copyWith => _$CanonicalEncounterCopyWithImpl<CanonicalEncounter>(this as CanonicalEncounter, _$identity);

  /// Serializes this CanonicalEncounter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CanonicalEncounter&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.patient, patient) || other.patient == patient)&&(identical(other.westernTriage, westernTriage) || other.westernTriage == westernTriage)&&(identical(other.ayurvedicTriage, ayurvedicTriage) || other.ayurvedicTriage == ayurvedicTriage)&&(identical(other.status, status) || other.status == status)&&(identical(other.canonicalId, canonicalId) || other.canonicalId == canonicalId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,patient,westernTriage,ayurvedicTriage,status,canonicalId,createdAt);

@override
String toString() {
  return 'CanonicalEncounter(sessionId: $sessionId, patient: $patient, westernTriage: $westernTriage, ayurvedicTriage: $ayurvedicTriage, status: $status, canonicalId: $canonicalId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CanonicalEncounterCopyWith<$Res>  {
  factory $CanonicalEncounterCopyWith(CanonicalEncounter value, $Res Function(CanonicalEncounter) _then) = _$CanonicalEncounterCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String sessionId, Patient patient,@JsonKey(name: 'socrates') SocratesData westernTriage,@JsonKey(name: 'ayurveda') AyurvedaData ayurvedicTriage, String? status,@JsonKey(readValue: _readCanonicalId) String? canonicalId,@JsonKey(name: 'started_at') DateTime? createdAt
});


$PatientCopyWith<$Res> get patient;$SocratesDataCopyWith<$Res> get westernTriage;$AyurvedaDataCopyWith<$Res> get ayurvedicTriage;

}
/// @nodoc
class _$CanonicalEncounterCopyWithImpl<$Res>
    implements $CanonicalEncounterCopyWith<$Res> {
  _$CanonicalEncounterCopyWithImpl(this._self, this._then);

  final CanonicalEncounter _self;
  final $Res Function(CanonicalEncounter) _then;

/// Create a copy of CanonicalEncounter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? patient = null,Object? westernTriage = null,Object? ayurvedicTriage = null,Object? status = freezed,Object? canonicalId = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,patient: null == patient ? _self.patient : patient // ignore: cast_nullable_to_non_nullable
as Patient,westernTriage: null == westernTriage ? _self.westernTriage : westernTriage // ignore: cast_nullable_to_non_nullable
as SocratesData,ayurvedicTriage: null == ayurvedicTriage ? _self.ayurvedicTriage : ayurvedicTriage // ignore: cast_nullable_to_non_nullable
as AyurvedaData,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,canonicalId: freezed == canonicalId ? _self.canonicalId : canonicalId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of CanonicalEncounter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientCopyWith<$Res> get patient {
  
  return $PatientCopyWith<$Res>(_self.patient, (value) {
    return _then(_self.copyWith(patient: value));
  });
}/// Create a copy of CanonicalEncounter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocratesDataCopyWith<$Res> get westernTriage {
  
  return $SocratesDataCopyWith<$Res>(_self.westernTriage, (value) {
    return _then(_self.copyWith(westernTriage: value));
  });
}/// Create a copy of CanonicalEncounter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyurvedaDataCopyWith<$Res> get ayurvedicTriage {
  
  return $AyurvedaDataCopyWith<$Res>(_self.ayurvedicTriage, (value) {
    return _then(_self.copyWith(ayurvedicTriage: value));
  });
}
}


/// Adds pattern-matching-related methods to [CanonicalEncounter].
extension CanonicalEncounterPatterns on CanonicalEncounter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CanonicalEncounter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CanonicalEncounter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CanonicalEncounter value)  $default,){
final _that = this;
switch (_that) {
case _CanonicalEncounter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CanonicalEncounter value)?  $default,){
final _that = this;
switch (_that) {
case _CanonicalEncounter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String sessionId,  Patient patient, @JsonKey(name: 'socrates')  SocratesData westernTriage, @JsonKey(name: 'ayurveda')  AyurvedaData ayurvedicTriage,  String? status, @JsonKey(readValue: _readCanonicalId)  String? canonicalId, @JsonKey(name: 'started_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CanonicalEncounter() when $default != null:
return $default(_that.sessionId,_that.patient,_that.westernTriage,_that.ayurvedicTriage,_that.status,_that.canonicalId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String sessionId,  Patient patient, @JsonKey(name: 'socrates')  SocratesData westernTriage, @JsonKey(name: 'ayurveda')  AyurvedaData ayurvedicTriage,  String? status, @JsonKey(readValue: _readCanonicalId)  String? canonicalId, @JsonKey(name: 'started_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _CanonicalEncounter():
return $default(_that.sessionId,_that.patient,_that.westernTriage,_that.ayurvedicTriage,_that.status,_that.canonicalId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String sessionId,  Patient patient, @JsonKey(name: 'socrates')  SocratesData westernTriage, @JsonKey(name: 'ayurveda')  AyurvedaData ayurvedicTriage,  String? status, @JsonKey(readValue: _readCanonicalId)  String? canonicalId, @JsonKey(name: 'started_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CanonicalEncounter() when $default != null:
return $default(_that.sessionId,_that.patient,_that.westernTriage,_that.ayurvedicTriage,_that.status,_that.canonicalId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CanonicalEncounter implements CanonicalEncounter {
  const _CanonicalEncounter({@JsonKey(name: 'id') required this.sessionId, required this.patient, @JsonKey(name: 'socrates') required this.westernTriage, @JsonKey(name: 'ayurveda') required this.ayurvedicTriage, this.status, @JsonKey(readValue: _readCanonicalId) this.canonicalId, @JsonKey(name: 'started_at') this.createdAt});
  factory _CanonicalEncounter.fromJson(Map<String, dynamic> json) => _$CanonicalEncounterFromJson(json);

@override@JsonKey(name: 'id') final  String sessionId;
@override final  Patient patient;
@override@JsonKey(name: 'socrates') final  SocratesData westernTriage;
@override@JsonKey(name: 'ayurveda') final  AyurvedaData ayurvedicTriage;
@override final  String? status;
@override@JsonKey(readValue: _readCanonicalId) final  String? canonicalId;
@override@JsonKey(name: 'started_at') final  DateTime? createdAt;

/// Create a copy of CanonicalEncounter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CanonicalEncounterCopyWith<_CanonicalEncounter> get copyWith => __$CanonicalEncounterCopyWithImpl<_CanonicalEncounter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CanonicalEncounterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CanonicalEncounter&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.patient, patient) || other.patient == patient)&&(identical(other.westernTriage, westernTriage) || other.westernTriage == westernTriage)&&(identical(other.ayurvedicTriage, ayurvedicTriage) || other.ayurvedicTriage == ayurvedicTriage)&&(identical(other.status, status) || other.status == status)&&(identical(other.canonicalId, canonicalId) || other.canonicalId == canonicalId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,patient,westernTriage,ayurvedicTriage,status,canonicalId,createdAt);

@override
String toString() {
  return 'CanonicalEncounter(sessionId: $sessionId, patient: $patient, westernTriage: $westernTriage, ayurvedicTriage: $ayurvedicTriage, status: $status, canonicalId: $canonicalId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CanonicalEncounterCopyWith<$Res> implements $CanonicalEncounterCopyWith<$Res> {
  factory _$CanonicalEncounterCopyWith(_CanonicalEncounter value, $Res Function(_CanonicalEncounter) _then) = __$CanonicalEncounterCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String sessionId, Patient patient,@JsonKey(name: 'socrates') SocratesData westernTriage,@JsonKey(name: 'ayurveda') AyurvedaData ayurvedicTriage, String? status,@JsonKey(readValue: _readCanonicalId) String? canonicalId,@JsonKey(name: 'started_at') DateTime? createdAt
});


@override $PatientCopyWith<$Res> get patient;@override $SocratesDataCopyWith<$Res> get westernTriage;@override $AyurvedaDataCopyWith<$Res> get ayurvedicTriage;

}
/// @nodoc
class __$CanonicalEncounterCopyWithImpl<$Res>
    implements _$CanonicalEncounterCopyWith<$Res> {
  __$CanonicalEncounterCopyWithImpl(this._self, this._then);

  final _CanonicalEncounter _self;
  final $Res Function(_CanonicalEncounter) _then;

/// Create a copy of CanonicalEncounter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? patient = null,Object? westernTriage = null,Object? ayurvedicTriage = null,Object? status = freezed,Object? canonicalId = freezed,Object? createdAt = freezed,}) {
  return _then(_CanonicalEncounter(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,patient: null == patient ? _self.patient : patient // ignore: cast_nullable_to_non_nullable
as Patient,westernTriage: null == westernTriage ? _self.westernTriage : westernTriage // ignore: cast_nullable_to_non_nullable
as SocratesData,ayurvedicTriage: null == ayurvedicTriage ? _self.ayurvedicTriage : ayurvedicTriage // ignore: cast_nullable_to_non_nullable
as AyurvedaData,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,canonicalId: freezed == canonicalId ? _self.canonicalId : canonicalId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of CanonicalEncounter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientCopyWith<$Res> get patient {
  
  return $PatientCopyWith<$Res>(_self.patient, (value) {
    return _then(_self.copyWith(patient: value));
  });
}/// Create a copy of CanonicalEncounter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocratesDataCopyWith<$Res> get westernTriage {
  
  return $SocratesDataCopyWith<$Res>(_self.westernTriage, (value) {
    return _then(_self.copyWith(westernTriage: value));
  });
}/// Create a copy of CanonicalEncounter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyurvedaDataCopyWith<$Res> get ayurvedicTriage {
  
  return $AyurvedaDataCopyWith<$Res>(_self.ayurvedicTriage, (value) {
    return _then(_self.copyWith(ayurvedicTriage: value));
  });
}
}

// dart format on
