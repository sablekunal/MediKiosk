// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Patient _$PatientFromJson(Map<String, dynamic> json) => _Patient(
  name: json['name'] as String?,
  age: (json['age'] as num?)?.toInt(),
  gender: json['gender'] as String?,
  mobileNumber: json['mobileNumber'] as String?,
  abhaId: json['abhaId'] as String?,
);

Map<String, dynamic> _$PatientToJson(_Patient instance) => <String, dynamic>{
  'name': instance.name,
  'age': instance.age,
  'gender': instance.gender,
  'mobileNumber': instance.mobileNumber,
  'abhaId': instance.abhaId,
};
