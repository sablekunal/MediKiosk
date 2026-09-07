// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ayurveda_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AyurvedaData {

 String? get agni; String? get koshtha; String? get ahara; String? get vihara; String? get nidra;
/// Create a copy of AyurvedaData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyurvedaDataCopyWith<AyurvedaData> get copyWith => _$AyurvedaDataCopyWithImpl<AyurvedaData>(this as AyurvedaData, _$identity);

  /// Serializes this AyurvedaData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AyurvedaData&&(identical(other.agni, agni) || other.agni == agni)&&(identical(other.koshtha, koshtha) || other.koshtha == koshtha)&&(identical(other.ahara, ahara) || other.ahara == ahara)&&(identical(other.vihara, vihara) || other.vihara == vihara)&&(identical(other.nidra, nidra) || other.nidra == nidra));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,agni,koshtha,ahara,vihara,nidra);

@override
String toString() {
  return 'AyurvedaData(agni: $agni, koshtha: $koshtha, ahara: $ahara, vihara: $vihara, nidra: $nidra)';
}


}

/// @nodoc
abstract mixin class $AyurvedaDataCopyWith<$Res>  {
  factory $AyurvedaDataCopyWith(AyurvedaData value, $Res Function(AyurvedaData) _then) = _$AyurvedaDataCopyWithImpl;
@useResult
$Res call({
 String? agni, String? koshtha, String? ahara, String? vihara, String? nidra
});




}
/// @nodoc
class _$AyurvedaDataCopyWithImpl<$Res>
    implements $AyurvedaDataCopyWith<$Res> {
  _$AyurvedaDataCopyWithImpl(this._self, this._then);

  final AyurvedaData _self;
  final $Res Function(AyurvedaData) _then;

/// Create a copy of AyurvedaData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? agni = freezed,Object? koshtha = freezed,Object? ahara = freezed,Object? vihara = freezed,Object? nidra = freezed,}) {
  return _then(_self.copyWith(
agni: freezed == agni ? _self.agni : agni // ignore: cast_nullable_to_non_nullable
as String?,koshtha: freezed == koshtha ? _self.koshtha : koshtha // ignore: cast_nullable_to_non_nullable
as String?,ahara: freezed == ahara ? _self.ahara : ahara // ignore: cast_nullable_to_non_nullable
as String?,vihara: freezed == vihara ? _self.vihara : vihara // ignore: cast_nullable_to_non_nullable
as String?,nidra: freezed == nidra ? _self.nidra : nidra // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AyurvedaData].
extension AyurvedaDataPatterns on AyurvedaData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AyurvedaData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AyurvedaData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AyurvedaData value)  $default,){
final _that = this;
switch (_that) {
case _AyurvedaData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AyurvedaData value)?  $default,){
final _that = this;
switch (_that) {
case _AyurvedaData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? agni,  String? koshtha,  String? ahara,  String? vihara,  String? nidra)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AyurvedaData() when $default != null:
return $default(_that.agni,_that.koshtha,_that.ahara,_that.vihara,_that.nidra);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? agni,  String? koshtha,  String? ahara,  String? vihara,  String? nidra)  $default,) {final _that = this;
switch (_that) {
case _AyurvedaData():
return $default(_that.agni,_that.koshtha,_that.ahara,_that.vihara,_that.nidra);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? agni,  String? koshtha,  String? ahara,  String? vihara,  String? nidra)?  $default,) {final _that = this;
switch (_that) {
case _AyurvedaData() when $default != null:
return $default(_that.agni,_that.koshtha,_that.ahara,_that.vihara,_that.nidra);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AyurvedaData implements AyurvedaData {
  const _AyurvedaData({this.agni, this.koshtha, this.ahara, this.vihara, this.nidra});
  factory _AyurvedaData.fromJson(Map<String, dynamic> json) => _$AyurvedaDataFromJson(json);

@override final  String? agni;
@override final  String? koshtha;
@override final  String? ahara;
@override final  String? vihara;
@override final  String? nidra;

/// Create a copy of AyurvedaData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyurvedaDataCopyWith<_AyurvedaData> get copyWith => __$AyurvedaDataCopyWithImpl<_AyurvedaData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AyurvedaDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AyurvedaData&&(identical(other.agni, agni) || other.agni == agni)&&(identical(other.koshtha, koshtha) || other.koshtha == koshtha)&&(identical(other.ahara, ahara) || other.ahara == ahara)&&(identical(other.vihara, vihara) || other.vihara == vihara)&&(identical(other.nidra, nidra) || other.nidra == nidra));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,agni,koshtha,ahara,vihara,nidra);

@override
String toString() {
  return 'AyurvedaData(agni: $agni, koshtha: $koshtha, ahara: $ahara, vihara: $vihara, nidra: $nidra)';
}


}

/// @nodoc
abstract mixin class _$AyurvedaDataCopyWith<$Res> implements $AyurvedaDataCopyWith<$Res> {
  factory _$AyurvedaDataCopyWith(_AyurvedaData value, $Res Function(_AyurvedaData) _then) = __$AyurvedaDataCopyWithImpl;
@override @useResult
$Res call({
 String? agni, String? koshtha, String? ahara, String? vihara, String? nidra
});




}
/// @nodoc
class __$AyurvedaDataCopyWithImpl<$Res>
    implements _$AyurvedaDataCopyWith<$Res> {
  __$AyurvedaDataCopyWithImpl(this._self, this._then);

  final _AyurvedaData _self;
  final $Res Function(_AyurvedaData) _then;

/// Create a copy of AyurvedaData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? agni = freezed,Object? koshtha = freezed,Object? ahara = freezed,Object? vihara = freezed,Object? nidra = freezed,}) {
  return _then(_AyurvedaData(
agni: freezed == agni ? _self.agni : agni // ignore: cast_nullable_to_non_nullable
as String?,koshtha: freezed == koshtha ? _self.koshtha : koshtha // ignore: cast_nullable_to_non_nullable
as String?,ahara: freezed == ahara ? _self.ahara : ahara // ignore: cast_nullable_to_non_nullable
as String?,vihara: freezed == vihara ? _self.vihara : vihara // ignore: cast_nullable_to_non_nullable
as String?,nidra: freezed == nidra ? _self.nidra : nidra // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
