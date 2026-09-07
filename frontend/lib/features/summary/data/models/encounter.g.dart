// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encounter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CanonicalEncounter _$CanonicalEncounterFromJson(Map<String, dynamic> json) =>
    _CanonicalEncounter(
      sessionId: json['id'] as String,
      patient: Patient.fromJson(json['patient'] as Map<String, dynamic>),
      westernTriage: SocratesData.fromJson(
        json['socrates'] as Map<String, dynamic>,
      ),
      ayurvedicTriage: AyurvedaData.fromJson(
        json['ayurveda'] as Map<String, dynamic>,
      ),
      status: json['status'] as String?,
      canonicalId: _readCanonicalId(json, 'canonicalId') as String?,
      createdAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
    );

Map<String, dynamic> _$CanonicalEncounterToJson(_CanonicalEncounter instance) =>
    <String, dynamic>{
      'id': instance.sessionId,
      'patient': instance.patient,
      'socrates': instance.westernTriage,
      'ayurveda': instance.ayurvedicTriage,
      'status': instance.status,
      'canonicalId': instance.canonicalId,
      'started_at': instance.createdAt?.toIso8601String(),
    };
